# Script: get-agent-citations-simple.ps1
# Simplificado: Llama directamente al endpoint sin buscar

$agentUrl = $Env:AGENT_URL
$agentToken = $Env:AGENT_TOKEN

if (-not $agentUrl) {
    Write-Error "Variable AGENT_URL no definida"
    exit 1
}

$chatUrl = "$agentUrl/api/v1/chat/completions"

Write-Host "Llamando a: $chatUrl" -ForegroundColor Cyan

# Body con formato correcto
$body = @{
    messages = @(
        @{
            role = "user"
            content = "Respond briefly and cite your sources"
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
    Write-Host "`n[...] Esperando respuesta..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post `
        -Headers $headers `
        -Body $body `
        -TimeoutSec 30

    # Guardar respuesta
    $response | ConvertTo-Json -Depth 20 | Out-File -FilePath "agent_response_complete.json" -Encoding utf8
    Write-Host "[OK] Respuesta guardada: agent_response_complete.json" -ForegroundColor Green

    # Extraer datos
    if ($response.retrieval) {
        Write-Host "`n[RETRIEVAL DATA]" -ForegroundColor Cyan
        Write-Host "Items encontrados: $(($response.retrieval.retrieved_data | Measure-Object).Count)" -ForegroundColor Green
        $response.retrieval.retrieved_data | ForEach-Object {
            Write-Host "  - $($_.filename)" -ForegroundColor White
        }
    }

    if ($response.citations -and $response.citations.Count -gt 0) {
        Write-Host "`n[CITATIONS]" -ForegroundColor Cyan
        Write-Host "Citaciones encontradas: $($response.citations.Count)" -ForegroundColor Green
        $response.citations | ForEach-Object {
            Write-Host "  - $($_.text.Substring(0, [Math]::Min(60, $_.text.Length)))..." -ForegroundColor White
        }
    }

    Write-Host "`n[OK] Extraccion completada" -ForegroundColor Green
}
catch {
    Write-Error "Error: $_"
    exit 1
}
