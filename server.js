const express = require('express');
const fetch = require('node-fetch');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const API_URL = process.env.API_URL || 'https://qyu5z3uycrlt22lufgs5ac6v.agents.do-ai.run/api/v1/chat/completions';
const AGENT_ID = process.env.AGENT_ID || 'a141afdb-c01e-11f0-b074-4e013e2ddde4';
const ACCESS_TOKEN = process.env.ACCESS_TOKEN || '';

if (!ACCESS_TOKEN) {
  console.warn('Warning: ACCESS_TOKEN not set in environment; proxy calls to the API may fail. Set ACCESS_TOKEN in .env');
}

app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    // Ensure AGENT_ID is set by the server, and do not forward a client-supplied ACCESS_TOKEN
    body.agent_id = AGENT_ID;

    // Forward to remote API
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'X-Agent-Id': AGENT_ID
      },
      body: JSON.stringify(body)
    });

    const text = await response.text();
    // copy status and body to client
    res.status(response.status);
    res.set('content-type', response.headers.get('content-type') || 'application/json');
    res.send(text);
  } catch (err) {
    console.error('Proxy Error:', err);
    res.status(500).json({ error: 'Proxy error', message: err.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Proxy server listening on http://localhost:${port}`);
});
