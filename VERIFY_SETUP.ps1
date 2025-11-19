# ============================================================================
# VERIFY_SETUP.ps1 - Verifica que todos los archivos están en su lugar
# ============================================================================
# Uso: .\VERIFY_SETUP.ps1
# Salida: ✓ Verde = Archivo presente | ✗ Rojo = Archivo faltante
# ============================================================================

Write-Host "🔍 Verificando estructura del proyecto..." -ForegroundColor Cyan
Write-Host ""

# Define los archivos que deben existir
$expectedFiles = @(
    # Scripts
    @{ path = "scripts/test-agent-connection.ps1"; type = "Script PowerShell" },
    @{ path = "scripts/get-agent-citations.ps1"; type = "Script PowerShell" },
    @{ path = "scripts/enrich-citations-with-urls.js"; type = "Script Node.js" },
    @{ path = "scripts/run-citations-workflow.ps1"; type = "Script Orquestador" },
    @{ path = "scripts/citations-mapper.ts"; type = "Funciones TypeScript" },
    
    # Documentación
    @{ path = "CITATIONS_GUIDE.md"; type = "Guía Completa" },
    @{ path = "QUICK_START.md"; type = "Inicio Rápido" },
    @{ path = "PROYECTO_STATUS.md"; type = "Estado del Proyecto" },
    @{ path = "SETUP_INSTRUCTIONS.md"; type = "Instrucciones de Setup" },
    @{ path = "DELIVERABLES.md"; type = "Resumen de Entregables" },
    
    # Proyecto
    @{ path = "index.html"; type = "Página Principal" }
)

# Verificar cada archivo
$allPresent = $true
$presentCount = 0

foreach ($file in $expectedFiles) {
    $fullPath = Join-Path (Get-Location) $file.path
    if (Test-Path $fullPath) {
        Write-Host "✓" -ForegroundColor Green -NoNewline
        Write-Host " $($file.type): " -NoNewline
        Write-Host $file.path -ForegroundColor Green
        $presentCount++
    } else {
        Write-Host "✗" -ForegroundColor Red -NoNewline
        Write-Host " $($file.type): " -NoNewline
        Write-Host $file.path -ForegroundColor Red
        $allPresent = $false
    }
}

Write-Host ""
Write-Host "═" * 70

# Resumen
$total = $expectedFiles.Count
Write-Host "Archivos encontrados: $presentCount / $total" -ForegroundColor Cyan

if ($allPresent) {
    Write-Host "✅ Todos los archivos están presentes. ¡Sistema listo!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "  1. Configura las variables de entorno:"
    Write-Host "     `$Env:AGENT_URL = 'https://webasistente-l9ise.ondigitalocean.app'"
    Write-Host "     `$Env:AGENT_TOKEN = 'tu_token_aqui'"
    Write-Host ""
    Write-Host "  2. Ejecuta el workflow automático:"
    Write-Host "     .\scripts\run-citations-workflow.ps1"
    Write-Host ""
    Write-Host "  3. Lee QUICK_START.md para la integración React"
} else {
    Write-Host "❌ Faltan algunos archivos. Verifica la instalación." -ForegroundColor Red
    exit 1
}

Write-Host ""
