require('dotenv').config();
const fs    = require('fs');
const path  = require('path');
const mysql = require('mysql2/promise');

async function migrate() {
  // Conectamos SIN especificar database todavía porque el schema la crea
  const conn = await mysql.createConnection({
    host:     process.env.DB_HOST     || 'localhost',
    port:     parseInt(process.env.DB_PORT || '3306'),
    user:     process.env.DB_USER     || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true,   // necesario para ejecutar todo el .sql de una vez
  });

  const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');

  try {
    console.log('[migrate] Ejecutando schema.sql …');
    await conn.query(sql);
    console.log('[migrate] ✅  Tablas creadas correctamente.');
  } catch (err) {
    console.error('[migrate] ❌  Error:', err.message);
    process.exit(1);
  } finally {
    await conn.end();
  }
}

migrate();