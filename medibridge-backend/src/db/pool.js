const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host:               process.env.DB_HOST     || 'localhost',
  port:               parseInt(process.env.DB_PORT || '3306'),
  database:           process.env.DB_NAME     || 'medibridge',
  user:               process.env.DB_USER     || 'root',
  password:           process.env.DB_PASSWORD || '',
  waitForConnections: true,
  connectionLimit:    20,
  queueLimit:         0,
  // Devuelve JS objects en vez de arrays para las columnas
  namedPlaceholders:  false,
});

pool.on('connection', () => {
  // opcional: console.log('[DB] Nueva conexión establecida');
});

// Helper: ejecuta una query con parámetros posicionales (?)
// Devuelve siempre { rows, rowCount } para que las rutas
// no tengan que saber si es mysql2 o pg.
async function query(sql, params = []) {
  const [result] = await pool.execute(sql, params);
  // Para SELECT: result es un array de rows
  // Para INSERT/UPDATE/DELETE: result es un ResultSetHeader
  if (Array.isArray(result)) {
    return { rows: result, rowCount: result.length };
  }
  return { rows: [], rowCount: result.affectedRows };
}

module.exports = { pool, query };