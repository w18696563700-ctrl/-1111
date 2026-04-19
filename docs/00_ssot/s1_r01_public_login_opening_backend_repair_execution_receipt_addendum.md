---
owner: Codex 总控
status: frozen
purpose: Freeze the execution receipt for S1-R01 P0-1a public login opening backend repair after verifying the reported code changes, bounded checks, and smoke evidence.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_public_login_opening_backend_repair_execution_prompt_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
  - apps/server/src/modules/auth/auth-anti-abuse.service.ts
  - apps/server/test/auth-public-login-opening.test.cjs
---

# 《S1-R01 P0-1a public login opening backend repair execution receipt》

## 1. Scope

- 本回执只记录：
  - `S1-R01` backend execution 已完成
  - 实际变更文件
  - runtime gate / whitelist 语义修正
  - build / test / smoke 结果
  - 当前仍未进入的范围
- 本回执不代表：
  - `S1-R01` 已通过独立结果校验
  - `S1-R02` 已打开
  - `stage 2` 已打开
  - `release-prep / launch`

## 2. Execution Result

- `S1-R01` 已在 `apps/server` 侧完成。
- 当前只改了后端 auth 的最小触点。

## 3. Changed Files

- [auth-anti-abuse.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-anti-abuse.service.ts)
- [auth-public-login-opening.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/auth-public-login-opening.test.cjs)

## 4. Runtime Gate / Whitelist Semantics Repair

- 新增显式访问模式判定：
  - `public`
  - `isolated_whitelist`
  - `closed`
- 当 `AUTH_PUBLIC_OTP_SEND_ENABLED=1` 时：
  - OTP send 直接进入 `public` 语义
  - 不再依赖白名单混写
- 当公共模式关闭时：
  - 只有在允许隔离白名单且手机号命中白名单时，才进入 `isolated_whitelist`
- 其他情况统一进入：
  - `closed`
- `assertOtpSendAllowed()` 仍保留：
  - rate limit
  - anti-abuse
  - audit / event materialization 所需流程
- 本次修正未外扩到：
  - organization scope
  - certification
  - messages
  - trade runtime

## 5. Auth Route Family Status

- `/server/auth/otp/send|login|refresh|logout` canonical family 保持不变。
- 本次未修改：
  - [auth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth.controller.ts)

## 6. Control Recheck

- `总控` 已复核实际 diff：
  - `auth-anti-abuse.service.ts` 新增 `resolveOtpSendAccessMode()`
  - `isOtpSendEnabledForMobile()` 改为基于显式 access mode
  - `assertOtpSendAllowed()` 对 `closed` 模式 fail-closed
- `总控` 已复跑以下检查：
  - `corepack pnpm build` in `apps/server`：passed
  - `node --test test/auth-public-login-opening.test.cjs`：passed，`3/3`
  - smoke：
    - command family: `NODE_ENV=production AUTH_PUBLIC_OTP_SEND_ENABLED=1 ... node - <<'NODE' ...`
    - result: `{\"mode\":\"public\",\"enabled\":true}`

## 7. Blockers

- 无代码 blocker。
- 仅有环境说明：
  - `pnpm` 不在 PATH 中，使用 `corepack pnpm`

## 8. Explicit Confirmations

- 本次后端执行未编辑：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`
  - `packages/**`
  - `docs/**`
- 本次后端执行未打开：
  - `S1-R02`
  - `S1-R03`
  - `S1-R04`
  - `S1-R05`
  - `S1-R06`
  - `stage 2`
  - `payment / billing`
  - `V2.3`
  - `release-prep`
  - `launch`

## 9. Current Stage Meaning

- 当前正确口径固定为：
  - `S1-R01 backend execution 已完成`
  - `S1-R01 result verification 尚未完成`
- 当前不得写成：
  - `S1-R01 已通过`
  - `S1-R02 已打开`
  - `阶段1 closure 已完成`

## 10. Next Unique Action

- 当前下一步唯一动作固定为：
  - `向结果校验 Agent 发出 S1-R01 独立结果校验口令`

## 11. Formal Conclusion

- `S1-R01` backend execution receipt 已冻结。
- 当前状态推进到：
  - `S1-R01 execution 完成，待独立结果校验`
