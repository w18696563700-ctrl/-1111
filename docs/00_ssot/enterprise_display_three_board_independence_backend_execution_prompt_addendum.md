---
owner: Codex 总控
status: active
purpose: Freeze the backend execution prompt for enterprise-display three-board independence so Server closes the media ownership truth gap before any BFF, Flutter, or data-repair follow-up is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_bounded_implementation_dispatch_bundle_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_three_board_independence_backend_truth_scope_addendum.md
  - apps/server/src/modules/enterprise_hub/**
---

# 《enterprise display three-board independence backend execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display / three-board independence`
- 子阶段：
  - `Stage B / backend truth repair`
- 当前包：
  - `backend media ownership`

## 2. 唯一目标

- 你这轮只负责关闭 `Server truth` 的 media ownership gap。
- 这轮只允许解决五件事：
  1. basic media write-time validation
  2. factory showcase write-time validation
  3. direct case / published-change case write-time validation
  4. live apply fail-close validation
  5. `enterprise_media_asset_ref` sync + read-side fail-close

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_three_board_independence_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_three_board_independence_bounded_implementation_dispatch_bundle_addendum.md`
- `docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md`
- `docs/02_backend/enterprise_display_three_board_independence_backend_truth_scope_addendum.md`

## 4. 只允许修改的范围

- `apps/server/src/modules/enterprise_hub/**`
- 与本轮最小闭环直接相关的最小 `apps/server/test/**`
- 如确有新的 contract 漏项，必须先由总控补文书，backend 不得自行扩 path family

## 5. 禁止事项

- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不改线上数据
- 不新增新的 `/api/app/*` path family
- 不新增第二套 enterprise truth
- 不新增第二状态机
- 不把 fileKind 全链拆分当成当前轮唯一出口

## 6. 当前已冻结的事实

1. upload confirm 只校验 `FileAsset` 基础真值，不等于业务 ownership 已闭合。
2. direct case create / update 当前仍可吞进非法 `fileAssetId`。
3. published-change current case / live apply 当前仍缺少同级 media ownership 校验。
4. `enterprise_media_asset_ref` 表已存在，但当前没有进入正式职责。
5. read-side 当前会把任意 image `FileAsset` 投影成 URL，导致非 `enterprise_display` 图片可被 case/public read 消费。

## 7. 你必须完成

### 7.1 write-time media ownership validation

- 你必须让以下写路径在落库前完成统一校验：
  - basic media
  - factory showcase
  - direct case create
  - direct case update
  - published-change current basic
  - published-change current case create/update
  - live apply
- 校验至少必须覆盖：
  - `businessType = enterprise_display`
  - `businessId = current enterpriseId`
  - `organizationId = listing.organizationId`
  - `fileKind` 与当前媒体角色一致
  - image mime type

### 7.2 board-scoped case truth

- 你必须保证：
  - case media 只能服务当前 `enterpriseId + boardType`
  - `boardType` 不能借 update 漂移
  - published-change corridor 不能回灌 sibling board media

### 7.3 `enterprise_media_asset_ref` 正式入责

- 你必须为 live carrier 至少同步：
  - listing basic logo / album
  - factory showcase
  - enterprise case cover / case media
- 如 current-change carrier 一并同步更稳妥，可以纳入；
  但不得因此扩成第二套状态机。

### 7.4 read-side fail-close

- 你必须让 enterprise display read-side 不再给以下对象发 URL：
  - 非 `enterprise_display` image
  - 非合法 enterprise display fileKind image
- 当前最少要保证：
  - `profile/business_license` 不再被当成企业展示案例图投影

## 8. 你必须补的测试

至少补齐以下覆盖：

1. direct case update 遇到非法 media ownership 被拒绝
2. published-change case create/update 遇到非法 media ownership 被拒绝
3. live apply 遇到非法 media ownership fail-close
4. media projection 不再把 `profile/business_license` 投成 enterprise display URL
5. `enterprise_media_asset_ref` 至少有一条 live carrier sync 覆盖

## 9. 完成标准

- 结果必须能证明：
  1. 非法 `fileAssetId` 不再能进入 live case truth
  2. 非法 `fileAssetId` 不再能进入 current-change truth
  3. 非 enterprise-display image 不再被 enterprise display read-side 投影
  4. `enterprise_media_asset_ref` 不再是闲置表
- 如果你只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 backend package 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_three_board_independence_backend_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. media ownership validation 的实现说明
  4. `enterprise_media_asset_ref` sync 的实现说明
  5. read-side fail-close 的实现说明
  6. 新增或更新的测试清单
  7. build / test 结果
  8. 当前剩余未闭合项
  9. 是否可移交下一轮 `BFF / Flutter`

## 11. 输出禁令

- 不要只给代码阅读结论
- 不要把 upload confirm 真值冒充成业务 ownership 真值
- 不要把 data repair 混入当前 backend package
- 不要把 `enterprise_case_media` fileKind 全链重构当成当前轮必要前提
- 只给真实实现、真实测试、真实剩余风险
