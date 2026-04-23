# Admin Skeleton

Phase 0 scope:
- enterprise review
- project review
- template configuration
- audit logs
- basic ticketing

Routing principle:
- `Admin` uses controlled `Server` Admin APIs.
- `Admin` does not go through `BFF`.

Runtime entry notes:
- `npm run dev`, `build`, and `start` load formal cloud target values from `infra/env/formal_cloud_target.env`.
- `npm run dev` defaults to `SERVER_ADMIN_API_ENTRY_MODE=cloud`.
- `npm run dev:tunnel` targets `127.0.0.1:8080/server/admin`.
- `npm run dev:local` targets `127.0.0.1:3001/server/admin`.
- `SERVER_ADMIN_API_BASE_URL` may still override the mode for a custom target.
