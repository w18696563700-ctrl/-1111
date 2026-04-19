---
owner: Codex 总控
status: frozen
purpose: >
  Restore the compact template download area on the Flutter bid-submit page and
  keep the required upload cards visually uniform with a four-block structure.
layer: L5 Frontend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/04_frontend/exhibition_bid_submit_full_version_frontend_surface_addendum.md
  - docs/04_frontend/exhibition_bid_submit_attachment_layout_refine_frontend_surface_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/gate_register_v1.md
---

# 《竞标提交页模板下载与附件卡规整化 frontend addendum》

## 1. Scope

- 本文件只覆盖 Flutter App 的 `/exhibition/bids/submit` 页面。
- 本文件不改动：
  - BFF / Server contract
  - upload `init -> direct upload -> confirm`
  - 项目详情页公共资源下载区
  - 生产运行面

## 2. Supersession

- 本文件对
  `exhibition_bid_submit_attachment_layout_refine_frontend_surface_addendum.md`
  中“submit page 隐藏模板下载区”的结论做后续覆盖。
- 新冻结结论为：
  - submit page 必须保留模板下载能力；
  - 隐藏的是冗长说明、分类说明面板和大段空态，不是下载入口。

## 3. Template Download Area

- `第三步 上传必选文档` 顶部保留精简版 `模板下载区`。
- 精简版固定承接 3 个下载入口：
  - `合同模板`
  - `流程图与说明`
  - `公共资料`
- 每个入口只展示：
  - 分类标题
  - 当前可下载资料标题或短提示
  - 下载按钮
- submit 页不再展示：
  - `当前说明`
  - `资料分类`
  - 分类说明卡
  - 大段公共资源空态说明

## 4. Required Upload Cards

- `项目理解`、`报价表`、`进度安排` 三张上传卡必须统一宽高。
- 卡片内容固定为四个结构块：
  - 标题
  - 用途说明
  - `支持格式` 与 `当前状态`
  - 上传 / 重新上传按钮
- 上传后的文件名、类型、大小或反馈信息只能压缩进入状态行，不再额外撑开卡片高度。

## 5. Responsive Freeze

- mobile：
  - 模板下载入口纵向排列；
  - 三张上传卡保持单列；
  - 同类卡保持统一宽度和固定高度。
- tablet / desktop：
  - 模板下载入口 3 列；
  - 三张上传卡单排 3 列；
  - 上传卡必须等宽等高。

## 6. Implementation Index

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_template_download_support.dart`
  - submit 页精简模板下载入口。
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_attachment_layout_support.dart`
  - 必传上传卡四段式与等高布局。
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_step3_layout_support.dart`
  - step 3 布局常量与三列分组工具。
- `apps/mobile/test/shell_app_test.dart`
  - bid submit 模板下载、技术说明隐藏、宽屏三列等高回归。

## 7. Validation

- Targeted regression:

```bash
cd apps/mobile
flutter test test/shell_app_test.dart --plain-name "bid submit"
```

- Result:
  - `16/16` bid submit 用例通过。

## 8. Formal Conclusion

- 当前 frontend authority 增补冻结为：
  - bid submit step 3 = compact template download area + required upload cards
  - template download function remains available on submit page
  - upload cards use a uniform four-block layout
  - mobile single-column remains unchanged
  - tablet / desktop keeps three-column attachment layout
