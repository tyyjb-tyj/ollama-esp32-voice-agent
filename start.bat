@echo off
chcp 65001 >nul
title 智慧物院 AI 校园客服

cd /d D:\voice_assistant_project

echo ================================================
echo    智慧物院 AI 校园客服 —— 一键启动
echo ================================================
echo.
echo  [提醒] 启动前请确认：
echo    1. 电脑已开启移动热点（名称 ESP32-Test）
echo    2. ESP32 已上电
echo.

rem 检查 Ollama（Qwen 兜底用）
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo  [1/2] Ollama 未运行，正在后台启动...
    start "ollama" /min ollama serve
) else (
    echo  [1/2] Ollama 已在运行
)

echo  [2/2] 启动 AI 服务器（Whisper + 向量库 + edge-tts）...
echo        模型加载约 10-20 秒，请稍候...
echo.

python -u ws_server.py

echo.
echo  服务器已退出，按任意键关闭窗口...
pause >nul
