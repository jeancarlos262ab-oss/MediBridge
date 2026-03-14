const express  = require('express');
const bcrypt   = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { query }      = require('../db/pool');
const { signToken }  = require('../utils/jwt');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ── POST /auth/register ───────────────────────────────────────────────────────
router.post('/register', async (req, res) => {
  const { email, password, fullName } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña son obligatorios.' });
  }
  if (password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres.' });
  }

  try {
    // Verificar duplicado
    const { rows: exists } = await query(
      'SELECT id FROM users WHERE email = ?',
      [email.toLowerCase()]
    );
    if (exists.length > 0) {
      return res.status(409).json({ error: 'Ya existe una cuenta con ese email.' });
    }

    const hash = await bcrypt.hash(password, 12);
    const id   = uuidv4();

    // MySQL no tiene RETURNING — hacemos INSERT y luego SELECT
    await query(
      `INSERT INTO users (id, email, password_hash, full_name, provider)
       VALUES (?, ?, ?, ?, 'email')`,
      [id, email.toLowerCase(), hash, fullName || null]
    );

    const { rows } = await query(
      'SELECT id, email, full_name, avatar_url FROM users WHERE id = ?',
      [id]
    );
    const user  = rows[0];
    const token = signToken({ id: user.id, email: user.email });

    return res.status(201).json({
      token,
      user: {
        id:        user.id,
        email:     user.email,
        fullName:  user.full_name,
        avatarUrl: user.avatar_url,
      },
    });
  } catch (err) {
    console.error('[auth/register]', err.message);
    return res.status(500).json({ error: 'Error al registrarse.' });
  }
});

// ── POST /auth/login ──────────────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña son obligatorios.' });
  }

  try {
    const { rows } = await query(
      'SELECT id, email, password_hash, full_name, avatar_url FROM users WHERE email = ?',
      [email.toLowerCase()]
    );

    const user = rows[0];
    if (!user || !user.password_hash) {
      return res.status(401).json({ error: 'Email o contraseña incorrectos.' });
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Email o contraseña incorrectos.' });
    }

    const token = signToken({ id: user.id, email: user.email });

    return res.json({
      token,
      user: {
        id:        user.id,
        email:     user.email,
        fullName:  user.full_name,
        avatarUrl: user.avatar_url,
      },
    });
  } catch (err) {
    console.error('[auth/login]', err.message);
    return res.status(500).json({ error: 'Error al iniciar sesión.' });
  }
});

// ── GET /auth/me  (requiere token) ────────────────────────────────────────────
router.get('/me', requireAuth, async (req, res) => {
  try {
    const { rows } = await query(
      'SELECT id, email, full_name, avatar_url, created_at FROM users WHERE id = ?',
      [req.user.id]
    );
    if (!rows[0]) return res.status(404).json({ error: 'Usuario no encontrado.' });

    const u = rows[0];
    return res.json({
      id:        u.id,
      email:     u.email,
      fullName:  u.full_name,
      avatarUrl: u.avatar_url,
      createdAt: u.created_at,
    });
  } catch (err) {
    console.error('[auth/me]', err.message);
    return res.status(500).json({ error: 'No se pudo obtener el perfil.' });
  }
});

// ── POST /auth/change-password  (requiere token) ──────────────────────────────
router.post('/change-password', requireAuth, async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: 'currentPassword y newPassword son obligatorios.' });
  }
  if (newPassword.length < 8) {
    return res.status(400).json({ error: 'La nueva contraseña debe tener al menos 8 caracteres.' });
  }

  try {
    const { rows } = await query(
      'SELECT password_hash FROM users WHERE id = ?',
      [req.user.id]
    );
    const user = rows[0];
    if (!user?.password_hash) {
      return res.status(400).json({ error: 'Este tipo de cuenta no soporta cambio de contraseña.' });
    }

    const valid = await bcrypt.compare(currentPassword, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'La contraseña actual es incorrecta.' });
    }

    const hash = await bcrypt.hash(newPassword, 12);
    await query('UPDATE users SET password_hash = ? WHERE id = ?', [hash, req.user.id]);

    return res.json({ message: 'Contraseña actualizada correctamente.' });
  } catch (err) {
    console.error('[auth/change-password]', err.message);
    return res.status(500).json({ error: 'Error al cambiar la contraseña.' });
  }
});

module.exports = router;