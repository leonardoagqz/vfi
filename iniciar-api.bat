@echo off
echo =====================================
echo  VFI - Iniciando API C# .NET
echo =====================================
cd /d "%~dp0src\api"
echo.
echo Iniciando em http://localhost:5000
echo Swagger: http://localhost:5000/swagger
echo.
dotnet run --urls "http://localhost:5000"
pause
