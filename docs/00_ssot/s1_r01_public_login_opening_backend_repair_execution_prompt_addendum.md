---
owner: Codex 总控
status: frozen
purpose: Freeze the execution prompt for S1-R01 P0-1a public login opening backend repair, with exact backend scope, stop conditions, checks, and the unique receipt filing path.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
  - docs/00_ssot/p0_1_public_login_opening_judgment_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_bounded_implementation_dispatch_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - apps/server/src/core/runtime-config.service.ts
  - apps/server/src/modules/auth/auth.controller.ts
  - apps/server/src/modules/auth/auth-otp.service.ts
  - apps/server/src/modules/auth/auth-session.service.ts
  - apps/server/src/modules/auth/auth-anti-abuse.service.ts
  - apps/server/src/modules/auth/auth-event-materialization.service.ts
---

# 《S1-R01 P0-1a public login opening backend repair execution 口令》

## A. Prompt Object

- 本文书是 `阶段1` 当前唯一允许发出的 execution 口令：
  - `S1-R01｜P0-1a public login opening backend repair`
- 派发对象固定为：
  - `后端 Agent（仅云端）`
- 本文书只放行：
  - backend repair execution
- 本文书不放行：
  - `S1-R02+`
  - `BFF` execution
  - `Frontend` execution
  - `stage 2`
  - `release-prep`
  - `launch`

## B. Backend Agent Identity Reminder

- 你是：
  - `后端 Agent（仅云端）`
- 你不是：
  - `总控`
  - `总控文书冻结`
  - `BFF Agent`
  - `前端 Agent`
  - `结果校验 Agent`
  - `联调发布 Agent`
- 你不独占代码库。
- 你不得回滚他人修改；若遇到并行变更，必须兼容已有变更并仅在自己负责范围内推进。

## C. Accepted Inputs

- `stage1_repair_dispatch_master_addendum.md`
- `p0_1_public_login_opening_judgment_addendum.md`
- `my_building_p0_public_login_opening_bounded_implementation_dispatch_addendum.md`
- `identity_permission_minimum_contracts.yaml`
- `account_and_enterprise_certification_rules_v1_backend_truth_addendum.md`
- `account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
- 当前 auth 相关代码：
  - `apps/server/src/core/runtime-config.service.ts`
  - `apps/server/src/modules/auth/auth.controller.ts`
  - `apps/server/src/modules/auth/auth-otp.service.ts`
  - `apps/server/src/modules/auth/auth-session.service.ts`
  - `apps/server/src/modules/auth/auth-anti-abuse.service.ts`
  - `apps/server/src/modules/auth/auth-event-materialization.service.ts`

## D. Current Objective

- 只实现 `S1-R01` 的 backend 最小 repair：
  - 把 `public OTP send` 从“开发态 / 白名单例外语义混写”修正为“受控公众可用语义”
  - 保持既有 `/server/auth/otp/send|login|refresh|logout` canonical family 不变
  - 保持既有 session / audit / anti-abuse / rollback-able runtime gate 能力可用
- 本包目标不是：
  - 公众正式上线
  - 全量开放
  - 第二登录体系
  - 组织 scope
  - 企业认证
  - messages
  - trade runtime

## E. Allowed Write Scope

- 只允许写：
  - `apps/server/src/modules/auth/**`
  - `apps/server/src/core/**` 中与 runtime gate / env semantics 直接相关的最小触点
  - `apps/server/test/**` 中与 `S1-R01` 直接相关的最小测试
- 如果需要更窄的落点，优先遵守现有模块结构，不新建平行架构。

## F. Forbidden Write Scope

- 不得写：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`
  - `packages/**`
  - `docs/**`
  - `apps/server/src/modules/profile/**`
  - `apps/server/src/modules/organization/**`
  - `apps/server/src/modules/review/**`
  - `apps/server/src/modules/project/**`
- 如发现 formal truth 或 contract 缺口，停止并返回 blocker，不得自行改 docs。

## G. Required Backend Behavior

- 必须保留：
  - `POST /server/auth/otp/send`
  - `POST /server/auth/otp/login`
  - `POST /server/auth/refresh`
  - `POST /server/auth/logout`
- 必须修正：
  - `AUTH_PUBLIC_OTP_SEND_ENABLED`
  - whitelist / test gate
  - public-open 语义与 rollback 语义的边界
- 必须保证：
  - 非白名单 actor 在受控 gate 开启时可进入 OTP send 主链
  - gate 未开启时仍然 fail-closed
  - rate-limit / abuse guard / audit / security-event materialization 不回退
  - `shellBootstrapState` 相关登录后承接不被破坏
  - 既有 `login / refresh / logout` 主链不回归

## H. Explicit Non-goals

- 不实现：
  - password login
  - WeChat login
  - SSO
  - 第二套注册体系
  - organization scope closure
  - certification submit/resubmit closure
  - `message/index`
  - `payment / billing`
  - `V2.3`
  - `release-prep`
  - `launch`

## I. Required Checks

- 运行当前云端/后端工作区内最强有界检查：
  - auth 相关 build
  - auth 相关 targeted tests
  - 若可行，最小 smoke：`otp/send -> otp/login -> refresh -> logout`
- 若任何检查无法运行，必须在 receipt 中写明：
  - 未运行原因
  - 缺少什么条件
  - 是否阻断后续 `S1-R02`

## J. Required Receipt

- 本轮 execution 的唯一正式 receipt 文书路径固定为：
  - `docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_receipt_addendum.md`
- `后端 Agent` 本轮不得直接写 `docs/**`。
- `后端 Agent` 必须先在回执消息中完整返回以下内容，由 `总控 / 总控文书冻结` 负责冻结到上述唯一 receipt 路径：
  - 云端工作区路径与运行上下文，排除任何 secret
  - changed files
  - runtime gate / whitelist 语义修正摘要
  - auth route family 是否保持不变
  - build / test / smoke commands 与结果
  - 未完成项与 blocker
  - 显式确认未编辑 `apps/bff/**`、`apps/mobile/**`、`apps/admin/**`、`packages/**`、`docs/**`
  - 显式确认 `S1-R02+`、`stage 2`、`payment / billing`、`V2.3`、`release-prep`、`launch` 仍未打开

## K. Stop Conditions

- 若实现 `S1-R01` 必须改：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `docs/**`
  则停止并返回 blocker。
- 若实现 `S1-R01` 必须提前改：
  - organization scope
  - certification
  - messages
  - trade runtime
  则停止并返回 blocker。
- 若现有 auth 代码无法在不破坏 `login / refresh / logout` 主链的前提下修正 public-open 语义，则停止并返回 blocker。

## L. Next Handoff After Receipt

- `后端 Agent` 返回 execution receipt 后：
  - 由 `结果校验 Agent` 做 `S1-R01` 独立复核
  - 只有 `S1-R01` 通过，才允许总控发 `S1-R02` execution 口令
- `后端 Agent` 不得自行继续到：
  - `S1-R02`
  - `BFF execution`
  - `Frontend execution`
  - `stage 2`
