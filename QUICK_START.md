# Quick Start: Mostrar Citations en 5 Pasos

## TL;DR
Ejecuta tres comandos para extraer citations del agent, enriquecer con URLs y generar el patch para tu cliente React.

---

## Comando 1: Configurar variables (PowerShell)
```powershell
$Env:AGENT_URL = "https://webasistente-l9ise.ondigitalocean.app"  # Cambia si es necesario
$Env:AGENT_TOKEN = "TU_BEARER_TOKEN_AQUI"                         # Obtén del agent/GenAI
```

## Comando 2: Extraer citations del agent
```powershell
cd C:\Users\santiagota\source\repos\StaticChatbotDemo
.\scripts\get-agent-citations.ps1
```
✓ Genera: `agent_response_complete.json`

## Comando 3: Enriquecer con URLs
```powershell
node .\scripts\enrich-citations-with-urls.js
```
✓ Genera: `agent_response_with_urls.json`

---

## Paso 4: Integrar en React
Abre tu archivo `AgentDetailPlayground.tsx` y añade en `handleNewMessages()`:

```typescript
import { enrichCitationsWithUrls, citationsToLinks } from '../scripts/citations-mapper';

// ... dentro de handleNewMessages, cuando isLast === true:
if (json?.citations?.length > 0) {
  const enriched = enrichCitationsWithUrls(json.citations, json.retrieval?.retrieved_data ?? []);
  const links = citationsToLinks(enriched);
  if (message && links.length > 0) {
    message.links = [...(message.links || []), ...links];
  }
}
```

## Paso 5: Renderizar en UI
Asegúrate de que tu componente renderiza `message.links`:

```jsx
{message.links?.length > 0 && (
  <div className="message-links">
    <strong>📚 Sources:</strong>
    <ul>
      {message.links.map((link, i) => (
        <li key={i}>
          <a href={link.url} target="_blank" rel="noopener noreferrer">
            {link.text}
          </a>
        </li>
      ))}
    </ul>
  </div>
)}
```

---

## Archivos Generados
- `scripts/get-agent-citations.ps1` — extrae citations via API
- `scripts/enrich-citations-with-urls.js` — enriquece con URLs
- `scripts/citations-mapper.ts` — funciones TypeScript para el cliente
- `CITATIONS_GUIDE.md` — guía completa con troubleshooting
- `QUICK_START.md` — este archivo

---

## Troubleshooting

| Problema | Solución |
|----------|----------|
| No hay URLs en citations | Los PDFs deben estar en un Space público o el agent debe devolver URLs. Ver CITATIONS_GUIDE.md "Solución de problemas". |
| Error 401 en PowerShell | Verifica que `$Env:AGENT_TOKEN` sea válido. Si es público, deja vacío: `$Env:AGENT_TOKEN = ""` |
| Node.js no encontrado | Instala Node.js: https://nodejs.org/ |
| Links no aparecen en UI | Asegúrate de que tu componente renderiza `message.links`. Ver paso 5 arriba. |

---

## Siguientes pasos
1. ✓ Ejecuta comandos 1–3 arriba
2. ✓ Revisa `agent_response_with_urls.json` para confirmar que citations tienen URLs
3. ✓ Integra el patch en React (paso 4)
4. ✓ Prueba localmente (npm start)
5. ✓ Commit + push a GitHub
6. ✓ DigitalOcean redeploy automático

---

**Más detalles:** ver `CITATIONS_GUIDE.md`
