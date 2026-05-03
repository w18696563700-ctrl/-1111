---
owner: Codex 总控
status: active
layer: L0 SSOT index
recorded_at_local: 2026-05-03
scope: Current release-scope truth index only
---

# Current Truth Index

## 20260503 Release Scope

本索引只登记 `20260503 发布范围四层对齐收口轮` 的当前真相，不代表全项目所有模块均已重新索引。

| Scope | Current truth |
| --- | --- |
| 四层对齐收口 | `docs/00_ssot/release_scope_four_layer_alignment_20260503.md` |
| 发布验收回执 | `docs/00_ssot/evidence/mobile_uat_20260503/20260503-release-acceptance-receipt.md` |
| 手机端 UAT evidence | `docs/00_ssot/evidence/mobile_uat_20260503/` |
| release build gate fix | `docs/00_ssot/evidence/release_build_gate_fix_20260503.md` |
| P0 contracts parity baseline receipt | `docs/00_ssot/evidence/p0_contracts_parity_20260503/day0_day6_p0_contracts_parity_baseline_receipt.md` |

Current裁决：

- `Go` for next development baseline on runtime-verified project communication / workbench / material-review tested path / read-cursor / release infrastructure.
- `No-Go` for treating contract confirmation, final confirmed amount, payment, callback, file upload three-step flow, enterprise hub full scope, membership full scope, or project publish full chain as covered by this release.
- `Conditional` because workbench / material-review / read-cursor / project communication message read paths now have formal OpenAPI and generated type parity in the current working tree, but the patch must be committed and pushed before it becomes an inherited repository baseline.

P0 contracts parity snapshot:

- `Current`: `GET /api/app/message/counterpart-conversation/detail`.
- `Current`: `GET /api/app/message/project-communication/thread`.
- `Current`: `GET /api/app/message/project-communication/messages`.
- `Current`: `POST /api/app/message/project-communication/read-cursor`.
- `Current`: `GET /api/app/message/project-communication/workbench`.
- `Current`: `POST /api/app/message/project-communication/workbench/material-review`.
- `Reserved / next gate`: `POST /api/app/message/project-communication/messages` exists in code and tests, but is not part of this contracts parity baseline because the current runtime-verified scope only requires message read plus the previously controlled UAT write receipt.
