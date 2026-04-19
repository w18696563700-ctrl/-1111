---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the mainline-facing ruling for approved-organization certification
  correction, including whether approved organizations may initiate it, whether
  current approved truth remains effective, and how the three-board mainline is
  affected.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_license_field_collection_ruling_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
---

# 《已认证主体资料更正入口裁决单》

## 1. Final Naming

- 当前正式能力名称冻结为：
  - `认证资料更正`
- 本轮不再使用用户可见的“双名并行”：
  - `重认证`
  - `重新认证`

## 2. Mainline Position

- `认证资料更正` 是：
  - `项目工作台 / 项目发布 / 项目展示`
  的前置资格修复能力。
- 它不是独立的 profile 小功能。

## 3. Entry Ruling

- `approved` 组织当前正式允许发起：
  - `认证资料更正`
- 当前不要求先把组织打回 `rejected / expired` 才允许修正资料。

## 4. Current-round State Ruling

- 当前轮不引入新的认证状态机取值。
- 当前明确不新增：
  - `revalidating`
  - `approved_pending_refresh`
  - `updating`
- 当前继续复用现有正式认证状态：
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`

## 5. Truth Switch Ruling

- 当前轮不引入“待审核影子 truth”。
- 当前轮的 `认证资料更正` 走的是：
  - `受控更正命令`
  - `即时 OCR 自动核验`
  - `通过才覆盖正式 truth`
  - `不通过不改变当前已生效认证`

## 6. Impact On Three-board Mainline

- 当 `approved` 组织发起 `认证资料更正` 时：
  - 若更正成功：
    - 正式认证资料更新
    - 认证状态仍为 `approved`
    - `项目工作台` 资格不被先行冻结
    - `项目发布` 资格不被先行冻结
    - `项目展示` 已公开内容不因本轮资料更正被自动下线
  - 若更正失败：
    - 当前正式认证 truth 保持不变
    - `项目工作台 / 项目发布 / 项目展示` 继续沿用旧的已批准认证 truth

## 7. Audit Ruling

- `认证资料更正` 必须记录审计：
  - 发起人
  - 组织
  - 旧资料摘要
  - 新资料摘要
  - 证照文件
  - OCR 结果
  - 更正说明
- 当前轮正式要求：
  - 单独的 `revalidation audit carrier`
  - 但不引入单独的 `review/admin` 处理链

## 8. Formal Conclusion

- 当前正式允许 `approved` 组织发起 `认证资料更正`。
- 当前轮采用最小闭环：
  - 不引入新状态机
  - 不引入待审核 shadow truth
  - 不保留待审核更正中的并行正式资格
  - 通过独立审计载体记录每次资料更正尝试
  - 只在 OCR 自动核验通过时更新正式认证资料
  - 失败不打断当前已通过认证，也不先行冻结三板块主线资格
