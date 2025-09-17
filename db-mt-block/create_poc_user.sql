-- Script to create common user for secure multi-tenant PoC (strict model)

-- 1. Create user
CREATE USER multi_tenant_user_block WITH PASSWORD 'password123';

-- 2. Allow database connection
GRANT CONNECT ON DATABASE multi_tenant TO multi_tenant_user_block;

-- 3. Allow public schema usage
GRANT USAGE ON SCHEMA public TO multi_tenant_user_block;

-- 4. Allow access to events table
GRANT SELECT, INSERT ON events TO multi_tenant_user_block;

-- 5. (Optional) Allow usage of functions and triggers
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO multi_tenant_user_block;

-- Now connect using:
-- psql -h localhost -U multi_tenant_user_block -d multi_tenant
-- and run tests normally!
