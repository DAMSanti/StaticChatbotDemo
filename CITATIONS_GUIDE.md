# Guía: Mostrar Citations en el Chatbot

## Resumen del proceso
Este flujo extrae las citations del agente DigitalOcean Gradient y las convierte en enlaces clicables en la UI.

---

## Paso 1: Obtener token y URL del agent

### 1.1 Obtener la URL del agent
Tu agent URL es algo como:
```
https://webasistente-l9ise.ondigitalocean.app
```
(Cambia por la URL real de tu despliegue en DO App Platform)

### 1.2 Obtener el Bearer Token
Necesitas un token con permisos para llamar a `/api/v1/chat/completions`.

**Opciones:**
- Si tu agent es público o no requiere auth: usa un token vacío (sin Bearer).
- Si requiere auth: obtén el token desde:
  - Cloud Console → GenAI → Agent settings → API keys, o
  - Desde la plataforma que corre el agent.

---

## Paso 2: Llamar al agent y extraer citations (PowerShell)

### 2.1 Configura las variables
Abre PowerShell y ejecuta:

```powershell
# Reemplaza con tu URL y token
$Env:AGENT_URL = "https://webasistente-l9ise.ondigitalocean.app"
$Env:AGENT_TOKEN = "tu_bearer_token_aqui"

# (Si no requiere token, deja vacío: "")
```

### 2.2 Ejecuta el script PowerShell
```powershell
cd C:\Users\santiagota\source\repos\StaticChatbotDemo

.\scripts\get-agent-citations.ps1
```

**Qué hace:**
- Llama al agent con `provide_citations=true` y `stream=false`
- Guarda la respuesta completa en `agent_response_complete.json`
- Muestra en consola los campos `retrieval` y `citations`

**Resultado esperado:**
- Archivo `agent_response_complete.json` con la estructura JSON completa
- En la consola ves `[RETRIEVAL]` y `[CITATIONS]` con los datos

---

## Paso 3: Enriquecer citations con URLs (Node.js)

### 3.1 Verifica que Node.js esté disponible
```powershell
node --version
```

### 3.2 Ejecuta el script de enriquecimiento
```powershell
node .\scripts\enrich-citations-with-urls.js
```

**Qué hace:**
- Lee `agent_response_complete.json`
- Busca URLs en `retrieval.retrieved_data[]`
- Mapea cada citation con su URL correspondiente
- Guarda en `agent_response_with_urls.json` con `citation.metadata.url` enriquecido

**Resultado esperado:**
- Archivo `agent_response_with_urls.json` donde cada citation tiene `metadata.url`
- En consola ves qué citations se enriquecieron y cuáles no

---

## Paso 4: Integrar el patch en el cliente React/TypeScript

**Ubicación:** archivo `AgentDetailPlayground.tsx` (tu componente React)

### 4.1 Importar las funciones
Al inicio del archivo, añade:
```typescript
import { enrichCitationsWithUrls, citationsToLinks } from '../scripts/citations-mapper';
```

### 4.2 Ubicar la función handleNewMessages
Busca la función `handleNewMessages` donde procesas los chunks SSE/streaming.

### 4.3 Insertar el código de enriquecimiento
Después de parsear el JSON final (cuando `isLast === true` o similar), añade:

```typescript
// Enriquecer citations con URLs
if (isLast && json?.citations?.length > 0) {
  const retrieved = json.retrieval?.retrieved_data ?? [];
  const citations = json.citations ?? [];
  
  const enrichedCitations = enrichCitationsWithUrls(citations, retrieved);
  const links = citationsToLinks(enrichedCitations);
  
  // Añadir links al mensaje actual
  if (message && links.length > 0) {
    message.links = [...(message.links || []), ...links];
  }
}
```

### 4.4 Renderizar los links en la UI
En tu componente de mensaje, asegúrate de renderizar `message.links`:

```jsx
{message.links && message.links.length > 0 && (
  <div className="message-links" style={{ marginTop: '8px' }}>
    <strong>📚 Sources:</strong>
    <ul style={{ margin: '4px 0', paddingLeft: '20px' }}>
      {message.links.map((link, i) => (
        <li key={i}>
          <a 
            href={link.url} 
            target="_blank" 
            rel="noopener noreferrer"
            style={{ color: '#0284c7', textDecoration: 'underline' }}
          >
            {link.text}
          </a>
        </li>
      ))}
    </ul>
  </div>
)}
```

---

## Paso 5: Probar el flujo completo

### 5.1 Local (en desarrollo)
1. Ejecuta los scripts (pasos 2–3) para validar que las citations contienen URLs.
2. Integra el patch en tu código React.
3. Inicia tu servidor de desarrollo (npm start / yarn dev).
4. Genera una respuesta en el chatbot → verifica que abajo aparecen los enlaces clicables.

### 5.2 En producción (GitHub + DigitalOcean App Platform)
1. Commit y push de los cambios a GitHub.
2. DigitalOcean redeploy automático.
3. Accede a tu app en DigitalOcean App Platform URL.
4. Prueba la respuesta del chatbot → verifica links.

---

## Solución de problemas

### Problema: No hay URLs en las citations
**Causa:** El agent no devuelve URLs en `retrieval.retrieved_data.filename` ni en `citation.metadata.url`.

**Soluciones:**
1. Subir los PDFs/archivos a DigitalOcean Spaces y actualizar la pipeline de retrieval para usar URLs públicas (`https://bucket.digitaloceanspaces.com/file.pdf`).
2. Pedir al equipo del agent que añada `metadata.url` a cada citation (o que devuelva `retrieval.retrieved_data[].filename` con URL pública).
3. Crear un proxy que reescriba filenames → URLs públicas antes de devolverlas al cliente.

### Problema: El script PowerShell da error de autorización (401)
**Causa:** Token inválido o expirado.

**Solución:**
- Verifica que el token sea válido y tenga permisos para `/api/v1/chat/completions`.
- Si es bearer token, asegúrate de que está en formato correcto.

### Problema: Los links aparecen pero no son clickeables
**Causa:** URL no válida (no empieza con `http://` o `https://`).

**Solución:**
- Revisa `agent_response_with_urls.json` → verifica que `citation.metadata.url` sea una URL completa y válida.
- Valida URLs en TypeScript antes de renderizar:
  ```typescript
  const isValidUrl = (url: string) => /^https?:\/\//.test(url);
  ```

---

## Archivos generados

- `agent_response_complete.json` — respuesta completa del agent (para inspección/debugging)
- `agent_response_with_urls.json` — respuesta enriquecida con URLs en citations (referencia para el cliente)
- `citations-mapper.ts` — funciones TypeScript reutilizables para enriquecer y mapear citations
- Este archivo README.md

---

## Próximos pasos

1. **Ejecuta los scripts** (pasos 2–3) para validar que el agent devuelve citations con URLs.
2. **Integra el patch** en tu código React (paso 4).
3. **Prueba localmente** (paso 5.1) antes de deployar.
4. **Deploya** a GitHub + DigitalOcean (paso 5.2).
5. Si faltan URLs, usa una de las **soluciones de troubleshooting** arriba.

---

## Referencias

- [DigitalOcean Gradient Platform Documentation](https://docs.digitalocean.com/products/genai/)
- [KB Citations & Retrieval](https://docs.digitalocean.com/reference/api/digitalocean/#tag/GradientAI-Platform)
- [DigitalOcean Spaces (almacenar PDFs)](https://docs.digitalocean.com/products/spaces/)
- [DigitalOcean CDN (servir con velocidad)](https://docs.digitalocean.com/products/cdn/)
