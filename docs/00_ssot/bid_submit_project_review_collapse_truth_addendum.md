---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the narrow frontend UX refinement for the exhibition bid-submit staged
  reveal so the first project-check step collapses after continuation while
  preserving an explicit re-open path for review.
layer: L0 SSOT
freeze_date_local: 2026-04-27
based_on:
  - AGENTS.md
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
  - docs/04_frontend/project_attachment_prepublish_and_bid_materials_frontend_surface_addendum.md
---

# 《竞标提交页项目核对折叠体验 truth addendum》

## 1. Current Minimum Loop

- `立即参与竞标` 进入 `/exhibition/bids/submit` 后，首屏仍固定为：
  - `第一步 核对项目`
- 首屏仍必须展示：
  - 核心信息
  - 地点与安排
- 点击 `继续竞标` 后，当前页继续显示：
  - 项目附件只读区
  - `第二步 填写报价与方案说明`
  - `第三步 上传必选文档`

## 2. UX Refinement Freeze

- 点击 `继续竞标` 后，`第一步 核对项目` 不再继续完整占据第二屏顶部。
- 点击后允许把第一步压缩为：
  - 已核对摘要
  - 项目名称 / 编号 / 状态 / 地点 / 时间等最小识别信息
  - `重新展开核对` 动作
- 用户点击 `重新展开核对` 后，可以再次查看完整：
  - 核心信息
  - 地点与安排
- 展开后允许提供：
  - `收起核对信息`

## 3. Boundary

- 本次只改变 Flutter 展示密度。
- 本次不改变：
  - `POST /api/app/bid/submit`
  - 3 个 confirmed `FileAsset` 必传槽位
  - 项目附件只读投影
  - BFF aggregation / shaping
  - Server business truth
  - seat / completeness retired-from-page decision

## 4. Which Is Safer / Cheaper / Stage-fit

- 更稳：折叠为摘要并保留 `重新展开核对`。
- 更省成本：仅点击后自动滚动到项目附件。
- 更适合当前阶段：折叠为摘要并保留重看入口。
- 风险更大：删除第一步、重做 stepper 状态机，或把 submit page 扩回完整工作台。

## 5. Formal Conclusion

- 当前正式冻结为：
  - 首屏完整核对项目
  - 继续后第一步折叠成摘要
  - 必要时可重新展开核对
  - 不改动任何 BFF / Server 真值
