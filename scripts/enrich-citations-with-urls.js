#!/usr/bin/env node

/**
 * Script: enrich-citations-with-urls.js
 * Objetivo: Lee agent_response_complete.json, extrae citations/retrieval,
 *           y crea agent_response_with_urls.json con metadata.url enriquecido
 * 
 * Uso:
 *   node scripts/enrich-citations-with-urls.js
 */

const fs = require('fs');
const path = require('path');

const INPUT_FILE = 'agent_response_complete.json';
const OUTPUT_FILE = 'agent_response_with_urls.json';

function enrichCitationsWithUrls() {
  // Leer archivo de entrada
  if (!fs.existsSync(INPUT_FILE)) {
    console.error(`✗ Archivo no encontrado: ${INPUT_FILE}`);
    console.error('  Ejecuta primero: $Env:AGENT_URL=... ; .\scripts\get-agent-citations.ps1');
    process.exit(1);
  }

  const rawData = fs.readFileSync(INPUT_FILE, 'utf8');
  const response = JSON.parse(rawData);

  const retrieved = response?.retrieval?.retrieved_data ?? [];
  const citations = response?.citations ?? [];

  console.log(`📄 Input: ${INPUT_FILE}`);
  console.log(`  - retrieved_data items: ${retrieved.length}`);
  console.log(`  - citations: ${citations.length}`);

  // Construir mapa de URLs desde retrieved_data
  const urlMap = new Map();
  for (const r of retrieved) {
    const filename = r.filename || r.path || r.url;
    const metadata = r.metadata || {};

    if (!filename) continue;

    // Caso 1: filename es ya una URL HTTPS
    if (typeof filename === 'string' && /^https?:\/\//i.test(filename)) {
      urlMap.set(filename, filename);
      if (metadata.url) urlMap.set(`${r.id || filename}:meta`, metadata.url);
      continue;
    }

    // Caso 2: metadata contiene url
    if (metadata.url && /^https?:\/\//i.test(metadata.url)) {
      urlMap.set(filename, metadata.url);
      continue;
    }

    // Caso 3: filename es estilo spaces://
    const spacesMatch = filename.match(/^spaces:\/\/([^\/]+)\/(.+)$/);
    if (spacesMatch) {
      const bucket = spacesMatch[1];
      const filePath = spacesMatch[2];
      const publicUrl = `https://${bucket}.nyc3.digitaloceanspaces.com/${filePath}`;
      urlMap.set(filename, publicUrl);
      continue;
    }

    // Caso 4: nombre de archivo simple (sin URL)
    // Por ahora, registramos pero no mapeamos (requeriría base URL manual)
    console.log(`  ⚠ Filename sin URL detectado: "${filename}"`);
  }

  console.log(`\n✓ URL Map construido: ${urlMap.size} entradas`);
  urlMap.forEach((url, key) => {
    if (!key.includes(':meta')) {
      console.log(`  - "${key.substring(0, 40)}" → ${url}`);
    }
  });

  // Enriquecer citations
  const enrichedCitations = citations.map((c, idx) => {
    const out = { ...c };
    let foundUrl = null;

    // Opción 1: ya tiene metadata.url
    if (c.metadata?.url && /^https?:\/\//i.test(c.metadata.url)) {
      foundUrl = c.metadata.url;
    }
    // Opción 2: buscar por filename
    else if (c.filename && urlMap.has(c.filename)) {
      foundUrl = urlMap.get(c.filename);
    }
    // Opción 3: buscar por id en retrieved_data
    else if (c.id) {
      const found = retrieved.find(r => r.id === c.id && /^https?:\/\//.test(r.filename || ''));
      if (found) foundUrl = found.filename;
    }
    // Opción 4: matching por texto (si retrieved tiene item con texto similar)
    else if (c.text) {
      for (const r of retrieved) {
        if (r.content?.includes?.(c.text.substring(0, 50))) {
          if (urlMap.has(r.filename)) {
            foundUrl = urlMap.get(r.filename);
            break;
          }
        }
      }
    }

    if (foundUrl) {
      out.metadata = { ...(out.metadata || {}), url: foundUrl };
      console.log(`\n  ✓ Citation ${idx + 1} enriquecida:`);
      console.log(`    text: "${c.text?.substring(0, 50)}..."`);
      console.log(`    url:  ${foundUrl}`);
    } else {
      console.log(`\n  ⚠ Citation ${idx + 1} SIN URL encontrada`);
    }

    return out;
  });

  // Crear respuesta modificada
  const modified = { ...response };
  modified.citations = enrichedCitations;

  // Guardar
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(modified, null, 2), 'utf8');
  console.log(`\n✓ Archivo enriquecido guardado: ${OUTPUT_FILE}`);

  // Resumen
  const citationsWithUrls = enrichedCitations.filter(c => c.metadata?.url).length;
  console.log(`\nResumen:`);
  console.log(`  - Citations con URL: ${citationsWithUrls}/${enrichedCitations.length}`);
  console.log(`\nSiguiente paso: usa agent_response_with_urls.json para parchear el cliente React.`);
}

enrichCitationsWithUrls();
