const jwt = require('jsonwebtoken');

const SECRET  = process.env.JWT_SECRET  || 'CHANGE_ME';
const EXPIRES = process.env.JWT_EXPIRES_IN || '30d';

/**
 * Sign a token for a user.
 * @param {{ id: string, email: string }} payload
 */
function signToken(payload) {
  return jwt.sign(payload, SECRET, { expiresIn: EXPIRES });
}

/**
 * Verify a token and return its decoded payload, or null on failure.
 * @param {string} token
 */
function verifyToken(token) {
  try {
    return jwt.verify(token, SECRET);
  } catch {
    return null;
  }
}

module.exports = { signToken, verifyToken };