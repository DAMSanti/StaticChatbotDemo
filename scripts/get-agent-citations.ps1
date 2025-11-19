# Script: get-agent-citations.ps1
# Objetivo: Llamar al agent del chatbot y extraer citations + retrieval
# Uso: 
#   $Env:AGENT_URL = "https://webasistente-l9ise.ondigitalocean.app"
#   $Env:AGENT_TOKEN = "tu_bearer_token_aqui"
#   .\scripts\get-agent-citations.ps1

# Variables de configuracion
$agentUrl = $Env:AGENT_URL
$agentToken = $Env:AGENT_TOKEN

if (-not $agentUrl) {
    Write-Error "Variable AGENT_URL no definida. Establece: `$Env:AGENT_URL = 'https://tu-agent.com'"
    exit 1
}

if (-not $agentToken) {
    Write-Error "Variable AGENT_TOKEN no definida. Establece: `$Env:AGENT_TOKEN = 'tu_token'"
    exit 1
}

Write-Host "Llamando a agent: $agentUrl" -ForegroundColor Cyan

# Construir body de la peticion con formato correcto de DigitalOcean
$body = @{
    messages = @(
        @{
            role = "user"
            content = "Respond with a brief answer and include any citations from your knowledge base"
        }
    )
    stream = $false
    include_retrieval_info = $true
} | ConvertTo-Json -Depth 10

# Headers
$headers = @{
    "Authorization" = "Bearer $agentToken"
    "Content-Type" = "application/json"
}

try {
    # Hacer la peticion
    $response = Invoke-RestMethod -Uri "$agentUrl/api/v1/chat/completions" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -TimeoutSec 30

    # Guardar respuesta completa
    $response | ConvertTo-Json -Depth 20 | Out-File -FilePath "agent_response_complete.json" -Encoding utf8
    Write-Host "[OK] Respuesta guardada en: agent_response_complete.json" -ForegroundColor Green

    # Extraer y mostrar retrieval
    if ($response.retrieval) {
        Write-Host "`n[RETRIEVAL]" -ForegroundColor Yellow
        $response.retrieval | ConvertTo-Json -Depth 10 | Write-Host
    }

    # Extraer y mostrar citations
    if ($response.citations) {
        Write-Host "`n[CITATIONS]" -ForegroundColor Yellow
        $response.citations | ConvertTo-Json -Depth 10 | Write-Host
    }

    # Si no hay retrieval/citations, mostrar estructura completa
    if (-not $response.retrieval -and -not $response.citations) {
        Write-Host "`nNo retrieval/citations encontrados. Estructura completa:" -ForegroundColor Yellow
        $response | ConvertTo-Json -Depth 10 | Write-Host
    }

    Write-Host "`n[OK] Proceso completado. Verifica agent_response_complete.json" -ForegroundColor Green
}
catch {
    Write-Error "Error al llamar al agent: $_"
    exit 1
}
