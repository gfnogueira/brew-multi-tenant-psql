# Multi-Tenant PoC with PostgreSQL and Row Level Security (RLS)

This project demonstrates two approaches for multi-tenant isolation using PostgreSQL with Row Level Security (RLS):

- **Model 1 (db/):** Trigger overwrites tenant_id with session value, preventing invasion but accepts the insert (passed value is ignored).
- **Model 2 (db-mt-block/):** Trigger only fills tenant_id if not provided and RLS blocks any attempt to insert events for another tenant (error when trying to invade).

## Structure

- `db/` — Standard model (trigger overwrites tenant_id)
  - `init.sql` — Table creation, trigger, RLS and examples
  - `multitenant_poc_tests.sql` — Test script
  - `create_poc_user.sql` — Common user creation for testing
- `db-mt-block/` — Strict model (blocks invasion attempts)
  - `init.sql` — Table creation, trigger, RLS and examples
  - `multitenant_poc_tests.sql` — Test script
  - `create_poc_user.sql` — Common user creation for testing

## How isolation works

- **RLS (Row Level Security):**
  - Ensures each SELECT/INSERT only sees or inserts data from the session tenant (defined by `SET app.tenant_id = '...'`).
- **Trigger:**
  - In the standard model, always overwrites tenant_id with session value.
  - In the strict model, only fills tenant_id if not provided, allowing RLS to block invasion attempts.

## Steps to run the PoC

1. **Start PostgreSQL database (can use docker-compose or local).**
2. **Execute the desired initialization script:**
   - Standard model: `db/init.sql`
   - Strict model: `db-mt-block/init.sql`
3. **Create test user:**
   - Standard model: `db/create_poc_user.sql`
   - Strict model: `db-mt-block/create_poc_user.sql`
4. **Connect with common user:**
   ```sh
   psql -h localhost -U multi_tenant_user -d multi_tenant
   # or
   psql -h localhost -U multi_tenant_user_block -d multi_tenant
   ```
5. **Run tests from corresponding script:**
   - Standard model: `db/multitenant_poc_tests.sql`
   - Strict model: `db-mt-block/multitenant_poc_tests.sql`

## What to test

- Insertion without tenant_id defined (should error)
- Correct insertion per tenant
- Invasion attempt (in standard model, value is ignored; in strict model, errors)
- Isolated reading per tenant
- Reading without tenant_id defined (should error)

## Notes

- Always define `SET app.tenant_id = '...'` before any operation.
- RLS doesn't apply to superusers, so always test with common user.
- The strict model is more secure as it blocks explicit invasion attempts.

## Technologies

- PostgreSQL 13+
- Python 3.8+ (for application examples)
- Row Level Security (RLS)
- PL/pgSQL triggers

## Security Benefits

- **Data Isolation:** Complete separation between tenants at database level
- **Application-level Protection:** Even if application has bugs, database prevents data leakage
- **Transparent to Application:** Queries don't need complex WHERE clauses
- **Performance:** RLS is applied at query planning time, maintaining good performance
