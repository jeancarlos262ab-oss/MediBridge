const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ── Gemini client (singleton) ─────────────────────────────────────────────────
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

function getModel() {
  return genAI.getGenerativeModel({
    model: 'gemini-2.5-flash',
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 2048,
    },
    systemInstruction:
      'You are MediBridge, a specialized medical interpreter AI. ' +
      'Translate with precise clinical accuracy. ' +
      'When translating for patients, use simple language. ' +
      'Respond only with the requested content, no extra commentary.',
  });
}

// Todas las rutas requieren token
router.use(requireAuth);

// ── POST /ai/translate ────────────────────────────────────────────────────────
router.post('/translate', async (req, res) => {
  const { text, fromLanguage, toLanguage, speaker } = req.body;

  if (!text || !fromLanguage || !toLanguage || !speaker) {
    return res.status(400).json({ error: 'text, fromLanguage, toLanguage y speaker son obligatorios.' });
  }

  const role = speaker === 'doctor' ? 'doctor' : 'patient';
  const simplify = speaker === 'patient'
    ? 'Simplify medical terms with brief explanations.'
    : 'Keep clinical precision.';

  const prompt =
    `Translate this ${role} statement from ${fromLanguage} to ${toLanguage}.\n` +
    `${simplify}\n\n` +
    `"${text}"\n\n` +
    `Respond with ONLY the translation, nothing else.`;

  try {
    const model = getModel();
    const result = await model.generateContent(prompt);
    const translation = result.response.text()?.trim() ?? 'Translation unavailable';
    return res.json({ translation });
  } catch (err) {
    console.error('[ai/translate]', err.message);
    return res.status(500).json({ error: 'Translation failed.' });
  }
});

// ── POST /ai/summary ──────────────────────────────────────────────────────────
router.post('/summary', async (req, res) => {
  const { messages, patientLanguage, doctorLanguage } = req.body;

  if (!messages || !Array.isArray(messages) || !patientLanguage || !doctorLanguage) {
    return res.status(400).json({ error: 'messages, patientLanguage y doctorLanguage son obligatorios.' });
  }

  const conversation = messages
    .map((m) => `[${m.speaker.toUpperCase()}] ${m.originalText}`)
    .join('\n');

  const prompt =
    `Summarize this medical consultation.\n` +
    `Doctor language: ${doctorLanguage}\n` +
    `Patient language: ${patientLanguage}\n\n` +
    `Conversation:\n${conversation}\n\n` +
    `Reply using EXACTLY this format (keep the labels, replace the values):\n\n` +
    `COMPLAINT: <main reason for the visit>\n` +
    `DIAGNOSIS: <doctor assessment or diagnosis>\n` +
    `MEDICATIONS: <list medications as "Name – dose – frequency", one per line, or "None">\n` +
    `FOLLOWUP: <follow-up instructions, one per line, or "None">\n` +
    `PATIENT_SUMMARY: <simple summary in ${patientLanguage} for the patient to take home>\n\n` +
    `Use the exact labels above. Do not add extra sections.`;

  try {
    const model = getModel();
    const result = await model.generateContent(prompt);
    const raw = result.response.text()?.trim() ?? '';
    return res.json({ raw });
  } catch (err) {
    console.error('[ai/summary]', err.message);
    return res.status(500).json({ error: 'Summary generation failed.' });
  }
});

// ── POST /ai/urgency ──────────────────────────────────────────────────────────
router.post('/urgency', async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'text es obligatorio.' });
  }

  const prompt =
    `Classify the urgency of this medical statement.\n` +
    `Statement: "${text}"\n\n` +
    `Reply with EXACTLY two lines:\n` +
    `LEVEL: <none|low|medium|high|critical>\n` +
    `REASON: <reason in max 8 words>\n\n` +
    `Rules:\n` +
    `- critical: chest pain, breathing difficulty, stroke, heavy bleeding, overdose\n` +
    `- high: severe pain, high fever, allergic reaction, broken bone\n` +
    `- medium: moderate symptoms, chronic conditions\n` +
    `- low: mild symptoms, general questions\n` +
    `- none: normal conversation, scheduling`;

  try {
    const model = getModel();
    const result = await model.generateContent(prompt);
    const raw = result.response.text()?.trim() ?? '';

    const level =
      /LEVEL:\s*(\w+)/i.exec(raw)?.[1]?.toLowerCase() ?? 'none';
    const reason =
      /REASON:\s*(.+)/i.exec(raw)?.[1]?.trim() ?? '';

    return res.json({ level, reason });
  } catch (err) {
    console.error('[ai/urgency]', err.message);
    return res.json({ level: 'none', reason: '' });
  }
});

// ── POST /ai/symptoms ─────────────────────────────────────────────────────────
router.post('/symptoms', async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'text es obligatorio.' });
  }

  const prompt =
    `Extract any medical symptoms or complaints mentioned in this text.\n` +
    `Text: "${text}"\n\n` +
    `Reply with ONLY a comma-separated list of symptoms (e.g. "headache, fever, nausea").\n` +
    `If no symptoms are mentioned, reply with exactly: NONE`;

  try {
    const model = getModel();
    const result = await model.generateContent(prompt);
    const raw = result.response.text()?.trim() ?? '';

    if (!raw || raw.toUpperCase() === 'NONE') {
      return res.json({ symptoms: [] });
    }

    const symptoms = raw
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    return res.json({ symptoms });
  } catch (err) {
    console.error('[ai/symptoms]', err.message);
    return res.json({ symptoms: [] });
  }
});

// ── POST /ai/emergency-translate ──────────────────────────────────────────────
router.post('/emergency-translate', async (req, res) => {
  const { text, targetLanguage } = req.body;

  if (!text || !targetLanguage) {
    return res.status(400).json({ error: 'text y targetLanguage son obligatorios.' });
  }

  const prompt =
    `Translate this emergency medical phrase to ${targetLanguage}.\n` +
    `Keep it short and clear for a patient who may be in distress.\n\n` +
    `"${text}"\n\n` +
    `Respond with ONLY the translation, nothing else.`;

  try {
    const model = getModel();
    const result = await model.generateContent(prompt);
    const translation = result.response.text()?.trim() ?? text;
    return res.json({ translation });
  } catch (err) {
    console.error('[ai/emergency-translate]', err.message);
    return res.json({ translation: text });
  }
});

module.exports = router;