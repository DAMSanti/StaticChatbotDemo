# ⚖️ Abogado Virtual - Chat Personalizado

**Chat inteligente de consultas legales con citaciones clickeables hacia documentos del BOE.**

## ✨ Características

✅ **Chat personalizado** (sin widget externo)  
✅ **Llamadas directas a la API** del agente DigitalOcean  
✅ **Citaciones automáticas** como enlaces clickeables  
✅ **Responsive** (funciona en móvil, tablet, desktop)  
✅ **Historial de conversación** con contexto  
✅ **UI moderna** con gradientes y animaciones  
✅ **Fuentes legales reales** del Boletín Oficial del Estado (BOE)

## 🚀 Quick Start

### Local (Windows - PowerShell)

```powershell
# Abre PowerShell en la carpeta del proyecto
python -m http.server 8000

# Abre el navegador en:
# http://localhost:8000
```

### En Producción

El código ya está deployado en:  
👉 **https://webasistente-l9ise.ondigitalocean.app**


Solo abre la URL y empieza a hacer preguntas legales.

## 💬 Cómo Funciona

### 1. Usuario Escribe una Pregunta
```
"¿Cuál es la Ley de Procedimiento Administrativo?"
```

### 2. Frontend Envía a la API
```javascript
fetch('https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/api/v1/chat/completions', {
  method: 'POST',
  body: JSON.stringify({
    messages: [
      { role: 'user', content: '¿Cuál es la Ley de Procedimiento Administrativo?' }
    ]
  })
})
```

### 3. Agente Responde con Citaciones
```
"La Ley de Procedimiento Administrativo [C1] establece los principios..."
```

### 4. Frontend Detecta [C1], [C2]...
Busca en `retrieval.retrieved_data[]` las URLs correspondientes

### 5. Convierte a Enlaces Clickeables
```html
La Ley de Procedimiento Administrativo 
<a href="https://www.boe.es/buscar/pdf/2015/BOE-A-2015-10565-consolidado.pdf" 
   class="citation-link" target="_blank">[C1]</a> 
establece los principios...
```

### 6. Usuario Hace Click
Se abre el PDF del BOE en nueva pestaña 📄

## 🎨 Diseño de las Citaciones

Los enlaces de citaciones tienen:
- **Color**: Azul (`#0284c7`)
- **Fondo**: Degradado suave
- **Hover**: Se oscurece y agranda 5%
- **Click**: Se abre en nueva pestaña

```css
.citation-link {
  color: #0284c7;
  background: linear-gradient(120deg, #e0eaff 0%, #f0f4ff 100%);
  padding: 2px 6px;
  border-radius: 4px;
  transition: all 0.2s ease;
  cursor: pointer;
}

.citation-link:hover {
  background: linear-gradient(120deg, #0284c7 0%, #0369a1 100%);
  color: white;
  transform: scale(1.05);
}
```

## 📦 Estructura

```
index.html                      ← Todo el código
CITATIONS_CLICKEABLES.md        ← Docs del anterior widget (opcional)
README.md                       ← Este archivo
```

## 🔧 Configuración

Para cambiar el agente o credentials, edita en `index.html`:

```javascript
const API_URL = 'https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/api/v1/chat/completions';
const AGENT_ID = 'a141afdb-c01e-11f0-b074-4e013e2ddde4';
const ACCESS_TOKEN = 'XUud8PiXyP3rlDiEtGEwJylKwIKdWwpt';
```

## 📱 Responsive

- **Desktop**: Chat centrado (600px max)
- **Tablet**: Se adapta al ancho
- **Mobile**: Pantalla completa (100vh)

## 🛠️ Stack

- **Frontend**: HTML5 + CSS3 + JavaScript (vanilla, sin dependencias)
- **API**: DigitalOcean Gradient AI Platform
- **Fuentes**: Boletín Oficial del Estado (BOE)
- **Deploy**: DigitalOcean Apps Platform

## ✅ Testing

### Local
1. Abre `index.html` en navegador
2. El chat debería funcionar inmediatamente
3. Prueba: _"¿Qué es la LRJSP?"_
4. Verifica que aparezcan enlaces azules `[C1]`, `[C2]`, etc.

### Producción
1. Abre https://webasistente-l9ise.ondigitalocean.app
2. Espera a que el chat cargue
3. Haz una pregunta
4. Click en cualquier `[C#]` para ver el PDF

## 🐛 Debugging

Abre la consola del navegador (F12):

```javascript
// Si hay errores, verás en Console:
[citation-linker] Errores de conexión
[citation-linker] Response inesperada

// Si todo ok:
[citation-linker] Chat iniciado
[citation-linker] Citaciones detectadas: 3
```

### Test directo de la API (PowerShell)

```powershell
$response = Invoke-RestMethod `
  -Uri "https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/api/v1/chat/completions" `
  -Method POST `
  -Headers @{
    "Authorization" = "Bearer XUud8PiXyP3rlDiEtGEwJylKwIKdWwpt"
    "Content-Type" = "application/json"
  } `
  -Body (@{ messages = @(@{ role="user"; content="Hola" }) } | ConvertTo-Json)

$response.choices[0].message.content
```

## 📊 Ventajas vs Widget Original

| Aspecto | Widget Original | Chat Personalizado |
|---------|-----------------|-------------------|
| UI | Iframe externo | HTML + CSS propio |
| Citaciones | Ocultas | Automáticas y clickeables |
| Estilo | Fijo | Totalmente personalizable |
| Control | Limitado | Total |
| Mantenimiento | Depende del proveedor | Tuyo |
| Velocidad | Lenta (iframe) | Rápida (directo) |

## 🚀 Deploy a DigitalOcean

El repo ya está sincronizado. Los cambios se despliegan automáticamente:

```bash
git push origin master
# → DigitalOcean detecta el push
# → Redeploy automático en 2-3 minutos
# → https://webasistente-l9ise.ondigitalocean.app se actualiza
```

## 📝 Cambios Recientes

**Commit `0d20ac8`**: Reemplazo de widget por chat personalizado
- ✅ Removido widget externo
- ✅ Agregado chat con UI propia
- ✅ Llamadas directas a API
- ✅ Citaciones automáticas con enlaces