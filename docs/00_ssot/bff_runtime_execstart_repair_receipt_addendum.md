# BFF Runtime ExecStart Repair Receipt Addendum

## Current Object
- Date: `2026-04-11`
- Target host: `47.108.180.198`
- Incident scope: `exhibition-bff.service` runtime startup failure blocking `Nginx -> BFF -> /api/app/auth/*`

## Failure Snapshot
- Local tunnel `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` was listening on local `127.0.0.1:8080`.
- `GET http://127.0.0.1:8080/health/server/live` returned `200`.
- `GET http://127.0.0.1:8080/health/bff/live` returned `502 Bad Gateway`.
- `systemctl status exhibition-bff --no-pager` showed `activating (auto-restart)`.
- `journalctl -u exhibition-bff -n 120 --no-pager` showed:
  - `Error: Cannot find module '/srv/releases/bff/20260410233019/apps/bff/dist/apps/bff/src/main.js'`

## Root Cause
- Active release artifact under `/srv/releases/bff/20260410233019/apps/bff/dist` contains `dist/main.js`.
- Active systemd unit had drifted to:
  - `ExecStart=/usr/bin/node dist/apps/bff/src/main.js`
- Repository BFF workspace also still declared:
  - `apps/bff/package.json -> start:prod = node dist/apps/bff/src/main.js`
- Therefore the runtime startup contract drifted away from the actual `nest build` output shape.

## Repair Actions
- Remote runtime hot repair:
  - Backed up `/etc/systemd/system/exhibition-bff.service` to a timestamped `.bak.*` file
  - Restored `ExecStart=/usr/bin/node dist/main.js`
  - Executed `systemctl daemon-reload`
  - Executed `systemctl restart exhibition-bff`
- Repository source repair:
  - Updated `apps/bff/package.json` `start:prod` from `node dist/apps/bff/src/main.js` to `node dist/main.js`

## Verification
- `systemctl status exhibition-bff --no-pager`
  - `Active: active (running)`
  - `Main PID` present
  - Runtime command: `/usr/bin/node dist/main.js`
- Cloud:
  - `GET http://127.0.0.1:80/health/bff/live` -> `200`
- Local tunnel:
  - `GET http://127.0.0.1:8080/health/bff/live` -> `200`
- Auth corridor:
  - `POST /api/app/auth/otp/login` with mobile `18696563700`, otp `000000`, and non-empty `deviceId` -> `200`
  - `POST /api/app/auth/otp/send` still returns `400 AUTH_REQUEST_INVALID`

## Impact Judgment
- The blocker for the user's login page was the BFF runtime startup failure, not the SSH tunnel.
- After the runtime repair, whitelist test login through `/api/app/auth/otp/login` is functional again.
- OTP send remains a separate server-side validation/runtime behavior and was not repaired in this action.

## Hard Conclusion
`bff runtime repaired; tunnel path healthy; login corridor recovered for whitelist test login`
