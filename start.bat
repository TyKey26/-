@echo off
setlocal EnableExtensions
chcp 65001 >nul
title ТОиР-Проф — запуск API, Desktop, Web

rem Корень репозитория = папка, где лежит этот .bat
set "ROOT=%~dp0"

rem Если .bat лежит НЕ в корне репозитория — раскомментируйте и укажите путь:
rem set "ROOT=C:\path\to\professionals-task\"

set "API_DIR=%ROOT%src\Api"
set "DESKTOP_DIR=%ROOT%src\Desktop"
set "WEB_DIR=%ROOT%src\Web"

rem --- Проверка папок ---
if not exist "%API_DIR%" (
    echo [ERROR] Не найдена папка API: "%API_DIR%"
    pause
    exit /b 1
)
if not exist "%DESKTOP_DIR%" (
    echo [ERROR] Не найдена папка Desktop: "%DESKTOP_DIR%"
    pause
    exit /b 1
)
if not exist "%WEB_DIR%\package.json" (
    echo [ERROR] Не найден "%WEB_DIR%\package.json"
    pause
    exit /b 1
)

rem --- Автопоиск .csproj ---
set "API_PROJECT="
for /r "%API_DIR%" %%F in (*.csproj) do if not defined API_PROJECT set "API_PROJECT=%%F"

set "DESKTOP_PROJECT="
for /r "%DESKTOP_DIR%" %%F in (*.csproj) do if not defined DESKTOP_PROJECT set "DESKTOP_PROJECT=%%F"

if not defined API_PROJECT (
    echo [ERROR] В "%API_DIR%" не найден .csproj
    pause
    exit /b 1
)
if not defined DESKTOP_PROJECT (
    echo [ERROR] В "%DESKTOP_DIR%" не найден .csproj
    pause
    exit /b 1
)

rem --- Проверка инструментов ---
where dotnet >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Не найден dotnet в PATH
    pause
    exit /b 1
)

where npm >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Не найден npm в PATH
    pause
    exit /b 1
)

rem --- Установка зависимостей web, если node_modules ещё нет ---
if not exist "%WEB_DIR%\node_modules" (
    echo [WEB] node_modules не найден, выполняю npm install...
    pushd "%WEB_DIR%"
    call npm install
    if errorlevel 1 (
        popd
        echo [ERROR] npm install завершился с ошибкой
        pause
        exit /b 1
    )
    popd
)

echo [API] %API_PROJECT%
start "ТОиР-Проф API" /D "%ROOT%" cmd /k dotnet run --project "%API_PROJECT%"

rem Небольшая пауза, чтобы API начал стартовать первым
timeout /t 3 /nobreak >nul

echo [DESKTOP] %DESKTOP_PROJECT%
start "ТОиР-Проф Desktop" /D "%ROOT%" cmd /k dotnet run --project "%DESKTOP_PROJECT%"

echo [WEB] %WEB_DIR%
start "ТОиР-Проф Web" /D "%WEB_DIR%" cmd /k npm run dev

echo.
echo Запущены 3 окна: API, Desktop, Web.
echo PostgreSQL этим скриптом не запускается — БД должна быть доступна отдельно.
echo.
endlocal
exit /b 0