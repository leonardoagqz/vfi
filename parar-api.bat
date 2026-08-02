@echo off
echo =====================================
echo  VFI - Parando API
echo =====================================
taskkill /f /im dotnet.exe 2>nul
if %errorlevel% equ 0 (
    echo API parada com sucesso.
) else (
    echo API nao estava rodando.
)
echo.
pause
