@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================
REM  拖拽两个 WAV 文件到本脚本：
REM  第 1 个 = 左声道，第 2 个 = 右声道
REM  输出：与第 1 个文件同目录，命名为 原文件名_LR.wav
REM ============================================================

REM 检查是否拖入了两个文件
if "%~2"=="" (
    echo.
    echo 用法：请将两个 WAV 文件一起拖拽到本脚本上。
    echo   第 1 个 = 左声道
    echo   第 2 个 = 右声道
    echo.
    pause
    exit /b 1
)

set "LEFT=%~1"
set "RIGHT=%~2"

REM 简单校验扩展名
if /i not "%~x1"==".wav" (
    echo [错误] 第 1 个文件不是 .wav：%LEFT%
    pause
    exit /b 1
)
if /i not "%~x2"==".wav" (
    echo [错误] 第 2 个文件不是 .wav：%RIGHT%
    pause
    exit /b 1
)

REM 生成输出文件名：与左声道文件同目录
set "OUTDIR=%~dp1"
set "NAME1=%~n1"
set "OUTNAME=!NAME1:~0,19!_LR.wav"
set "OUTPUT=%OUTDIR%%OUTNAME%"

echo.
echo 左声道：%LEFT%
echo 右声道：%RIGHT%
echo 输出  ：%OUTPUT%
echo.

REM 调用 FFmpeg（假设 ffmpeg 已加入 PATH；否则改成完整路径）
ffmpeg -y -i "%LEFT%" -i "%RIGHT%" -filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo:map=0.0-FL|1.0-FR[aout]" -map "[aout]" "%OUTPUT%"

if errorlevel 1 (
    echo.
    echo [失败] FFmpeg 执行出错，请检查上面的日志。
) else (
    echo.
    echo [完成] 已生成：%OUTPUT%
)

echo.
pause
endlocal