---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF shaping boundary for approved certification correction.
layer: L4 BFF
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/certification_revalidation_contracts_addendum.md
---

# 《认证资料更正 BFF Surface 补充冻结》

## 1. BFF Responsibility

- `BFF` 只负责：
  - app-facing route 暴露
  - auth consolidation
  - error normalization
  - accepted response shaping

## 2. Hard Boundary

- `BFF` 不得：
  - 自建认证更正状态机
  - 自建资格判断
  - 自建旧值/新值 truth

## 3. Route Rule

- 当前轮新增：
  - `POST /api/app/profile/certification/revalidate`

## 4. Error Rule

- BFF 必须区分：
  - 当前状态不允许更正
  - 当前组织 scope 不可用
  - 当前营业执照文件不可用
  - OCR 自动核验未通过

## 5. Current Surface Rule

- 当前轮不要求新增独立 revalidation read surface。
- `certification/current` 仍然只返回当前正式 truth。
- 因为当前轮没有待审核 shadow truth：
  - Flutter 若需表达“当前是否处于待审核更正中”
  - 只能消费冻结结论：
    - 当前不存在独立待审核更正状态
