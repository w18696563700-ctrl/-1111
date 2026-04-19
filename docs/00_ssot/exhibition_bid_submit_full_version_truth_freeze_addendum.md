---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the user-confirmed exhibition bid-submit full-version truth so the
  current page becomes a clean project-check + required-attachments flow
  without reintroducing seat limits, fee semantics, or the old
  seat/completeness explanation face.
layer: L0 SSOT
freeze_date_local: 2026-04-15
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《竞标提交页满分版 truth freeze》

## 1. Scope

- 本文件只冻结：
  - `竞标提交页满分版改造`
- 本文件不进入：
  - implementation
  - implementation unlock
  - 新的 second state machine
  - 独立 seat console
  - 独立 completeness workspace

## 2. Frozen Objective

- 当前页面的正式目标固定为：
  - 先核对项目
  - 再填写报价与方案说明
  - 再上传 3 份必选文档
  - 最后提交竞标
- 当前页面不再以解释卡驱动用户。

## 3. Confirmed UI Truth

- 首屏标题固定为：
  - `第一步 核对项目`
- 顶部必须直接展示：
  - 核心信息
  - 地点与安排
- 当前必须隐藏的内容固定为：
  - 页面总说明卡
  - 当前展示方式卡
  - 冗长承接说明
  - 席位状态
  - 资料完整度
  - 结果页大段解释卡
- 当前 submit page 不再把 seat / completeness 作为主阅读入口。

## 4. Business Rule Freeze

- 当前竞标规则固定为：
  - 不设置席位数量限制
  - 报价自由
  - 不收报名费
  - 不收占位费
- 当前页面仍然允许保留最小提交反馈，但不得重新长成工作台。

## 5. Required Attachment Semantics

- 当前必选文档固定为 3 份：
  - `项目理解`
  - `报价表`
  - `进度安排`
- 每一份都必须是独立上传槽位。
- 每一份都必须先完成：
  - `init -> direct upload -> confirm`
- 提交时引用的必须是：
  - confirmed `FileAsset`
- 提交时不得引用：
  - `objectKey`
  - 未 confirm 的上传会话
  - 本地伪造文件状态

## 6. Template Download Semantics

- 模板下载区固定放在：
  - `第三步 上传必选文档`
  - 标题下方
- 模板下载区只承接：
  - 后台管理系统已发布的 3 份实例模板
- 模板下载区不得放到：
  - 结果页按钮下方
  - 另一个资源中心入口
- 模板下载区的存在只为：
  - 帮助用户照着填
  - 不重开第二套模板治理系统

## 7. Canonical Path Retention Decision

- `POST /api/app/bid/submit` 继续是当前 submit 的唯一 app-facing 提交入口。
- `POST /api/app/file/upload/init`
- `POST /api/app/file/upload/confirm`
- `GET /api/app/file/access`
  继续是当前页面的文件链路基础。
- `GET /api/app/project/public-resources`
  继续是已存在的 app-shared 目录 truth。
- `seat` / `bid package completeness`
  相关 canonical path truth 当前不删除，但对本 submit page 的消费面已退役。
- 也就是说：
  - canonical truth 仍在
  - 当前页面不再消费旧 seat / completeness 展示面

## 8. Acceptance Boundary

- 进入页面后应首先看到：
  - 项目核对信息
- 用户完成 3 个 confirmed FileAsset 后才允许提交。
- 模板区必须先于上传槽位出现。
- 提交成功后只保留最小回执。
- 结果页不得再出现 seat / completeness 说明卡。

## 9. Formal Conclusion

- 当前 truth freeze 的正式结论固定为：
  - 这是一个清爽型、必传附件型、模板下载型的最小竞标提交页
  - 不是席位页
  - 不是 completeness 工作台
  - 不是收费页
