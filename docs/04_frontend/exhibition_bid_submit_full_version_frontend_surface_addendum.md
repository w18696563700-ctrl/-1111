---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption boundary for the exhibition bid-submit full
  version so the page becomes a clean first-step project-check flow with three
  required upload slots and a step-3 template download zone, while the old
  seat/completeness/explanation cards stay hidden.
layer: L5 Frontend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/01_contracts/openapi.yaml
---

# 《竞标提交页满分版 frontend surface freeze》

## 1. Scope

- 本文件只覆盖：
  - `/exhibition/bids/submit`
  - `mode=result` 的最小结果回读面
- 本文件不进入：
  - implementation
  - second workbench
  - seat console
  - completeness workspace

## 2. Page Layout Freeze

- 页面首屏固定为：
  - `第一步 核对项目`
- 首屏必须直接展示：
  - 项目完整关键信息
  - 核心信息
  - 地点与安排
- 页面必须隐藏：
  - 页面总说明卡
  - 当前展示方式卡
  - 冗长承接说明
  - 席位状态
  - 资料完整度
  - 结果页大段解释卡

## 3. Step Flow Freeze

- Step 1:
  - `第一步 核对项目`
- Step 2:
  - `第二步 填写报价与方案说明`
- Step 3:
  - `第三步 上传必选文档`
- Submit:
  - `提交竞标`

## 4. Required Upload Slots

- `方案说明` 下方必须出现 3 个独立上传槽位：
  - `项目理解`
  - `报价表`
  - `进度安排`
- 每个槽位都必须走：
  - `init -> direct upload -> confirm`
- 3 个槽位都 confirmed 之前：
  - 禁止提交
- 3 个槽位的 binding 只允许对接：
  - confirmed `FileAsset`

## 5. Template Download Zone Freeze

- 模板下载区必须放在：
  - `第三步 上传必选文档`
  - 标题下方
- 模板下载区只展示：
  - 后台已上传的 3 份实例模板
- 模板下载区不得放到：
  - 结果页按钮下方
  - 另一个资源中心入口
- 模板区的作用只允许是：
  - 让用户照着填

## 6. Result Surface Freeze

- 提交成功后的结果页只保留：
  - 最小回执
  - 回到项目详情
  - 回到项目展示
- 结果页不得再展示：
  - seat 状态
  - completeness 状态
  - 大段解释卡
  - 模板下载区

## 7. Local State Boundary

- Flutter 可以做：
  - section rendering
  - upload progress rendering
  - confirmed FileAsset binding display
  - controlled invalid / unavailable presentation
- Flutter 不得做：
  - 自己造 bid truth
  - 自己造 seat truth
  - 自己造 completeness truth
  - 自己造 FileAsset truth
  - 自己直连 Server

## 8. Acceptance Criteria

- 进入 submit page 后，首屏先看到项目核对信息。
- 3 个必选文档都必须完成 confirm。
- submit 按钮在 3 个 confirmed FileAsset 都齐全前不可用。
- 模板下载区出现在 step 3 标题下方。
- 结果页不再出现长解释与 seat / completeness 卡。

## 9. Formal Conclusion

- 当前 Flutter authority 正式冻结为：
  - 清爽型 bid submit
  - 3 槽位必传附件
  - step 3 模板下载区
  - 最小结果回读
