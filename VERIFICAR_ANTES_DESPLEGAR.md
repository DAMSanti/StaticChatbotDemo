# ✅ CHECKLIST ANTES DE DESPLEGAR

## 1. Verificar Cambios Locales

```powershell
# Ver qué cambió
git status

# Ver diferencias
git diff index.html
```

Expected: index.html tiene el nuevo script de interceptación.

## 2. Probar Localmente (Opcional pero Recomendado)

Si tienes un servidor local:

```powershell
# Opción 1: Python
python -m http.server 8000

# Opción 2: Node.js
npx http-server

# Opción 3: VS Code Live Server
# Click derecho en index.html → Open with Live Server
```

Luego abre: `http://localhost:8000`

**Qué verificar:**
- [ ] El chatbot widget carga correctamente
- [ ] Escribo una pregunta
- [ ] Aparece respuesta del chatbot
- [ ] En la esquina inferior derecha aparece el panel con "📚 Fuentes de Información"
- [ ] El panel tiene links clickeables
- [ ] Los links abren en nueva ventana

## 3. Verificar el Commit

```powershell
git log --oneline -5
```

Expected: Ver "feat: add citations display panel with URLs enrichment"

## 4. Desplegar a Producción

### Opción A: Automático (Recomendado)

```powershell
git push
```

DigitalOcean detectará el push y redeploy automáticamente en 2-3 minutos.

### Opción B: Manual

1. Ve a DigitalOcean Control Panel
2. App Platform → Tu app
3. Click en "Deploy"
4. Selecciona el commit más reciente
5. Click "Deploy"

## 5. Verificar en Producción

Una vez desplegado (espera 3-5 minutos):

1. Abre: https://webasistente-l9ise.ondigitalocean.app
2. Prueba el chatbot
3. Verifica que aparezca el panel de citations

## 6. Troubleshooting

### Si el panel NO aparece:
- Abre DevTools (F12) → Console
- Busca logs que empiezan con "[Citations Enricher]"
- Si no hay logs, el script no se ejecutó

**Soluciones:**
1. Refresca la página (Ctrl+F5)
2. Abre en incógnito (por si hay caché)
3. Comprueba que escribas en el chatbot y esperes respuesta

### Si aparece pero sin URLs:
- Los datos de retrieval no tienen URLs
- Esto es responsabilidad del agente

### Si hay errores en Console:
- Copia el error exacto
- Verifica que index.html se modificó correctamente

## 7. Rollback (Si es necesario)

Si algo sale mal:

```powershell
# Revertir al commit anterior
git revert HEAD

# O simplemente descargar el commit anterior en producción
git push
# (En DO, selecciona el commit anterior)
```

## 8. Estado Final

✅ **Commits**: 1 nuevo commit con los cambios
✅ **Archivos**: index.html modificado
✅ **Panel**: Visible en la web con citations
✅ **URLs**: Clickeables y funcionales
✅ **Deployed**: En DigitalOcean

---

## ¿Preguntas?

Si algo no funciona:
1. Lee PROYECTO_COMPLETADO.txt
2. Lee CITATIONS_VISIBLE.md
3. Abre DevTools y revisa la consola
4. Comparte el error exacto
