---
owner: Codex 总控
status: active
purpose: >
  Freeze the runtime entry boundary for the repository-wide environment cleanup
  so future work does not confuse formal cloud ingress, SSH tunnel ingress,
  cloud-host internal loopback, and explicit local or isolated chains.
layer: L0 SSOT
decision_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/04_frontend/exhibition_d1_d2_smoke_checklist_and_tunnel_runbook.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - infra/nginx/cloud.conf
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/admin/src/core/config/env.ts
  - apps/bff/src/core/runtime/runtime-config.service.ts
  - apps/server/src/core/runtime-config.service.ts
---

# Runtime Environment Entry Boundary Cleanup Freeze Addendum

## 1. Scope

- This addendum covers only repository runtime-entry cleanup and anti-drift rules.
- This addendum does not freeze or reopen:
  - business truth
  - API contract semantics
  - domain state machines
  - release approval on its own

## 2. Runtime Entry Classes

- `formal_cloud_ingress`
  - public or semi-public app-facing cloud entry such as `http://47.108.180.198/api/app`
  - may be used by explicit cloud-run scripts
- `ssh_tunnel_ingress`
  - local machine `127.0.0.1:<local_port>` forwarded to cloud host `127.0.0.1:80`
  - current mainline example:
    - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
  - valid only when the caller explicitly chooses tunnel mode
- `cloud_host_internal_loopback`
  - cloud host internal links such as:
    - `nginx :80 -> BFF :3000`
    - `BFF -> Server :3001`
    - `nginx -> Admin :3002`
  - these loopback links are legitimate runtime topology and must not be mechanically removed
- `explicit_local_or_isolated_chain`
  - local-only development or isolated package runtime such as:
    - local `BFF :3000`
    - local `Server :3001`
    - `runtime/package1-isolated/*`
  - must stay explicitly named as local or isolated and must not masquerade as formal runtime

## 3. Frozen Cleanup Rules

- Formal cloud entry and tunnel entry are both allowed, but they must be explicit choices.
- No frontend or admin caller may silently default to a local `127.0.0.1` target while presenting itself as formal or production-like.
- Cloud-host internal loopback is allowed only inside cloud topology, deployment config, or clearly marked runtime scripts.
- Local or isolated scripts may use loopback, but:
  - the script name must read as local, smoke, or isolated
  - the output must print the actual target chain
  - the defaults must not be reused as the formal caller default by accident
- `Admin` must not hide a local `127.0.0.1:3001/server/admin` fallback behind an apparently formal runtime.
- `Flutter App` may keep tunnel support, but tunnel mode must not be the only hidden fallback path.

## 4. Repository Anti-Drift Requirements

- Future threads must classify runtime-entry changes into one of the four classes above before editing code.
- A raw search hit on `127.0.0.1` is not by itself a defect.
- The following are defects:
  - a formal entry silently falling back to localhost
  - a script whose name suggests formal runtime but actually opens a local or isolated chain
  - mixed naming where cloud, tunnel, and local modes are indistinguishable from command output
- The following are not defects by themselves:
  - `infra/nginx/cloud.conf` loopback upstreams
  - cloud-host `BFF -> Server` loopback defaults used inside the single-host topology
  - tests and demos that intentionally bind ephemeral localhost listeners

## 5. Required Cleanup Outcomes

- `mobile` runtime entry selection must clearly separate:
  - explicit cloud mode
  - explicit tunnel mode
  - explicit local mode
- `infra/env/formal_cloud_target.env` is the canonical non-secret formal cloud
  target register for repository runtime entry resolution.
- formal cloud callers and smoke scripts must derive their host or origin from
  that file or from an explicit env override, rather than repeating a raw cloud
  host or IP in multiple entrypoints.
- `admin` runtime selection must require an explicit admin API target rather than silently assuming a local server.
- `bff` and `server` runtime config must expose whether they are using:
  - cloud-host internal loopback
  - explicit local development dependencies
  - isolated runtime dependencies
- local and isolated scripts must self-identify their chain and target ports in startup output.

## 6. Formal Conclusion

- Repository-wide runtime cleanup may proceed without changing business truth or contracts, provided it stays inside this boundary.
- Later code changes must preserve the distinction between:
  - explicit tunnel access for local frontend work
  - legitimate cloud-host internal loopback
  - explicit local or isolated chains
- Any future change that reintroduces a silent localhost fallback into a formal caller path must be treated as drift and rejected.
