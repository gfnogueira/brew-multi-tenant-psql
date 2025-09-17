-- Script to create common user for secure multi-tenant PoC

-- 1. Create user
CREATE USER multi_tenant_user WITH PASSWORD 'password123';

-- 2. Allow database connection
GRANT CONNECT ON DATABASE multi_tenant TO multi_tenant_user;

-- 3. Allow public schema usage
GRANT USAGE ON SCHEMA public TO multi_tenant_user;

-- 4. Allow access to events table
GRANT SELECT, INSERT ON events TO multi_tenant_user;

-- 5. (Optional) Allow usage of functions and triggers
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO multi_tenant_user;

-- Now connect using:
-- psql -h localhost -U multi_tenant_user -d multi_tenant
-- and run tests normally!
