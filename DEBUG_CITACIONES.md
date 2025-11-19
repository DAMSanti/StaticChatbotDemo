# 🔍 DEBUG - Inspeccionar Citaciones

Ahora el chat tiene **logging detallado** para ver exactamente qué está pasando con las citaciones.

## Pasos para Debuggear:

### 1. Abre la Página
Abre: https://webasistente-l9ise.ondigitalocean.app

### 2. Abre la Consola del Navegador
Presiona: **F12** o **Ctrl + Shift + I**

Luego ve a la pestaña **Console**

### 3. Escribe una Pregunta
En el chat, escribe una pregunta que genere citaciones:
- "¿Cuál es la Ley de Procedimiento Administrativo Común?"
- "¿Qué dice la Ley Orgánica de Protección de Datos?"
- "Explícame la LRJSP"

### 4. Observa la Consola
Deberías ver logs como estos:

```
=== RESPUESTA COMPLETA DE API ===
{
  "id": "cmpl-...",
  "object": "chat.completion",
  "choices": [
    {
      "message": {
        "content": "La Ley de Procedimiento Administrativo [C1] establece..."
      }
    }
  ],
  "retrieval": {
    "retrieved_data": [
      {
        "filename": "https://www.boe.es/buscar/pdf/...",
        ...
      }
    ]
  }
}
=== FIN RESPUESTA ===

Mensaje: La Ley de Procedimiento Administrativo [C1] establece...
Buscando citaciones en:
  - data.retrieval: {...}
  - data.citations: [...]
  - data.context: undefined

✓ Encontrado en data.retrieval.retrieved_data
Mapeado C1 → https://www.boe.es/buscar/pdf/2015/BOE-A-2015-10565-consolidado.pdf

Citaciones encontradas en texto: [C1]
  Procesando [C1]: url = https://www.boe.es/buscar/pdf/2015/BOE-A-2015-10565-consolidado.pdf
```

## ¿Qué Significa Cada Línea?

### `=== RESPUESTA COMPLETA ===`
La respuesta JSON completa que devuelve la API. **Aquí es donde podemos ver si hay datos de retrieval.**

### `Buscando citaciones en:`
El código intenta encontrar URLs en 3 lugares diferentes:
- `data.retrieval.retrieved_data` ← Principal
- `data.context.retrieved_data` ← Alternativo
- `data.citations` ← Si lo anterior no existe

### `✓ Encontrado en data.retrieval.retrieved_data`
Significa que SÍ encontró las URLs. Si ves esto, las citaciones deberían funcionar.

### `Mapeado C1 → https://www.boe.es/...`
Asoció la citación `[C1]` con una URL específica.

### `Procesando [C1]: url = ...`
Está convertiendo `[C1]` a un enlace HTML.

## ❌ Si NO Ves Logging

Si presionas F12 y **no ves nada de esto**, significa:
1. La página no se actualizó
2. El JavaScript no se ejecutó
3. Hay un error de conexión

**Solución:** Presiona **Ctrl + Shift + R** (reload sin cache) en la página.

## 🐛 Errores Comunes

### Error 1: "data.retrieval is undefined"
```
Buscando citaciones en:
  - data.retrieval: undefined
  - data.citations: []
✗ No se encontraron datos de recuperación
```

**Significa:** La API devolvió una respuesta, pero sin datos de retrieval. Probablemente la pregunta no generó contexto relevante.

**Solución:** Intenta con preguntas más específicas.

### Error 2: "No se encontraron datos de recuperación"
La respuesta llegó, pero está vacía.

**Solución:** Comprueba la pregunta o reinicia.

### Error 3: "[C1] pero url = NO ENCONTRADA"
```
Procesando [C1]: url = NO ENCONTRADA
```

La respuesta tiene `[C1]` pero el mapeo está vacío.

**Significa:** El retrieval_data no tiene suficientes elementos para C1.

## 📋 Copiar Logs

Para compartir los logs conmigo:

1. En la consola, selecciona todo
2. **Ctrl + C** para copiar
3. Envía los logs

O toma una captura de pantalla de la consola.

## 🔗 Prueba Directa de API

Si quieres probar la API directamente (sin el navegador):

### PowerShell:
```powershell
$body = @{ messages = @(@{ role="user"; content="Hola" }) } | ConvertTo-Json -Compress

$response = Invoke-RestMethod `
  -Uri "https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/api/v1/chat/completions" `
  -Method POST `
  -Headers @{
    "Authorization" = "Bearer XUud8PiXyP3rlDiEtGEwJylKwIKdWwpt"
    "Content-Type" = "application/json"
  } `
  -Body $body

# Ver si hay retrieval_data
$response.retrieval.retrieved_data | Select-Object -First 3 | Format-Table
```

## ✅ Si TODO Funciona

Deberías ver:
1. ✓ Respuesta completa en console.log
2. ✓ `Encontrado en data.retrieval.retrieved_data`
3. ✓ `Mapeado C1 →`, `Mapeado C2 →`, etc.
4. ✓ En el chat, los `[C1]`, `[C2]` aparecen en azul y son clickeables

---

## Siguiente Paso

Una vez que veas los logs, comparte conmigo:
1. **¿Aparece `Encontrado en...` ?** (Sí/No/Otro)
2. **¿Qué dice en `Mapeado`?** (Las URLs están ahí)
3. **¿Los [C1][C2] son clickeables?** (Sí/No)

Así podré saber exactamente dónde está el problema. 🔍
