-- db/init.sql
-- Standard model: trigger overwrites tenant_id with session value

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  message TEXT,
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_select_policy ON events
  FOR SELECT USING (tenant_id = current_setting('app.tenant_id')::uuid);

CREATE POLICY tenant_insert_policy ON events
  FOR INSERT WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

-- Trigger to automatically fill tenant_id
CREATE OR REPLACE FUNCTION set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.tenant_id := current_setting('app.tenant_id')::uuid;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON events;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON events
  FOR EACH ROW
  EXECUTE FUNCTION set_tenant_id();

-- Inserting data for two tenants

-- Tenant A
SET app.tenant_id = '11111111-1111-1111-1111-111111111111';
INSERT INTO events (message) VALUES ('Alarm A1'), ('Alarm A2');

-- Tenant B
SET app.tenant_id = '22222222-2222-2222-2222-222222222222';
INSERT INTO events (message) VALUES ('Alarm B1');
