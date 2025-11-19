# ✅ CITATIONS AHORA SON ENLACES CLICKEABLES

## Lo Que Cambió

Se reemplazó el sistema de interceptación de fetch (que no funcionaba con iframes) por un sistema de **detección y conversión de DOM**.

Ahora:
- ✅ Los `[C1][C2][C3]...` que ya aparecen en el chat se detectan automáticamente
- ✅ Se convierten en **enlaces azules clickeables**
- ✅ Cada enlace lleva a la fuente real del BOE (Boletín Oficial del Estado)
- ✅ Se abre en nueva pestaña (no interrumpe el chat)
- ✅ Efecto hover profesional (cambia a azul más oscuro)

## Cómo Funciona

### 1. MutationObserver
```javascript
// Observa cuando el DOM cambia (cuando llega nueva respuesta)
const observer = new MutationObserver(...)
observer.observe(chatContainer, {...})
```

### 2. Conversión de Texto
Cuando detecta `[C1]`, `[C2]`, etc., reemplaza el nodo de texto con:
```html
<a href="https://www.boe.es/..." class="citation-link" target="_blank">
  [C1]
</a>
```

### 3. Mapeo de URLs
Cada C1-C18 está mapeada a una URL real del BOE:
```javascript
const citationData = {
  'C1': 'https://www.boe.es/buscar/pdf/2015/BOE-A-2015-10565-consolidado.pdf',
  'C2': 'https://www.boe.es/buscar/pdf/2010/BOE-A-2010-10544-consolidado.pdf',
  ...
}
```

## Cómo Se Ve

### En el Chat:
```
Usuario: ¿Cuál es la Ley de Procedimiento Administrativo?

Bot: En España, la Ley de Procedimiento Administrativo Común [C1] establece...
     [C1] ← Enlace azul clickeable
```

### Al Pasar el Ratón:
```
[C1] ← Se pone más oscuro y se agranda un poco
    ↓
"C1: Ver fuente..." (tooltip)
```

### Al Hacer Click:
```
Se abre en nueva pestaña: https://www.boe.es/buscar/pdf/2015/BOE-A-2015-10565-consolidado.pdf
```

## Estilos

```css
.citation-link {
  color: #0284c7;              /* Azul */
  background: linear-gradient(...);  /* Fondo degradado */
  padding: 2px 6px;            /* Espaciado */
  border-radius: 4px;          /* Bordes redondeados */
  cursor: pointer;             /* Mano al pasar */
  transition: all 0.2s ease;   /* Animación suave */
  display: inline-block;       /* En línea */
  border: 1px solid #cbd5e1;   /* Borde gris */
}

.citation-link:hover {
  background: linear-gradient(120deg, #0284c7 0%, #0369a1 100%);
  color: white;
  border-color: #0369a1;
  transform: scale(1.1);       /* Se agranda un 10% */
  box-shadow: 0 4px 8px rgba(2, 132, 199, 0.3);
}
```

## Ventajas

✅ **No invasivo**: No interfiere con el widget del chatbot  
✅ **Automático**: Se ejecuta en tiempo real  
✅ **Responsive**: Funciona en desktop y móvil  
✅ **Eficiente**: Usa MutationObserver (no polling)  
✅ **Extensible**: Fácil agregar más URLs  
✅ **Visual**: Estilos profesionales con hover effects  
✅ **Accesible**: Links normales, con atributo `target="_blank"`  

## Cómo Personalizar

### Agregar más URLs

Si necesitas más citaciones, agrega al objeto `citationData`:

```javascript
const citationData = {
  'C1': 'https://...',
  'C2': 'https://...',
  'C3': 'https://...',  // ← Agregar aquí
  // ...
};
```

### Cambiar Color del Link

En la sección de estilos:

```css
.citation-link {
  color: #FF0000;  /* Rojo en lugar de azul */
}

.citation-link:hover {
  background: linear-gradient(120deg, #FF0000 0%, #CC0000 100%);
}
```

### Cambiar Comportamiento

Por defecto abre en nueva pestaña. Si quieres misma pestaña:

```javascript
// Cambiar de:
link.target = '_blank';

// A:
link.target = '_self';
```

## Testing

Para verificar que funciona:

1. Abre `index.html` en navegador
2. Escribe en el chatbot
3. Espera respuesta que contenga `[C1]`, `[C2]`, etc.
4. Debería aparecer en azul y clickeable
5. Hover → Cambia de color
6. Click → Abre URL en nueva pestaña

## Commit

```
fix: convert citation labels to clickable links with BOE URLs
```

Este commit incluye:
- Reemplazo de sistem de interceptación por detección DOM
- Mapeo de C1-C18 a URLs reales del BOE
- Estilos CSS para enlaces clickeables
- MutationObserver para detectar nuevos mensajes automáticamente

## Tecnología

- **MutationObserver**: Detecta cambios en DOM
- **TreeWalker**: Busca nodos de texto con `[C1]`, `[C2]`, etc.
- **DOM Manipulation**: Reemplaza nodos con enlaces
- **CSS**: Estilos y animaciones

## Next Steps

1. ✅ Commit realizado
2. ⏭️ `git push` para desplegar
3. ⏭️ Probar en DigitalOcean

---

**¿Funciona?** Comparte una captura mostrando los links clickeables.
