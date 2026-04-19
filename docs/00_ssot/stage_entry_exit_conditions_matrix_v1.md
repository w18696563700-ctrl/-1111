---
owner: Codex 总控
status: frozen
purpose: Freeze one unified entry/exit matrix for each stage in the current serial platform-completion route, including minimum goal, mandatory deliverables, exit conditions, next-stage permission, and stop lines.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_completion_stage_route_map_v1.md
  - docs/00_ssot/current_stage_position_and_unique_mainline_ruling_addendum.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
  - docs/00_ssot/my_building_full_capability_diagnosis_and_cross_building_prerequisite_audit_addendum.md
  - docs/00_ssot/app_infrastructure_upgrade_scan_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_bounded_implementation_dispatch_addendum.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_round1_integration_release_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_release_prep_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_launch_approval_stage_gate_checklist_addendum.md
---

# 《阶段进入 / 退出条件总表 V1》

## 1. Matrix Rule

- 每个阶段必须同时具备：
  - `进入条件`
  - `当前阶段最小目标`
  - `必须交付物`
  - `退出条件`
  - `允许进入下一阶段`
  - `必须停住`
- 任一阶段只要存在未关闭 veto gate，即不得退出。

## 2. `S1`《我的楼 P0 prerequisite repair》

- 进入条件：
  - `my_building prerequisite repair` 已被正式提升为当前战略级主线。
  - `No-Go for direct exhibition/messages continuation` 仍成立。
  - 当前第一子位置 `P0-1 public login opening bounded implementation dispatch` 已冻结，但 execution receipt 尚未形成。
- 当前阶段最小目标：
  - 依固定顺序完成 `P0-1 -> P0-2 -> P0-3 -> P0-4 -> P0-5`。
  - 把当前跨楼 veto 链从“未闭环”推进到“可作为下一阶段前置基座”。
- 必须交付物：
  - `P0-1` execution receipt 与 verification evidence。
  - `P0-2 / P0-3 / P0-4 / P0-5` 的 judgment / freeze / dispatch / execution / verification 文书链。
  - `S1` closure checklist 与遗留清单。
- 退出条件：
  - 公众 actor 的受控登录走廊成立。
  - organization scope 稳定承接成立。
  - certification upload / submit / resubmit 最小闭环成立。
  - Admin 最小审核运营闭环成立。
  - `messages` 单一对象真源已裁决完成。
  - 现行诊断中的 `S1` veto 项不再阻断进入 `S2`。
- 允许进入下一阶段：
  - 只允许进入 `S2`。
- 必须停住：
  - 任一 `S1` 子包越出冻结目录或越权扩成跨包主线。
  - 未完成 `P0-5` 就直接 author `message/index` 实现。
  - 任何试图在 `S1` 内直接切回 `Round 1`、`release-prep` 或 `payment / billing`。

## 3. `S2`《跨楼 transport 与运营支撑收口》

- 进入条件：
  - `S1` 已正式退出。
  - 当前跨楼继续面已不再依赖白名单 / 占位前置。
  - `messages` 单一对象真源已先有结论。
- 当前阶段最小目标：
  - 补齐首发允许范围内最小 transport 与运营支撑缺口。
- 必须交付物：
  - `forum / exhibition transport inventory closure` 文书与执行证据。
  - `message/index` 最小闭环文书与执行证据。
  - `Admin content-safety review task` 接口闭环文书与执行证据。
  - `BFF profile/governance/appeals` 与 `Server` 路由对齐文书与执行证据。
  - 验收真相载体缺口收口结论。
  - `S2` stage gate checklist 与 verification packet。
- 退出条件：
  - 首发范围内不再存在 orphan canonical path。
  - 关键 Admin / governance support 断链已关闭。
  - `message/index` 已建立在已裁决对象上，而非双对象并存。
  - 当前允许首发的继续面不再靠 demo / placeholder 冒充 transport。
- 允许进入下一阶段：
  - 只允许进入 `S3`。
- 必须停住：
  - 试图把 `S2` 直接扩成完整交易 runtime 无限开放。
  - 在 `messages` 真源未锁死前继续叠加消息功能。
  - 把 `S2` 的 support closure 写成平台全量运营已完成。

## 4. `S3`《我的楼功能本体 Round 1 重入与 bounded implementation》

- 进入条件：
  - `S1` 与 `S2` 均已退出。
  - 当前已不存在阻断 `Round 1` 重入的 prerequisite veto。
  - 总控重新提交 `Round 1` 进入门禁，并获得 `Go`。
- 当前阶段最小目标：
  - 在既有真源内完成 `我的楼 -> 我的项目 -> Package 1 bounded consumption` 一致性收口。
- 必须交付物：
  - `Round 1` 重入 judgment / dispatch 文书。
  - 前端、本地消费面对齐执行证据。
  - 后端 `my_project` read truth / presenter 对齐执行证据。
  - BFF `my_project` shaping / projection drift 修复执行证据。
  - 独立结果校验结论。
- 退出条件：
  - `Round 1` bounded implementation 已完成并得到可引用结果结论。
  - `entry owner / route owner / page owner / truth owner` 漂移已被收住。
  - 仍保留的缺口已明确为后续 `S4` integration 验证对象，而不是未识别风险。
- 允许进入下一阶段：
  - 只允许进入 `S4`。
- 必须停住：
  - 把 profile 写成第二 truth owner。
  - 把 docs-frozen / existing page 写成 runtime fully open。
  - 借 `Round 1` 抢开 `payment / billing`、`V2.3` 或完整 trade runtime。

## 5. `S4`《首发业务包结果校验与 integration closure》

- 进入条件：
  - `S3` 已退出。
  - bounded implementation 执行证据齐全。
  - 真实拓扑、最小 smoke、运行态样本已可用于 integration 验证。
- 当前阶段最小目标：
  - 完成首发有界业务包的 integration 验证、保留缺口修正与 rerun closure。
- 必须交付物：
  - integration verification checklist。
  - retained-gap dispatch 与 rerun 结论。
  - integration release go / no-go conclusion。
- 退出条件：
  - 当前首发有界业务包的 integration verification 明确通过。
  - `release-prep` 前置证据不再存在 veto 级缺口。
  - 下一阶段只剩 `release-prep -> launch approval -> launch`。
- 允许进入下一阶段：
  - 只允许进入 `S5`。
- 必须停住：
  - 在 verification 未通过前声称 release ready。
  - 以补验证名义重开新业务包或新路径族。

## 6. `S5`《release-prep -> launch approval -> launch》

- 进入条件：
  - `S4` 已退出。
  - 真实拓扑、rollback、observability、audit、smoke evidence 已齐全。
  - 首发 building 仍只限 `exhibition / messages / profile`。
- 当前阶段最小目标：
  - 在可回滚、可观测、可复盘前提下完成首发放行。
- 必须交付物：
  - `release-prep` gate checklist。
  - `launch approval` gate checklist。
  - 首发 smoke evidence、rollback plan、runtime signoff。
  - launch receipt。
- 退出条件：
  - 首发已按受控方式上线。
  - 回滚路径已验证可用。
  - 上线后运营 handoff 已被正式接收。
- 允许进入下一阶段：
  - 只允许进入 `S6`。
- 必须停住：
  - hidden buildings visible 化。
  - 未有 rollback / observability 就强行放行。
  - 用 launch 阶段顺手打开战略保留包。

## 7. `S6`《上线后稳定化与运营回看》

- 进入条件：
  - `S5` 已退出，首发已上线。
  - 运行监控、审计、告警、回滚纪律均已接手。
- 当前阶段最小目标：
  - 完成首发后稳定化、运营回看与后续重入门禁冻结。
- 必须交付物：
  - post-launch monitoring baseline。
  - incident / rollback report 模板与首轮回看结论。
  - deferred backlog re-entry register。
  - post-launch closure conclusion。
- 退出条件：
  - 首发稳定窗口结束。
  - 无未处理的 veto 级 incident。
  - 后续任何新包都必须走新的 stage gate，而不是沿用当前首发路线。
- 允许进入下一阶段：
  - 当前完工路线到此结束；后续只允许进入新的独立重入判断。
- 必须停住：
  - 借稳定化期继续扩 scope。
  - 未经新门禁直接打开 `payment / billing`、`V2.3`、`个人实名` 或更大平台化深化。

## 8. Formal Conclusion

- 每个阶段的进入、退出、停住条件现已统一固定。
- 当前唯一活动阶段仍是 `S1`，其退出前不得切入 `S2` 及以后阶段。
- `verification / closure / release` 只能沿 `S3 -> S4 -> S5 -> S6` 顺序进入。
