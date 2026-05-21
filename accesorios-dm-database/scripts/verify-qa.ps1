# verify-qa.ps1
# Script de verificacion para ambiente QA (puerto 5433)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICANDO BASE DE DATOS - QA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$CONTAINER = "accesorios-dm-postgres-qa"
$DB = "accesorios_dm_db"
$USER = "admin"

Write-Host "Verificando contenedor..." -ForegroundColor Yellow
docker ps --filter "name=$CONTAINER"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. SCHEMAS" -ForegroundColor Cyan
Write-Host "========================================"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "\dn"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "2. TABLAS PRINCIPALES" -ForegroundColor Cyan
Write-Host "========================================"

Write-Host "Security.rol:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT COUNT(*) FROM security.rol;"

Write-Host "Clientes.cliente:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT COUNT(*) FROM clientes.cliente;"

Write-Host "Catalogo.producto:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT COUNT(*) FROM catalogo.producto;"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "3. DATOS INICIALES" -ForegroundColor Cyan
Write-Host "========================================"

Write-Host "Roles:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT id_rol, nombre FROM security.rol;"

Write-Host "Productos:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT id_producto, nombre, precio FROM catalogo.producto;"

Write-Host "Total Productos:"
docker exec -it $CONTAINER psql -U $USER -d $DB -c "SELECT COUNT(*) FROM catalogo.producto;"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "VERIFICACION COMPLETADA - QA" -ForegroundColor Green
Write-Host "========================================"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")