---
owner: Codex 总控
status: frozen
purpose: Freeze the corrective BFF execution prompt for ED-3 of the enterprise-display full-closure mainline after result verification found submit-confirm error normalization drift.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_bff_execution_prompt_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
---

# 《enterprise display full closure ED-3 BFF execution prompt R2》

## 1. 当前唯一任务

- 你现在继续是：
  - `enterprise display full closure mainline`
  - `ED-3 BFF execution owner`
- 你的唯一任务不是重做 ED-3。
- 你的唯一任务是：
  - 修正 `application submit` 的 `confirm` 缺项/错误值归一语义
  - 确保 BFF 的 submit transport 不会把 `confirm` 问题误报成“资料未完成”

## 2. 当前 blocker

- verifier 已确认：
  - `Server` 侧 `submitApplication()` 要求 `payload.confirm === true`
  - 当前 `BFF normalizeSubmitPayload()` 只校验 `confirm` 是否为 `boolean`
  - 当客户端传入 `confirm = false` 时，BFF 会继续转发到 Server
  - Server 将返回 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
  - 但当前 `normalizeApplicationSubmitError()` 的 400 fallback 被写成：
    - `ENTERPRISE_HUB_PROFILE_NOT_COMPLETED`
- 结果就是：
  - 用户明明是“未确认提交”
  - app-facing 却会被错误归一成“基础资料/板块画像未完成”

## 3. 这次只允许修改

- `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- 与此问题直接相关的最小测试文件

## 4. 这次不允许修改

- `apps/server/**`
- `apps/mobile/**`
- `apps/admin/**`
- `ED-3` 其他已经通过的 create/status 中文归一逻辑
- `ED-4/ED-5` 范围

## 5. 你必须完成

1. 让 `submit` 在 BFF 侧就把 `confirm !== true` 视为缺项，不再转发成假业务 blocker。
2. 或者保证即使继续透传，最终 app-facing 也必须稳定落到：
   - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
   - `请先确认提交入驻申请后再继续。`
3. 不允许把 `confirm` 错误归一成：
   - `ENTERPRISE_HUB_PROFILE_NOT_COMPLETED`
4. 补一条最小测试，至少覆盖：
   - `submitApplication("app-1", { confirm: false }, ...)`
   - 最终 app-facing code/message 正确

## 6. 你必须遵守

1. 不得在 BFF 推导 `submitReady`。
2. 不得在 BFF 复制 application 状态机。
3. 不得把这个问题转嫁给前端拦截。
4. 不得顺手扩写到 admin review/publish 或 public list/detail。

## 7. 完成标准

- 结果必须证明：
  - `confirm` 缺项或 `confirm = false` 时，app-facing 错误语义稳定
  - 不会再把 submit 确认问题误报成资料未完成

## 8. 交付回执要求

1. 修改文件清单
2. 为什么之前会把 confirm 问题误归一为 profile-not-completed
3. 现在如何保证 submit confirm 错误语义稳定
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
