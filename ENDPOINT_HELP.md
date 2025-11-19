# ⚠️ PROBLEMA ENCONTRADO

## El Descubrimiento

`https://webasistente-l9ise.ondigitalocean.app` **NO es el endpoint del agente**.

Es el **sitio web estático** donde está embebido el widget.

El endpoint real está en **otro lugar**.

---

## ¿Dónde Encontrar el Endpoint Real?

### Opción 1: DigitalOcean Control Panel (RECOMENDADO)

1. Ve a: https://cloud.digitalocean.com
2. Menú izquierdo: **Agent Platform**
3. Tab: **Agent Workspaces**
4. Selecciona tu workspace
5. Tab: **Agents**
6. Haz click en tu agente
7. Tab: **Overview**
8. Busca la sección **ENDPOINT**
9. Copia la URL que aparece ahí

**Esa URL es la que necesitamos.**

### Opción 2: API de DigitalOcean

```powershell
# Necesitas un token de DigitalOcean (no el Agent Token)
# Lo puedes generar en: https://cloud.digitalocean.com/account/api/tokens

$doToken = "dop_v1_xxxxxxxxxxxxx"

$response = Invoke-RestMethod -Uri "https://api.digitalocean.com/v2/gen-ai/agents" `
    -Headers @{ "Authorization" = "Bearer $doToken" }

$response.agents | ForEach-Object {
    Write-Host "Nombre: $($_.name)"
    Write-Host "Endpoint: $($_.endpoint_url)"
    Write-Host ""
}
```

---

## Ejemplo de Endpoint Real

Probablemente se vea así:

- `https://xxxxxxxx-xxxxxxxx.do-ai.run`
- `https://agent-xxxxxxxx.digitalocean.app`
- `https://something.ondigitalocean.app/agents/xxxxx`
- Algo parecido

---

## Una Vez que Tengas el Endpoint

1. Abre `.env.local`
2. Actualiza: `AGENT_URL=https://[el-endpoint-real-aqui]`
3. Guarda
4. Ejecuta: `.\scripts\run-citations-workflow.ps1`
5. ¡Listo!

---

**¿Necesitas ayuda encontrando el endpoint?**

Comparte una captura de pantalla de tu DigitalOcean Control Panel mostrando el agente, y lo vemos juntos.
