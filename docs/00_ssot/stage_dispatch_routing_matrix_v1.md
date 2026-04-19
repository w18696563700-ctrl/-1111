---
owner: Codex 总控
status: frozen
purpose: Freeze the dispatch-routing matrix for the new 10-stage platform-completion route, including who enters when, who owns implementation, and which stages forbid the control role from writing code.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_completion_stage_route_map_v1.md
  - docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md
  - docs/00_ssot/stage_entry_exit_conditions_table_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md
---

# 《阶段派工路由矩阵 V1》

## 1. Routing Laws

- `总控` 在所有阶段都只负责：
  - 锁定当前唯一主线
  - 提交阶段门禁核查表
  - 做 judgment / go-no-go / dispatch routing
  - 写 `docs/**` 控制文书
- `总控` 在所有阶段都不得：
  - 下场写 `apps/mobile/**`
  - 下场写 `apps/admin/**`
  - 下场写 `apps/bff/**`
  - 下场写 `apps/server/**`
  - 把 dispatch 偷换成 acceptance
- `总控文书冻结` 在所有阶段都只负责：
  - 同步真源文书
  - 固化口径、引用链、门禁、前后序
- `总控文书冻结` 在所有阶段都不得：
  - 越权改方向
  - 越权改优先级
  - 越权授予 implementation unlock
  - 写任何 `apps/**` 代码
- `前端` 只指：
  - `apps/mobile`
- `后端` 只指：
  - `apps/server`
  - 以及按仓库 ownership 默认承接的 `apps/admin`
- `BFF` 只指：
  - `apps/bff`
- 真实施工必须遵守：
  - `judgment -> dispatch -> implementation -> verification -> closure`
- `结果校验` 只能在 execution evidence 已形成后进入。
- `联调发布` 只能在总控明确放行，且 release 相关阶段满足门禁后进入。

## 2. Stage Dispatch Matrix

| 阶段 | 总控 | 总控文书冻结 | 前端 | 后端 | BFF | 结果校验 | 联调发布 |
|---|---|---|---|---|---|---|---|
| `阶段 1` | 锁定 `P0` 修复顺序与 veto 清单；一子包一裁决；不越级切阶段 2。 | 只同步 repair / checklist / closure 文书。 | 只在认证上传、登录承接等被正式 dispatch 后介入。 | 第一执行 owner；修公众登录、组织范围、认证上传、治理路由、对象裁决上游。 | 只在 Server truth 冻结后介入；负责 app-facing shaping。 | 对每个修复子包独立复核；不通过不得进下一子包。 | 不得介入。 |
| `阶段 2` | 锁定展览交易主链 transport 最小目标；先做 controller review 再发 dispatch。 | 只同步 transport route、closure、遗留风险文书。 | 在 Server + BFF transport 可用后，负责 mobile consumption 与 placeholder 清退。 | 第一执行 owner；补 order/contract/milestone/inspection 最小 read corridor。 | 第二执行 owner；补 app-facing transport family、error normalization、visibility trimming。 | 独立复核 backend/BFF/mobile 三段证据。 | 原则上不得介入；除非总控单独放行为受控 smoke 取证。 |
| `阶段 3` | 锁定 Admin 最小运营与治理闭环边界；只允许 controller review，不得直接发 implementation。 | 只同步 Admin workbench、权限、治理动作、closure 文书。 | 默认不介入。 | 第一执行 owner；先做 `Server` Admin API 与 `apps/admin` 最小工作台，保持 Admin 直连 Server。 | 默认不介入；只有在 app-facing user-side summary 需要配套读模型时，才以支撑角色介入。 | 独立复核工作台、动作权限、审计与治理链是否闭环。 | 不得介入。 |
| `阶段 4` | 锁定单一 active object 与 `message/index` 最小闭环；禁止重开双主线。 | 只同步对象裁决、routeTarget、closure 文书。 | 负责 mobile messages 消费面对齐与 fail-closed 承接。 | 第一执行 owner；固化 message object truth 与 upstream family。 | 第二执行 owner；补 `message/index` app-facing shaping 与 canonical path 对齐。 | 复核单一对象、routeTarget、一致性与占位误读风险。 | 不得介入。 |
| `阶段 5` | 锁定 `我的楼功能本体 Round 1` 的 bounded 目标；按子包发 dispatch。 | 只同步 Round 1 judgment / dispatch / verification / closure 文书。 | 第一消费 owner；处理 `profile / my_project / package1` 的一致性承接。 | 第一 truth owner；修 `my_project` read truth、command upstream 与 runtime gap。 | 第二执行 owner；修 app-facing shaping、projection drift、error normalization。 | 作为阶段 5 主复核 owner；不给 pass 不得进入阶段 6。 | 不得介入。 |
| `阶段 6` | 锁定 membership 的唯一范围，不得带入支付/保障。 | 只同步 membership rules、quota、closure 文书。 | 承接 membership summary、detail、quota 消费面。 | 第一执行 owner；建立 paid-membership truth、entitlement/quota rules。 | 第二执行 owner；暴露 app-facing membership family。 | 复核规则可执行性、命名隔离与审计。 | 不得介入。 |
| `阶段 7` | 锁定信用/保证金/交易保障 package，不得偷带 payment。 | 只同步 guarantee 规则、约束、closure 文书。 | 承接 guarantee summary 与交易链受控提示。 | 第一执行 owner；建立 credit/deposit/guarantee truth、约束与审计链。 | 第二执行 owner；提供 app-facing guarantee projection。 | 复核约束执行、记录可追踪性和交易绑定。 | 不得介入。 |
| `阶段 8` | 锁定支付/账单/服务费 package，不得偷带 release 话术。 | 只同步 payment/billing/service-fee 规则与 closure 文书。 | 承接支付页、账单页、服务费摘要消费面。 | 第一执行 owner；建立 payment/billing settlement truth。 | 第二执行 owner；提供 app-facing payment/billing family。 | 复核账单、状态、服务费核算与审计链。 | 不得介入。 |
| `阶段 9` | 锁定私域操作系统整理边界，只允许整理，不允许新开业务包。 | 只同步 IA、分层、承接矩阵与 closure 文书。 | 第一执行 owner；重整私域导航、入口分层、性能与可达性。 | 只做必要的 supporting truth / aggregator corrections。 | 只做必要的 shaping corrections。 | 复核 IA、性能、truth owner 边界是否稳定。 | 不得介入。 |
| `阶段 10` | 锁定 release-prep、launch、90 天运营的 go/no-go；禁止再开新业务主线。 | 只同步 release checklist、launch signoff、运营结案文书。 | 只修 release blocker。 | 只修 release blocker。 | 只修 release blocker。 | 复核 smoke、rollback、observability、audit、90 天指标。 | 主执行 owner；负责受控联调、发布、回滚演练与 90 天运营取证。 |

## 3. 角色介入顺序规则

- 默认介入顺序固定为：
  1. `总控`
  2. `总控文书冻结`
  3. `后端`
  4. `BFF`
  5. `前端`
  6. `结果校验`
  7. `联调发布`
- `阶段 3` 为例外：
  - 因为 `Admin` 直连 `Server`
  - 所以后端先做 `Server + apps/admin`
  - `BFF` 不得成为 Admin 主通道
- `阶段 10` 为唯一允许 `联调发布` 成为主执行 owner 的阶段。

## 4. 哪些阶段绝不能让总控自己下场写代码

- 绝不能让 `总控` 自己下场写 `apps/**` 代码的阶段固定为：
  - `阶段 1`
  - `阶段 2`
  - `阶段 3`
  - `阶段 4`
  - `阶段 5`
  - `阶段 6`
  - `阶段 7`
  - `阶段 8`
  - `阶段 9`
  - `阶段 10`
- 唯一允许 `总控` 直接写的内容固定为：
  - `docs/**` 控制文书

## 5. verification 与 closure 进入规则

- `阶段 1`：
  - 对应 repair 子包 execution evidence 齐全后，才允许 verification；全部 repair 收口后才允许 closure。
- `阶段 2`：
  - backend / BFF / mobile 三段 transport evidence 齐全后，才允许 verification 与 closure。
- `阶段 3`：
  - `Server Admin API + apps/admin workbench` 的 execution evidence 齐全后，才允许 verification 与 closure。
- `阶段 4`：
  - 单一对象、routeTarget、consumer evidence 齐全后，才允许 verification 与 closure。
- `阶段 5~9`：
  - 对应业务包的 backend/BFF/frontend evidence 齐全后，才允许 verification 与 closure。
- `阶段 10`：
  - release facts、rollback drill、90 天运营 evidence 齐全后，才允许最终完工结论。

## 6. 当前阶段不悬空机制

1. 当前阶段完成度：
   - `阶段 3 judgment 完成`
2. 当前下一步唯一动作：
   - `由总控输出《阶段3 Admin 最小运营与治理闭环 controller review spec bundle》`
3. 下一步执行角色：
   - `总控`
4. 下一步进入条件：
   - 四份总控底稿已冻结
   - `stage3 gate checklist` 仍为 `Go for stage3 controller review`
   - 未新增 veto 级反证

## 7. Formal Conclusion

- 当前派工路由正式锁定为：
  - `总控` 负责判断与路由
  - `总控文书冻结` 负责真源同步
  - `前端 / 后端 / BFF` 只在被正式 dispatch 后进入
  - `结果校验` 负责独立复核
  - `联调发布` 只在 `阶段 10` 成为主执行 owner
- 在整条 10 阶段路线中，不存在“总控自己直接写 apps 代码”的合法阶段。
