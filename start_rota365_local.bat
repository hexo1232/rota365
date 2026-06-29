@echo off
title Rota365 Local Launcher

set "ROOT=%~dp0"
set "BACKEND_DIR=%ROOT%backend"
set "FRONTEND_DIR=%ROOT%rota365_frontend"

echo =====================================================
echo   ROTA365 - ARRANQUE LOCAL
echo =====================================================
echo.

echo Backend:  %BACKEND_DIR%
echo Frontend: %FRONTEND_DIR%
echo.

if not exist "%BACKEND_DIR%" (
    echo [ERRO] Pasta backend nao encontrada.
    pause
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo [ERRO] Pasta rota365_frontend nao encontrada.
    pause
    exit /b 1
)

echo [1/2] A arrancar backend Spring Boot...
start "Rota365 Backend" cmd /k "cd /d "%BACKEND_DIR%" && if exist mvnw.cmd (mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local) else (mvn spring-boot:run -Dspring-boot.run.profiles=local)"

echo.
echo A aguardar alguns segundos para o backend iniciar...
timeout /t 8 /nobreak > nul

echo [2/2] A arrancar Flutter...
start "Rota365 Flutter" cmd /k "cd /d "%FRONTEND_DIR%" && flutter pub get && flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8080"

echo.
echo Tudo iniciado em janelas separadas.
echo.
pause