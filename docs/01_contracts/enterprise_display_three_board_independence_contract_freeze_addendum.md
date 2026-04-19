---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 app-facing contract direction for enterprise display three-board independence, including board-scoped entry/case/upload families, compatibility expectations, board-scoped case identity, and media ownership validation requirements.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_docs_only_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_company_factory_case_media_repair_contract_freeze_addendum.md
---

# 《enterprise display three-board independence Day-1 contracts freeze addendum》

## 1. Scope

- 当前 contract freeze 只覆盖：
  - `company / factory / supplier` 三板块独立语义
  - board-scoped entry family
  - board-scoped case family
  - board-scoped upload consumption family
  - case identity 与 media ownership validation 的 app-facing 约束
- 当前不覆盖：
  - 新 board type
  - 新筛选 contract
  - Admin 审核扩面
  - 第二套 enterprise display 工作台

## 2. Board-scoped Entry Family Direction

- 当前正式冻结：
  - `company / factory / supplier` 必须进入三条独立 private family 方向
  - 当前共享 `/api/app/exhibition/enterprise-hub/**` 只允许作为 compatibility bridge 存续
- 当前桥接期允许继续存在的 entry carrier 包括：
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType={boardType}`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType={boardType}`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType={boardType}`

正式裁决：

- `boardType` 当前继续是 bridge family 的显式 contract carrier。
- `company / factory / supplier` 不得再被解释成：
  - 同一入口下的 UI 标签切换
  - 同一 listing 的不同展示皮肤
- 当前 Day-1 只冻结独立 family 方向，
  具体 canonical path 形态允许在下一轮 concrete contract patch 中定稿。

## 3. Board-scoped Case Family Direction

- 当前 case family 正式拆成两层 contract 方向：
  - 未发布 / draft-editable 语义下的 direct case continuation family
  - 已发布展示语义下的 published-change corridor case family

当前桥接期仍可继续存在的 shared path 至少包括：

1. `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases`
2. `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
3. `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
4. `DELETE /api/app/exhibition/enterprise-hub/cases/{caseId}`
5. `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
6. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
7. `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`

正式裁决：

- final case contract 不得长期停留在：
  - shared family + runtime `boardType` 分流
- direct create-case request 继续允许携带：
  - `boardType`
  但其语义只允许是：
  - 与目标 `enterpriseId` 所属 listing 主板块一致的 board declaration
- direct case update 与 published-change update 当前都不得把 `boardType` 作为可变字段重新提交。
- 已发布态案例修改不得回退成：
  - direct case continuation backdoor
- 不允许发明：
  - mixed-board case family
  - user-owned case family

## 4. Board-scoped Upload Consumption Direction

- 当前正式重申：
  - enterprise display 继续复用 shared upload `init -> direct upload -> confirm`
  - 不新增第二套 board-only upload transport family
- 但 app-facing consumption family 必须按媒体角色独立承接：
  - `enterprise_logo`
  - `enterprise_album`
  - `enterprise_factory_showcase`
  - `enterprise_case_media`

正式裁决：

- upload transport 是共享的；
  media consumption family 必须是分离的。
- `factory showcase` 只允许服务：
  - factory board profile
- `case media` 只允许服务：
  - 当前 board-scoped case family
- `enterprise_logo / enterprise_album` 只允许服务：
  - 当前 listing basic family
- `objectKey` 继续不得进入 app-facing business contract。

## 5. Compatibility Expectation

- 当前 Day-1 formal direction 属于：
  - existing contract clarification
  - board ownership tightening
  - media validation tightening
- 当前 Day-1 formal direction 不属于：
  - path widening
  - 新 transport 协议
  - 新状态机

兼容要求正式冻结为：

- 已存在的 shared boardType bridge path 继续保持兼容。
- 已存在的 direct case continuation 与 published-change corridor bridge path 继续保持兼容。
- 已存在的 request / response media carrier 继续使用：
  - `fileAssetId`
  - `fileAssetIds[]`
- 若后端补强 board ownership 校验导致历史脏请求失败：
  - 该行为属于 contract tightening
  - 不得被定性为 contract breakage

## 6. Board-scoped Case Identity Rule

- 当前正式冻结：
  - case 是 `listing-owned` 对象
  - 不是 organization 级共享案例
  - 也不是 user-owned 案例

单案例 app-facing carrier 当前至少必须稳定承接：

- `caseId`
- `enterpriseId`
- `boardType`

正式裁决：

- `caseId` 是单案例读取入口。
- `enterpriseId + boardType` 是 case 的 board-scoped ownership identity。
- 前端不得只凭当前 tab、当前页面标题或历史缓存猜测 case 属于哪个板块。
- `boardType` 一旦形成 case truth，即视为不可变 ownership field；
  write request 不得借 update 把 case 从一个 board 搬到另一个 board。

## 7. Media Ownership Validation Requirement

- 当前所有承接 enterprise display 媒体写入的 request body，
  只允许消费：
  - confirmed `FileAsset`
- 当前至少包括：
  - `logoFileAssetId`
  - `albumImageFileAssetIds`
  - `showcaseImageFileAssetIds`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`

正式裁决：

- media ownership validation 是硬性 contract expectation，不是 best effort。
- 后端必须校验：
  - `FileAsset` 已 confirm
  - `businessType = enterprise_display`
  - `fileKind` 与当前媒体角色一致
  - 当前媒体归属与当前 `enterpriseId / boardType / case family` 一致
- 校验失败时：
  - 必须返回受控失败
  - 不得静默丢弃非法 `fileAssetId`
  - 不得把异板块媒体伪装成成功保存

## 8. Anti-revert

- 不得把三板块独立性退回成“一个 listing + 三个展示视角”。
- 不得新增第二套 enterprise display upload family。
- 不得把 `boardType` 从 case read carrier 中静默移除。
- 不得继续允许前端在 case update 时重提可变 `boardType`。
- 不得把 media ownership mismatch 包装成 success empty projection。

## 9. Formal Conclusion

- 当前 Day-1 contract direction 已冻结为：
  - board-scoped private family direction
  - shared bridge path only where necessary
  - direct-case 与 published-change 双 case family 分离
  - shared upload transport with separated media consumption families
  - `caseId + enterpriseId + boardType` 的 board-scoped case identity
  - mandatory media ownership validation on confirmed `FileAsset`
