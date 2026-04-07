---
owner: Codex 总控
status: draft
purpose: 对《账户与企业认证规则 V1》第一包进行真源收口复核，明确当前有效依据、已形成链条、未冻结项与下一轮唯一动作。
layer: L0 SSOT
---

# 《账户与企业认证规则 V1》第一包真源收口复核单

## 1. Scope
- 当前对象仅限：
  - `账户与企业认证规则 V1`
  - 第一包主线
  - 真源收口复核
- 本文只用于：
  - 确认当前有效真源
  - 确认当前阶段允许动作
  - 确认第一包已经形成到哪一层
  - 确认未冻结项与未放行项
- 本文不代表：
  - implementation unlock
  - release-prep unlock
  - release execution approval

## 2. 当前有效真源基线

### 2.1 顶层真源
- 当前项目顶层执行真源仍为：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [source_of_truth_map.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/source_of_truth_map.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)

### 2.2 当前阶段真源
- 当前四文书进入 contracts freeze 的阶段裁决真源为：
  - [exhibition_trade_governance_four_documents_contracts_freeze_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_contracts_freeze_stage_gate_checklist_addendum.md)

### 2.3 第一包专属真源链
- `L0 SSOT`：
  - [account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md)
- `L2 Contracts`：
  - [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)
- `L3 Backend`：
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
- `L3 BFF`：
  - [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
- `L3 Frontend / Admin`：
  - 第一包专属 surface 文书现已形成：
    - [account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md)
    - [account_and_enterprise_certification_rules_v1_admin_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md)
  - 相关上游 basis 仍包括：
    - [profile_my_building_compact_hub_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md)
    - [admin_governance_surface_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/05_admin/admin_governance_surface_matrix.md)

## 3. 当前真源链判定

### 3.1 已成立
- 第一包不是“还没开始”，而是已经形成如下真源链条：
  - `L0 App-aligned freeze` 已存在
  - `L2 contracts addendum` 已存在
  - `L3 backend truth addendum` 已存在
  - `L3 bff surface addendum` 已存在
- 真源语言总体一致：
  - 不新造第二套 identity truth
  - 不新造第二套 organization truth
  - 不新造第二套 role / permission truth
  - app-facing 仍限定在 `/api/app/*`
  - admin 仍限定在 `/server/admin/*`
  - `BFF` 不得持有业务真相
  - `Server` 仍是 truth owner

### 3.2 仍未成立
- 当前并不能据此宣称第一包已完成全链冻结，原因如下：
  1. 核心文书状态多数仍为 `draft`
  2. 当前这份文书本身只覆盖 `docs/**-only L2 contracts freeze` 收口；其后的 docs-only backend/BFF freeze review 已由独立 gate 文书管理，二者不得混写成同一阶段口径
  3. `openapi.yaml` 与 `error_codes.yaml` 需要对第一包 contract family 做专属核对与收口
  4. 当前没有第一包的 implementation unlock 裁决文书

## 4. 当前阶段裁决

### 4.1 允许动作
- 当前允许：
  - `docs/**` 内的第一包真源收口
  - 第一包 `L2 contracts freeze` 正式冻结
  - 围绕第一包的本体级独立复核
  - 第一包 `openapi.yaml / error_codes.yaml / generated contracts` 对齐检查
  - 在 `L2 contracts freeze` 完成后，按独立阶段门禁进入 docs-only backend/BFF package-level freeze review

### 4.2 不允许动作
- 当前不允许：
  - `apps/server` implementation
  - `apps/bff` implementation
  - `apps/mobile` implementation
  - `apps/admin` implementation
  - release-prep
  - release execution

## 5. 第一包当前主线
- 第一包当前正确主线应固定为：
  1. 收口 `L2 contracts freeze`
  2. 复核 `openapi.yaml`
  3. 复核 `error_codes.yaml`
  4. 如需要，补齐 generated contracts
  5. 完成第一包 contract family 的独立复核
  6. 再决定是否允许进入 backend-truth / bff-surface / frontend-admin 的 package-level 连续冻结收口

## 6. 当前未冻结项
- 第一包 contract family 与 `openapi.yaml` / `error_codes.yaml` 的 package-level 对照结论已单独成文，但仍不构成 implementation unlock
- 第一包未形成 package-level implementation unlock 评估

## 7. 风险判定
- `PASS`：
  - 第一包方向正确
  - 第一包真源链条存在
  - 当前继续推进 `L2 contracts freeze` 与真源收口，符合顶层 change order
- `RISK`：
  - 若把“已有 backend/bff draft 文书存在”误判成“已允许实现”，会发生越级
  - 若跳过 `openapi / error_codes / generated contracts` 收口，会造成 contract family 名义存在但 formal contract 未闭环
- `FAIL`：
  - 当前若直接进入实现，属于阶段越权

## 8. 正式结论
- 当前正式结论：
  - 第一包《账户与企业认证规则 V1》真源链已初步存在
  - `L2 contracts freeze` 收口与其后的 docs-only backend/BFF freeze review 是两个相邻但独立的阶段，不得混用口径
  - 当前实现与发布层面仍未获得任何放行
  - 当前阶段性裁决应理解为：
    - `Go for docs-only first-package truth closure and L2 contracts freeze completion`
    - `Go for docs-only backend/BFF package-level freeze review only after the dedicated stage gate is used`
    - `No-Go for implementation / release`

## 9. 下一步唯一动作
- 下一步唯一动作：
  - 本文书的直接收口任务已完成；其后续阶段动作应以专属 stage gate 与 review conclusion 文书为准
- 当前仍不得做：
  - implementation unlock
  - backend implementation
  - bff implementation
  - frontend implementation
  - admin implementation
  - release-prep / release
