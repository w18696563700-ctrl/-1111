---
owner: Codex 总控
status: frozen
purpose: >
  Record the boundary for analyzer cleanup after the May analyzer pass: business
  source deletion must distinguish safe dead code, old conflicting code, and
  strategic reserve code before any physical removal.
layer: L0 SSOT
freeze_date_local: 2026-05-02
based_on:
  - AGENTS.md
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/00_ssot/bid_submit_project_review_collapse_truth_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
---

# 《analyzer 清理业务代码保留边界 addendum》

## 1. 本轮裁决

- analyzer 提示 `unused_*` 只能作为线索，不能直接作为删除依据。
- 凡涉及已冻结业务真相、contract、阶段预埋、未来链路承接的代码，必须先归类，再决定是否删除、保留、迁移或受控忽略。
- 后续物理删除业务源代码前，必须先输出拟删除清单并获得总控确认。

## 2. 已恢复并记录为战略预埋

### 2.1 `seat / bid package completeness` Flutter 预埋 UI

- 文件：
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart`
- 恢复对象：
  - `_buildBidSeatAndCompletenessSections`
  - `_buildBidSeatSection`
  - `_buildBidCompletenessSection`
  - `_missingItemsFromPayload`
  - `_boolFromPayload`
  - `_isQuoteAmountItem`
  - `_isProposalSummaryItem`
  - `_missingItemLabel`
- 当前状态：
  - 不接回当前 `bid submit` 主展示面。
  - 保留为 Package A 后续受控重启的展示层扩展位。
- 边界：
  - 当前 submit page 仍不把 `seat / completeness` 作为主阅读入口。
  - canonical truth 不删除。
  - 若后续要重新展示，必须先补 SSOT/验收口径。

### 2.2 `_ActionCard` header / summary 扩展参数

- 文件：
  - `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_surface_widgets.dart`
- 恢复对象：
  - `titleTrailing`
  - `summaryStyle`
- 当前状态：
  - 不强制当前调用方使用。
  - 作为密集工作台头部操作位、风险说明样式位保留。
- 边界：
  - 不能借此新增业务真相。
  - 只能服务展示层组合。

## 3. 保留删除的安全项

以下删除项不具备当前战略预埋必要性，或与现有实现存在旧口径冲突，允许保留删除：

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_attachment_support.dart`
  - `_BidSubmitAttachmentUploadUiStatus`
  - `_bidSubmitAttachmentUploadFailureMessage`
  - 理由：当前附件上传展示以 `AppUploadState` 为准，旧私有 UI 状态会形成第二套状态口径。
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart`
  - `_p0PayFeeRateDisplay`
  - `_p0PayFeeRatePercent`
  - 理由：当前普通竞标体验不应突出旧费率施工口径；平台服务费文案另行受控。
- `apps/mobile/lib/features/exhibition/data/trading_im_models.dart`
  - `_requiredNumber`
  - 理由：当前解析路径无调用，且无冻结字段依赖。
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
  - `_HomeForumFilterPresentation.label`
  - 理由：当前论坛筛选只有单项静态 label，调用处已直接提供展示文案。
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_step3_layout_support.dart`
  - `_bidSubmitAttachmentCardHeight`
  - 理由：当前布局不消费该固定高度，保留会形成误导。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_sections.dart`
  - `_buildFactoryEquipmentField`
  - 理由：该文件内函数未被调用；设备字段真实展示承接在 display sections，不应在 case sections 保留重复实现。

## 4. 后续删除门禁

任何后续删除需先回答：

1. 是否有 SSOT / contract / test 指向该能力。
2. 是否是当前页面消费面退役，但未来主链路仍需要的扩展位。
3. 是否与当前实现冲突。
4. 是否可以通过受控 ignore 或迁移记录替代物理删除。
5. 是否已获得总控确认。

## 5. 当前结论

- 本轮恢复战略预埋：
  - `seat / completeness` Flutter UI reserve
  - `_ActionCard` 展示扩展参数
- 本轮保留安全删除：
  - 旧附件上传 UI 状态
  - 旧费率格式化 helper
  - 无冻结依赖的解析 helper / 静态 label / 未用布局常量 / 重复设备字段函数
- 本轮不改：
  - BFF
  - Server
  - OpenAPI
  - 数据库
  - 云端 runtime
