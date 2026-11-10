# 智慧物院 · AI 校园客服

> 基于端侧大模型与 RAG 的校园智能语音问答系统 —— 毕业设计项目

一套「**ESP32-S3 硬件语音终端 + PC 边缘端 AI 服务器**」的智能校园问答系统：
用户对着麦克风说话，ESP32 采集音频经 WiFi 上传到 PC，PC 完成语音识别、知识库检索与
大模型生成，再把文字与合成语音返回给硬件端播报。同时提供一套 Gradio Web 可视化界面，
用于在 PC 上直观演示与调试完整问答链路。

---

## 系统架构

```
┌─────────────────────────────┐        WiFi (热点 ESP32-Test)        ┌──────────────────────────────┐
│  ESP32-S3 (硬件语音终端)     │  ────────── WebSocket ────────────▶  │  PC 边缘端 AI 服务器           │
│  INMP441 麦克风 录音          │       ws://192.168.137.1:12345      │                              │
│  MAX98357A 喇叭 播报          │ ◀───────── 文字 + PCM ────────────  │  1. Whisper 语音识别           │
│  OLED 显示状态               │                                      │  2. ChromaDB 向量检索          │
└─────────────────────────────┘                                       │  3. MySQL 关键词兜底           │
                                                                      │  4. Ollama Qwen 大模型生成      │
                                                                      │  5. edge-tts 语音合成          │
                                                                      └──────────────────────────────┘
```

**三级检索级联（向量 → MySQL → 大模型）：**

1. **ChromaDB 向量检索**：BGE 中文向量 + 字符 bigram 关键词混合打分（`sim + 0.4*kw`，阈值 0.55）
2. **MySQL 关键词兜底**：`faq` 表 `question LIKE` 精确关键词匹配
3. **Ollama Qwen 大模型生成**：前两级都未命中时，交给 `qwen2.5:1.5b` 生成兜底回答

---

## 目录结构

```
.
├── ws_server.py           # PC 端主服务器：WebSocket 收音频 → 识别 → 检索 → TTS 回传
├── web_ui.py              # Gradio Web 可视化界面（复用同一套检索逻辑）
├── start.bat              # 一键启动硬件语音服务（Ollama + ws_server.py）
├── start_webui.bat        # 一键启动 Web 界面（MySQL + Ollama + Gradio）
├── start_mysql.bat        # 单独启动 MySQL
├── start_all.bat          # 旧版启动脚本（依赖 Windows 服务，已弃用）
│
├── campus_assistant.py    # 早期原型版本
├── voice_chat.py          # 早期语音对话原型
├── ws_server_save.py      # 服务器备份版本
│
├── inspect_faq.py         # 向量库巡检 / 查询测试脚本
├── test_db.py             # MySQL 连接测试
├── test_ollama.py         # Ollama 调用测试
├── test_tts.py            # edge-tts 语音合成测试
├── read_serial.py         # ESP32 串口日志读取
│
├── chroma_db/             # ChromaDB 向量库（faq 集合，已含 FAQ 向量）
├── hmlc.sql               # MySQL 建库建表 + 数据（hmlc_college，16 张表）
├── esp32-s3-voice/        # ESP32-S3 固件（PlatformIO 工程）
│   ├── src/main.cpp       # 固件主程序：录音 → WebSocket 上传 → 收 PCM 播报
│   └── platformio.ini     # 板型 / Flash / 依赖配置
└── received_audio/        # 收到的音频缓存（已 gitignore）
```

---

## 环境依赖

### PC 端（Python）

| 依赖 | 说明 |
|---|---|
| Python 3.12 | 运行时 |
| faster-whisper | 语音识别（Whisper `small`，CPU int8 量化） |
| sentence-transformers | 向量模型 `BAAI/bge-small-zh-v1.5` |
| chromadb | 向量数据库（PersistentClient） |
| pymysql | MySQL 连接 |
| edge-tts | 在线语音合成（需联网） |
| miniaudio | PCM 解码 |
| websockets | WebSocket 服务 |
| gradio | Web 可视化界面 |

模型权重缓存在本地（`HF_HUB_OFFLINE=1` 离线读取）：
- BGE / Whisper：`C:\Users\<用户>\.cache\huggingface`
- Qwen：Ollama 本地模型 `qwen2.5:1.5b`

### 数据库（MySQL 8.0）

- 数据库：`hmlc_college`（连接账号密码见 `ws_server.py` / `web_ui.py` 的 `DB_CONFIG`）
- 初始化：`mysql -uroot -p < hmlc.sql`

### 硬件端（ESP32-S3）

- 开发板：ESP32-S3 DevKitC-1 **N16R8V**（16MB Flash + 8MB PSRAM）
- 外设：INMP441 麦克风、MAX98357A 功放 + 喇叭、SSD1306 OLED
- 构建：PlatformIO（`esp32-s3-voice/platformio.ini`）

---

## 快速开始

### 方式一：硬件语音演示（ESP32 说话 → 语音回复）

1. PC 开启移动热点，名称与密码需和固件 `main.cpp` 内的 `WIFI_SSID` / `WIFI_PASS` 一致
2. ESP32-S3 上电（固件已烧录）
3. 双击 `start.bat`（自动启动 Ollama + ws_server.py，首次模型加载约 10-20 秒）
4. 首次运行弹出防火墙提示时，勾选「允许访问」（监听 12345 端口）
5. 对着麦克风说话即可

> 注意：MAX98357A 的 **SD 引脚必须拉高**（接 VIN/3.3V），否则喇叭无声。

### 方式二：Web 界面演示（无需硬件）

1. 双击 `start_webui.bat`（自动启动 MySQL + Ollama + Gradio）
2. 浏览器打开 <http://127.0.0.1:7860>
3. 输入文本问题，观察三级检索路径的实时标注

---

## 关键配置

| 配置项 | 位置 | 说明 |
|---|---|---|
| WiFi 热点 | `esp32-s3-voice/src/main.cpp` | `WIFI_SSID` / `WIFI_PASS` 常量 |
| WebSocket 服务 | `ws_server.py` | `0.0.0.0:12345` |
| 向量阈值 | `ws_server.py` / `web_ui.py` | `SIMILARITY_THRESHOLD = 0.55` |
| MySQL 连接 | `ws_server.py` / `web_ui.py` | `DB_CONFIG` 常量 |
| Web 界面 | `web_ui.py` | `0.0.0.0:7860` |
| 兜底大模型 | `ws_server.py` / `web_ui.py` | Ollama `qwen2.5:1.5b` |
