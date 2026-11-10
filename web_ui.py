# -*- coding: utf-8 -*-
"""
web_ui.py —— PC 端可视化监控界面（Gradio）

作用：给边缘端 AI 服务器加一个轻量级 Web 交互界面，方便在 PC 上
直观地测试 / 演示「两路检索 + 大模型兜底」的完整问答链路。

后台逻辑与 ws_server.py 完全复用同一套：
    1. ChromaDB 向量检索（BGE 向量 + 关键词混合打分，阈值 0.55）
    2. MySQL LIKE 关键词兜底（faq 表）
    3. Ollama Qwen2.5 大模型生成兜底

运行方式：python web_ui.py  （默认监听 http://0.0.0.0:7860）
"""
import os
import sys

import requests
import chromadb
import pymysql
from sentence_transformers import SentenceTransformer
import gradio as gr

# Windows 中文控制台默认 GBK，打印表情/中文会抛 UnicodeEncodeError，统一转 UTF-8
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 国内直连 huggingface.co 会超时；模型权重/配置均已缓存到本地，强制离线读缓存
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

print("🔧 正在加载模型 (BGE / ChromaDB)...")
embedding_model = SentenceTransformer('BAAI/bge-small-zh-v1.5', local_files_only=True)
chroma_client = chromadb.PersistentClient(path="./chroma_db")
collection = chroma_client.get_or_create_collection(name="faq", metadata={"hnsw:space": "cosine"})
print(f"✅ 模型加载完成，向量库共 {collection.count()} 条 FAQ")


def keyword_overlap(q: str, doc: str) -> float:
    """字符 bigram 重叠度，用于修正短问句的向量误配"""
    qg = {q[i:i + 2] for i in range(len(q) - 1)} if len(q) >= 2 else {q}
    dg = {doc[i:i + 2] for i in range(len(doc) - 1)}
    return len(qg & dg) / len(qg) if qg else 0.0


def vector_retrieve(user_text: str):
    """第一路：ChromaDB 向量检索（向量 + 关键词混合打分）"""
    query_emb = embedding_model.encode(user_text).tolist()
    results = collection.query(query_embeddings=[query_emb], n_results=5)

    best_sim, best_kw, best_answer = -1.0, 0.0, None
    for doc, dist, meta in zip(results['documents'][0],
                               results['distances'][0],
                               results['metadatas'][0]):
        sim = 1 - dist
        kw = keyword_overlap(user_text, doc)
        if sim + 0.4 * kw > best_sim + 0.4 * best_kw:
            best_sim, best_kw, best_answer = sim, kw, meta['answer']

    if best_answer and best_sim >= SIMILARITY_THRESHOLD:
        return best_answer, f"向量知识库（相似度 {best_sim:.2f}）"
    return None, None


def sql_retrieve(user_text: str):
    """第二路：MySQL LIKE 关键词兜底"""
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
            return result[0], "MySQL 关键词兜底"
    except Exception as e:
        print(f"⚠️ MySQL 兜底跳过（{e}）")
    return None, None


def llm_retrieve(user_text: str):
    """第三级：Ollama Qwen2.5 大模型生成兜底"""
    prompt = f"你是一个大学校园助手，请用简短的一句话回答：{user_text}"
    try:
        resp = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": "qwen2.5:1.5b", "prompt": prompt, "stream": False},
            timeout=30,
        )
        return resp.json().get("response", "抱歉，我暂时不知道。").strip(), "Qwen 大模型兜底"
    except Exception:
        return "AI 服务未启动，请先运行 Ollama。", "错误"


def chat_logic(user_text, history):
    if not user_text or not user_text.strip():
        return "", history
    user_text = user_text.strip()

    # 级联：向量 -> SQL -> 大模型
    reply_text, route = vector_retrieve(user_text)
    if not reply_text:
        reply_text, route = sql_retrieve(user_text)
    if not reply_text:
        reply_text, route = llm_retrieve(user_text)

    final_reply = f"{reply_text}\n\n🔍 匹配路径：{route}"
    # Gradio 6 的 Chatbot 使用 messages 格式（dict 列表）
    history = history + [
        {"role": "user", "content": user_text},
        {"role": "assistant", "content": final_reply},
    ]
    return "", history


with gr.Blocks(title="校园智能问答终端") as demo:
    gr.Markdown("# 🏫 智慧物院 · AI 智能问答监控面板")
    gr.Markdown("此界面用于展示 PC 边缘端的 AI 推理过程。硬件端（ESP32）的交互数据同样通过此逻辑处理。")

    with gr.Row():
        with gr.Column(scale=3):
            chatbot = gr.Chatbot(label="对话记录", height=500)
            msg = gr.Textbox(
                label="输入测试文本（模拟语音转写结果）",
                placeholder="例如：学校是公办还是民办？",
            )
            clear = gr.Button("清空对话")

        with gr.Column(scale=1):
            gr.Markdown("### 📊 系统状态")
            gr.Markdown(
                "- **语音识别 (Whisper)**：待机\n"
                "- **大模型 (Qwen)**：已就绪\n"
                "- **知识库 (Chroma)**：已连接"
            )
            gr.Markdown(
                "### 💡 提示\n"
                "你可以在这里测试两路检索和大模型兜底的问答效果。\n"
                "实际硬件端输入也是走这套后台逻辑。"
            )

    msg.submit(chat_logic, [msg, chatbot], [msg, chatbot])
    clear.click(lambda: [], None, chatbot, queue=False)

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860, theme=gr.themes.Soft())
