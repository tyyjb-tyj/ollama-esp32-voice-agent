@echo off
chcp 65001 >nul
title 智慧物院 AI 问答 —— Web 可视化界面（Gradio）

cd /d D:\voice_assistant_project

echo ================================================
echo    智慧物院 AI 问答 —— Web 可视化界面
echo    （MySQL + Ollama + Gradio 一键启动）
echo ================================================
echo.

echo  [1/3] 启动 MySQL（数据目录 D:\mysql_data）...
start "mysql" /min "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --no-defaults --datadir=D:/mysql_data --port=3306 --console

echo  [2/3] 检查 Ollama（Qwen 兜底）...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo        未运行，正在后台启动...
    start "ollama" /min ollama serve
) else (
    echo        已在运行
)

echo  [3/3] 启动 Web 界面（模型加载约 10-20 秒）...
echo        浏览器访问 http://127.0.0.1:7860
echo.
python -u web_ui.py

echo.
echo  服务器已退出，按任意键关闭窗口...
pause >nul
