---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 Server-side truth direction for enterprise display three-board independence, including listing-rooted board separation, asset/file validation, enterprise_media_asset_ref usage, board-scoped case query/write rules, same-board published-change behavior, and the likely future write set.
layer: L2 Backend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_backend_truth_scope_addendum.md
  - docs/02_backend/enterprise_display_continuation_and_auto_review_round22_backend_truth_scope_addendum.md
  - apps/server/src/modules/enterprise_hub/**
  - apps/server/src/modules/upload/**
---

# 《enterprise display three-board independence Day-1 backend truth scope》

## 1. Scope

- 当前 backend truth freeze 只覆盖：
  - listing-rooted board separation
  - enterprise display asset / file validation
  - `enterprise_media_asset_ref` 使用方向
  - case query / write 的 board-scoped 真值边界
  - published-change 同板块快照与 apply 规则
  - likely future write set
- 当前不覆盖：
  - 新 board type persistence
  - Admin review 扩面
  - 公共资源下载或附件新对象
  - 第二套 enterprise display state machine

## 2. Listing-rooted Board Separation

- 当前正式冻结：
  - `enterprise_listing` 是 enterprise display 三板块独立性的唯一 root truth
- 同一 organization 可以拥有多条 listing，
  但每条 listing 只允许承接一个主板块：
  - `company`
  - `factory`
  - `supplier`

正式裁决：

- board 独立性必须锚定到：
  - `enterprise_listing.id`
  - `enterprise_listing.primary_board_type`
- `enterprise_case`
  - `enterprise_change_request`
  - `enterprise_profile_*`
  - `enterprise_media_asset_ref`
  都只能从当前 listing root 派生。
- `Server` 不得再把：
  - organization scope
  - enterprise legal subject
  - 同主体多个 board
  混写成一个共享展示 truth。

## 3. Asset / File Validation Truth

- 当前 enterprise display 媒体真值继续只认：
  - `FileAsset`
  - `enterprise_media_asset_ref`
- `objectKey` 继续不是 business truth。

正式裁决：

- 所有 enterprise display 媒体写入成功前，`Server` 都必须完成：
  - 文件存在性校验
  - `confirmed FileAsset` 校验
  - `businessType = enterprise_display` 校验
  - `fileKind` 与媒体角色匹配校验
  - 当前 actor 对目标 listing 的 ownership 校验
- 当前最小 file-kind 边界继续固定为：
  - `enterprise_logo`
  - `enterprise_album`
  - `enterprise_factory_showcase`
  - `enterprise_case_media`
- 异角色、异 listing、异 board 的 fileAsset handoff 不得写入成功。

## 4. `enterprise_media_asset_ref` Usage Direction

- 当前 Day-1 backend direction 正式冻结：
  - `enterprise_media_asset_ref` 是 enterprise display 媒体归属与排序的归一化 binding truth
  - 不是 public URL projection truth
  - 也不是 upload transport truth

当前至少应承接以下 owner 语义：

- listing basic media
  - `logo`
  - `album`
- board profile media
  - `factory showcase`
- case media
  - `case cover`
  - `case gallery`

正式裁决：

- `enterprise_media_asset_ref.enterprise_id` 必须继续锚定当前 listing。
- `owner_type + owner_id + media_role` 必须标识媒体属于哪个业务对象。
- JSON `fileAssetId[]` carrier 当前可以继续保留为 request / response 兼容层，
  但后台真值方向不得停留在“只存数组、不建归属引用”。
- 若未来需要做：
  - cross-check
  - repair
  - same-board apply
  - media ownership audit
  应以 `enterprise_media_asset_ref` 为主索引对象。

## 5. Case Query / Write Scope

- 当前正式冻结：
  - 所有 case read / create / update / delete / promotion / snapshot / apply
    都必须按：
    - `enterpriseId + boardType`
    收口

正式裁决：

- `caseId` 可以作为 direct read/write entry，
  但真正落库与治理校验时，必须回到：
  - 当前 case 的 `enterpriseId`
  - 当前 case 的 `boardType`
  - 当前 listing 的 `primaryBoardType`
- create-case 允许读取 request body 的 `boardType`，
  但该字段只允许做：
  - 与当前 listing 主板块一致性的写前校验
- case update / delete 不得承接 board migration。
- case minimum、read aggregation、promotion 和历史 repair，
  都不得只按 `enterpriseId` 裸聚合。

## 6. Same-board Published-change Behavior

- 当前 published-change corridor 继续只属于：
  - `listing-owned change request`
- 该 change request 的 `boardType` 必须始终等于：
  - live listing `primaryBoardType`

正式裁决：

- live snapshot 只允许抓取当前 listing 同板块 case。
- current change draft 只允许保存当前 listing 同板块 case。
- apply live listing 时：
  - 只允许删除当前 listing 同板块旧 case
  - 只允许写回当前 listing 同板块 snapshot case
  - 不得碰异板块 case
- `approved` 只代表当前板块变更审核通过。
- `applied` 才代表当前板块 live listing 真值已被覆盖更新。

## 7. Likely Future Write Set

- 当前 Day-1 之后最可能进入实现的 backend write set 正式冻结为：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-listing-write-support.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation-support.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts`
  - `apps/server/src/modules/enterprise_hub/entities/enterprise-media-asset-ref.entity.ts`
  - `apps/server/src/modules/upload/upload-write.service.ts`
  - 与上述直接相关的 migration / support / test

## 8. Anti-revert

- 不得继续把同主体三板块解释成一个共享 listing truth。
- 不得把 `enterprise_media_asset_ref` 退化成可有可无的旁路表。
- 不得让 case snapshot / apply 再次越过 board 边界。
- 不得只校验 `fileAssetId` 存在，而不校验其 role / ownership / business binding。
- 不得把 media ownership correction 下放给 `BFF` 或 Flutter。

## 9. Formal Conclusion

- 当前 Day-1 backend truth direction 已冻结为：
  - listing-rooted three-board separation
  - `FileAsset + enterprise_media_asset_ref` 的媒体真值方向
  - `enterpriseId + boardType` 收口的 case query / write truth
  - published-change same-board snapshot / apply behavior
  - 一组明确受控的 likely future write set
