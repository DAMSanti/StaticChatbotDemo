# Script: test-agent-connection.ps1
# Objetivo: Validar conectividad y token al agent sin solicitar citations
# Uso: .\scripts\test-agent-connection.ps1

$agentUrl = $Env:AGENT_URL
$agentToken = $Env:AGENT_TOKEN

Write-Host "Prueba de Conexion al Agent" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Validar variables
if (-not $agentUrl) {
    Write-Host "[X] AGENT_URL no definida" -ForegroundColor Red
    Write-Host "  Ejecuta: `$Env:AGENT_URL = 'https://your-agent-url'" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] AGENT_URL: $agentUrl" -ForegroundColor Green

if (-not $agentToken) {
    Write-Host "[!] AGENT_TOKEN no definida (puede ser opcional si agent es publico)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] AGENT_TOKEN configurado (${agentToken.Length} caracteres)" -ForegroundColor Green
}

# Test 1: Conectividad basica (HEAD request)
Write-Host "`n[Test 1] Conectividad basica..." -ForegroundColor Cyan
try {
    $headResponse = Invoke-WebRequest -Uri $agentUrl -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($headResponse.StatusCode -eq 200 -or $headResponse.StatusCode -eq 301) {
        Write-Host "[OK] Agent accesible (HTTP $($headResponse.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "[!] Status code: $($headResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[X] Error de conexion: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Endpoint de chat completions
Write-Host "`n[Test 2] Buscar endpoint de chat..." -ForegroundColor Cyan

# Intentar varios endpoints comunes
$endpointCandidates = @(
    "$agentUrl/api/v1/chat/completions",
    "$agentUrl/api/chat/completions",
    "$agentUrl/v1/chat/completions",
    "$agentUrl/chat/completions",
    "$agentUrl/api/v1/completions",
    "$agentUrl/completions"
)

$chatUrl = $null
$headers = @{ "Content-Type" = "application/json" }
if ($agentToken) {
    $headers["Authorization"] = "Bearer $agentToken"
}

# Intentar primero con format correcto de DO (messages en lugar de input)
$correctBody = @{
    messages = @(
        @{
            role = "user"
            content = "Hola, por favor responde brevemente"
        }
    )
    stream = $false
    include_retrieval_info = $true
} | ConvertTo-Json -Depth 3

# Fallback a formato alternativo
$minimalBody = @{
    model = "default"
    input = "hola"
    stream = $false
} | ConvertTo-Json -Depth 3

foreach ($endpoint in $endpointCandidates) {
    try {
        Write-Host "Intentando: $endpoint" -ForegroundColor Gray
        
        # Primero con formato correcto
        $response = Invoke-RestMethod -Uri $endpoint -Method Post `
            -Headers $headers `
            -Body $correctBody `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        $chatUrl = $endpoint
        Write-Host "[OK] Endpoint encontrado: $endpoint (formato correcto)" -ForegroundColor Green
        break
    } catch {
        $status = $_.Exception.Response.StatusCode
        Write-Host "  No (formato correcto): $status" -ForegroundColor Gray
        
        # Fallback a formato alternativo
        try {
            $response = Invoke-RestMethod -Uri $endpoint -Method Post `
                -Headers $headers `
                -Body $minimalBody `
                -TimeoutSec 5 `
                -ErrorAction Stop
            
            $chatUrl = $endpoint
            Write-Host "[OK] Endpoint encontrado: $endpoint (formato alternativo)" -ForegroundColor Green
            break
        } catch {
            $status2 = $_.Exception.Response.StatusCode
            Write-Host "  No (formato alternativo): $status2" -ForegroundColor Gray
        }
    }
}

if (-not $chatUrl) {
    Write-Host "[X] No se encontro endpoint valido" -ForegroundColor Red
    Write-Host "Endpoints intentados:" -ForegroundColor Yellow
    $endpointCandidates | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    exit 1
}

# Test con endpoint encontrado
try {
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post `
        -Headers $headers `
        -Body $minimalBody `
        -TimeoutSec 10 `
        -ErrorAction SilentlyContinue

    if ($response) {
        Write-Host "[OK] Endpoint funcional" -ForegroundColor Green
        
        # Verificar estructura
        if ($response.citations) {
            Write-Host "[OK] Citations disponibles ($(($response.citations | Measure-Object).Count) items)" -ForegroundColor Green
        }
        
        if ($response.retrieval) {
            Write-Host "[OK] Retrieval disponible ($(($response.retrieval.retrieved_data | Measure-Object).Count) items)" -ForegroundColor Green
        }
        
        if (-not $response.citations -and -not $response.retrieval) {
            Write-Host "[!] No hay citations ni retrieval en la respuesta" -ForegroundColor Yellow
            Write-Host "  Estructura de respuesta:" -ForegroundColor Yellow
            $response | ConvertTo-Json -Depth 2 | Write-Host
        }
    } else {
        Write-Host "[X] Respuesta vacia" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[X] Error en peticion: $_" -ForegroundColor Red
    exit 1
}

# Resumen
Write-Host "`n===============================" -ForegroundColor Cyan
Write-Host "[OK] Pruebas completadas exitosamente" -ForegroundColor Green
Write-Host "`nSiguiente paso:" -ForegroundColor Cyan
Write-Host "  .\scripts\get-agent-citations.ps1" -ForegroundColor Yellow
