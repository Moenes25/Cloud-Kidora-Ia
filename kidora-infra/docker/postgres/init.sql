-- ═══════════════════════════════════════════════════════
-- Kidora — PostgreSQL Initialization Script
-- ═══════════════════════════════════════════════════════
-- This runs on first database creation.
-- ═══════════════════════════════════════════════════════

-- Create Kidora application schema (adjust as needed)
CREATE SCHEMA IF NOT EXISTS kidora;

-- Set search path
ALTER DATABASE "${POSTGRES_DB}" SET search_path TO kidora, public;

-- Create application user (if different from POSTGRES_USER)
-- DO $$ BEGIN
--   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_user') THEN
--     CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password';
--   END IF;
-- END $$;
-- GRANT ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" TO app_user;
-- GRANT ALL PRIVILEGES ON SCHEMA kidora TO app_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA kidora TO app_user;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";