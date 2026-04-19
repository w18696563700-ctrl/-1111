---
owner: Codex 总控
status: frozen
purpose: >
  Refine the Flutter bid-submit step-3 layout so the required attachment area
  becomes a cleaner upload-first surface: the template download zone is hidden
  on the submit page, mobile stays single-column, and tablet or desktop uses a
  three-column attachment layout.
layer: L5 Frontend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/gate_register_v1.md
---

# 《竞标提交页附件区排版细化 frontend addendum》

## 1. Scope

- 本文件只覆盖：
  - `/exhibition/bids/submit`
  - `第三步 上传必选文档`
- 本文件不改动：
  - contract
  - backend truth
  - BFF surface
  - upload transport

## 2. Step 3 Layout Refinement

- `第三步 上传必选文档` 当前固定为：
  - upload-first surface
  - 只保留 3 个必传附件卡
- 当前页面必须隐藏：
  - `模板下载区`
  - 模板分类 chip
  - `当前说明`
  - 公共资源暂不可用提示
- 当前变更只影响：
  - submit page 的 step 3 展示顺序
- 当前变更不等于：
  - 公共资源能力删除
  - 项目详情文书区删除

## 3. Responsive Layout Freeze

- `mobile`：
  - 3 个上传卡保持单列纵向排列
- `tablet / desktop`：
  - `项目理解`
  - `报价表`
  - `进度安排`
  - 必须单排 3 列展示
- 宽屏 3 列时必须保持：
  - 卡片视觉对齐
  - 单卡信息不被压成难读碎片

## 4. Card Content Freeze

- 每个附件卡继续保留：
  - 标题
  - 附件说明
  - `支持格式`
  - `当前状态`
  - 当前文件名
  - 文件信息
  - 上传反馈
  - 上传按钮
- 本轮不新增：
  - 第四种附件
  - 模板入口按钮
  - 结果页资源区

## 5. Acceptance Criteria

- submit page 首次进入时：
  - step 3 不再出现 `模板下载区`
- compact mobile 宽度下：
  - 3 张附件卡纵向排列
- wide tablet/desktop 宽度下：
  - 3 张附件卡同排展示
- 本轮不影响：
  - `init -> direct upload -> confirm`
  - 附件必传门禁
  - submit command body

## 6. Formal Conclusion

- 当前 frontend authority 增补冻结为：
  - bid submit step 3 = upload-first
  - template zone hidden on submit page
  - mobile single-column attachment layout
  - tablet and desktop three-column attachment layout
