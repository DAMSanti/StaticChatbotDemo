# AbogadoVirtual Chatbot - Static Demo

Este repositorio contiene una página estática (`index.html`) que incluye dos opciones de chat:

- Un ejemplo de UI simple (en la propia página) que hace POST a un backend en `API_URL`.
- El widget de chatbot alojado por el proveedor (script externo) que aparece como botón flotante.

Detalles del widget incluido:

- Chatbot ID: `IurFFh0JbzeH7PLauKvv7WKGaCJb5F6L`
- Script cargado desde: `https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/static/chatbot/widget.js`

## Archivos añadidos

- `index.html` — Página principal (actualizada para incluir el widget).
- `static/chatbot/icons/default-agent.svg` — Icono usado por el widget (placeholder).

## Probar localmente (Windows - PowerShell)

1. Abre PowerShell en la carpeta del proyecto (donde está `index.html`).
2. Si tienes Python 3 instalado, ejecuta:

```powershell
python -m http.server 8000
```

3. Abre tu navegador en `http://localhost:8000` y verifica que la página carga y que el widget aparece (botón flotante). El widget se carga desde un proveedor externo, así que puede tardar unos segundos.

Nota: la página también contiene un cliente simple que realiza POST a la variable `API_URL` dentro del script; si quieres usar esa UI, actualiza `API_URL` en `index.html` a tu backend y asegúrate de habilitar CORS en el backend.

## Despliegue en DigitalOcean

Opción 1 — App Platform (Static Site):

1. Empuja tu repo a GitHub/GitLab/Bitbucket.
2. En DigitalOcean App Platform, crea una nueva App y elige "Static Site".
3. Conecta el repositorio y la rama. No necesitas build commands (salvo que añadas assets que requieran build).
4. Indica la carpeta raíz (por ejemplo `/` si `index.html` está en la raíz).
5. Despliega. La App Platform servirá la página estática.

Opción 2 — Droplet + Nginx:

1. Crea un Droplet (Ubuntu).
2. Sube los archivos al servidor (scp, rsync o git clone).
3. Instala Nginx:

```bash
sudo apt update; sudo apt install -y nginx
```

4. Copia los archivos a `/var/www/tu_sitio` y configura un server block en Nginx apuntando al `root /var/www/tu_sitio;`.
5. Reinicia Nginx:

```bash
sudo systemctl restart nginx
```

6. (Opcional) Configura un dominio y SSL con Certbot.

## Notas y seguridad

- El widget se carga desde un dominio externo y puede requerir que aceptes la política del proveedor.
- Si tu backend requiere autenticación o tiene CORS, ajusta la configuración en el servidor.
- Reemplaza `data-starting-message` y colores en el script del widget según prefieras.

---

Si quieres, puedo:

- Añadir un pequeño archivo `nginx.conf` de ejemplo.
- Añadir un `dockerfile` para servir el sitio desde un contenedor.
- Automatizar el despliegue hacia DigitalOcean usando `doctl`.

Dime cuál prefieres y lo preparo.