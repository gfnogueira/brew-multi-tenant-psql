-- Practical tests for multi-tenant PoC with RLS (strict model)

-- 1. Test insertion WITHOUT tenant_id defined
-- Expected: ERROR (tenant_id cannot be NULL)
INSERT INTO events (message) VALUES ('Test without tenant_id');

-- 2. Test insertion WITH tenant_id defined correctly
SET app.tenant_id = '11111111-1111-1111-1111-111111111111';
INSERT INTO events (message) VALUES ('Tenant A event');

SET app.tenant_id = '22222222-2222-2222-2222-222222222222';
INSERT INTO events (message) VALUES ('Tenant B event');

-- 3. Invasion test: try to insert event for another tenant
SET app.tenant_id = '11111111-1111-1111-1111-111111111111';
INSERT INTO events (tenant_id, message) VALUES ('22222222-2222-2222-2222-222222222222', 'Trying to invade another tenant');
-- Expected: ERROR (RLS blocks)

-- 4. Reading test: should only see events from session tenant
SET app.tenant_id = '11111111-1111-1111-1111-111111111111';
SELECT * FROM events;
-- Expected: only tenant A events

SET app.tenant_id = '22222222-2222-2222-2222-222222222222';
SELECT * FROM events;
-- Expected: only tenant B events

-- 5. Reading test without tenant_id defined
RESET app.tenant_id;
SELECT * FROM events;
-- Expected: ERROR (tenant_id cannot be NULL)
