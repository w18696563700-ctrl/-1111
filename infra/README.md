# Infra Baseline

## Local Infra
- PostgreSQL
- Redis
- MinIO

## Cloud Baseline
- Nginx
- BFF on port `3000`
- Server on port `3001`
- Nginx reverse proxy in front

## Phase 0 Startup Order
1. Start Docker Compose infra.
2. Verify PostgreSQL, Redis, and MinIO health.
3. Scaffold app runtimes only after truth docs are accepted.
4. Add BFF and Server `/health/live` and `/health/ready`.
5. Run smoke script.

## Formal Cloud Guardrails
- `infra/scripts/formal_cloud_release_env_guard.sh`
  - `MODE=check` verifies the active cloud `Server` / `BFF` release `.env`
    files still match the approved `/srv/apps/*/.env` snapshots.
  - `MODE=sync` copies the approved app env snapshots into the current release
    directories.
  - `RESTART_PM2=true SERVER_PM2_NAME=... BFF_PM2_NAME=...` may be supplied
    when the active PM2 processes must be reloaded after env sync.
- `apps/server/scripts/exhibition_home_weather_release_guard_smoke.sh`
  - verifies both coordinate-based weather lookup and manual-selection-style
    administrative-hint lookup continue returning live weather instead of the
    controlled degradation chain.
