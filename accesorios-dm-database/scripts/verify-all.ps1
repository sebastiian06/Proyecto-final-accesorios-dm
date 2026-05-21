# verify-all.ps1
# Verifica los 3 ambientes

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "VERIFICANDO TODOS LOS AMBIENTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "1. VERIFICANDO DEVELOP (puerto 5432)" -ForegroundColor Blue
& ".\docs\scripts-verificacion\verify-develop.ps1"

Write-Host ""
Write-Host "2. VERIFICANDO QA (puerto 5433)" -ForegroundColor Green
& ".\docs\scripts-verificacion\verify-qa.ps1"

Write-Host ""
Write-Host "3. VERIFICANDO MAIN (puerto 5434)" -ForegroundColor Red
& ".\docs\scripts-verificacion\verify-main.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "VERIFICACION COMPLETADA - TODOS LOS AMBIENTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")