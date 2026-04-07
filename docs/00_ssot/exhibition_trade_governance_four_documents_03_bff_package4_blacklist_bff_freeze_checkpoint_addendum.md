---
owner: Codex 总控
status: frozen
purpose: 第 4 份 docs/03_bff package（黑白名单与永久封禁规则）在 package-level 的冻结 checkpoint 与边界复核归档，作为 implementation 前复核链的一部分。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF 四包：第四包冻结 Checkpoint（黑白名单与永久封禁）

## 1. Checkpoint 对象

- 对象：`docs/03_bff` 下第四聚合包
- 包名：`黑白名单与永久封禁规则 V1`
- 目标文件：`docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
- 本次结论定位：`package-level冻结签核`，非 implementation 解锁。

## 2. 本轮冻结范围（限定）

- 路径家族：`/api/app/profile/governance/status`、`/api/app/profile/governance/appeals`
  - 以及 shell/profile 对应的 governance 聚合摘要字段
- 禁止扩展项：
  - 不新增 `/risk/* /ban/* /whitelist/* /penalty/* /appeal/*` 为 BFF 实现路由
  - 不新增 `/server/admin` 到 BFF 的代理承接
  - 不新增 penalty/appeal/ban 相关判定状态机
  - 不新增跨页治理真相持久化与处罚生效链
  - 不新增 `/tmp`、`/evidence` 等裸路由替代文件真相

## 3. 核验对照清单

### 3.1 上位文书与契约基线
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)
- [docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md)

### 3.2 关键 section 核验（本体）
- Scope 与 scope-limit：通过
  - `profile governance` 聚合面仅覆盖治理摘要与申诉提交入口，不覆盖处罚计算、封禁落地、黑白名单写入。
  - 与 `project_publish_board_boundary_freeze_addendum.md` 冲突时以 active board freeze 为准。
- BFF 非 owner 边界：通过
  - 明确仅作 request/trace 透传与 read-model shaping；
  - 明确不持久化、不得决策 `governance_penalties/governance_appeals/governance_whitelist/governance_bans`。
- 聚合语义边界：通过
  - 统一 actor/organization 归一化；
  - 统一不可见态/受限态 copy；
  - 统一 app-facing 错误码对齐，不外透 admin 内部语义。
- 错误码与失败态：通过
  - 指定本轮固定治理前端 copy 与外显语义；
  - 不新增 governance 业务错误命名空间的 BFF 内生管理。
- 文件真相边界：通过
  - 继续使用 `FileAsset`/`Evidence` 与三段式上传，不将 `raw URL`、`objectKey` 作为业务字段。
- 交叉包边界：通过
  - 与 `P2` 共享风险提示语义，不共享处罚 lifecycle；
  - 与 `P3` 共享 project status 聚合 copy，不共享合同/争议真相；
  - 与 `P1` 共享 profile 上下文，不共享资格判定 truth。

### 3.3 非 owner 禁止项核验
- 禁止 BFF ownership：通过
  - 不新增罚金、封禁、申诉裁决、黑白名单提升/移除真值逻辑；
  - 不新增处罚落地状态机、执行动作。
- 禁止路径越权：通过
  - 无 `/server/admin` 透传；
  - 无裸露治理私有路由族。

## 4. 条款风险说明（本 checkpoint 内）

- 本 checkpoint 为 package 4 聚合边界冻结，仅覆盖该包；
- 不构成四包总 implementation 解锁；
- 不包含 `admin` 治理实施；
- 不包含平台风险惩戒引擎落地；
- 不改变发布最小走廊边界。

## 5. 结果结论

- 本包 Checkpoint 结论：`passed`
- 本文件角色结论：`package-level_frozen_checkpoint`
- 实施授权：`No-Go for implementation`
- 允许动作：`Go for implementation 前聚合边界签核闭环复核`

## 6. 责任与签字

- 复核与冻结归档：Codex 总控
- 关键复核依据：`docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## 7. 下一步

- 进入下一轮唯一动作前提：该 checkpoint 文档与四包本体签核同时归档后，提交 implementation 前 package-level 解锁条件复核。
- 只允许提交 docs/SSOT 阶段文档；不得下发 apps/bff、apps/server 实现。

## 8. 非允许含义

- 本文件不是 `/apps/bff` implementation dispatch。
- 本文件不是 `release-prep` / `release` 许可。
- 本文件不是 admin 实施许可。
