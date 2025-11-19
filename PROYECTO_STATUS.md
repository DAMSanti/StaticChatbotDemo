# 📊 Estado del Proyecto: Mostrar Citations

## ✅ Completado

### 1. Scripts PowerShell
- **`scripts/test-agent-connection.ps1`** — Valida conectividad y token (sin hacer petición de chat)
- **`scripts/get-agent-citations.ps1`** — Extrae citations del agent y guarda en JSON
- **Uso:**
  ```powershell
  $Env:AGENT_URL = "https://tu-agent-url"
  $Env:AGENT_TOKEN = "tu_token"
  
  .\scripts\test-agent-connection.ps1    # Test primero
  .\scripts\get-agent-citations.ps1      # Luego extrae
  ```

### 2. Script Node.js
- **`scripts/enrich-citations-with-urls.js`** — Lee JSON del agent, enriquece citations con URLs, exporta resultado
- **Uso:**
  ```powershell
  node .\scripts\enrich-citations-with-urls.js
  ```

### 3. Código TypeScript/React Reutilizable
- **`scripts/citations-mapper.ts`** — Funciones para mapear citations → message.links
  - `enrichCitationsWithUrls()` — Enriquece citations con URLs desde retrieved_data
  - `citationsToLinks()` — Convierte citations a formato de links para UI
  - Completamente tipado (TypeScript)
  - Incluye documentación inline

### 4. Documentación
- **`QUICK_START.md`** — Guía de 5 pasos (comando a comando, copiar/pegar)
- **`CITATIONS_GUIDE.md`** — Guía completa con explicaciones y troubleshooting
- **`PROYECTO_STATUS.md`** — Este archivo

---

## 📝 Pasos para usar (en orden)

### Fase 1: Validación (5 min)
```powershell
cd C:\Users\santiagota\source\repos\StaticChatbotDemo

# 1. Configura variables
$Env:AGENT_URL = "https://webasistente-l9ise.ondigitalocean.app"
$Env:AGENT_TOKEN = "TU_BEARER_TOKEN"  # O déjalo vacío si es público

# 2. Prueba conexión
.\scripts\test-agent-connection.ps1
# ✓ Si todo funciona, verás checkmarks verdes
```

### Fase 2: Extracción (2 min)
```powershell
# 3. Extrae citations del agent
.\scripts\get-agent-citations.ps1
# ✓ Genera: agent_response_complete.json
# ✓ Muestra en consola: [RETRIEVAL] y [CITATIONS]
```

### Fase 3: Enriquecimiento (1 min)
```powershell
# 4. Enriquece citations con URLs
node .\scripts\enrich-citations-with-urls.js
# ✓ Genera: agent_response_with_urls.json
# ✓ Muestra en consola: Citations enriquecidas
```

### Fase 4: Integración (10 min — React)
1. Abre tu archivo `AgentDetailPlayground.tsx`
2. Importa las funciones:
   ```typescript
   import { enrichCitationsWithUrls, citationsToLinks } from '../scripts/citations-mapper';
   ```
3. En `handleNewMessages()`, cuando se reciba el chunk final, enriquece:
   ```typescript
   if (json?.citations?.length > 0) {
     const enriched = enrichCitationsWithUrls(json.citations, json.retrieval?.retrieved_data ?? []);
     const links = citationsToLinks(enriched);
     if (message && links.length > 0) {
       message.links = [...(message.links || []), ...links];
     }
   }
   ```
4. En tu componente de mensaje, renderiza los links (ejemplo en `QUICK_START.md`)

### Fase 5: Verificación (1 min)
```powershell
# En desarrollo:
npm start
# Genera una respuesta en el chatbot → verifica que aparecen enlaces abajo

# En producción:
git add .
git commit -m "feat: add citations support"
git push
# DigitalOcean redeploy automático
```

---

## 🎯 Resultado Final
Cuando termines, tu chatbot mostrará:
```
[Respuesta del agent]

📚 Sources:
- document1.pdf (clickeable → abre PDF)
- document2.html (clickeable → abre página)
- ...
```

---

## 📋 Checklist
- [ ] Ejecuté `test-agent-connection.ps1` y pasó ✓
- [ ] Ejecuté `get-agent-citations.ps1` y generó JSON ✓
- [ ] Ejecuté `enrich-citations-with-urls.js` y enriqueció URLs ✓
- [ ] Integré el patch en `AgentDetailPlayground.tsx` ✓
- [ ] Rendericé `message.links` en el componente de mensaje ✓
- [ ] Probé localmente y vi los links ✓
- [ ] Hice commit y push a GitHub ✓
- [ ] Verifiqué que DigitalOcean hizo redeploy ✓

---

## 🆘 Si algo falla

### No hay URLs en citations
→ Ver `CITATIONS_GUIDE.md` → "Solución de problemas" → "No hay URLs"

### Error 401 (Unauthorized)
→ Verifica token. Si es público: `$Env:AGENT_TOKEN = ""`

### Los links no aparecen en la UI
→ Asegúrate de renderizar `message.links` en el componente (ver QUICK_START.md paso 5)

### Node.js no encontrado
→ Instala: https://nodejs.org/

---

## 📂 Estructura de archivos
```
StaticChatbotDemo/
├── index.html
├── QUICK_START.md                 ← Guía 5 pasos
├── CITATIONS_GUIDE.md             ← Guía completa + troubleshooting
├── PROYECTO_STATUS.md             ← Este archivo
├── scripts/
│   ├── test-agent-connection.ps1  ← Valida conexión
│   ├── get-agent-citations.ps1    ← Extrae citations
│   ├── enrich-citations-with-urls.js ← Enriquece con URLs
│   └── citations-mapper.ts        ← Funciones TypeScript para React
├── agent_response_complete.json   ← Generado por get-agent-citations.ps1
└── agent_response_with_urls.json  ← Generado por enrich-citations-with-urls.js
```

---

## 🚀 Próximos pasos opcionales

1. **Subir PDFs a Spaces** (si faltan URLs)
   → `CITATIONS_GUIDE.md` → "Solución de problemas" → "Subir a Spaces"

2. **Crear CDN endpoint** (para servir PDFs con velocidad)
   → `CITATIONS_GUIDE.md` → "CDN"

3. **Pedir al proveedor que devuelva URLs** (request formal)
   → Usar template en `CITATIONS_GUIDE.md` → "Preparar ticket al proveedor"

---

**Última actualización:** 2025-11-19
**Archivos ejecutables:** PowerShell + Node.js
**Plataforma:** DigitalOcean Gradient + App Platform
