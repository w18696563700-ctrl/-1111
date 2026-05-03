---
owner: Codex 总控
status: frozen
layer: L0 SSOT / release scope alignment
recorded_at_local: 2026-05-03
runtime_release_commit: d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8
evidence_archive_commit: 31834287b3c86f9d60e2c7b673b5661df5153b6e
scope: 20260503 release range four-layer alignment
---

# 20260503 发布范围四层对齐收口

## 1. 总裁决

本次四层对齐裁决为 `Conditional Go for next development baseline`。

允许把本次 release 中已经 runtime verified 的项目沟通、工作台、资料审阅、read-cursor、BFF runtime source、Admin release build、Server native dependency 修复和 release evidence 作为下一轮开发基线。

不允许把合同确认、最终成交金额确认、支付、扣费、回调、文件上传三步流、企业馆全量、会员系统全量或项目发布全链路纳入本次基线外推。

P0 contracts parity 已在本轮工作区补齐并通过生成与校验；在该补丁正式 commit / push 前，仓库基线仍按 `Conditional` 管理。

## 2. 对齐输入

| Item | Path / Value |
| --- | --- |
| runtime release commit | `d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8` |
| evidence archive commit | `31834287b3c86f9d60e2c7b673b5661df5153b6e` |
| 发布验收回执 | `docs/00_ssot/evidence/mobile_uat_20260503/20260503-release-acceptance-receipt.md` |
| 手机端 UAT evidence | `docs/00_ssot/evidence/mobile_uat_20260503/` |
| workbench SSOT | `docs/00_ssot/project_communication_workbench_ten_entry_review_day1_freeze_addendum.md` |
| workbench contracts freeze | `docs/01_contracts/project_communication_workbench_ten_entry_review_contract_field_table_day2_addendum.md` |
| workbench Server truth | `docs/02_backend/project_communication_workbench_ten_entry_review_server_truth_day3_addendum.md` |
| workbench BFF freeze | `docs/03_bff/project_communication_workbench_ten_entry_review_bff_route_read_model_day2_addendum.md` |
| workbench Flutter freeze | `docs/04_frontend/project_communication_workbench_ten_entry_review_day4_flutter_structure_addendum.md` |
| unread/read contracts freeze | `docs/01_contracts/project_communication_unread_read_contract_field_table_day1_addendum.md` |
| unread/read BFF freeze | `docs/03_bff/project_communication_unread_read_bff_route_read_model_day1_addendum.md` |
| release build gate fix | `docs/00_ssot/evidence/release_build_gate_fix_20260503.md` |

## 3. 状态枚举

| Status | Meaning |
| --- | --- |
| `Current` | 文书、代码或本地 main 已存在，可作为当前事实，但不单独证明云端可用。 |
| `Runtime Verified` | 已通过云端 current / PID cwd / health / smoke / UAT evidence 证明。 |
| `Runtime Unknown` | 本地或文书存在，但本轮未证明云端可用。 |
| `Reserved` | 入口或设计保留，但本轮不开通正式写入或对外能力。 |
| `Blocked` | 存在明确漂移或缺口，进入下一轮前必须补齐。 |
| `Deprecated` | 旧口径已废止，不得作为新正式入口或新 truth。 |

## 4. 四层对齐表

| Release scope item | 文书 / SSOT | 合同 / OpenAPI / Types | 代码实现 | 运行态 | Verdict |
| --- | --- | --- | --- | --- | --- |
| project communication 主链 | `Current`：项目沟通工作台与消息记录边界已冻结。 | `Current`：counterpart detail、thread、messages、read-cursor、workbench、material-review 已补入 OpenAPI 和 generated app types。 | `Current`：Flutter counterpart conversation、BFF message interaction、Server project communication 均有实现。 | `Runtime Verified`：双账号 UAT 可进入项目沟通页，health 200。 | `Runtime Verified`；contracts parity 已补，待入库。 |
| thread / messages | `Current`：项目、thread、message 锚点冻结。 | `Current`：`/api/app/message/project-communication/messages` 在 generated paths 中存在；read-state 字段为 additive freeze。 | `Current`：Flutter 消息列表、BFF transport、Server message/read cursor 实现存在。 | `Runtime Verified`：UAT smoke 消息双方 UI 可见。 | `Runtime Verified`。 |
| workbench 10 入口 | `Current`：10 入口、5+3+2 命名和旧名废止已冻结。 | `Current`：`/api/app/message/project-communication/workbench`、10 个 entryKey、分组、状态、truthAnchor 已进入 OpenAPI/generated。 | `Current`：BFF/Server route、Flutter workbench UI 和 parser 已实现。 | `Runtime Verified`：双账号工作台截图显示 `报价表确认` 已确认。 | `Runtime Verified`；合同层已补，待入库。 |
| material-review 8 项资料审阅 | `Current`：8 资料确认/反馈 truth owner 已冻结为 Server。 | `Current`：`/api/app/message/project-communication/workbench/material-review` request/response、8 个 material review entryKey 和 action 枚举已进入 OpenAPI/generated。 | `Current`：Server material review table/service/controller、BFF forwarder、Flutter detail/submit chain 存在。 | `Runtime Verified`：controlled write smoke 将 `bid_quote_sheet_review` 置为 `confirmed`，UI 已验证。 | `Runtime Verified` for tested path；8 entry matrix 仍需后续补验。 |
| read-cursor | `Current`：read cursor 口径冻结为 `projectId + threadId + lastReadMessageId`。 | `Current`：`/api/app/message/project-communication/read-cursor` request/response 已进入 OpenAPI/generated。 | `Current`：BFF/Server POST read-cursor 和 Flutter 调用存在。 | `Runtime Verified`：controlled write smoke 已执行 1 次 read-cursor，未出现 5xx。 | `Runtime Verified`；待入库。 |
| BFF runtime source | `Current`：release build gate fix 已冻结。 | `Current`：不涉及 OpenAPI。 | `Current`：`.gitignore` 放行 `apps/bff/src/core/runtime/*.ts`，两个 runtime source 已 tracked。 | `Runtime Verified`：BFF current 指向新 release，PID cwd 指向新 release，health 200。 | `Runtime Verified`。 |
| Admin release build | `Current`：release build gate fix 已冻结 `next build --webpack` 策略。 | `Current`：不涉及 App OpenAPI。 | `Current`：`apps/admin/package.json` build 使用 `next build --webpack`。 | `Runtime Verified`：Admin current/PID cwd 指向新 release，`/api/health` 200。 | `Runtime Verified`。 |
| Server native dependency | `Current`：发布链路中已记录 native dependency / GLIBC 修复。 | `Current`：不涉及 App OpenAPI。 | `Current`：Server release 使用当前 ECS 环境重建 production dependency。 | `Runtime Verified`：Server native-fix release current/PID cwd 指向新 release，health/ready 200。 | `Runtime Verified`。 |
| release / smoke / UAT evidence | `Current`：发布验收回执已归档。 | `Current`：不涉及接口定义。 | `Current`：evidence archive commit 已入 main。 | `Runtime Verified`：4 张 2560x1440 PNG 截图和验收回执已归档。 | `Runtime Verified`。 |
| contract_confirmation | `Reserved`：入口可见，Server truth owner 已冻结。 | `Current`：deal-confirmations route 已在 OpenAPI/generated 中存在。 | `Reserved`：入口/只读状态可展示。 | `Reserved`：本次未执行真实合同确认写 smoke。 | `Reserved`，不能作为 RC 写入项。 |
| final_confirmed_amount_confirmation | `Reserved`：最终成交金额不得由 Flutter/BFF 造真值。 | `Current`：deal-confirmations route family 存在；不得混用 `/api/app/contract/confirm`。 | `Reserved`：入口/只读状态可展示。 | `Reserved`：未触发最终成交金额确认、未触发扣费。 | `Reserved`，不能作为 RC 写入项。 |
| 旧入口名 `报价确认 / 排期确认 / 工艺材质确认` | `Deprecated`：正式入口名已废止。 | `Deprecated`：不得作为新 contract label。 | `Deprecated`：新工作台不得使用为正式入口。 | `Deprecated`：UAT 验证新 UI 使用 `报价表确认`。 | `Deprecated`。 |

## 5. Runtime Evidence

本轮只读复核云端运行态：

| Layer | current | PID cwd | health |
| --- | --- | --- | --- |
| Server | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` | `live=200`, `ready=200`, Nginx server live `200` |
| BFF | `/srv/releases/bff/20260503034500-d97a3f2-main-phase-a3` | `/srv/releases/bff/20260503034500-d97a3f2-main-phase-a3` | `live=200`, `ready=200`, Nginx bff live `200` |
| Admin | `/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3` | `/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3` | `/api/health=200` |

UAT evidence:

| Evidence | Path |
| --- | --- |
| owner 工作台确认状态 | `docs/00_ssot/evidence/mobile_uat_20260503/owner_workbench_message.png` |
| owner 消息可见 | `docs/00_ssot/evidence/mobile_uat_20260503/owner_message_visible.png` |
| counterpart 工作台确认状态 | `docs/00_ssot/evidence/mobile_uat_20260503/counterpart_workbench_message.png` |
| counterpart 消息可见 | `docs/00_ssot/evidence/mobile_uat_20260503/counterpart_message_visible.png` |

## 6. 仍存在的漂移

| Drift | Current finding | Risk | Fix recommendation |
| --- | --- | --- | --- |
| Workbench/material-review 正式 OpenAPI 缺口 | 本轮已补：`docs/01_contracts/openapi.yaml`、`packages/contracts/openapi/openapi.bundle.json`、`packages/contracts/src/generated/app-api.types.ts` 均包含 workbench/material-review path 和 schema。 | 未 commit / push 前仍不是远端仓库基线。 | 先完成入库门禁，再进入 8 entry matrix。 |
| read-cursor formal contract parity 不完整 | 本轮已补：正式 OpenAPI/generated 已包含 read-cursor payload/result 与 `lastReadMessageId`。 | 未 commit / push 前仍不是远端仓库基线。 | 先完成入库门禁，再扩大调用方使用。 |
| `Contract / final amount` 入口与真实写入边界 | 入口保留，deal-confirmations route family 存在；本次未执行真实写 smoke。 | 误把入口可见当成合同/金额可写，会触发资金风险。 | 保持 `Reserved`，单独做支付/合同/最终金额门禁，禁止并入资料审阅线。 |
| 文件预览能力不是文件上传三步流验收 | 本次只验证已有文件预览和资料读取。 | 不能证明上传、确认 FileAsset、预览全格式都可用。 | 文件上传三步流另起验收，不纳入本次 release baseline。 |
| 受控写 smoke 覆盖有限 | `material-review` 只验证指定 project/thread/bid 的 `bid_quote_sheet_review`。 | 不能证明 8 个 entry 全组合都在真实数据上通过。 | 下一轮补 8 entry matrix 的只读和低风险写入测试，仍需避免支付/合同/金额。 |

## 7. 可作为新开发基线的能力

以下能力允许作为下一轮 P0 主链开发基线：

| Capability | Baseline status |
| --- | --- |
| 项目沟通页进入和消息显示 | `Runtime Verified` |
| 指定 thread/message 的 UAT 消息显示 | `Runtime Verified` |
| 10 入口工作台基本展示 | `Runtime Verified` |
| `bid_quote_sheet_review` confirmed 状态读取和 UI 展示 | `Runtime Verified` |
| material-review command 受控写入链路 | `Runtime Verified` for tested entry |
| read-cursor 受控写入链路 | `Runtime Verified` |
| BFF runtime source 纳入 Git 并可发布 | `Runtime Verified` |
| Admin release build 隔离策略 | `Runtime Verified` |
| Server native dependency 修复 release | `Runtime Verified` |

## 8. 不能作为 RC / 对外开放项的能力

以下能力仍不得作为 RC 或对外开放项：

| Capability | Status | Reason |
| --- | --- | --- |
| 合同确认真实写入 | `Reserved` | 本次禁止并未验证。 |
| 最终成交金额确认真实写入 | `Reserved` | 涉及平台服务费收费基准，本次禁止并未验证。 |
| 支付 / 扣费 / 回调 | `Blocked` | 本次明确禁止。 |
| 文件上传三步流 | `Runtime Unknown` | 本次仅验证已有文件读取/预览。 |
| 企业馆全量 | `Out of scope` | 不属于本次 release 范围。 |
| 会员系统全量 | `Out of scope` | 不属于本次 release 范围。 |
| 项目发布全链路 | `Out of scope` | 不属于本次 release 范围。 |
| APNs / FCM / 震动 | `Reserved` | 用户明确后置。 |

## 9. 下一轮 P0 主链四层对齐清单

下一轮建议按以下顺序进入，不直接扩功能：

1. Contracts parity 入库：把本轮 OpenAPI/generated patch 作为正式仓库基线。
2. Runtime route matrix：用 GET 验证 10 入口 read-model 全字段，记录 entry count、entryKey、状态、routeTarget。
3. Material review matrix：在受控测试数据上覆盖 8 个资料 entry 的 `pending_review / confirmed / needs_supplement / unsubmitted`。
4. UI matrix：手机端分别验证 owner/counterpart 对 5+3 资料页的只读、可确认、可反馈状态。
5. Boundary matrix：继续证明合同确认、最终成交金额、支付、扣费、回调没有被误触发。
6. Evidence closure：每轮形成 receipt，不以本地测试替代云端 runtime 证据。

## 10. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 先把本轮 OpenAPI/generated parity 入库，再扩 8 entry matrix 和合同/金额门禁。 |
| 哪个更省成本 | 直接沿用当前 runtime verified 的 workbench/material-review/read-cursor 做下一轮开发，但在未入库前会留下仓库基线漂移。 |
| 哪个更适合当前阶段 | 采用 `Conditional Go`：承认 runtime baseline 和本轮合同补丁，同时要求先完成入库门禁。 |
| 哪个风险更大 | 把合同确认、最终成交金额、支付、文件上传三步流混入本次 release baseline。 |

## 11. Go / No-Go

`Go`：

- project communication、thread/messages、workbench、material-review tested path、read-cursor、BFF runtime source、Admin release build、Server native dependency、release/smoke/UAT evidence 可作为下一轮开发基线。

`No-Go`：

- 不能把本次 release 直接标成合同/最终金额/支付/文件上传/企业馆/会员/项目发布全量 RC。

`Conditional`：

- 下一轮进入开发前，必须先把本轮 workbench/material-review/read-cursor OpenAPI/generated contract parity patch 入库；否则只能按工作区草案处理，不能作为远端仓库基线。
