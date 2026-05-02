# Project Communication Unread / Read Day 6 Cloud Release Probe Receipt Addendum

## Verdict

Conditional Pass.

Server and BFF cloud releases were published and restarted successfully. Health checks passed. App-facing project communication routes reach Server through BFF, but authenticated 8080 probes for live message fields and read cursor write were not completed because no verifiable app session was available and cloud whitelist test session issuance is disabled.

## Release Scope

### Server

- New current:
  - `/srv/releases/server/20260502172500-project-communication-unread-day6-server`
- Previous current:
  - `/srv/releases/server/20260502135031-public-resource-file-access`
- Service:
  - `exhibition-server`
- Restart result:
  - `active`

### BFF

- New current:
  - `/srv/releases/bff/20260502172500-project-communication-unread-day6-bff`
- Previous current:
  - `/srv/releases/bff/20260502052616-sincerity-internal-no-freeze/apps/bff`
- Service:
  - `exhibition-bff`
- Restart result:
  - `active`

## Deployment Method

- Copied cloud `current` into a new release directory.
- Overlaid only Day 2 to Day 5 related compiled outputs and source files.
- Did not replace the entire cloud `dist`.
- Did not run migrations.
- Did not modify Nginx.
- Did not modify systemd unit files.
- Did not manually write business database rows.

## Local Pre-Release Verification

- `cd apps/server && npm run build`
  - Pass.
- `cd apps/server && node --test test/project-communication-message-read-state.test.cjs test/project-communication-album.test.cjs`
  - Pass: 10/10.
- `cd apps/bff && npm run build`
  - Pass.
- `cd apps/bff && node --test test/message-interaction-transport.test.cjs`
  - Pass: 10/10.

## Cloud Candidate Verification

### Server Candidate

- `node --test test/project-communication-message-read-state.test.cjs`
  - Pass: 1/1.

### BFF Candidate

- `node --test test/message-interaction-transport.test.cjs`
  - Pass: 10/10.

Note: BFF runtime release did not originally include full TypeScript source required by the test runner. The candidate release was supplemented with `src`, `tsconfig.json`, `tsconfig.build.json`, `nest-cli.json`, `package.json`, and `package-lock.json` for remote test execution. Runtime still starts from compiled `dist/apps/bff/src/main.js`.

## 8080 Health Probe

- `GET http://127.0.0.1:8080/health/server/live`
  - `200 OK`
  - `service=exhibition-server`
- `GET http://127.0.0.1:8080/health/bff/live`
  - `200 OK`
  - `service=exhibition-bff`

## 8080 Route Probe

### Message List Route

- Method:
  - `GET`
- Path:
  - `/api/app/message/project-communication/messages`
- Probe result:
  - `401 AUTH_SESSION_INVALID`
  - `source=server`

Interpretation:

- BFF route exists.
- Request reaches Server.
- Auth carrier is required before live message field payload can be read.

### Read Cursor Route

- Method:
  - `POST`
- Path:
  - `/api/app/message/project-communication/read-cursor`
- Probe result:
  - `401 AUTH_SESSION_INVALID`
  - `source=server`

Interpretation:

- BFF route exists.
- Request reaches Server.
- Writable probe was blocked by missing verifiable session carrier.

## Blocked Probe

Attempted to issue a short-lived whitelist test session for probe isolation.

- Internal Server route:
  - `/server/auth/whitelist-test-session`
- Result:
  - `503 AUTH_RESOURCE_UNAVAILABLE`
- Reason:
  - cloud whitelist test session issuance is disabled.

No access token or refresh token was printed or written to this receipt.

## Rollback Plan

### Server

```bash
ln -sfn /srv/releases/server/20260502135031-public-resource-file-access /srv/apps/server/current
systemctl restart exhibition-server
systemctl is-active exhibition-server
```

### BFF

```bash
ln -sfn /srv/releases/bff/20260502052616-sincerity-internal-no-freeze/apps/bff /srv/apps/bff/current
systemctl restart exhibition-bff
systemctl is-active exhibition-bff
```

## Residual Risks

- Live `deliveryState/readState/readByCounterpartAt` payload is not proven through 8080 without an authenticated session.
- Live read cursor write is not proven through 8080 without an authenticated session.
- Day 7 must use a real logged-in account or an explicitly enabled test session path.
- This is not a double-account acceptance pass.
