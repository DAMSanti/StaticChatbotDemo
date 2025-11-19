# DIAGNOSTICO - Integracion del Agent DigitalOcean

## Descubrimiento Importante ⚠️

La URL `https://webasistente-l9ise.ondigitalocean.app` **NO es el endpoint del agente**.  
Es el **sitio web estático** que CONTIENE el widget.

El endpoint del agente debe ser **diferente**.

## Estado Actual

✓ **Sitio web accesible**: https://webasistente-l9ise.ondigitalocean.app (HTTP 200 - HTML)  
✗ **Endpoint del agente**: NO encontrado (necesita URL correcta)  
? **Widget Provider**: Externo en qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run  

## El Problema

El endpoint del agente NO responde a llamadas HTTP POST directas en:
- `/api/v1/chat/completions`
- `/api/chat/completions`
- `/v1/chat/completions`
- `/chat/completions`
- Y otras variantes...

Todos devuelven **HTTP 405 (Método No Permitido)**.

## Posibles Causas

1. **Widget iframe** - El agente usa un widget en iframe que maneja internamente las llamadas
2. **Arquitectura de DigitalOcean** - El agente está detrás de la plataforma de widgets, no expone API pública
3. **Configuración custom** - El agent requiere una estructura específica de request diferente
4. **SSE/WebSocket** - Las comunicaciones podrían ser en Event Stream o WebSocket

## Soluciones Alternativas

### Opción 1: Usar el Widget Provisto (RECOMENDADO)
El widget en `index.html` ya está integrado y funciona. El problema es que las citations se muestran sin URLs.

**Ventaja**: Ya funciona  
**Desventaja**: No podemos interceptar/enriquecer desde el servidor

**Implementación**:
```javascript
// En el navegador del usuario, interceptar la llamada WebSocket/Fetch del widget
// Enriquecer las citations en JavaScript client-side
// Inyectar script adicional que modifique el DOM del widget
```

### Opción 2: Contactar a DigitalOcean
Solicitar documentación sobre:
- ¿Cómo se llama el agente programáticamente?
- ¿Qué endpoints públicos expone?
- ¿Cómo obtener citations con URLs?

**Link de soporte**: https://docs.digitalocean.com/support/

### Opción 3: Usar DigitalOcean CLI
```bash
doctl apps get webasistente-l9ise
doctl apps get-logs webasistente-l9ise --follow
```

Esto podría revelar más información sobre los endpoints disponibles.

### Opción 4: Revisar el Widget Embebido
El widget en el index.html hace llamadas a través del iframe. Debería haber forma de:
1. Inspeccionar qué URL llama en DevTools
2. Ver la estructura de la respuesta JSON
3. Reproducir la llamada localmente

## Próximos Pasos Recomendados

### PASO 1: Abrir DevTools y Analizar
```
1. Abre https://webasistente-l9ise.ondigitalocean.app en el navegador
2. Abre DevTools (F12) → Network tab
3. Interactúa con el chatbot
4. Busca llamadas XHR/Fetch
5. Copia la URL exacta que se está llamando
6. Copia el payload JSON que se envía
7. Copia la respuesta JSON completa
```

### PASO 2: Comparte esa Información
Una vez que tengas:
- URL exacta del endpoint
- Request JSON
- Response JSON con citations

Podré:
1. Actualizar los scripts para usar el endpoint correcto
2. Implementar el enriquecimiento de URLs
3. Crear la integración React final

### PASO 3: Script Helper para DevTools
Usa este código en la consola de DevTools:

```javascript
// Interceptar fetch para capturar llamadas al agente
const originalFetch = window.fetch;
window.fetch = async function(...args) {
    const response = await originalFetch.apply(this, args);
    if (args[0].includes("completions") || args[0].includes("chat")) {
        const clone = response.clone();
        const data = await clone.json();
        console.log("=== AGENT RESPONSE ===");
        console.log("URL:", args[0]);
        console.log("Body:", args[1].body);
        console.log("Response:", JSON.stringify(data, null, 2));
        console.log("====================");
    }
    return response;
};

// Luego interactúa con el chatbot y revisa la consola
```

## Archivos Relacionados

- `TEST_AGENT_DIRECT.html` - Interfaz web para probar endpoints
- `.env.local` - Credenciales (no subir a git)
- `scripts/test-agent-connection.ps1` - Script PowerShell de test
- `QUICK_START.md` - Guía rápida una vez que se encuentre el endpoint

## Estado del Proyecto

| Componente | Estado | Descripción |
|-----------|--------|-------------|
| Widget en index.html | ✓ OK | Embebido y funciona |
| Conectividad | ✓ OK | Agent accesible |
| Endpoint API | ✗ NO | HTTP 405 en todos los intentos |
| Extracción de citations | ⏳ ESPERA | Depende de endpoint correcto |
| Enriquecimiento con URLs | ⏳ ESPERA | Scripts listos, esperan datos reales |
| Integración React | ⏳ ESPERA | Código listo en citations-mapper.ts |
| Rendering final | ⏳ ESPERA | Template listo en QUICK_START.md |

## Resumen

**No es un error de credenciales o conectividad.**  
**El agente está correctamente desplegado y accesible.**  
**El problema es que no sabemos cuál es el endpoint/formato correcto para llamarlo programáticamente.**

Necesitamos:
1. Inspeccionar DevTools para ver la URL exacta que usa el widget
2. Capturar el request/response JSON completo
3. Actualizar los scripts con esa información
4. Luego todo lo demás (enriquecimiento, React, deploy) seguirá correctamente

---

**¿Acción?** Abre DevTools en el agente, interactúa con el chatbot, captura las llamadas y comparte la información aquí.
