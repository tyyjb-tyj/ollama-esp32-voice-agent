import os
import pymysql

try:
    from local_config import DB_PASSWORD
except ImportError:
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "")

# 连接数据库
conn = pymysql.connect(
    host='localhost',
    user='root',
    password=DB_PASSWORD,
    database='hmlc_college',
    charset='utf8mb4'
)

cursor = conn.cursor()

# 查询 FAQ
cursor.execute("SELECT question, answer FROM faq LIMIT 5")
results = cursor.fetchall()

for q, a in results:
    print(f"Q: {q}")
    print(f"A: {a}")
    print("-" * 40)

conn.close()