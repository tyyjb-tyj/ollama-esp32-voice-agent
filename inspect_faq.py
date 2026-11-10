import os
os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TRANSFORMERS_OFFLINE"] = "1"
import sys
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import chromadb
from sentence_transformers import SentenceTransformer

client = chromadb.PersistentClient(path="./chroma_db")
col = client.get_or_create_collection(name="faq", metadata={"hnsw:space": "cosine"})
print(f"FAQ 总数: {col.count()}")
data = col.get(include=["documents", "metadatas"])
for i, (doc, meta) in enumerate(zip(data["documents"], data["metadatas"])):
    ans = (meta.get("answer") or "")[:36] if meta else ""
    print(f"{i:3d} | Q: {doc[:42]} | A: {ans}")

model = SentenceTransformer("BAAI/bge-small-zh-v1.5", local_files_only=True)
for q in ["学校叫什么名字", "怎么请假", "校园网怎么连", "图书馆开放时间"]:
    emb = model.encode(q).tolist()
    r = col.query(query_embeddings=[emb], n_results=3)
    print(f"\n=== 查询: {q} ===")
    for doc, dist in zip(r["documents"][0], r["distances"][0]):
        print(f"  sim={1-dist:.3f}  Q: {doc[:48]}")
