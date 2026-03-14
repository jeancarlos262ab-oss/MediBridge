const { verifyToken } = require('../utils/jwt');

/**
 * Express middleware that validates the Bearer JWT in the Authorization header.
 * Attaches `req.user = { id, email }` on success.
 */
function requireAuth(req, res, next) {
  const header = req.headers['authorization'] || '';
  const token  = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: 'Missing authorization token.' });
  }

  const payload = verifyToken(token);
  if (!payload) {
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }

  req.user = { id: payload.id, email: payload.email };
  next();
}

module.exports = { requireAuth };