@echo off
chcp 65001 >nul
title Baixar Video em Full HD
cd /d "%~dp0"

echo ============================================
echo    BAIXAR VIDEO EM FULL HD (MP4)
echo ============================================
echo.

REM --- 1) Procura o Python (instala se faltar) ---
call :achar_python
if defined PY goto :tem_python

echo Python nao encontrado. Vou baixar e instalar automaticamente.
echo.
echo [0/2] Baixando o instalador do Python...
powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe' -OutFile 'python_setup.exe' } catch { exit 1 }"
if errorlevel 1 goto :erro_download
echo Instalando o Python, aguarde 1-2 minutos ^(pode pedir confirmacao^)...
python_setup.exe /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1 Include_test=0
del /q python_setup.exe >nul 2>&1
call :achar_python
if not defined PY goto :reabrir

:tem_python
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

:reabrir
echo.
echo ============================================
echo  Python instalado com sucesso!
echo  FECHE esta janela e abra o programa de novo
echo  para terminar a configuracao.
echo ============================================
goto :fim

:erro_download
echo.
echo [ERRO] Nao consegui baixar. Verifique sua internet e tente de novo.
goto :fim

:fim
echo.
pause
exit /b

REM ============ sub-rotina: localiza o Python ============
:achar_python
set "PY="
REM 1) caminho de instalacao padrao (evita o stub da Microsoft Store)
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\python.exe" set "PY=%%D\python.exe"
if defined PY exit /b
REM 2) Python real no PATH (--version falha no stub da Store)
python --version >nul 2>&1 && set "PY=python" && exit /b
py --version >nul 2>&1 && set "PY=py" && exit /b
exit /b
