const express = require('express');
const { query } = require('../db/pool');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Todas las rutas requieren token
router.use(requireAuth);

// ── GET /sessions  — listar sesiones del usuario ──────────────────────────────
router.get('/', async (req, res) => {
  try {
    const { rows } = await query(
      `SELECT id, date, doctor_lang, patient_lang,
              messages, message_count, summary_data, created_at
       FROM sessions
       WHERE user_id = ?
       ORDER BY date DESC
       LIMIT 50`,
      [req.user.id]
    );

    return res.json(rows.map(toSessionRecord));
  } catch (err) {
    console.error('[sessions/list]', err.message);
    return res.status(500).json({ error: 'No se pudieron cargar las sesiones.' });
  }
});

// ── POST /sessions  — crear o actualizar (upsert) ─────────────────────────────
router.post('/', async (req, res) => {
  const { id, date, doctorLanguage, patientLanguage, messages, messageCount, summaryData } = req.body;

  if (!id || !date) {
    return res.status(400).json({ error: 'id y date son obligatorios.' });
  }

  try {
    // MySQL: INSERT ... ON DUPLICATE KEY UPDATE
    await query(
      `INSERT INTO sessions
         (id, user_id, date, doctor_lang, patient_lang, messages, message_count, summary_data)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         date          = VALUES(date),
         doctor_lang   = VALUES(doctor_lang),
         patient_lang  = VALUES(patient_lang),
         messages      = VALUES(messages),
         message_count = VALUES(message_count),
         summary_data  = VALUES(summary_data)`,
      [
        id,
        req.user.id,
        new Date(date),
        doctorLanguage,
        patientLanguage,
        JSON.stringify(messages ?? []),
        messageCount ?? 0,
        summaryData ? JSON.stringify(summaryData) : null,
      ]
    );

    return res.status(201).json({ message: 'Sesión guardada.' });
  } catch (err) {
    console.error('[sessions/save]', err.message);
    return res.status(500).json({ error: 'No se pudo guardar la sesión.' });
  }
});

// ── GET /sessions/:id  — detalle de una sesión ────────────────────────────────
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await query(
      `SELECT id, date, doctor_lang, patient_lang,
              messages, message_count, summary_data, created_at
       FROM sessions
       WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    if (!rows[0]) return res.status(404).json({ error: 'Sesión no encontrada.' });
    return res.json(toSessionRecord(rows[0]));
  } catch (err) {
    console.error('[sessions/get]', err.message);
    return res.status(500).json({ error: 'No se pudo obtener la sesión.' });
  }
});

// ── DELETE /sessions/:id  — eliminar una sesión ───────────────────────────────
router.delete('/:id', async (req, res) => {
  try {
    const { rowCount } = await query(
      'DELETE FROM sessions WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );

    if (rowCount === 0) return res.status(404).json({ error: 'Sesión no encontrada.' });
    return res.json({ message: 'Sesión eliminada.' });
  } catch (err) {
    console.error('[sessions/delete]', err.message);
    return res.status(500).json({ error: 'No se pudo eliminar la sesión.' });
  }
});

// ── DELETE /sessions  — eliminar todo el historial ────────────────────────────
router.delete('/', async (req, res) => {
  try {
    await query('DELETE FROM sessions WHERE user_id = ?', [req.user.id]);
    return res.json({ message: 'Historial eliminado.' });
  } catch (err) {
    console.error('[sessions/clear]', err.message);
    return res.status(500).json({ error: 'No se pudo limpiar el historial.' });
  }
});

// ── Helper: fila MySQL → JSON compatible con Flutter ─────────────────────────
function toSessionRecord(row) {
  // mysql2 ya parsea JSON automáticamente si la columna es tipo JSON
  // row.date llega como objeto Date de JS — lo convertimos a ISO string
  // para que Flutter pueda hacer DateTime.parse() correctamente
  const dateValue = row.date instanceof Date
    ? row.date.toISOString()
    : String(row.date);

  return {
    id:              row.id,
    date:            dateValue,
    doctorLanguage:  row.doctor_lang,
    patientLanguage: row.patient_lang,
    messages:        typeof row.messages === 'string'
                       ? JSON.parse(row.messages)
                       : (row.messages ?? []),
    messageCount:    row.message_count,
    summaryData:     typeof row.summary_data === 'string'
                       ? JSON.parse(row.summary_data)
                       : (row.summary_data ?? null),
  };
}

module.exports = router;