-- ============================================
-- RASHA Super App — Database Initialization
-- Creates per-service databases AND their users.
-- (rasha_core_db + rasha_user are created by the POSTGRES_DB/POSTGRES_USER env vars)
-- NOTE: Credentials here must match .env / .env.example (CRM_DB_*, ERP_DB_*, DYNAMIC_FORM_DB_*).
-- ============================================

-- CRM database
CREATE DATABASE rasha_crm_db;
CREATE USER rasha_crm_user WITH PASSWORD 'rasha_crm_secret_2024';
ALTER DATABASE rasha_crm_db OWNER TO rasha_crm_user;

-- Dynamic Form database
CREATE DATABASE rasha_dynform_db;
CREATE USER rasha_dynform_user WITH PASSWORD 'rasha_dynform_secret_2024';
ALTER DATABASE rasha_dynform_db OWNER TO rasha_dynform_user;

-- ERP database
CREATE DATABASE rasha_erp_db;
CREATE USER rasha_erp_user WITH PASSWORD 'rasha_erp_secret_2024';
ALTER DATABASE rasha_erp_db OWNER TO rasha_erp_user;
