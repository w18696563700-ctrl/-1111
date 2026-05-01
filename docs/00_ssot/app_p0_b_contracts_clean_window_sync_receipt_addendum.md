---
owner: 总控 Agent
status: frozen
purpose: Record the P0-B contracts clean-window synchronization result.
layer: L0 SSOT
freeze_date_local: 2026-05-01
depends_on:
  - docs/00_ssot/app_p0_b_contracts_clean_window_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/openapi/openapi.bundle.json
  - packages/contracts/src/generated/app-api.types.ts
  - packages/contracts/contracts-manifest.json
---

# 《P0-B contracts clean-window 同步回执》

## 1. 总结论

P0-B contracts clean-window 同步结论：`Pass with inherited dirty-worktree note`。

本次实际关闭的 P0-B 漂移：

- `GET /api/app/message/index` 已从 active formal path 中移除。
- `GET /api/app/message/interactions` 已进入 formal OpenAPI / bundle / generated `APP_API_PATHS`。
- `POST /api/app/profile/governance/appeals` 已从 active formal method 中移除；`GET list/detail` 保持只读 active。
- `POST /api/app/auth/password/login|set|reset` 已进入 formal OpenAPI / bundle / generated `APP_API_PATHS`，范围限定为 App-facing bounded auth。

## 2. 合同路径核查

| path | 期望 | 当前结果 | 裁决 | 依据类型 |
| --- | --- | --- | --- | --- |
| `/api/app/message/index` | 不在 active formal path | `ABSENT` | 关闭旧 path 漂移 | contracts / generated |
| `/api/app/message/interactions` | `GET` active | `GET` | 当前消息交互主线 formalized | contracts / generated / 代码 / runtime |
| `/api/app/profile/governance/appeals` | 只保留 `GET` | `GET` | 申诉历史只读，submit 移出 P0 active | contracts / generated / 代码 / runtime |
| `/api/app/auth/password/login` | `POST` active | `POST` | bounded password login formalized | contracts / generated / 代码 / runtime |
| `/api/app/auth/password/set` | `POST` active | `POST` | bounded password set formalized | contracts / generated / 代码 |
| `/api/app/auth/password/reset` | `POST` active | `POST` | bounded password reset formalized | contracts / generated / 代码 |

## 3. 执行命令

| 命令 | 结果 |
| --- | --- |
| `pnpm contracts:generate` | 通过；生成 `contracts-manifest.json`、`openapi.bundle.json`、`app-api.types.ts`、`error-codes.ts`、`index.ts` |
| `pnpm contracts:check` | 通过；manifest hash 与派生产物一致 |
| `ruby -ryaml -e ...` 路径断言 | 通过；P0-B 六个 active path/method 与裁决一致 |

## 4. inherited dirty-worktree note

本次执行前 `docs/01_contracts/openapi.yaml`、`docs/01_contracts/error_codes.yaml`、`packages/contracts/src/generated/app-api.types.ts`、`packages/contracts/src/generated/error-codes.ts`、`packages/contracts/openapi/openapi.bundle.json` 已处于 dirty 状态。

因此，官方 `pnpm contracts:generate` 在保持派生产物一致性的同时，也追平了既存 OpenAPI / error-code 输入中的非 P0-B 变更。这些变更不得被解释为本轮 P0-B 新增业务范围，不得据此把 payment、membership、notification、order、contract、fulfillment、settlement 等能力纳入本轮 P0 裁决。

本轮 P0-B 的验收只看第 2 节列出的四类 clean-window 断言。

## 5. 门禁结论

第 2 天 `P0-B 最小 Contracts 同步`：`Pass`。

允许进入第 3 天 `P0-C Exhibition Report 最小闭环设计`。
