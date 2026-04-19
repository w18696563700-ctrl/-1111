---
owner: Codex 总控
status: active
purpose: Record the backend execution receipt for enterprise-display three-board independence Stage B package A after Server closes the current media ownership truth gap.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_backend_execution_prompt_addendum.md
  - docs/01_contracts/error_codes.yaml
  - apps/server/src/modules/enterprise_hub/**
  - apps/server/test/enterprise-hub-media-ownership-truth.test.cjs
  - apps/server/test/enterprise-hub-case-continuation.test.cjs
  - apps/server/test/enterprise-hub-published-change-governance.test.cjs
  - apps/server/test/enterprise-hub-public-read-closure.test.cjs
  - apps/server/test/enterprise-hub-workbench-closure.test.cjs
---

# 《enterprise display three-board independence backend execution receipt》

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub-media-truth.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-app.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts`
- `apps/server/test/enterprise-hub-media-ownership-truth.test.cjs`
- `apps/server/test/enterprise-hub-case-continuation.test.cjs`
- `apps/server/test/enterprise-hub-published-change-governance.test.cjs`
- `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
- `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
- `docs/01_contracts/error_codes.yaml`

## 2. 冻结事实对应

- 对应 prompt 第 `6.1 / 6.2 / 6.3` 条：
  - 直接写链路、published-change corridor、live apply 之前都缺少 media ownership 真相校验。
- 对应 prompt 第 `6.4` 条：
  - `enterprise_media_asset_ref` 已从闲置表升级为 live carrier 的正式 ref 同步载体。
- 对应 prompt 第 `6.5` 条：
  - read-side projection 已对非 `enterprise_display` 或非法 fileKind image fail-close。

## 3. media ownership validation 实现说明

- 新增 `enterprise-hub-media-truth.service.ts`，统一承接：
  - listing basic logo / album 校验
  - factory showcase 校验
  - case cover / case media 校验
  - live carrier ref 同步
- 统一校验条件固定为：
  - `businessType = enterprise_display`
  - `businessId = current enterpriseId`
  - `organizationId = listing.organizationId`
  - `fileKind` 与当前媒体角色一致
  - `mimeType` 必须是 image
- direct workbench 路径已接入：
  - `updateBasic`
  - `updateFactoryProfile`
  - `createCase`
  - `updateCase`
- published-change 路径已接入：
  - `updateCurrentBasic`
  - `updateCurrentBoardProfile(factory showcase)`
  - `createCurrentCase`
  - `updateCurrentCase`
  - `applyToLiveListing`

## 4. `enterprise_media_asset_ref` sync 实现说明

- 当前已同步 live carrier refs：
  - `enterprise_listing_basic`
  - `enterprise_factory_profile`
  - `enterprise_case`
- direct case create / update 会同步 live case refs。
- direct case delete / enterprise delete 会清理对应 refs。
- published-change live apply 会在落 live listing / live case 后同步 refs。
- 当前有意不把 draft snapshot 保存直接写入 ref 表：
  - 当前轮只让最终 live carrier 入责
  - 避免把草稿快照提升成第二套真值系统

## 5. read-side fail-close 实现说明

- `enterprise-hub-media-projection.service.ts` 已收紧：
  - 只有 enterprise display image file asset 才会被投成 URL
  - 非 `enterprise_display`
  - 或不在允许 fileKind 集合中的 image
  - 一律返回 `null`
- 因此 `profile/business_license` 不再会被 enterprise display read-side 当作合法案例图投影。

## 6. 新增或更新的测试

- `enterprise-hub-media-ownership-truth.test.cjs`
  - direct case create 拒绝非法 media ownership
  - direct case create sync `enterprise_media_asset_ref`
  - current change case create 拒绝非法 media ownership
  - live apply sync `enterprise_media_asset_ref`
  - media projection fail-close `profile/business_license`
- `enterprise-hub-case-continuation.test.cjs`
  - 接线更新，保持 direct continuation 回归可跑
- `enterprise-hub-published-change-governance.test.cjs`
  - 接线更新，保持 corridor 主流程回归可跑
- `enterprise-hub-public-read-closure.test.cjs`
  - 接线更新，保持 read-side projection 回归可跑
- `enterprise-hub-workbench-closure.test.cjs`
  - 接线更新，保持 workbench 主链回归可跑

## 7. build / test 结果

- `corepack pnpm build`
  - 通过
- `node --test test/enterprise-hub-media-ownership-truth.test.cjs test/enterprise-hub-case-continuation.test.cjs test/enterprise-hub-published-change-governance.test.cjs test/enterprise-hub-public-read-closure.test.cjs test/enterprise-hub-workbench-closure.test.cjs`
  - 33 通过
  - 0 失败

## 8. 当前剩余未闭合项

- 当前轮没有做历史脏数据修复。
- 当前轮没有做 case media fileKind 的三板块拆分，仍兼容既有 `enterprise_case_media`。
- 当前轮没有放行 `BFF / Flutter`，所以前端入口与 app-facing family 的最终独立感仍待下一轮接线完成。

## 9. 是否可移交下一轮

- 可以移交下一轮：
  - `BFF / Flutter` 接线讨论
  - data repair stage gate 讨论
- 当前不应直接跳到：
  - 云端数据修复
  - release judgment
