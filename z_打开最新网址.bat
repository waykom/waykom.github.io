@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
set /a max=0

for /f "tokens=2 delims=_. " %%a in ('dir /b Cert*.html 2^>nul') do (
    set /a num=%%a
    if !num! gtr !max! set /a max=!num!
)

set "p1=https://"
set "p2=waykom.github.io/"
set "p3=Cert_!max!.html"
set "url=!p1!!p2!!p3!"

:: 1. 输出网址并无换行复制到剪贴板
echo !url!
set /p="!url!" <nul | clip

:: 2. 使用默认浏览器打开该网站
start "" "!url!"

echo 已复制到剪贴板并打开浏览器！
