-- ═══════════════════════════════════════════════════════════════════════════
-- MediBridge — MySQL schema (XAMPP)
-- Ejecutar una sola vez:  node src/db/migrate.js
-- O pegarlo directamente en phpMyAdmin → pestaña SQL
-- ═══════════════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS medibridge
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE medibridge;

-- ── Usuarios ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36)     NOT NULL PRIMARY KEY,        -- UUID desde Node.js
  email         VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) DEFAULT NULL,                -- NULL para cuentas OAuth
  full_name     VARCHAR(255) DEFAULT NULL,
  avatar_url    TEXT         DEFAULT NULL,
  provider      VARCHAR(50)  NOT NULL DEFAULT 'email',    -- 'email' | 'google'
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                             ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Sesiones de consulta ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sessions (
  id            VARCHAR(36)  NOT NULL PRIMARY KEY,        -- UUID desde Flutter
  user_id       CHAR(36)     NOT NULL,
  date          DATETIME     NOT NULL,
  doctor_lang   VARCHAR(100) NOT NULL,
  patient_lang  VARCHAR(100) NOT NULL,
  messages      JSON         NOT NULL,
  message_count INT          NOT NULL DEFAULT 0,
  summary_data  JSON         DEFAULT NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_sessions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_date    ON sessions(date);