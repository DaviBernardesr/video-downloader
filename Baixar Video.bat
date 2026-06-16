@echo off
chcp 65001 >nul
title Baixar Video em Full HD
cd /d "%~dp0"

echo ============================================
echo    BAIXAR VIDEO EM FULL HD (MP4)
echo ============================================
echo.

REM --- 1) Procura o Python ---
set "PY="
where python >nul 2>&1 && set "PY=python"
if not defined PY where py >nul 2>&1 && set "PY=py"
if not defined PY goto :sem_python

REM --- 2) Garante a pasta bin ---
if not exist "bin" mkdir "bin"

REM --- 3) Baixa o yt-dlp (se faltar) ---
if exist "bin\yt-dlp.exe" goto :tem_ytdlp
echo [1/2] Baixando o yt-dlp...
powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'bin\yt-dlp.exe' } catch { exit 1 }"
if errorlevel 1 goto :erro_download
:tem_ytdlp

REM --- 4) Baixa o ffmpeg (se faltar) ---
if exist "bin\ffmpeg.exe" goto :tem_ffmpeg
echo [2/2] Baixando o ffmpeg, pode demorar um pouco ^(~112 MB^)...
powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'; Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_tmp' -Force; $f = Get-ChildItem 'ffmpeg_tmp' -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1; $p = Get-ChildItem 'ffmpeg_tmp' -Recurse -Filter 'ffprobe.exe' | Select-Object -First 1; Copy-Item $f.FullName 'bin\ffmpeg.exe' -Force; Copy-Item $p.FullName 'bin\ffprobe.exe' -Force; Remove-Item 'ffmpeg.zip','ffmpeg_tmp' -Recurse -Force } catch { exit 1 }"
if errorlevel 1 goto :erro_download
:tem_ffmpeg

REM --- 5) Loop de downloads ---
:baixar
echo.
echo --------------------------------------------
set "FONTE="
set /p "FONTE=Cole o LINK do video (ou digite o nome p/ buscar): "
if not defined FONTE goto :fim

echo.
%PY% "baixar_video.py" "%FONTE%"

echo.
set "DENOVO="
set /p "DENOVO=Baixar outro? (S/N): "
if /I "%DENOVO%"=="S" goto :baixar
goto :fim

:sem_python
echo [ERRO] Python nao encontrado.
echo.
echo Instale o Python em: https://www.python.org/downloads/
echo IMPORTANTE: marque a opcao "Add Python to PATH" na instalacao.
echo Depois feche e abra este programa de novo.
start "" "https://www.python.org/downloads/"
goto :fim

:erro_download
echo.
echo [ERRO] Nao consegui baixar as ferramentas.
echo Verifique sua internet e tente novamente.
goto :fim

:fim
echo.
pause
