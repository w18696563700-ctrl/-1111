---
owner: Codex 总控
status: frozen
purpose: Freeze frontend consumption behavior for Logo-only after shell/application responsibilities are formally separated.
layer: L3 Frontend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/01_contracts/enterprise_display_trust_repair_round11_logo_only_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
---

# Enterprise Display Trust Repair Round 11 Logo-only Frontend Consumption Freeze

## 1. Consumption Objective

- 让 `Logo-only`、基础资料首次保存、图片走廊首次使用都能在无联系人时先拿到 `enterpriseId`。
- 保持 submit 前联系人仍是 blocker。

## 2. Frontend Rule

- 当前 `_ensureEnterpriseId()` 正式改为：
  - 先尝试读取现有 `enterpriseId`
  - 若缺失，则调用 `ensure-shell(boardType)`
  - 成功后继续原有 upload / basic-save corridor
- 当前 `Logo-only` 路径不得再前置要求：
  - 联系人姓名
  - 联系人手机号

## 3. Application Flow Rule

- 前端仍必须在真正进入申请流时再调用：
  - `createApplication(boardType, applicantName, applicantMobile)`
- 前端不得把：
  - 已拿到 `enterpriseId`
  误展示成：
  - 已创建申请
  - 已完成联系人持久化

## 4. UX Rule

- `Logo-only` 成功拿壳后：
  - 不弹“请先填写联系人和电话才能上传 Logo”的阻断提示
- submit/readiness 仍可显示：
  - 缺联系人
  - 缺申请草稿
  - 缺案例
  - 缺画像
- 无 application 但已有 shell 的 copy 必须与旧文案区分。

## 5. Allowed Write Set

- 当前 round-11 frontend 优先允许：
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_profile_actions.dart`
  - `apps/mobile/test/**`

## 6. Anti-revert

- 不得继续把联系人缺失当成获取 `enterpriseId` 的前置条件。
- 不得把新 shell route 伪装成 submit-ready。
- 不得因为修 `Logo-only` 顺手放宽 submit blocker。

## 7. Formal Conclusion

- round-11 frontend consumption 已冻结为：
  - `shell first for logo/basic`
  - `application later for submit chain`
- 旧的 `_ensureEnterpriseId() -> createApplication -> contact required` 链路正式判定为 `No-Go`。
