---
owner: Codex 总控
status: frozen
purpose: 第 2 份 docs/03_bff package（假项目举报与裁决）在 package-level 的冻结 checkpoint 与边界复核归档，作为下一步 implementation 前复核链的一部分。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF 四包：第二包冻结 Checkpoint（假项目举报与裁决）

## 1. Checkpoint 对象

- 对象：`docs/03_bff` 下第二聚合包
- 包名：`假项目举报与裁决规则 V1`
- 目标文件：`docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`
- 本次结论定位：`package-level冻结签核`，非 implementation 解锁。

## 2. 本轮冻结范围（限定）

- 路径家族：仅 `exhibition`、`project`（本包内冻结声明的 report submit 与受限态 copy）
- 禁止扩展项：
  - 不新增 report 列表/详情/进度 API
  - 不新增 `/api/app/risk/* /api/app/penalty/* /api/app/appeal/* /api/app/ban/* /api/app/whitelist/*` 路由
  - 不新增 `/server/admin/exhibition/report*` 透传到 BFF
  - 不新增上报/审核/裁决/处罚/封禁生命周期真相

## 3. 核验对照清单

### 3.1 上位文书与契约基线
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md)
- [fake_project_report_and_adjudication_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md)
- [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md)

### 3.2 关键 section 核验（本体）
- Scope 与 scope-limit：通过
  - 目标明确限定于 `POST /api/app/exhibition/report/submit` 等当前已冻结最小 handoff；
  - 明确仅消费现有 trade-side read family 的受限 copy。
- BFF 非 owner 边界：通过
  - 明确不承接 report/admin/restriction/adjudication/penalty 的状态机；
  - 明确不新增 report 真相持久化/裁决权。
- 聚合语义边界：通过
  - request/trace 与 actor+org normalization；
  - submit acknowledgement 与受限态 copy 的 read-model shaping。
- 错误码与失败态：通过
  - 指定受控 error family；
  - 仅 map app-facing 可外显 copy，不外透 admin 内部语义。
- 冲突优先级：通过
  - 与 `project_publish_board_boundary_freeze_addendum.md` 冲突时以 active board freeze 为准；
  - 明确本包不放开 bid/order/contract/dispute 后链实现。

### 3.3 非 owner 禁止项核验
- 禁止 BFF ownership：通过
  - 不创建第二套 `report` 真相；
  - 不持有 `exhibition_report_cases`、`governance_ticket`、`review_tasks`、`penalty / ban / whitelist` 决策真值。
- 禁止路径越权：通过
  - 无 `/admin` 透传；
  - 无裸露治理私有路由族。

## 4. 条款风险说明（本 checkpoint 内）

- 本 checkpoint 为 package 2 聚合边界冻结，仅覆盖该包；
- 不构成四包总 package-level implementation 解锁；
- 不包含 contract/fulfillment/blacklist 后链实现；
- 不包含 /admin governance 的实现放行；
- 不改变 `/forum` 或发布最小走廊边界的现状约束。

## 5. 结果结论

- 本包 Checkpoint 结论：`passed`
- 本文件角色结论：`package-level_frozen_checkpoint`
- 实施授权：`No-Go for implementation`
- 允许动作：`Go for docs-only 下一包实现前对齐复核`

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
- 本文件不是 admin 实施许可。
