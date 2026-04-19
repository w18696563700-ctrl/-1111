---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side surface for prepublish attachment continuation and
  bid-submit staged reveal with read-only project materials.
layer: L5 Frontend
freeze_date_local: 2026-04-16
inputs_canonical:
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
---

# 《项目附件预发布前移与竞标材料只读投影 frontend freeze》

## 1. Bid Submit Staged Reveal

- `立即参与竞标` 进入 `/exhibition/bids/submit` 后，首屏只显示：
  - `第一步 核对项目`
- 点击：
  - `继续竞标`
  后，当前页才继续显示：
  - `项目附件`
  - `第二步 填写报价与方案说明`
  - `第三步 上传必选文档`

## 2. Bid-side Attachment Read

- Flutter 当前允许在 bid-submit 读取只读项目附件投影。
- 当前只展示：
  - `效果图`
  - `施工图`
- 当前不得在 bid-submit 展示：
  - `其他资料`
  - owner 删除/上传按钮

## 3. Owner Attachment Entry

- `我的项目详情`
- `项目编辑`
- create-success handoff
  当前都允许在 `submitted-or-later` 打开 `项目详情文书区`。

## 4. Copy Adjustment

- 当前不得继续把附件区写成：
  - `项目发布后开放`
- 当前应改为：
  - `进入预发布列表后即可补充`
  - 或同义 owner-facing 文案

## 5. Lifecycle Clarification

- Flutter 不得伪造：
  - `竞标中 -> 预发布列表`
  的本地回退动作。
- 若当前没有 canonical transition，前端只能明确说明或不展示该动作，不得伪造成功。

## 6. Formal Conclusion

- 当前 frontend authority 正式冻结为：
  - prepublish attachment continuation
  - bid-submit staged reveal
  - bid-side read-only effect/construction materials
