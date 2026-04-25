# Flutter App Skeleton

Phase 0 keeps this app at shell and feature skeleton level only.

Required structure:
- `lib/shell`
- `lib/features/exhibition`
- `lib/features/renovation`
- `lib/features/custom_furniture`
- `lib/features/messages`
- `lib/features/profile`
- `lib/core`
- `lib/shared`

First visible buildings:
- exhibition
- messages
- profile

Hidden pre-embeds:
- renovation
- custom_furniture

Runtime entry notes:
- formal cloud host and port come from `infra/env/formal_cloud_target.env`.
- `apps/mobile/scripts/run_macos_formal.sh` defaults to `ssh_tunnel`.
- `apps/mobile/scripts/run_macos_formal.sh` accepts `APP_RUNTIME_ENTRY_MODE=cloud|ssh_tunnel|custom`.
- `apps/mobile/scripts/run_macos_cloud.sh` is the explicit cloud-direct entry.
- `apps/mobile/scripts/run_macos_exhibition_smoke.sh` is the explicit SSH tunnel entry.
- `apps/mobile/scripts/run_macos_ssh_tunnel.sh` is the approved local development entry.
- local membership and `local_dev` startup scripts are disabled and must not be
  used to start a local BFF or local Server for Flutter App runtime.
