---
owner: Codex 总控
status: draft
purpose: Record the current active implementation-candidate inventory after the four governance packages enter total closure, so the project returns to one real development mainline instead of continuing governance expansion.
layer: L0 SSOT
---

# 当前 active implementation candidate 盘点单

## A. 当前对象
- 本文书只回答一件事：
  - 当前项目里，哪个对象是下一轮真实开发主线的 active implementation candidate
- 本文书不是：
  - implementation unlock addendum
  - implementation dispatch
  - release-prep approval
  - release execution approval

## B. 当前依据
- 当前依据如下：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [source_of_truth_map.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/source_of_truth_map.md)
  - [forum_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_implementation_unlock_addendum.md)
  - [forum_implementation_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_implementation_stage_gate_checklist_addendum.md)
  - [forum_server_implementation_blocker_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_server_implementation_blocker_addendum.md)
  - [forum_implementation_asset_inventory_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_implementation_asset_inventory_addendum.md)
  - [enterprise_hub_v1_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_stage_gate_checklist_addendum.md)
  - [enterprise_hub_v1_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_implementation_unlock_addendum.md)
  - [enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md)
  - [enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md)
  - [exhibition_trade_governance_four_documents_total_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_total_closure_conclusion_addendum.md)

## C. 当前候选盘点
- 当前可识别的实现候选只有两类：
  1. `enterprise_hub V1`
  2. `论坛模块`
- 四份治理文书 package 不再属于当前 implementation candidate：
  - `账户与企业认证规则 V1`
  - `假项目举报与裁决规则 V1`
  - `合同归档与履约强制入链规则 V1`
  - `黑白名单与永久封禁规则 V1`

## D. 候选分级
### D1. 当前主 implementation candidate
- 当前主 implementation candidate：
  - `enterprise_hub V1`
- 判定依据：
  - 已存在 stage gate：
    - [enterprise_hub_v1_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_stage_gate_checklist_addendum.md)
  - 已存在 bounded implementation unlock：
    - [enterprise_hub_v1_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_implementation_unlock_addendum.md)
  - 已存在 Phase 0 exception legality package：
    - [enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_phase0_implementation_exception_unlock_addendum.md)
- 当前含义：
  - `enterprise_hub V1` 仍是唯一可被继续派发实现任务的主线对象
- 当前保留阻断：
  - release-prep / release 仍未通过
  - 真实账号 / 组织上下文仍是交付前依赖，而不是路由不存在问题

### D2. 次级历史实现候选
- 次级历史实现候选：
  - `论坛模块`
- 判定依据：
  - forum 曾获 bounded implementation unlock：
    - [forum_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_implementation_unlock_addendum.md)
  - 但当前仍存在正式 blocker：
    - [forum_server_implementation_blocker_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/forum_server_implementation_blocker_addendum.md)
- 当前含义：
  - forum 不是被否决
  - 但它不是当前下一轮的主 implementation dispatch 对象
  - 在 cloud-shell blocker 未解除前，不应把 forum 重新提为主开发线

## E. 当前排除项
- 以下对象当前明确排除出 implementation candidate：
  - 四份治理文书 package
  - 任何未获独立 unlock / exception legality 的新对象
  - 任何只完成 docs-only freeze、但未被明确指定为 active candidate 的对象

## F. 当前总控裁决
- 当前总控裁决明确如下：
  - `enterprise_hub V1 = 当前唯一主 implementation candidate`
  - `论坛模块 = 保留历史实现候选，但当前不作为主派工对象`
  - `四份治理文书 package = docs-frozen / implementation No-Go`

## G. 当前结论不代表的事项
- 本结论不代表：
  - `enterprise_hub V1` 已获得 release-prep 或 release 许可
  - `论坛模块` 已被永久关闭
  - 四份治理文书会自动进入实现

## H. 下一步唯一动作
- 下一步唯一动作：
  - 围绕 `enterprise_hub V1` 输出一份《当前主 implementation candidate 增量派工单》，并只给该对象派发实现任务
