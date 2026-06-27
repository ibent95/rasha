-- RASHA Super App — MySQL/MariaDB Database Initialization
-- Creates all databases for each service

-- Core database (created by MYSQL_DATABASE env, but ensure it exists)
CREATE DATABASE IF NOT EXISTS ibentmyi_app_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CRM database
CREATE DATABASE IF NOT EXISTS ibentmyi_app_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Dynamic Form database
CREATE DATABASE IF NOT EXISTS ibentmyi_app_dynamic_form CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ERP database
CREATE DATABASE IF NOT EXISTS ibentmyi_app_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF && echo 'MySQL init script created'
