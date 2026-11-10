import asyncio
import sys
import wave
import tempfile
import os
import numpy as np
import shutil
import requests
import websockets
import chromadb
import edge_tts
import miniaudio
import pymysql
from zhconv import convert
from faster_whisper import WhisperModel
from sentence_transformers import SentenceTransformer

# Windows 中文控制台默认 GBK，打印表情/中文会抛 UnicodeEncodeError，统一转 UTF-8
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 国内直连 huggingface.co 会超时 (WinError 10060)，卡在拉取本就非必需的可选配置上。
# 模型权重/配置均已缓存到本地，强制离线：只读本地缓存，跳过对 HF 的网络 HEAD 请求。
# 注意：这里不设置 HF_ENDPOINT 指向任何第三方镜像，只做断网读缓存。
os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TRANSFORMERS_OFFLINE"] = "1"

SIMILARITY_THRESHOLD = 0.55

try:
    from local_config import DB_PASSWORD
except ImportError:
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "")

DB_CONFIG = {
    'host': 'localhost', 'user': 'root', 'password': DB_PASSWORD,
    'database': 'hmlc_college', 'charset': 'utf8mb4'
}

print("🔧 正在加载模型 (Whisper / BGE / ChromaDB)...")
whisper_model = WhisperModel("small", device="cpu", compute_type="int8")
embedding_model = SentenceTransformer('BAAI/bge-small-zh-v1.5', local_files_only=True)
chroma_client = chromadb.PersistentClient(path="./chroma_db")
collection = chroma_client.get_or_create_collection(name="faq", metadata={"hnsw:space": "cosine"})
print(f"✅ 模型加载完成，向量库共 {collection.count()} 条 FAQ")
print("   等待 ESP32 连接...\n")


def process_audio(audio_bytes: bytes) -> str:
    """处理一段 16kHz/16bit/单声道 PCM，返回回复文本"""
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as f:
        with wave.open(f.name, 'wb') as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(16000)
            wf.writeframes(audio_bytes)
        temp_path = f.name

    # ---- 调试：打印音频电平并保存最后一帧，排查“没听清” ----
    pcm = np.frombuffer(audio_bytes, dtype=np.int16)
    peak = int(np.abs(pcm).max()) if pcm.size else 0
    rms = int(np.sqrt(np.mean(pcm.astype(np.float64) ** 2))) if pcm.size else 0
    print(f"[debug] {len(pcm)}样本/{len(pcm)/16000:.2f}s peak={peak} rms={rms}")
    shutil.copyfile(temp_path, os.path.join(os.path.dirname(os.path.abspath(__file__)), "debug_last.wav"))

    segments, _ = whisper_model.transcribe(
        temp_path, language="zh", initial_prompt="校园助手", vad_filter=True
    )
    user_text = convert("".join(seg.text for seg in segments), 'zh-cn').strip()
    os.unlink(temp_path)

    if not user_text:
        return "抱歉，我没有听清。"

    print(f"📝 识别结果: {user_text}")

    # 1. 向量 + 关键词混合检索：短问句按字符重叠加权，修正“学校叫什么名字”这类误配
    query_emb = embedding_model.encode(user_text).tolist()
    results = collection.query(query_embeddings=[query_emb], n_results=5)

    def keyword_overlap(q: str, doc: str) -> float:
        qg = {q[i:i + 2] for i in range(len(q) - 1)} if len(q) >= 2 else {q}
        dg = {doc[i:i + 2] for i in range(len(doc) - 1)}
        return len(qg & dg) / len(qg) if qg else 0.0

    best_sim, best_kw, best_answer = -1.0, 0.0, None
    for doc, dist, meta in zip(results['documents'][0], results['distances'][0], results['metadatas'][0]):
        sim = 1 - dist
        kw = keyword_overlap(user_text, doc)
        if sim + 0.4 * kw > best_sim + 0.4 * best_kw:
            best_sim, best_kw, best_answer = sim, kw, meta['answer']

    if best_answer and best_sim >= SIMILARITY_THRESHOLD:
        print(f"✅ 混合命中 (向量 {best_sim:.2f} + 关键词 {best_kw:.2f}): {best_answer}")
        return best_answer

    # 2. 向量未命中 -> MySQL 关键词兜底（与 Web 界面同一套逻辑）
    print("🔍 向量未命中，尝试 MySQL 关键词兜底...")
    try:
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute(
            "SELECT answer FROM faq WHERE question LIKE %s LIMIT 1",
            (f"%{user_text}%",),
        )
        result = cursor.fetchone()
        conn.close()
        if result:
            print(f"✅ MySQL 兜底命中: {result[0]}")
            return result[0]
    except Exception as e:
        print(f"⚠️ MySQL 兜底跳过（{e}）")

    # 3. 仍未命中 -> Qwen 大模型兜底
    print("🤖 知识库未命中，交给 Qwen...")
    prompt = f"你是一个大学校园助手，请用简短的一句话回答：{user_text}"
    try:
        resp = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": "qwen2.5:1.5b", "prompt": prompt, "stream": False},
            timeout=30,
        )
        reply = resp.json().get("response", "抱歉，我暂时不知道。").strip()
        print(f"🤖 Qwen 回复: {reply}")
        return reply
    except Exception as e:
        print(f"❌ Qwen 调用失败: {e}")
        return "大脑连接失败。"


async def text_to_pcm(text: str) -> bytes:
    """文字 -> edge-tts 语音 -> 24kHz/16bit/单声道 PCM"""
    tmp_mp3 = os.path.join(tempfile.gettempdir(), "reply.mp3")
    try:
        last_err = None
        for attempt in range(3):
            try:
                await edge_tts.Communicate(text, voice="zh-CN-XiaoxiaoNeural").save(tmp_mp3)
                last_err = None
                break
            except Exception as e:
                last_err = e
                if attempt < 2:
                    print(f"⚠️ TTS 重试 {attempt + 1}/3: {e}")
                    await asyncio.sleep(1)
        if last_err is not None:
            raise last_err
        with open(tmp_mp3, "rb") as f:
            mp3 = f.read()
        dec = miniaudio.decode(mp3, nchannels=1, sample_rate=24000,
                               output_format=miniaudio.SampleFormat.SIGNED16)
        return bytes(dec.samples)
    except Exception as e:
        print(f"❌ TTS 失败: {e}")
        return b""
    finally:
        if os.path.exists(tmp_mp3):
            try:
                os.unlink(tmp_mp3)
            except OSError:
                pass


async def handle_esp32(websocket):
    print(f"✅ ESP32 已连接: {websocket.remote_address}")
    try:
        async for message in websocket:
            if isinstance(message, bytes) and len(message) > 2000:
                print(f"🎵 收到音频 {len(message)} 字节，识别中...")
                reply = await asyncio.to_thread(process_audio, message)
                print(f"📤 回复: {reply}\n")
                await websocket.send(reply)   # 文字（ESP32 串口打印用）
                # 语音播报：文字 -> edge-tts -> PCM -> 分块发回
                pcm = await text_to_pcm(reply)
                if pcm:
                    CHUNK = 8192
                    for i in range(0, len(pcm), CHUNK):
                        await websocket.send(pcm[i:i + CHUNK])
                    print(f"🔊 已发送语音 {len(pcm)} 字节 ({len(pcm)//2/24000:.2f}s)")
            elif isinstance(message, str):
                print(f"📩 收到文本: {message}")
    except websockets.exceptions.ConnectionClosed:
        print("❌ ESP32 已断开")


async def main():
    async with websockets.serve(handle_esp32, "0.0.0.0", 12345, max_size=10 * 1024 * 1024):
        print("🚀 智能客服服务器已启动，监听 0.0.0.0:12345")
        print("   ⚠️ 若弹出防火墙提示，请勾选『允许访问』！")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())
