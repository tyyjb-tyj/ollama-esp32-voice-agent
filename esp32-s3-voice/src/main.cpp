#include <Arduino.h>
#include <WiFi.h>
#include <WebSocketsClient.h>
#include <Wire.h>
#include <U8g2lib.h>
#include <math.h>
#include <string.h>
#include "driver/i2s.h"

// ============ 网络 ============
// WiFi 密码放在本地 wifi_config.h（已被 .gitignore 忽略，不会提交）。
// 首次使用：复制 wifi_config.example.h 为 wifi_config.h，填入你的热点密码。
#if __has_include("wifi_config.h")
  #include "wifi_config.h"
  const char* WIFI_SSID = WIFI_SSID_LOCAL;
  const char* WIFI_PASS = WIFI_PASS_LOCAL;
#else
  const char* WIFI_SSID = "ESP32-Test";
  const char* WIFI_PASS = "";
#endif
const char* WS_HOST   = "192.168.137.1";   // 电脑移动热点地址
const uint16_t WS_PORT = 12345;

// ============ 引脚 ============
// 麦克风 INMP441 (I2S RX)
#define MIC_BCLK 17   // INMP441 SCK
#define MIC_WS   7    // INMP441 WS
#define MIC_DIN  8    // INMP441 SD
// 喇叭 MAX98357A (I2S TX)
#define SPK_BCLK 9
#define SPK_LRC  5
#define SPK_DIN  4
// 功放使能 (MAX98357A SD 脚，接 GPIO10)
#define AMP_SD 10              // HIGH=响, LOW=静音(内部100K下拉)
// OLED SSD1306 (I2C)
#define OLED_SDA 16
#define OLED_SCL 15

// ============ 参数 ============
#define MIC_RATE    16000
#define SPK_RATE    24000
#define CHUNK       512            // 每次读 512 采样 (~32ms)
#define VAD_THRESH  500            // 16bit 幅度阈值，可调
#define SILENCE_RUN 10             // 连续 10 块静音 = 说完 (~320ms)
#define MAX_SAMPLES (8 * MIC_RATE) // 最长 8 秒
#define AMP_START_MUTED true       // 测试阶段静音；全部调好后改 false 再烧录

WebSocketsClient webSocket;
static int16_t* recBuf = nullptr;
static int  recLen   = 0;
static int  silence  = 0;
static bool recording = false;

// ---- OLED 状态显示 (U8g2) ----
#define SCREEN_W 128
#define SCREEN_H 64
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE);
const uint8_t* F_CJK  = u8g2_font_wqy12_t_gb2312;  // 中文 12px
const uint8_t* F_FACE = u8g2_font_10x20_tf;         // 大号 ASCII 颜文字
static bool oledOk = false;
static bool speaking = false;
static unsigned long lastAudioMs = 0;

void setAmp(bool on) {
    digitalWrite(AMP_SD, on ? HIGH : LOW);
    USBSerial.printf("[AMP] %s\n", on ? "ON" : "MUTED");
}

// 居中画一行中文（UTF-8）
void centerCJK(const char* s, int y) {
    u8g2.setFont(F_CJK);
    int w = u8g2.getUTF8Width(s);
    u8g2.setCursor((SCREEN_W - w) / 2, y);
    u8g2.print(s);
}

// 纯文本屏（中文，1~2 行）
void showText(const char* l1, const char* l2 = "") {
    u8g2.clearBuffer();
    if (l2[0]) { centerCJK(l1, 28); centerCJK(l2, 48); }
    else       { centerCJK(l1, 38); }
    u8g2.sendBuffer();
}

// 颜文字 + 状态屏
void showFace(const char* face, const char* status) {
    u8g2.clearBuffer();
    u8g2.setFont(F_FACE);
    int w = u8g2.getStrWidth(face);
    u8g2.setCursor((SCREEN_W - w) / 2, 28);
    u8g2.print(face);
    centerCJK(status, 54);
    u8g2.sendBuffer();
}

// ---- UTF-8 安全截断（用于 AI 回复换行） ----
void copyUtf8N(char* dst, const char* src, int maxChars) {
    int n = 0;
    while (*src && n < maxChars) {
        if ((*src & 0xC0) != 0x80) n++;   // 非续字节 = 新字符
        *dst++ = *src++;
    }
    *dst = 0;
}
const char* skipUtf8N(const char* src, int maxChars) {
    int n = 0;
    while (*src && n < maxChars) {
        if ((*src & 0xC0) != 0x80) n++;
        src++;
    }
    return src;
}

// 显示 AI 回复文字（最多 2 行 × 10 字）
void showReply(const char* text) {
    u8g2.clearBuffer();
    char line[64];
    copyUtf8N(line, text, 10);
    centerCJK(line, 28);
    const char* rest = skipUtf8N(text, 10);
    if (*rest) { copyUtf8N(line, rest, 10); centerCJK(line, 48); }
    u8g2.sendBuffer();
}

void onWsEvent(WStype_t type, uint8_t* payload, size_t len) {
    switch (type) {
        case WStype_CONNECTED:
            USBSerial.printf("[WS] connected to %s:%d\n", WS_HOST, WS_PORT);
            showFace("(^_^)", "我在等你说话");
            break;
        case WStype_DISCONNECTED:
            USBSerial.println("[WS] disconnected");
            showText("连接断开", "重连中...");
            break;
        case WStype_TEXT: {
            static char buf[256];
            int n = len < sizeof(buf) - 1 ? len : sizeof(buf) - 1;
            memcpy(buf, payload, n);
            buf[n] = 0;
            USBSerial.printf("[AI] %s\n", buf);
            showReply(buf);
            break;
        }
        case WStype_BIN: {
            // 服务器返回 24kHz/16bit/单声道 PCM，直接写喇叭
            size_t written = 0;
            i2s_write(I2S_NUM_1, payload, len, &written, portMAX_DELAY);
            USBSerial.printf("[AUDIO] play %d bytes\n", (int)len);
            speaking = true;
            lastAudioMs = millis();
            showFace("(^o^)", "正在说话...");
            break;
        }
        default:
            break;
    }
}

void setup() {
    USBSerial.begin(115200);
    delay(300);
    USBSerial.println("\n=== Campus Assistant ESP32 boot ===");

    // ---- 功放静音 (测试阶段不响；SD=GPIO10) ----
    pinMode(AMP_SD, OUTPUT);
    setAmp(!AMP_START_MUTED);

    // ---- OLED 屏幕 ----
    Wire.begin(OLED_SDA, OLED_SCL);
    if (!u8g2.begin()) {
        USBSerial.println("[OLED] init FAIL (check SDA=16/SCL=15 wiring)");
    } else {
        oledOk = true;
        u8g2.enableUTF8Print();
        showText("智慧物院小助手", "启动中...");
        USBSerial.println("[OLED] init OK");
    }

    // 录音缓冲放 PSRAM (8MB)，避免占满内部 RAM
    recBuf = (int16_t*)ps_malloc(MAX_SAMPLES * sizeof(int16_t));
    USBSerial.printf("record buffer: %s\n", recBuf ? "OK (PSRAM)" : "FAIL");

    // ---- 麦克风 I2S RX (16kHz / 32bit / 左声道) ----
    i2s_config_t mic = {
        .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
        .sample_rate = MIC_RATE,
        .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
        .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
        .communication_format = I2S_COMM_FORMAT_STAND_I2S,
        .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
        .dma_buf_count = 8, .dma_buf_len = 512, .use_apll = false
    };
    i2s_pin_config_t micPin = {
        .mck_io_num = I2S_PIN_NO_CHANGE,
        .bck_io_num = MIC_BCLK, .ws_io_num = MIC_WS,
        .data_out_num = I2S_PIN_NO_CHANGE, .data_in_num = MIC_DIN
    };
    esp_err_t e = i2s_driver_install(I2S_NUM_0, &mic, 0, NULL);
    USBSerial.printf("mic i2s: %s\n", esp_err_to_name(e));
    i2s_set_pin(I2S_NUM_0, &micPin);

    // ---- 喇叭 I2S TX (24kHz / 16bit) ----
    i2s_config_t spk = {
        .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
        .sample_rate = SPK_RATE,
        .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
        .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
        .communication_format = I2S_COMM_FORMAT_STAND_I2S,
        .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
        .dma_buf_count = 8, .dma_buf_len = 512, .use_apll = false
    };
    i2s_pin_config_t spkPin = {
        .mck_io_num = I2S_PIN_NO_CHANGE,
        .bck_io_num = SPK_BCLK, .ws_io_num = SPK_LRC,
        .data_out_num = SPK_DIN, .data_in_num = I2S_PIN_NO_CHANGE
    };
    i2s_driver_install(I2S_NUM_1, &spk, 0, NULL);
    i2s_set_pin(I2S_NUM_1, &spkPin);

    // ---- WiFi ----
    showText("连接 WiFi 中", WIFI_SSID);
    USBSerial.printf("connecting WiFi %s ...\n", WIFI_SSID);
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASS);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        USBSerial.print(".");
    }
    USBSerial.printf("\nWiFi OK, IP=%s\n", WiFi.localIP().toString().c_str());
    showText("WiFi 已连接", WiFi.localIP().toString().c_str());

    // ---- WebSocket ----
    showText("连接 AI 中...");
    webSocket.begin(WS_HOST, WS_PORT, "/");
    webSocket.onEvent(onWsEvent);
    webSocket.setReconnectInterval(3000);
}

void loop() {
    webSocket.loop();

    int32_t raw[CHUNK];
    size_t got = 0;
    i2s_read(I2S_NUM_0, raw, sizeof(raw), &got, pdMS_TO_TICKS(20));
    int n = got / 4;              // 32bit 每采样 4 字节
    if (n <= 0) {
        // 播放结束 0.8s 后回到待机
        if (speaking && millis() - lastAudioMs > 800) {
            speaking = false;
            showFace("(^_^)", "我在等你说话");
        }
        return;
    }

    int16_t chunk[CHUNK];
    int64_t energy = 0;
    for (int i = 0; i < n; i++) {
        chunk[i] = (int16_t)(raw[i] >> 16);   // INMP441 24bit 左对齐 -> 取高16bit
        energy += (int64_t)chunk[i] * chunk[i];
    }
    int rms = (int)sqrt((double)energy / n);
    bool loud = rms > VAD_THRESH;

    if (loud) {
        if (!recording) {
            recording = true;
            recLen = 0;
            showFace("(o_O)", "正在聆听...");
            USBSerial.println("[VAD] speech start");
        }
        silence = 0;
        for (int i = 0; i < n && recLen < MAX_SAMPLES; i++) recBuf[recLen++] = chunk[i];
    } else if (recording) {
        silence++;
        for (int i = 0; i < n && recLen < MAX_SAMPLES; i++) recBuf[recLen++] = chunk[i];
        if (silence >= SILENCE_RUN || recLen >= MAX_SAMPLES) {
            recording = false;
            silence = 0;
            if (recLen > MIC_RATE / 2) {   // 至少 0.5 秒
                USBSerial.printf("[VAD] send %d bytes (%d ms)\n", recLen * 2, recLen * 1000 / MIC_RATE);
                webSocket.sendBIN((uint8_t*)recBuf, recLen * 2);
                showFace("(>_<)", "思考中...");
            } else {
                USBSerial.println("[VAD] too short, drop");
                showFace("(^_^)", "我在等你说话");
            }
            recLen = 0;
        }
    }
}
