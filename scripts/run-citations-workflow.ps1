#!/usr/bin/env pwsh
# Script: run-citations-workflow.ps1
# Orquesta todo el flujo de citations de principio a fin
# Uso: .\scripts\run-citations-workflow.ps1

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   WORKFLOW: Extraer y Mostrar Citations en Chatbot     " -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# Funcion auxiliar para separadores
function Show-Step {
    param([int]$Number, [string]$Title, [string]$Color = "Yellow")
    Write-Host "`n[$Number/5] $Title" -ForegroundColor $Color
    Write-Host ("=" * 60) -ForegroundColor $Color
}

# Paso 0: Verificar variables
Show-Step 0 "Verificacion de Variables" "Magenta"

if (-not $Env:AGENT_URL) {
    Write-Host "[X] AGENT_URL no definida" -ForegroundColor Red
    Write-Host "Establece:" -ForegroundColor Yellow
    Write-Host '  $Env:AGENT_URL = "https://tu-agent-url"' -ForegroundColor Cyan
    exit 1
}
Write-Host "[OK] AGENT_URL: $Env:AGENT_URL" -ForegroundColor Green

if ($Env:AGENT_TOKEN) {
    Write-Host "[OK] AGENT_TOKEN: configurado (${$Env:AGENT_TOKEN.Length} caracteres)" -ForegroundColor Green
} else {
    Write-Host "[!] AGENT_TOKEN: no configurado (puede ser opcional)" -ForegroundColor Yellow
}

# Paso 1: Test de conexion
Show-Step 1 "Test de Conexion al Agent"

Write-Host "`nEjecutando: .\scripts\test-agent-connection.ps1" -ForegroundColor Cyan
& .\scripts\test-agent-connection.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Test fallo. Verifica tu AGENT_URL y AGENT_TOKEN." -ForegroundColor Red
    exit 1
}

# Paso 2: Extraer citations
Show-Step 2 "Extraer Citations del Agent"

Write-Host "`nEjecutando: .\scripts\get-agent-citations.ps1" -ForegroundColor Cyan
& .\scripts\get-agent-citations.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Extraccion fallo." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "agent_response_complete.json")) {
    Write-Host "[X] No se genero agent_response_complete.json" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Archivo guardado: agent_response_complete.json" -ForegroundColor Green

# Paso 3: Enriquecer con URLs
Show-Step 3 "Enriquecer Citations con URLs"

Write-Host "`nEjecutando: node .\scripts\enrich-citations-with-urls.js" -ForegroundColor Cyan
& node .\scripts\enrich-citations-with-urls.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Enriquecimiento fallo." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "agent_response_with_urls.json")) {
    Write-Host "[X] No se genero agent_response_with_urls.json" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Archivo guardado: agent_response_with_urls.json" -ForegroundColor Green

# Paso 4: Verificar resultados
Show-Step 4 "Verificar Resultados" "Cyan"

$responseJson = Get-Content "agent_response_with_urls.json" | ConvertFrom-Json
$citations = $responseJson.citations
$citationsWithUrl = @($citations | Where-Object { $_.metadata.url }) 

Write-Host "`nCitations encontradas: $($citations.Count)" -ForegroundColor Green
Write-Host "Citations con URL: $($citationsWithUrl.Count)" -ForegroundColor Green

if ($citationsWithUrl.Count -gt 0) {
    Write-Host "`n[OK] Sample de URLs enriquecidas:" -ForegroundColor Green
    $citationsWithUrl | Select-Object -First 3 | ForEach-Object {
        $text = $_.text.Substring(0, [Math]::Min(50, $_.text.Length))
        Write-Host "  * $text" -ForegroundColor Green
        Write-Host "    -> $($_.metadata.url)" -ForegroundColor Cyan
    }
} else {
    Write-Host "`n[!] No hay citations con URLs enriquecidas" -ForegroundColor Yellow
    Write-Host "Posible causa: el agent no devuelve URLs en retrieval.retrieved_data" -ForegroundColor Yellow
    Write-Host "Ver: CITATIONS_GUIDE.md -> 'Solucion de problemas'" -ForegroundColor Yellow
}

# Paso 5: Resumen y siguientes pasos
Show-Step 5 "Resumen y Siguientes Pasos" "Green"

Write-Host "`n[OK] Workflow completado exitosamente!" -ForegroundColor Green
Write-Host "`nArchivos generados:" -ForegroundColor Cyan
Write-Host "  * agent_response_complete.json    -- Respuesta bruta del agent" -ForegroundColor White
Write-Host "  * agent_response_with_urls.json   -- Enriquecida con URLs" -ForegroundColor White

Write-Host "`nProximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Revisa: agent_response_with_urls.json" -ForegroundColor White
Write-Host "  2. Si hay URLs: integra el patch en tu React (ver QUICK_START.md)" -ForegroundColor White
Write-Host "  3. Prueba localmente: npm start" -ForegroundColor White
Write-Host "  4. Commit y push a GitHub" -ForegroundColor White
Write-Host "  5. DigitalOcean redeploy automatico" -ForegroundColor White

Write-Host "`nMas info: lee QUICK_START.md o CITATIONS_GUIDE.md" -ForegroundColor Cyan
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "                    [OK] LISTO PARA INTEGRAR              " -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan
