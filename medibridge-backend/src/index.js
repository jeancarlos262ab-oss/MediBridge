require('dotenv').config();

const express    = require('express');
const helmet     = require('helmet');
const cors       = require('cors');
const rateLimit  = require('express-rate-limit');

const authRoutes     = require('./routes/auth');
const sessionRoutes  = require('./routes/sessions');
const aiRoutes       = require('./routes/ai');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Security & parsing ────────────────────────────────────────────────────────
app.use(helmet());
app.use(express.json({ limit: '4mb' }));

// ── CORS ──────────────────────────────────────────────────────────────────────
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
  : '*';

app.use(cors({
  origin: allowedOrigins,
  methods: ['GET', 'POST', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ── Rate limiting ─────────────────────────────────────────────────────────────
app.use('/auth', rateLimit({
  windowMs: 15 * 60 * 1000,   // 15 minutes
  max: 30,
  message: { error: 'Too many requests, please try again later.' },
}));

// Limitar llamadas AI para evitar abuso de la API key
app.use('/ai', rateLimit({
  windowMs: 60 * 1000,  // 1 minuto
  max: 60,              // 60 llamadas por minuto por IP
  message: { error: 'Too many AI requests, please slow down.' },
}));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/auth',     authRoutes);
app.use('/sessions', sessionRoutes);
app.use('/ai',       aiRoutes);

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: 'Route not found.' }));

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error('[unhandled]', err.message);
  res.status(500).json({ error: 'Internal server error.' });
});

// ── Start ─────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`🚀  MediBridge API listening on port ${PORT}`);
});