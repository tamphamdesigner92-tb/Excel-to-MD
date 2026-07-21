@echo off
chcp 65001 >nul
title Hệ Thống Xử Lý Excel - Web Server

set "APP_DIR=%~dp0"
cd /d "%APP_DIR%"
set "VENV_DIR=%APP_DIR%.venv"
set "APP_URL=http://127.0.0.1:5000"

echo ==========================================================
echo      HỆ THỐNG XỬ LÝ EXCEL - TỰ ĐỘNG KHỞI ĐỘNG (WINDOWS)
echo ==========================================================
echo.

:CHECK_REQ
if exist "%APP_DIR%requirements.txt" goto CHECK_PYTHON
echo [X] Lỗi: Không tìm thấy file requirements.txt!
pause
exit /b 1

:CHECK_PYTHON
set "PYTHON_BIN="
where python >nul 2>&1
if %errorlevel% equ 0 set "PYTHON_BIN=python"
if defined PYTHON_BIN goto CHECK_VENV

where py >nul 2>&1
if %errorlevel% equ 0 set "PYTHON_BIN=py"
if defined PYTHON_BIN goto CHECK_VENV

echo [X] Lỗi: Chưa tìm thấy Python trên máy tính!
echo Vui lòng tải Python tại https://www.python.org và nhớ tích chọn "Add Python to PATH".
pause
exit /b 1

:CHECK_VENV
set "VENV_PYTHON=%VENV_DIR%\Scripts\python.exe"
if exist "%VENV_PYTHON%" goto VENV_EXISTS

echo [1/4] Đang tạo môi trường ảo Python (.venv)...
"%PYTHON_BIN%" -m venv "%VENV_DIR%"
if %errorlevel% neq 0 (
    echo [X] Lỗi khi tạo môi trường ảo Python.
    pause
    exit /b 1
)
goto INSTALL_DEPS

:VENV_EXISTS
echo [1/4] Đã tìm thấy môi trường ảo Python (.venv).

:INSTALL_DEPS
echo [2/4] Đang cập nhật pip và cài đặt thư viện từ requirements.txt...
"%VENV_PYTHON%" -m pip install --upgrade pip >nul 2>&1
"%VENV_PYTHON%" -m pip install -r "%APP_DIR%requirements.txt"

if %errorlevel% neq 0 (
    echo [X] Lỗi trong quá trình cài đặt thư viện!
    pause
    exit /b 1
)

echo.
echo [3/4] Đang khởi động Web Server...
echo Trình duyệt sẽ tự động mở tại: %APP_URL%
echo.
echo [4/4] Server đang chạy. VUI LÒNG KHÔNG TẮT CỬA SỔ NÀY TRONG LÚC DÙNG WEB.
echo Nhấn Ctrl + C để dừng server khi không dùng nữa.
echo ----------------------------------------------------------
echo.

start /b cmd /c "timeout /t 3 /nobreak >nul & start %APP_URL%"
"%VENV_PYTHON%" "%APP_DIR%app.py"

pause