---
owner: Codex 总控
status: frozen
purpose: 第 3 份 docs/03_bff package（合同归档与履约强制入链）在 package-level 的冻结 checkpoint 与边界复核归档，作为下一步 implementation 前复核链的一部分。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF 四包：第三包冻结 Checkpoint（合同归档与履约）

## 1. Checkpoint 对象

- 对象：`docs/03_bff` 下第三聚合包
- 包名：`合同归档与履约强制入链规则 V1`
- 目标文件：`docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`
- 本次结论定位：`package-level冻结签核`，非 implementation 解锁。

## 2. 本轮冻结范围（限定）

- 路径家族：`order / contract / milestone / inspection / rating / dispute`（仅在本轮已冻结 app-facing 列举内）
- 禁止扩展项：
  - 不新增 `daily-progress`、`archive-confirm`、`archive-export` 的 BFF 实现
  - 不新增 `contract history`、`inspection history`、`dispute close`、全链条 admin 代理
  - 不新增 `/server/admin/exhibition/contract/*`、`/server/admin/exhibition/milestone/*`、`/server/admin/exhibition/inspection/*`、`/server/admin/exhibition/dispute/*` 透传
  - 不新增 BFF 内部状态机（`contract/milestone/inspection/dispute/rating state`）
  - 不新增 `/risk/* /penalty/* /appeal/* /ban/* /whitelist/*` 裸路由

## 3. 核验对照清单

### 3.1 上位文书与契约基线
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)
- [docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md)

### 3.2 关键 section 核验（本体）
- Scope 与 scope-limit：通过
  - 覆盖 `order/detail`、`order/create`、`contract detail / confirm / amend`、`milestone`、`inspection`、`rating`、`dispute` 的 app-facing 聚合面。
  - 明确 `daily-progress`、`archive` 不在本轮放开范围。
- BFF 非 owner 边界：通过
  - 明确只做 request/trace 透传、read-model shaping、不可做审核或裁决；
  - 明确不持久化 `Order/Contract/Milestone/Inspection/Dispute/Rating` 的真相状态字段。
- 聚合语义边界：通过
  - 统一 envelope、错误码映射、continuation anchor 暂态导向；
  - 将 app-facing 成功态限制为最小投影片段。
- 错误码与失败态：通过
  - 指定本轮固定错误语义清单（如 `CONTRACT_INVALID_STATE` 等）；
  - 不新增错误命名空间，不透传 admin-only error。
- 文件真相边界：通过
  - 明确 FileAsset 三段式与 `evidenceFileAssetIds`；
  - 明确禁止 `raw URL`、`objectKey` 作为业务真相。
- 冲突优先级：通过
  - 与 `project_publish_board_boundary_freeze_addendum.md` 冲突时以 board freeze 为准；
  - 本包不放开 bid/order/contract 后链实现条件。

### 3.3 非 owner 禁止项核验
- 禁止 BFF ownership：通过
  - 不创建本体 contract/fulfillment/inspection/dispute 状态；
  - 不实现 archive 真值判断。
- 禁止路径越权：通过
  - 无 `/admin` 代理；
  - 无裸露治理私有路由族。

## 4. 条款风险说明（本 checkpoint 内）

- 本 checkpoint 为 package 3 聚合边界冻结，仅覆盖该包；
- 不构成四包总 implementation 解锁；
- 不包含黑白名单、裁决、处罚、申诉的 BFF 实现；
- 不包含 release-prep / release 放行动作。

## 5. 结果结论

- 本包 Checkpoint 结论：`passed`
- 本文件角色结论：`package-level_frozen_checkpoint`
- 实施授权：`No-Go for implementation`
- 允许动作：`Go for docs-only 第四包 implementation 前复核`

## 6. 责任与签字

- 复核与冻结归档：Codex 总控
- 关键复核依据：`docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## 7. 下一步

- 该 checkpoint 与本体签核一并归档后，进入下一轮 `implementation` 前 `package-level` 解锁复核，提交：
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_pre_unlock_checklist_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## 8. 非允许含义

- 本文件不是 `/apps/bff` implementation dispatch。
- 本文件不是 `release-prep` / `release` 许可。
- 本文件不是 Admin 实施许可。
