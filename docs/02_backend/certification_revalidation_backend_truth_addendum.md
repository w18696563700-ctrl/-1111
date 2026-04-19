---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth rule for approved certification correction without
  introducing a second certification state machine or shadow truth in the
  current round.
layer: L3 Backend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_revalidation_entry_ruling_addendum.md
---

# 《认证资料更正 Backend Truth 补充冻结》

## 1. Truth Owner

- `Server` 是 `认证资料更正` 的唯一 truth owner。

## 2. Current-round Truth Model

- 当前轮不引入 shadow truth 表。
- 当前轮不引入新的认证状态机。
- 当前轮采用：
  - 读取当前已批准认证 truth
  - 执行 OCR 自动核验
  - 核验通过才原位更新当前认证 truth
  - 核验失败则拒绝命令并保持旧 truth 不变

## 3. Eligibility Rule

- `revalidate` 当前只允许：
  - verified current session
  - current organization scope
  - organization admin
  - current certification status = `approved`

## 4. Audit Rule

- 必须记录：
  - old snapshot
  - new snapshot
  - correction note
  - license file id
  - OCR request ref
  - command outcome
- 当前轮正式允许：
  - 单独的 revalidation attempt audit table / entity
- 当前轮明确不要求：
  - 单独 review queue
  - 单独 admin review state machine

## 5. Three-board Safety Rule

- 当前轮 `revalidate` 成功前：
  - 不改变三板块主线资格
- 当前轮 `revalidate` 成功后：
  - 仍保持 `approved`
  - 三板块主线继续沿用当前已批准认证

## 6. Explicit Non-scope

- 当前不引入：
  - pending correction truth
  - delayed review queue
  - independent review workflow
  - project visibility side effects
