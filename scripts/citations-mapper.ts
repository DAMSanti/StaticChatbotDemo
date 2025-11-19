/**
 * Snippet TypeScript/React: Mapear Citations a Message Links
 * 
 * Ubicación recomendada: en AgentDetailPlayground.tsx, dentro de handleNewMessages()
 * justo después de parsear el chunk final JSON del stream.
 * 
 * Este código:
 * 1. Extrae retrieved_data y citations del JSON del agent
 * 2. Construye un mapa de URLs desde retrieved_data
 * 3. Enriquece cada citation con metadata.url si es posible
 * 4. Mapea citations enriquecidas a message.links
 * 5. Integra message.links al objeto mensaje que se renderiza en UI
 */

// === PASO 1: Función auxiliar para enriquecer citations ===
interface RetrievedData {
  id?: string;
  filename?: string;
  path?: string;
  url?: string;
  metadata?: { url?: string; [key: string]: any };
  content?: string;
  [key: string]: any;
}

interface Citation {
  id?: string;
  text?: string;
  filename?: string;
  metadata?: { url?: string; [key: string]: any };
  [key: string]: any;
}

interface MessageLink {
  text: string;
  url: string;
  type: 'source' | 'reference' | 'citation';
}

function enrichCitationsWithUrls(
  citations: Citation[],
  retrieved: RetrievedData[]
): Citation[] {
  // Construir mapa de URLs desde retrieved_data
  const urlMap = new Map<string, string>();

  for (const r of retrieved) {
    const filename = r.filename || r.path || r.url;
    const metadata = r.metadata || {};

    if (!filename) continue;

    // Caso 1: filename es ya una URL
    if (typeof filename === 'string' && /^https?:\/\//i.test(filename)) {
      urlMap.set(filename, filename);
      continue;
    }

    // Caso 2: metadata tiene url
    if (metadata.url && /^https?:\/\//i.test(metadata.url)) {
      urlMap.set(filename, metadata.url);
      continue;
    }

    // Caso 3: spaces:// → https://bucket.nyc3.digitaloceanspaces.com/...
    const spacesMatch = filename.match(/^spaces:\/\/([^\/]+)\/(.+)$/);
    if (spacesMatch) {
      const bucket = spacesMatch[1];
      const path = spacesMatch[2];
      const publicUrl = `https://${bucket}.nyc3.digitaloceanspaces.com/${path}`;
      urlMap.set(filename, publicUrl);
      continue;
    }
  }

  // Enriquecer cada citation
  return citations.map((c) => {
    const out = { ...c };
    let foundUrl: string | null = null;

    // Opción 1: ya tiene metadata.url válida
    if (c.metadata?.url && /^https?:\/\//i.test(c.metadata.url)) {
      foundUrl = c.metadata.url;
    }
    // Opción 2: buscar por filename en el mapa
    else if (c.filename && urlMap.has(c.filename)) {
      foundUrl = urlMap.get(c.filename) || null;
    }
    // Opción 3: buscar por id en retrieved_data
    else if (c.id) {
      const found = retrieved.find(
        (r) => r.id === c.id && r.filename && /^https?:\/\//.test(r.filename)
      );
      if (found && found.filename) {
        foundUrl = urlMap.get(found.filename) || found.filename;
      }
    }

    if (foundUrl) {
      out.metadata = { ...(out.metadata || {}), url: foundUrl };
    }

    return out;
  });
}

// === PASO 2: Función para convertir citations a message.links ===
function citationsToLinks(enrichedCitations: Citation[]): MessageLink[] {
  return enrichedCitations
    .map((c) => {
      const url = c.metadata?.url;
      if (!url || !url.startsWith('http')) {
        return null; // Descartar si no hay URL válida
      }

      // Generar texto del link
      const linkText =
        c.text?.substring(0, 60) ||
        c.filename?.split('/').pop() ||
        url.split('/').pop() ||
        'Reference';

      return {
        text: linkText,
        url: url,
        type: 'citation' as const,
      };
    })
    .filter(Boolean) as MessageLink[];
}

// === PASO 3: Integración en handleNewMessages ===
// 
// Ubica la función handleNewMessages en AgentDetailPlayground.tsx y añade esto
// justo después de parsear el JSON final del stream:
//
// EJEMPLO DE INTEGRACIÓN (adaptar con nombres reales):
//
// function handleNewMessages(jsonText: string, aiId: string, userId: string, isLast?: boolean) {
//   // ... código existente para parsear jsonText ...
//   
//   let json = {};
//   try {
//     json = JSON.parse(jsonText);
//   } catch (e) {
//     // handle error
//   }
//
//   // ===== NUEVO CÓDIGO PARA CITATIONS =====
//   if (isLast) {
//     const retrieved = json?.retrieval?.retrieved_data ?? [];
//     const citations = json?.citations ?? [];
//
//     if (citations.length > 0) {
//       const enriched = enrichCitationsWithUrls(citations, retrieved);
//       const links = citationsToLinks(enriched);
//       
//       // Añadir links al mensaje actual
//       if (message) {
//         message.links = [...(message.links || []), ...links];
//       }
//     }
//   }
//   // ===== FIN NUEVO CÓDIGO =====
//
//   // ... resto del código existente ...
// }

// === PASO 4: Renderizar links en la UI ===
//
// Si tu componente de mensaje ya renderiza message.links, asegúrate que luzca así:
//
// {message.links && message.links.length > 0 && (
//   <div className="message-links">
//     <strong>Sources:</strong>
//     <ul>
//       {message.links.map((link, i) => (
//         <li key={i}>
//           <a href={link.url} target="_blank" rel="noopener noreferrer">
//             {link.text}
//           </a>
//         </li>
//       ))}
//     </ul>
//   </div>
// )}

// === EXPORTAR para uso en otros archivos ===
export { enrichCitationsWithUrls, citationsToLinks };
export type { Citation, RetrievedData, MessageLink };
