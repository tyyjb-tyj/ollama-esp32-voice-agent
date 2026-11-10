@echo off
chcp 65001 >nul
title MySQL 8.0 (datadir=D:\mysql_data)

echo ================================================
echo    启动 MySQL（数据目录 D:\mysql_data）
echo ================================================
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --no-defaults --datadir=D:/mysql_data --port=3306 --console

echo.
echo MySQL 已退出，按任意键关闭窗口...
pause >nul
