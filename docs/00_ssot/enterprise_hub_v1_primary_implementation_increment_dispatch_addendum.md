---
owner: Codex 总控
status: draft
purpose: Freeze the current primary implementation dispatch boundary for enterprise_hub V1 so execution starts only within the bounded unlocked scope and does not drift into release or unrelated boards.
layer: L0 SSOT
---

# 展链库 V1 当前主 implementation candidate 增量派工单

## 1. Scope
- 本文书只适用于：
  - `enterprise_hub V1`
- 本文书只冻结：
  - 当前实现轮的唯一目标
  - 当前允许的增量范围
  - 当前执行角色与环境边界
  - 当前仍保留的阻断与非目标
- 本文书不代表：
  - release-prep 通过
  - release execution 通过
  - delivery closure 通过

## 2. Dispatch Basis
- 当前派工依据如下：
  - [enterprise_hub_v1_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_stage_gate_checklist_addendum.md)
  - [enterprise_hub_v1_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_implementation_unlock_addendum.md)
  - [enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md)
  - [enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md)
  - [current_active_implementation_candidate_inventory_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md)
  - [enterprise_hub_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md)
  - [enterprise_hub_v1_fields_states_api_contract_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## 3. Round Unique Goal
- 当前实现轮唯一目标是：
  - 只把 `enterprise_hub V1` 的冻结主链做成真实可跑的有界实现
- 当前主链仅包括：
  - 展览首页既有三卡承接
  - app-facing `list / detail / recommendations / application create-edit-submit-status`
  - server-admin `review / publish / offline / freeze`
- 当前轮不允许：
  - 扩到交易闭环
  - 扩到 IM
  - 扩到地图能力
  - 扩到新 building / 第七容器

## 4. Included Scope
### 4.1 Frontend Included Scope
- `apps/mobile` 当前只允许实现：
  - 既有首页三卡到 `enterprise_hub` 的消费与跳转
  - `companies / factories / suppliers` 列表消费
  - `enterprise detail` 详情消费
  - `enterprise apply / application status` 消费
  - 受控 `403 / 404 / empty-state` 展示
- `apps/mobile` 当前不允许实现：
  - 新 building
  - 新底部 tab
  - 直连 `Server`
  - 绕过 `BFF`

### 4.2 BFF Included Scope
- `apps/bff` 当前只允许实现：
  - enterprise_hub 冻结路径族的聚合、转发、错误归一、最小响应整形
  - 上传签名与上下文归一化所需的最小支撑
- `apps/bff` 当前不允许实现：
  - 第二套 enterprise truth
  - 第二状态机
  - `/bff/*` 成为产品合同
  - 绕开 frozen `/api/app/*` 路径族

### 4.3 Backend Included Scope
- `apps/server` 当前只允许实现：
  - enterprise_hub 冻结 truth/admin 路径
  - 冻结状态机
  - 冻结审核与上架动作
  - 审计、权限、数据落库与 read-model 支撑
- `apps/server` 当前不允许实现：
  - 第二套 identity truth
  - 交易闭环
  - 超出 enterprise_hub 当前冻结边界的后链

## 5. Execution Environment Boundary
- Frontend 只在本地执行：
  - `apps/mobile`
- `BFF` 只在云端执行：
  - `apps/bff`
- backend 只在云端执行：
  - `apps/server`
- 本地联调访问统一通过：
  - `http://127.0.0.1:8080`
- 隧道只用于访问验证：
  - 不等于本地写云端服务代码

## 6. Priority Order
1. `Server truth/admin` 先补齐并可启动
2. `BFF` 冻结路径族聚合接入
3. `apps/mobile` 冻结消费链接入
4. `结果校验` 做 enterprise_hub 专属回归
5. `联调发布` 只在前四步都完成后再进入

## 7. Frozen Dependency Handling
- 当前必须带着这条依赖进入实现：
  - [enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md)
- 当前含义是：
  - 允许开始实现
  - 但不允许把“真实账号/组织上下文未补齐”误报为“路由不存在”
  - `403 ENTERPRISE_HUB_PERMISSION_DENIED` 与业务态 `404` 目前可作为受控中间态
- 当前不允许据此得出：
  - release-ready
  - delivery-complete

## 8. Explicit Non-goals
- 不做真实账号体系重构
- 不做交易闭环
- 不做复杂评价体系
- 不做地图深度能力
- 不做 IM
- 不做 enterprise_hub 之外的并行主线
- 不重启四份治理文书 package 的实现线

## 9. Current Formal Conclusion
- 当前正式结论如下：
  - `enterprise_hub V1 = 当前唯一主 implementation dispatch 对象`
  - `enterprise_hub V1 = 现在可以开始有界开发`
  - `release-prep / release = 仍然 No-Go`

## 9.1 Mandatory Receipt Gate
- 当前实现轮还必须同时遵守：
  - [enterprise_hub_v1_implementation_receipt_filing_rule_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_implementation_receipt_filing_rule_addendum.md)
- 当前含义是：
  - 后端 / BFF / 前端每一轮执行完成后，必须先提交并落盘回执
  - 后端 / BFF 回执允许首先落盘在云端工作区
  - 前端回执继续首先落盘在当前仓库 `docs/00_ssot/`
  - 无三份回执，不启动结果校验

## 10. Next Unique Action
- 下一步唯一动作：
  - 按当前派工边界分别向 frontend、BFF、backend 发出 `enterprise_hub V1` 实现任务
  - 任务完成后先交结果校验，不得直接进入 release-prep
