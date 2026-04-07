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
