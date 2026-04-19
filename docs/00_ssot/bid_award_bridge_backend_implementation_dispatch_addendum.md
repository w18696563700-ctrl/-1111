---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the authored backend implementation dispatch prompt for
  `BidAward bridge` so the cloud Server execution handoff text stays inside
  the already-frozen bridge blueprint, stage-gate ruling, and bounded
  implementation-dispatch bundle, while real backend dispatch issuance
  remains blocked until a separate unlock-assessment concludes `Go`.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/domain_model.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《BidAward bridge backend implementation dispatch》

## 1. 当前阶段

- 主对象：
  - `BidAward bridge`
- 子阶段：
  - `backend implementation dispatch authoring`
- 当前必须明确：
  - 这份文书只是在 author 后端派工口令
  - 当前仍然不是 `real backend dispatch issuance`
  - 当前仍不得直接发送给 `Backend Agent`

## 2. 当前唯一动作

- 供后续使用的 `Backend Agent` 执行口令如下。
- 当前口令已 author 完成，但在单独的 backend real-dispatch assessment / unlock 结论放行为 `Go` 之前不得发送。

## 3. Backend Agent 口令正文

```text
你是 Backend Agent（仅云端），本轮不是重做交易主链，也不是直接打开 trading flow implementation。你这轮只在《BidAward bridge》已经冻结好的桥接范围内，完成 Server 侧首轮最小实现。

【一、唯一目标】
你这轮只完成 8 件事：
1. 建立唯一合法桥接 truth：
   - `BidAward`
2. 建立 `loser disposition` 子事实：
   - 不允许静默落选
3. 建立 buyer 侧 award command：
   - `POST /server/bid/award`
4. 建立 supplier 侧最小结果读出口：
   - `GET /server/bid/result`
5. 完成 `BidAward -> Order conversion`
6. 在同事务内同步生成 `contract seed`
7. 推进 `Project.state` 最小桥接迁移：
   - `published -> awarded -> converted_to_order`
8. 让 buyer 侧 `my-project / workbench` 承接最小 fallout refresh

【二、强制阅读】
- docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
- docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
- docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml
- apps/server/src/modules/bid/bid-write.service.ts
- apps/server/src/modules/project/project-write.service.ts
- apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.service.ts
- apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts

【三、只允许处理的范围】
- docs/01_contracts/openapi.yaml
- packages/contracts/src/generated/app-api.types.ts
- apps/server/src/app.module.ts
- apps/server/src/modules/bid/**
- apps/server/src/modules/project/**
- apps/server/src/modules/my_project/**
- apps/server/src/modules/exhibition_workbench/**
- apps/server/src/modules/organization/current-actor-eligibility.service.ts
- apps/server/src/modules/audit/**
- 允许新增：
  - apps/server/src/modules/bid_award/**

【四、后端内部唯一施工顺序】
1. 先冻结并落地 `BidAward` truth carrier 与 loser disposition persistence 结构
2. 再落 buyer 权限校验与 `POST /server/bid/award` command entry
3. 再落 `BidAward -> Order -> Contract seed -> Project.state` 同事务转换
4. 再落 `GET /server/bid/result` 最小 supplier 读出口
5. 再落 `my_project / exhibition_workbench` 的最小 fallout refresh
6. 最后补 focused tests、并发/幂等/原子性验证

【五、并发 / 幂等 / 原子性必须落地的位置】
1. 并发与唯一性裁决只允许落在：
   - `Server` 真值事务层
   - `BidAward` write service / repository lock path
2. 不允许把并发裁决下放到：
   - controller
   - BFF
   - frontend
3. 最小要求：
   - 同一 `projectId` 并发 award 只能单胜
   - 同一 `projectId` 重复 award 必须 fail-close
   - `BidAward -> loser disposition -> Order -> Contract seed -> Project.state`
     必须同事务提交
4. 若任一步失败：
   - 业务真值整体回滚
   - 只允许保留 append-only 审计 attempt
   - 不允许留下半成品 `Order`
   - 不允许留下没有 loser disposition 的 `BidAward`
   - 不允许留下 `converted_to_order` 但没有 `Order / Contract seed`

【六、状态迁移落地规则】
1. 当前桥接只允许：
   - `Project.state: published -> awarded -> converted_to_order`
2. `BidAward.state` 只允许：
   - `awarded`
   - `converted_to_order`
3. `Order.state` 当前只允许写入：
   - `active`
   但它只允许解释为：
   - bridge compatibility state
   绝不允许解释为：
   - 合同已确认完成
   - 完整交易已正式生效
   - 完整履约已正式启动
4. `Contract.state` 当前只允许 seed 为：
   - `pending_confirm`

【七、错误码与 fail-close 规则】
1. 当前必须有稳定业务错误族：
   - `BID_AWARD_INVALID`
   - `BID_AWARD_INVALID_STATE`
   - `BID_AWARD_DUPLICATE`
   - `BID_AWARD_CONCURRENT_CONFLICT`
   - `BID_RESULT_UNAVAILABLE`
   - `BID_RESULT_INVALID`
   - `ORDER_CONVERSION_FAILED`
   - `CONTRACT_SEED_FAILED`
2. 当前所有错误都必须 fail-close：
   - 不能猜成功
   - 不能 partial success
   - 不能 silent fallback 到旧 `/order/create`
3. 若当前 repo 结构不足以安全落地任一条：
   - 必须返回 blocker
   - 不得偷扩对象边界

【八、最小测试清单】
1. truth creation:
   - `BidAward` 创建成功
   - loser disposition 同步落库
2. duplicate / concurrent:
   - 同一 `projectId` 重复 award fail-close
   - 并发 award 只有一个成功
3. atomic conversion:
   - `BidAward -> Order -> Contract seed -> Project.state`
     成功时同闭合
   - 任一步失败时整体回滚
4. state transition:
   - `Project.state` 正确迁移到 `awarded / converted_to_order`
   - `Order.state = active` 仅作为兼容态
   - `Contract.state = pending_confirm`
5. result outlet:
   - `GET /server/bid/result?projectId=...`
     中标方可读 `won`
   - 落选方可读 `lost + reasonCode + reasonText`
6. fallout refresh:
   - `my-project` buyer 侧最小 refresh 成立
   - `workbench.project_chain / order_chain` buyer 侧最小 refresh 成立
7. non-regression:
   - `bid/submit` 不回退
   - `contract confirm / amend` 不回退
   - `inspection recheck` 不回退
   - `dispute withdraw` 不回退

【九、明确不做的事项】
- 不得重开 `POST /api/app/order/create`
- 不得扩到 `seat`
- 不得扩到 `bid package completeness`
- 不得扩到 payment / billing / settlement / split-billing
- 不得扩到 electronic signature
- 不得扩到 complex scoring / heavy risk control
- 不得扩到 full compare console
- 不得扩到 supplier bid workspace / my bids workspace
- 不得把 `Workbench` 写成 buyer compare owner
- 不得把 `My Project` 写成 bid truth owner
- 不得把 loser disposition 混进 `Order`
- 不得把 `Order` 写成 award truth owner
- 不得进入 BFF 或 frontend 范围

【十、阶段完成标志】
只有在以下条件同时成立时，这轮后端实施才算完成：
1. `BidAward` truth 与 loser disposition truth 已落地
2. `POST /server/bid/award` 可跑
3. `GET /server/bid/result` 可跑
4. `BidAward -> Order -> Contract seed -> Project.state`
   同事务闭合
5. duplicate / concurrent / rollback focused tests 全过
6. buyer 侧 `my-project / workbench` 最小 fallout refresh 成立
7. 没有把 `/order/create`、seat、支付、电子签、复杂评分带回

【十一、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. `BidAward` truth 落地结果
4. loser disposition 落地结果
5. `POST /server/bid/award` 结果
6. `GET /server/bid/result` 结果
7. `BidAward -> Order -> Contract seed` 原子闭合结果
8. `Project.state` 迁移结果
9. buyer 侧 `my-project / workbench` fallout refresh 结果
10. duplicate / concurrent / rollback 测试结果
11. 当前剩余阻断项
12. 是否可移交 `BFF Agent`

【十二、输出禁令】
- 不要把 authoring 当成 send
- 不要把兼容态 `order.active` 写成已签约完成
- 不要把 blocker 包装成 success
- 不要把 loser disposition 只留在 truth 层不留最小读出口
- 不要回退到 `/order/create`
- 只给真实代码修改与真实 focused tests 结果
```

## 4. 后端首轮最小写集

- `BidAward` truth carrier
- loser disposition truth
- `POST /server/bid/award`
- `GET /server/bid/result`
- `BidAward -> Order conversion`
- synchronous `contract seed`
- `Project.state = awarded / converted_to_order`
- buyer 侧 `my_project / exhibition_workbench` 最小 fallout refresh
- duplicate / concurrent / rollback focused tests

## 5. 计划触达文件族

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/src/generated/app-api.types.ts`
- `apps/server/src/app.module.ts`
- `apps/server/src/modules/bid/**`
- `apps/server/src/modules/project/**`
- `apps/server/src/modules/my_project/**`
- `apps/server/src/modules/exhibition_workbench/**`
- `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
- `apps/server/src/modules/audit/**`
- `apps/server/src/modules/bid_award/**` 新增最小模块
- `apps/server/test/bid-*.test.cjs`
- `apps/server/test/project-*.test.cjs`
- `apps/server/test/*award*.test.cjs`

## 6. 后端明确不做的事项

- 不做 `BFF` implementation dispatch
- 不做 frontend implementation dispatch
- 不做 `seat`
- 不做 `bid package completeness`
- 不做 payment / split-billing / electronic signature
- 不做 complex scoring / heavy risk control
- 不做 `/api/app/order/create`
- 不做 full compare console
- 不做 supplier bid workspace / `GET /api/app/my/bids`

## 7. Formal Conclusion

- `Go for package-level implementation unlock assessment authoring`
- `No-Go for real backend implementation dispatch issuance`
- `No-Go for direct implementation`
- `No-Go for BFF dispatch`
- `No-Go for frontend dispatch`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《BidAward bridge package-level implementation unlock assessment》
