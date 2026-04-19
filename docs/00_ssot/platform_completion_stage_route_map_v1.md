---
owner: Codex 总控
status: frozen
purpose: Freeze the 10-stage serial platform-completion route from the current real project state to release and the first 90 days of platform operations, replacing the old 6-stage control map.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/stage1_repair_closure_conclusion_addendum.md
  - docs/00_ssot/stage2_transport_admin_support_closure_conclusion_addendum.md
  - docs/00_ssot/stage3_stage_gate_checklist_addendum.md
  - docs/00_ssot/s1_c01_message_index_minimal_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_c03_admin_content_safety_review_tasks_minimal_interface_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md
---

# 《平台完工阶段总路线图 V1》

## 1. Scope

- 本路线图只冻结：
  - 从 `2026-04-09` 当前仓库真实状态到完工的唯一串行总路线
  - 每阶段的一句话目标
  - 每阶段与前后阶段的唯一关系
  - 基础设施阶段、业务包阶段、发布阶段的分类
- 本路线图不做：
  - implementation unlock
  - implementation dispatch
  - release go/no-go
  - 对既有历史 closure 结论做口头覆盖

## 2. Canonical 10-Stage Route

| 阶段 | 名称 | 一句话目标 | 前序 | 后序 | 类型 |
|---|---|---|---|---|---|
| `阶段 1` | `P0 前置依赖修复总包` | 关闭公众登录、组织范围、认证上传、治理路由、对象裁决等 veto 级前置缺口。 | 当前真实状态起点 | `阶段 2` | 基础设施阶段 |
| `阶段 2` | `展览交易主链 app-facing transport 最小闭环` | 让展览交易主链的最小 app-facing transport 真正可读、可消费、不可误写成 ghost route。 | `阶段 1` | `阶段 3` | 基础设施阶段 |
| `阶段 3` | `Admin 最小运营与治理闭环` | 把 Admin 从“支撑接口存在”推进到“最小运营与治理闭环成立”。 | `阶段 2` | `阶段 4` | 基础设施阶段 |
| `阶段 4` | `消息楼单一对象真相与 message/index 最小闭环` | 固化消息楼的单一 active object，并把 `message/index` 收成不漂移的最小闭环。 | `阶段 3` | `阶段 5` | 基础设施阶段 |
| `阶段 5` | `我的楼功能本体 Round 1 一致性收口` | 收拢 `profile / 我的楼 / 我的项目 / Package 1 bounded consumption` 的一致性与 owner 边界。 | `阶段 4` | `阶段 6` | 业务包阶段 |
| `阶段 6` | `V2.0 会员规则与 membership package` | 冻结并落地付费会员规则、权益、配额和最小 membership package。 | `阶段 5` | `阶段 7` | 业务包阶段 |
| `阶段 7` | `V2.1 信用 / 保证金 / 交易保障 package` | 建立信用约束、保证金和交易保障的最小执行闭环。 | `阶段 6` | `阶段 8` | 业务包阶段 |
| `阶段 8` | `V2.2 支付 / 账单 / 服务费 package` | 建立支付、账单、服务费的最小结算闭环。 | `阶段 7` | `阶段 9` | 业务包阶段 |
| `阶段 9` | `V2.3 我的楼私域操作系统整理` | 在前述包成立后，整理私域 IA、操作系统分层和承接效率。 | `阶段 8` | `阶段 10` | 业务包阶段 |
| `阶段 10` | `release-prep -> launch -> 上线后 90 天平台化运营` | 完成发布准备、放量上线和首个 90 天的平台化运营收口。 | `阶段 9` | 完工 | 发布阶段 |

## 3. Stage Relationship Lock

- 本路线图是：
  - `单主线`
  - `单线程`
  - `上一阶段 closure 后，下一阶段才可进入`
- 本路线图不是：
  - 并行待办池
  - 多阶段抢跑图
  - “哪个看起来顺手就先做哪个”的机会主义路线
- 阶段前后关系正式锁定为：
  - `阶段 1 -> 阶段 2 -> 阶段 3 -> 阶段 4 -> 阶段 5 -> 阶段 6 -> 阶段 7 -> 阶段 8 -> 阶段 9 -> 阶段 10`
- `阶段 10` 虽然包含：
  - `release-prep`
  - `launch`
  - `上线后 90 天平台化运营`
  但它们只属于同一发布阶段的内部子段，不构成新的并行主线。

## 4. Stage Type Classification

- 基础设施阶段：
  - `阶段 1`
  - `阶段 2`
  - `阶段 3`
  - `阶段 4`
- 业务包阶段：
  - `阶段 5`
  - `阶段 6`
  - `阶段 7`
  - `阶段 8`
  - `阶段 9`
- 发布阶段：
  - `阶段 10`
- `阶段 10` 内部再细分为：
  - 发布准备子段
  - 上线放行子段
  - 上线后 90 天运营子段

## 5. Existing Evidence Remap

- 本仓在 `2026-04-09` 已存在旧的 6 阶段控制文书链。
- 旧文书链中已冻结的结论，必须按以下方式映射进新 10 阶段路线：
  - `stage1 repair closure = PASS WITH RISK`
    - 视为 `阶段 1` 已完成的历史 closure 证据
  - `stage2 transport admin support closure = PASS WITH RISK`
    - 不再当作“当前主线”
    - 它的证据被拆入新路线的 `阶段 2 / 3 / 4` 作为已存在支撑基线
- 具体拆分固定为：
  - 旧 `S2` 的 `order-contract-fulfillment read corridor backend + BFF + mobile` 闭环
    - 归入新 `阶段 2` 的历史完成证据
  - 旧 `S1-C03 admin review-tasks minimal interface closure`
    - 归入新 `阶段 3` 的支撑输入
    - 但不等于新 `阶段 3` 已 closure
  - 旧 `S1-R05 governance appeals BFF-server route alignment`
    - 归入新 `阶段 3` 的支撑输入
    - 但不等于新 `阶段 3` 已 closure
  - 旧 `S1-C01 message index minimal closure`
    - 归入新 `阶段 4` 的支撑输入
    - 但不等于新 `阶段 4` 已 closure
- 以上 remap 的唯一含义是：
  - 旧证据可承接
  - 新路线的当前主线与后续顺序，仍以本路线图重新锁定后的阶段定义为准

## 6. Current Position Under The New Route

- 按 `2026-04-09` 已冻结文书链重映射后，当前平台位置固定为：
  - `阶段 1 = 历史 closure 已成立`
  - `阶段 2 = 历史 closure 已成立`
  - `阶段 3 = judgment 已成立，待进入 controller review`
- 因此：
  - 当前唯一主线不再是 `阶段 2`
  - 当前唯一主线必须转入 `阶段 3`

## 7. Out-of-route Misread Prohibition

- 以下对象不得被偷换成“当前主线”：
  - `payment / billing` 的旧单包文书
  - `my_building Round 1` 的旧增量派工文书
  - `private operating system` 的旧边界文书
  - 任意旧 `release-prep / launch` 检查单
- 上述对象在新路线下只能被理解为：
  - 历史准备材料
  - 后续阶段输入
  - 非当前阶段执行口令

## 8. Formal Conclusion

- 当前平台完工总路线正式改锁为 10 阶段串行主线。
- 当前阶段类型划分固定为：
  - `阶段 1~4 = 基础设施阶段`
  - `阶段 5~9 = 业务包阶段`
  - `阶段 10 = 发布阶段`
- 在 `2026-04-09` 的真实仓库状态下：
  - `阶段 1` 已 closure
  - `阶段 2` 已 closure
  - 当前唯一主线已推进到 `阶段 3`
