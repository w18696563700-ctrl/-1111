---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side entry, wording, and UI boundary for approved
  certification correction.
layer: L5 Frontend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_revalidation_entry_ruling_addendum.md
---

# 《认证资料更正 Frontend Surface 补充冻结》

## 1. Entry Rule

- 当当前组织认证状态为 `approved` 时：
  - Flutter 必须提供：
    - `更正认证资料`
  的正式入口。

## 2. Copy Rule

- 用户可见文案统一使用：
  - `更正认证资料`
- 当前轮不在主按钮文案中使用：
  - `重认证`
  - `重新认证`

## 3. Mainline Explanation Rule

- 页面必须明确说明：
  - 更正认证资料只在核验通过后才会更新当前正式资料
  - 本次失败不会直接影响当前项目工作台、项目发布、项目展示资格
  - 当前轮没有单独的“待审核更正中”并行资格状态

## 4. UI Boundary

- `OCR识别预览` 与 `正式认证资料` 继续严格分区。
- 不得把 OCR 原始结果直接表达成已正式收录。
- 页面必须同时能让用户看到：
  - 当前正式认证资料
  - OCR 识别预览
  - 当前轮不存在独立待审核更正状态

## 5. Explicit Non-scope

- 当前轮不新增：
  - 更正历史列表页
  - 更正审核状态中心
  - 资格冻结本地状态机
