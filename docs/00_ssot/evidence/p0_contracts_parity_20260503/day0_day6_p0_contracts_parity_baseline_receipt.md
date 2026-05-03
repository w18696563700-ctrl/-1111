---
owner: Codex 总控
status: accepted
layer: L0 SSOT / L1 Contracts / L2 Generated Types / L3 Code Parity / L4 Runtime Evidence
recorded_at_local: 2026-05-03
runtime_release_commit: d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8
evidence_archive_commit: 31834287b3c86f9d60e2c7b673b5661df5153b6e
four_layer_alignment_baseline_commit: 0c673d4cb76d50df2bf951f75a30aedab2508fe0
scope: P0 contracts parity for project communication verified release paths
---

# P0 Contracts Parity Baseline Receipt 20260503

## 1. 总裁决

本轮裁决为 `Conditional Pass`。

允许把本轮已补齐并验证通过的 contracts parity 草案进入入库门禁。未 commit / push 前，远端仓库基线仍不是正式完成态。

本轮不代表开通支付、扣费、支付回调、真实合同确认、最终成交金额确认、文件上传三步流上线、企业馆全量、会员系统全量或项目发布全链路。

## 2. 本轮范围

本轮只覆盖 20260503 release 已 runtime verified 的项目沟通相关路径：

| Capability | Contract status | Runtime status |
| --- | --- | --- |
| `GET /api/app/message/counterpart-conversation/detail` | `Current` | `Runtime Verified` |
| `GET /api/app/message/project-communication/thread` | `Current` | `Runtime Verified` |
| `GET /api/app/message/project-communication/messages` | `Current` | `Runtime Verified` |
| `POST /api/app/message/project-communication/read-cursor` | `Current` | `Runtime Verified` through controlled smoke |
| `GET /api/app/message/project-communication/workbench` | `Current` | `Runtime Verified` |
| `POST /api/app/message/project-communication/workbench/material-review` | `Current` | `Runtime Verified` through controlled smoke |
| Message interaction unread fields | `Current` | `Runtime Verified` |

`POST /api/app/message/project-communication/messages` exists in BFF / Flutter / tests, and one UAT message write was previously controlled-smoke verified. It is not included in this contracts parity baseline because this round intentionally froze `thread/messages` as verified GET paths plus read-cursor/material-review controlled writes. It remains `Reserved / next gate`.

## 3. Day 0 只读盘点回执

| Item | Result |
| --- | --- |
| Git status | Worktree had existing uncommitted contracts parity draft in `docs/01_contracts/openapi.yaml` and `packages/contracts/**`. |
| Release evidence | `docs/00_ssot/evidence/mobile_uat_20260503/20260503-release-acceptance-receipt.md` confirms release acceptance PASS. |
| Four-layer baseline | `docs/00_ssot/release_scope_four_layer_alignment_20260503.md` identified workbench/material-review/read-cursor contract drift before this round. |
| BFF route scan | Existing BFF routes and tests cover counterpart detail, thread, messages GET, read-cursor, workbench, material-review. |
| Flutter consumer scan | Existing Flutter consumer layers and pages consume counterpart detail, thread/messages, read-cursor, workbench, material-review. |
| Runtime current evidence | Server/BFF/Admin current symlinks and PID cwd point to the 20260503 releases; health is 200. |

Day 0 裁决：`Go`，缺口仅限已验证 release 范围。

## 4. Day 1 Contracts 缺口冻结

本轮允许补齐：

- counterpart conversation detail GET.
- project communication thread GET.
- project communication messages GET.
- project communication read-cursor POST.
- project communication workbench GET.
- project communication workbench material-review POST.
- message interaction unread fields: `conversationUnreadCount`、`hasUnread`、`latestUnreadMessageAt`.

本轮不纳入：

- project communication message send contract parity.
- contract confirmation real write.
- final confirmed amount real write.
- payment, charge, callback.
- file upload three-step go-live.
- generic chat center expansion.

Day 1 裁决：`Go`，OpenAPI additive 范围未混入禁止项。

## 5. Day 2 Generated Types 生成与验证

本轮生成范围：

| File | Purpose |
| --- | --- |
| `docs/01_contracts/openapi.yaml` | Add runtime-verified app-facing message/workbench/read-cursor paths and schemas. |
| `packages/contracts/openapi/openapi.bundle.json` | Generated OpenAPI bundle. |
| `packages/contracts/src/generated/app-api.types.ts` | Generated app-facing path registry and TypeScript DTOs. |
| `packages/contracts/contracts-manifest.json` | Generated manifest checksum update. |
| `packages/contracts/scripts/contracts_generation_lib.rb` | Generator extension for project communication message/workbench types and stable trailing newline. |

验证结果：

| Command | Result |
| --- | --- |
| `pnpm contracts:generate` | `PASS` |
| `pnpm contracts:check` | `PASS` |
| `git diff --check -- docs/01_contracts/openapi.yaml packages/contracts/contracts-manifest.json packages/contracts/openapi/openapi.bundle.json packages/contracts/scripts/contracts_generation_lib.rb packages/contracts/src/generated/app-api.types.ts` | `PASS` |

Day 2 裁决：`Go`，generated diff 对应本轮 schema。

## 6. Day 3 SSOT 状态标定

已更新：

- `docs/00_ssot/release_scope_four_layer_alignment_20260503.md`
- `docs/00_ssot/current_truth_index.md`

状态裁决：

| Item | Status |
| --- | --- |
| workbench / material-review / read-cursor OpenAPI parity | `Current in working tree, pending repository baseline commit` |
| runtime release evidence | `Runtime Verified` |
| contract confirmation | `Reserved` |
| final confirmed amount | `Reserved` |
| payment / charge / callback | `Blocked` |
| file upload three-step go-live | `Runtime Unknown / Reserved` |
| `POST /api/app/message/project-communication/messages` contract parity | `Reserved / next gate` |

Day 3 裁决：`Conditional Pass`，状态表已清楚区分 Current、Runtime Verified、Reserved、Blocked。

## 7. Day 4 Code Parity 只读复核

验证结果：

| Layer | Command / Evidence | Result |
| --- | --- | --- |
| BFF build | `cd apps/bff && npm run build` | `PASS` |
| Server build | `cd apps/server && npm run build` | `PASS` |
| BFF targeted tests | `node --test test/project-communication-workbench-transport.test.cjs test/message-interaction-transport.test.cjs` | `PASS`, 13/13 |
| Server targeted tests | `node --test test/project-communication-workbench-material-review.test.cjs test/project-communication-message-read-state.test.cjs` | `PASS`, 6/6 |
| Flutter workbench targeted test | `flutter test test/project_communication_five_material_confirmation_entry_test.dart` | `PASS`, 4/4 |
| Flutter broader counterpart chat test | `flutter test test/counterpart_conversation_chat_test.dart` | `FAIL`, existing business-card text assertion mismatch at `counterpart conversation header uses nickname and business cards are full-flow actions` |

Flutter broader failure is not caused by the contracts parity patch: this round did not modify Flutter code. It remains a separate frontend test debt and should not be used to block contracts parity入库, but it must be visible before a broader Flutter release gate.

Day 4 裁决：`Conditional Pass`。

## 8. Day 5 Runtime Verification 只读复核

Runtime current:

| Layer | current | PID cwd | health |
| --- | --- | --- | --- |
| Server | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` | `live=200`, `ready=200` |
| BFF | `/srv/releases/bff/20260503034500-d97a3f2-main-phase-a3` | `/srv/releases/bff/20260503034500-d97a3f2-main-phase-a3` | `live=200`, `ready=200` |
| Admin | `/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3` | `/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3` | `/api/health=200` |

GET-only unauth smoke:

| Endpoint | Result |
| --- | --- |
| `GET /api/app/message/interactions` | `401`, expected without login |
| `GET /api/app/message/counterpart-conversation/detail` | `401`, expected without login |
| `GET /api/app/message/project-communication/thread` | `401`, expected without login |
| `GET /api/app/message/project-communication/messages` | `401`, expected without login |
| `GET /api/app/message/project-communication/workbench` | `401`, expected without login |

Day 5 裁决：`Conditional Pass`。Runtime health/current 正常；登录态 GET matrix 本轮未重跑，沿用发布验收回执作为已验证证据。

## 9. Day 6 Final Baseline Receipt

本轮最终基线状态：

| Item | Verdict |
| --- | --- |
| Contracts parity patch | `Ready for repository intake gate` |
| OpenAPI scope | `Runtime verified release paths only` |
| Generated types | `PASS` |
| BFF/Server targeted tests | `PASS` |
| Flutter scoped workbench test | `PASS` |
| Runtime health/current | `PASS` |
| Broader Flutter chat test | `Known unrelated failure` |
| Business writes | `None in this round` |
| Deployment/restart/migration | `None in this round` |

## 10. 禁止项确认

本轮未执行：

- 真实支付。
- 平台服务费扣费。
- 支付回调。
- 合同确认真实写入。
- 最终成交金额确认。
- 文件上传三步流。
- 企业馆全量重构。
- 会员系统全量。
- 项目发布全链路重构。
- 大规模 UI 改版。
- 云端部署。
- migration。
- Server/BFF/Admin restart。
- current symlink 切换。
- POST/PUT/PATCH/DELETE runtime write smoke。

## 11. 下一轮建议

下一轮第一门禁应为 `contracts parity 入库门禁`：

1. 复核本轮只改 contracts/SSOT/generator/generated files。
2. commit / push contracts parity patch。
3. 合并后再次确认 `pnpm contracts:check` 和 targeted tests。
4. 再进入 8 entry material-review matrix 和 UI matrix。

不得把本轮局部 contracts parity 直接扩展成全平台 RC。
