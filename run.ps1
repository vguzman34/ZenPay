Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         ZENPAY - BANCA DIGITAL          " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Iniciar Backend con Docker
Write-Host "[1/3] Iniciando Base de Datos y API..." -ForegroundColor Yellow
Set-Location "$root\backend"
$dockerRunning = docker ps -q --filter "name=zenpay" 2>$null
if (-not $dockerRunning) {
    docker-compose up -d 2>&1 | Out-Null
    Write-Host "  ✔ PostgreSQL + API Spring Boot iniciados" -ForegroundColor Green
} else {
    Write-Host "  ✔ Backend ya estaba corriendo" -ForegroundColor Green
}

# 2. Iniciar Frontend Angular
Write-Host "[2/3] Iniciando Frontend Angular..." -ForegroundColor Yellow
Set-Location "$root"
Start-Process powershell -ArgumentList "-NoExit -Command ng serve -o"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ZENPAY INICIANDO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:4200" -ForegroundColor White
Write-Host "  Backend:  http://localhost:8080" -ForegroundColor White
Write-Host "  Swagger:  http://localhost:8080/swagger-ui.html" -ForegroundColor White
Write-Host "  Login:    vanessa@zenpay.com / admin123" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
