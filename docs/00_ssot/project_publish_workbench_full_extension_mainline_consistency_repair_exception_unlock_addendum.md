---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded consistency-repair exception for
  `发布项目工作台及延伸功能全链`, allowing runtime exposure rollback to
  match the current freeze surface without treating the round as trading-flow
  implementation, chain binding, or scope expansion.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - apps/mobile/AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_code_layer_scan_diagnosis_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_root_guardrail_exception_review_conclusion_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/src/generated/app-api.types.ts
---

# 《发布项目工作台 consistency repair 例外放行单》

## A. 当前对象

- 当前对象仅限：
  - `发布项目工作台及延伸功能全链`
  - `consistency repair only`
  - 运行面越界入口回收
- 本文书只回答：
  - 当前修复是否允许进入实现
  - 当前修复的边界是什么
  - 当前哪些 veto 继续保留
- 本文书不是：
  - trading-flow implementation unlock
  - root-guardrail exception unlock grant
  - implementation dispatch send for trading chain
  - integration / `release-prep` / production release

## B. 当前依据

- 当前 formal basis 只吸收以下依据：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [apps/mobile/AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [project_publish_workbench_full_extension_mainline_code_layer_scan_diagnosis_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_workbench_full_extension_mainline_code_layer_scan_diagnosis_addendum.md)
  - [project_publish_workbench_full_extension_mainline_package_level_implementation_unlock_assessment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_workbench_full_extension_mainline_package_level_implementation_unlock_assessment_addendum.md)
  - [project_publish_workbench_full_extension_mainline_root_guardrail_exception_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_workbench_full_extension_mainline_root_guardrail_exception_review_conclusion_addendum.md)
  - [project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md)
  - [project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md)
- 当前不得以以下事项替代上述依据：
  - 页面壳已存在
  - 旧测试仍然通过
  - 历史 generated path 曾经暴露过更多入口
  - runtime 还有旁路入口

## C. 当前矛盾的性质

- 当前已确认矛盾不是：
  - “功能尚未开发”
  - “后端链路待补齐”
- 当前已确认矛盾是：
  - formal contract surface 已收口
  - runtime exposure 仍然越界
  - 冻结能力仍可被 router / detail handoff / messages / tests 旁路拉起
- 因此当前对象需要的是：
  - bounded consistency repair
  - 不是 trading-flow implementation

## D. 当前例外边界

- 当前例外边界只允许进入：
  - `apps/mobile/**` 中已被冻结但仍可达入口的回收
  - 与上述入口直接绑定的 test 修正或删除
  - 防止冻结能力继续暴露所需的最小呈现层保护
- 当前例外边界明确限于：
  - router 入口
  - detail handoff 入口
  - messages registered-entry 旁路入口
  - 与其直接绑定的 route availability / page handoff / registry contract tests
- 当前例外边界不外溢到：
  - `apps/server/**`
  - `apps/bff/**` 的真实交易聚合实现
  - `order_chain / fulfillment_chain` 真绑定
  - 新 command path
  - 新 domain 行为

## E. 当前允许动作

- 当前正式允许：
  - 从 [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart) 收回 freeze 禁止的 route/page carrier
  - 从 [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart) 收回 `contract.confirm` 与 `contract.amend` handoff
  - 从 [rating_entry_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart) 收回 `rating.submit` handoff
  - 从 [messages_registered_entry_registry.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart) 撤下 freeze 不允许的 action registration
  - 修正或删除与上述越界入口直接绑定的 tests
- 当前允许的处理原则只有：
  - 只收，不补
  - 只退回 freeze 允许边界
  - 不把 shell / boundary 节点重新解释成 active command family

## F. 当前明确禁止

- 当前继续明确禁止：
  - `order_chain / fulfillment_chain` 真数据绑定
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating` 真链路接通
  - `dispute/withdraw`
  - 任何新增 `Server` domain logic
  - 任何新增 `BFF` 写链路或真实聚合链
  - 任何绕过 freeze 重新暴露禁用入口的行为

## G. 当前 retained veto

- `No trading flow implementation` 继续有效。
- `package-level implementation unlock = No-Go` 继续有效。
- `BFF implementation dispatch = No-Go` 继续有效。
- `frontend implementation dispatch = No-Go` 对 trading-flow implementation 继续有效。
- `order_chain / fulfillment_chain` 真绑定继续视为 veto 区。
- 任一超出“runtime exposure rollback”范围的实现动作，继续按越界处理。

## H. Formal Exception Conclusion

- 当前正式结论如下：
  - `project publish workbench / consistency repair only / exception unlock = Go`
  - `router / detail handoff / messages / tests runtime exposure rollback = Go`
  - `order_chain / fulfillment_chain true binding = No-Go`
  - `trading-flow implementation = No-Go`
  - `integration = No-Go`
  - `release-prep = No-Go`
  - `production release = No-Go`

## I. 当前结论的含义

- 当前放行的含义只有：
  - 允许把 runtime exposure 修回与 freeze 一致
  - 允许把“formal surface 已收口、运行面仍越界”的冲突态消除
- 当前放行不代表：
  - 允许补 order / contract / inspection / rating / dispute 真实现
  - 允许把 workbench 从 `project_chain only` 推进到完整交易摘要闭环

## J. Next Unique Action

- 下一步唯一动作：
  - 进入 `apps/mobile` bounded consistency repair
  - 只回收越界入口
  - 不新增任何真实交易实现
