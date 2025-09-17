-- db-mt-block/init.sql
-- Strict model: blocks attempts to insert events for another tenant (error when trying to invade)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DROP TABLE IF EXISTS events;

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

-- Optional trigger: only fills tenant_id if not provided (doesn't overwrite)
CREATE OR REPLACE FUNCTION set_tenant_id_strict()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := current_setting('app.tenant_id')::uuid;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON events;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON events
  FOR EACH ROW
  EXECUTE FUNCTION set_tenant_id_strict();

-- Usage example:
-- SET app.tenant_id = '11111111-1111-1111-1111-111111111111';
-- INSERT INTO events (message) VALUES ('Tenant A event');
-- INSERT INTO events (tenant_id, message) VALUES ('22222222-2222-2222-2222-222222222222', 'Trying to invade another tenant'); -- Will ERROR
