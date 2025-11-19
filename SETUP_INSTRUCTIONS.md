#!/usr/bin/env pwsh
# 
# ╔════════════════════════════════════════════════════════╗
# ║     SOLUCIÓN: Mostrar Citations en el Chatbot         ║
# ║            DigitalOcean Gradient + React              ║
# ╚════════════════════════════════════════════════════════╝
#
# ARCHIVOS ENTREGADOS:
# ────────────────────────────────────────────────────────
#
# 📂 scripts/
#   ├─ test-agent-connection.ps1       Valida conectividad (2 min)
#   ├─ get-agent-citations.ps1         Extrae citations del agent (1 min)
#   ├─ enrich-citations-with-urls.js   Enriquece con URLs (1 min)
#   ├─ citations-mapper.ts             Funciones TypeScript para React
#   └─ run-citations-workflow.ps1       EJECUTAR ESTO (orquesta todo)
#
# 📄 Documentación:
#   ├─ QUICK_START.md                  Guía de 5 pasos (EMPIEZA AQUÍ)
#   ├─ CITATIONS_GUIDE.md              Guía completa + troubleshooting
#   ├─ PROYECTO_STATUS.md              Estado y checklist
#   └─ SETUP_INSTRUCTIONS.md           Este archivo
#
# ────────────────────────────────────────────────────────
# CÓMO EMPEZAR (30 SEGUNDOS):
# ────────────────────────────────────────────────────────
#
# OPCIÓN A: EJECUTAR TODO AUTOMÁTICO
#   1. Abre PowerShell en el root del proyecto
#   2. $Env:AGENT_URL = "https://tu-agent-url"
#   3. $Env:AGENT_TOKEN = "tu_token"  (o déjalo vacío si es público)
#   4. .\scripts\run-citations-workflow.ps1
#   → Genera automáticamente agent_response_with_urls.json
#
# OPCIÓN B: PASO A PASO MANUAL
#   1. .\scripts\test-agent-connection.ps1      # Valida
#   2. .\scripts\get-agent-citations.ps1        # Extrae
#   3. node .\scripts\enrich-citations-with-urls.js  # Enriquece
#   → Verifica el JSON en agent_response_with_urls.json
#
# ────────────────────────────────────────────────────────
# INTEGRAR EN TU REACT (5 MIN):
# ────────────────────────────────────────────────────────
#
# 1. Importa en AgentDetailPlayground.tsx:
#    import { enrichCitationsWithUrls, citationsToLinks } from '../scripts/citations-mapper';
#
# 2. En handleNewMessages(), cuando recibas el chunk final (isLast === true):
#    if (json?.citations?.length > 0) {
#      const enriched = enrichCitationsWithUrls(json.citations, json.retrieval?.retrieved_data ?? []);
#      const links = citationsToLinks(enriched);
#      if (message && links.length > 0) {
#        message.links = [...(message.links || []), ...links];
#      }
#    }
#
# 3. Renderiza los links en tu componente:
#    {message.links?.length > 0 && (
#      <div className="message-links">
#        <strong>📚 Sources:</strong>
#        <ul>
#          {message.links.map((link, i) => (
#            <li key={i}>
#              <a href={link.url} target="_blank" rel="noopener noreferrer">
#                {link.text}
#              </a>
#            </li>
#          ))}
#        </ul>
#      </div>
#    )}
#
# ────────────────────────────────────────────────────────
# VERIFICACIÓN:
# ────────────────────────────────────────────────────────
#
# Local (desarrollo):
#   npm start
#   → Genera una pregunta en el chatbot
#   → Verifica que abajo aparecen enlaces clicables
#
# Producción (GitHub + DigitalOcean):
#   git add .
#   git commit -m "feat: add citations support"
#   git push
#   → DigitalOcean redeploy automático
#   → Verifica en tu app URL
#
# ────────────────────────────────────────────────────────
# SI ALGO FALLA:
# ────────────────────────────────────────────────────────
#
# "No hay URLs en las citations"
#   → Ver CITATIONS_GUIDE.md → Solución de problemas
#   → Opciones: Spaces + CDN o pedir al proveedor URLs
#
# "Error 401 (Unauthorized)"
#   → Verifica que $Env:AGENT_TOKEN sea válido
#   → Si agent es público: $Env:AGENT_TOKEN = ""
#
# "Los links no aparecen en la UI"
#   → Asegúrate de que tu componente renderiza message.links
#   → Ver paso 3 arriba
#
# ────────────────────────────────────────────────────────
# REFERENCIAS:
# ────────────────────────────────────────────────────────
#
# • QUICK_START.md       ← Guía copiar/pegar (EMPIEZA AQUÍ)
# • CITATIONS_GUIDE.md   ← Detalles + troubleshooting
# • PROYECTO_STATUS.md   ← Checklist y estado del proyecto
#
# ────────────────────────────────────────────────────────
# ESTRUCTURA DEL JSON GENERADO:
# ────────────────────────────────────────────────────────
#
# agent_response_with_urls.json:
# {
#   "citations": [
#     {
#       "text": "ejemplo de citation",
#       "filename": "document.pdf",
#       "metadata": {
#         "url": "https://bucket.example.com/document.pdf"   ← LO IMPORTANTE
#       }
#     },
#     ...
#   ],
#   "retrieval": {
#     "retrieved_data": [
#       {
#         "filename": "https://...",
#         "content": "...",
#         ...
#       }
#     ]
#   }
# }
#
# El cliente mapea cada citation.metadata.url → message.links[]
#
# ────────────────────────────────────────────────────────
# DIAGRAMA DEL FLUJO:
# ────────────────────────────────────────────────────────
#
#   Agent (DigitalOcean)
#           ↓
#   [get-agent-citations.ps1]
#           ↓
#   agent_response_complete.json (raw)
#           ↓
#   [enrich-citations-with-urls.js]
#           ↓
#   agent_response_with_urls.json (enriquecido con URLs)
#           ↓
#   [citations-mapper.ts]
#   (funciones TypeScript para React)
#           ↓
#   AgentDetailPlayground.tsx
#   (integrar en handleNewMessages)
#           ↓
#   message.links[] → UI renderiza enlaces clicables
#           ↓
#   Usuario ve: "📚 Sources: [link1] [link2] [link3]"
#
# ────────────────────────────────────────────────────────
# PRÓXIMOS PASOS OPCIONALES:
# ────────────────────────────────────────────────────────
#
# □ Si URLs faltan:
#   - Subir PDFs a DigitalOcean Spaces
#   - Crear CDN endpoint para servir con velocidad
#   - Actualizar pipeline retrieval para devolver URLs públicas
#
# □ Si requieres cambios en el server:
#   - Usar template de ticket en CITATIONS_GUIDE.md
#   - Pedir al proveedor que devuelva metadata.url
#
# ────────────────────────────────────────────────────────
# VERSIÓN: 1.0
# FECHA: 2025-11-19
# PLATAFORMA: DigitalOcean Gradient + App Platform
# ────────────────────────────────────────────────────────
