---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption detail for collapsing the bid-submit project
  review section after the user continues into the rest of the staged flow.
layer: L5 Frontend
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/bid_submit_project_review_collapse_truth_addendum.md
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
  - docs/04_frontend/project_attachment_prepublish_and_bid_materials_frontend_surface_addendum.md
---

# 《竞标提交页项目核对折叠 frontend surface addendum》

## 1. Current Minimum Loop

- 首屏仍完整展示 `第一步 核对项目`。
- 点击 `继续竞标` 后，Flutter 继续展示：
  - 项目附件
  - `第二步 填写报价与方案说明`
  - `第三步 上传必选文档`

## 2. Frontend Rendering Rule

- `_bidFlowExpanded = false` 时：
  - `第一步 核对项目` 展示完整核心信息与地点安排。
- `_bidFlowExpanded = true` 且用户未重新展开时：
  - `第一步 核对项目` 压缩为已核对摘要。
  - 摘要必须保留 `重新展开核对`。
- 用户点击 `重新展开核对` 后：
  - 完整核心信息与地点安排重新显示。
  - 页面允许显示 `收起核对信息`。

## 3. Non-goals

- 不新增 BFF / Server API。
- 不修改 `bid/submit` command shape。
- 不修改 3 个 confirmed `FileAsset` 必传槽位。
- 不把页面扩展成完整竞标工作台。

## 4. Formal Conclusion

- 当前 Flutter surface 正式固定为：
  - 首屏完整核对
  - 继续后摘要承接
  - 显式重新展开
  - 不改变后端真值
