---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the CI secrets and runtime-access boundary for the automated
  `我的信用与约束` credit-and-constraints payload parity gate, so GitHub
  Actions can run the existing read-only contract parity script without
  hard-coding real accounts, passwords, tokens, or SSH credentials.
layer: L0 SSOT
decision_date_local: 2026-05-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/runtime_environment_entry_boundary_cleanup_freeze_addendum.md
  - docs/00_ssot/credit_constraints_default_posture_initialization_stage_gate_addendum.md
  - package.json
  - packages/tooling/runtime_checks/credit_constraints_payload_parity_check.cjs
  - docs/01_contracts/openapi.yaml
  - packages/contracts/openapi/openapi.bundle.json
---

# Credit Constraints Payload Parity CI Access Runbook Addendum

## 1. 总裁决

`PASS FOR WORKFLOW AUTHORING`。

本文件只冻结 CI secrets 与 runtime access 方式。它不新增业务能力，不改
Flutter / BFF / Server / OpenAPI / generated types，不部署、不重启、不写库。

## 2. 当前最小闭环

- Existing reusable gate:
  - `pnpm runtime:credit-constraints:payload-parity`
- Contract source:
  - `packages/contracts/openapi/openapi.bundle.json`
- Runtime probe scope:
  - `GET /health/bff/live`
  - `GET /health/server/live`
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- Auth setup:
  - bounded App password login only to establish a temporary app session for
    the read-only probes.

## 3. Runtime Access Freeze

### 3.1 Current CI Mainline

CI mainline uses direct formal cloud ingress:

- `CREDIT_CONSTRAINTS_PARITY_BASE_URL`
- default candidate value:
  - `http://47.108.180.198`

Read-only local verification on 2026-05-06:

- `GET http://47.108.180.198/health/bff/live` -> `200`
- `GET http://47.108.180.198/health/server/live` -> `200`

### 3.2 SSH Tunnel Is Not Current CI Mainline

The existing local tunnel remains a local operator path only:

- `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

This root tunnel must not be used as the long-term CI path. If GitHub runner
cannot reach the public ingress, a future round may introduce an SSH tunnel
workflow only after a restricted CI user, restricted key, known-host pinning,
and explicit rollback boundary are frozen.

## 4. Secrets And Variables

Required GitHub Secret:

- `CREDIT_CONSTRAINTS_PARITY_ACCOUNTS_JSON`

Required GitHub Variable, or Secret when the base URL must not be visible:

- `CREDIT_CONSTRAINTS_PARITY_BASE_URL`

Reserved only for a future restricted SSH-tunnel workflow:

- `ALIYUN_CI_SSH_HOST`
- `ALIYUN_CI_SSH_USER`
- `ALIYUN_CI_SSH_PRIVATE_KEY`
- `ALIYUN_CI_SSH_KNOWN_HOSTS`

The account JSON format is:

```json
[
  {
    "label": "account_a",
    "mobile": "<test-mobile>",
    "password": "<test-password>"
  }
]
```

No real mobile number, password, token, cookie, private key, or full response
payload may be written to the repository.

## 5. GitHub Actions Boundary

- First workflow mode: `workflow_dispatch` only.
- No required PR blocking status yet.
- No scheduled run yet.
- No deploy, restart, migration, database write, payment execution, deposit
  freeze, refund, settlement, or transaction-guarantee activation.
- The workflow must call the existing script and must not duplicate contract
  schema rules in YAML.
- The workflow must pass secrets through environment variables only.

## 6. Go / No-Go

- Day 2 Gate: `PASS`.
- Allowed next action:
  - create the minimum `.github/workflows/credit-constraints-payload-parity.yml`
    for manual GitHub Actions execution.
- Blocked actions:
  - root SSH CI tunnel
  - hard-coded credentials
  - PR-required gate before CI stability is proven
  - any business write or runtime mutation

## 7. Four Judgments

- 最稳：public cloud ingress plus GitHub Secret account JSON, manual
  `workflow_dispatch` first.
- 最省成本：keep only the committed local script and run it before release.
- 最适合当前阶段：direct public-ingress workflow, manual trigger, no SSH.
- 风险最大：root SSH tunnel plus broad CI permissions or hard-coded credentials.
