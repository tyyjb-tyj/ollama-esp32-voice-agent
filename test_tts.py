import asyncio, os, tempfile
import edge_tts, miniaudio, numpy as np

async def main():
    text = "你好，我是智慧物院校园助手。"
    tmp = os.path.join(tempfile.gettempdir(), "tts_test.mp3")
    await edge_tts.Communicate(text, voice="zh-CN-XiaoxiaoNeural").save(tmp)
    print("mp3 bytes:", os.path.getsize(tmp))
    with open(tmp, "rb") as f:
        mp3 = f.read()
    dec = miniaudio.decode(mp3, nchannels=1, sample_rate=24000,
                           output_format=miniaudio.SampleFormat.SIGNED16)
    pcm = bytes(dec.samples)
    os.unlink(tmp)
    dur = len(pcm) // 2 / 24000
    print(f"pcm bytes={len(pcm)}  samples={len(pcm)//2}  duration={dur:.2f}s")
    a = np.frombuffer(pcm, dtype=np.int16)
    print(f"peak={int(np.abs(a).max())}  rms={int(np.sqrt(np.mean(a.astype(float)**2)))}")

asyncio.run(main())
