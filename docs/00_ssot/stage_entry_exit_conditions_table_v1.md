---
owner: Codex 总控
status: frozen
purpose: Freeze stage entry, exit, go, and hard-stop conditions for all 10 platform-completion stages, and make the stage structure explicit so no phase can float.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_completion_stage_route_map_v1.md
  - docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md
  - docs/00_ssot/stage3_stage_gate_checklist_addendum.md
---

# 《阶段进入 / 退出条件总表》

## 1. 阶段进退条件主表

| 阶段 | 进入前必须具备 | 阶段完成必须产出 | 允许进入下一阶段条件 | 必须停住条件 |
|---|---|---|---|---|
| `阶段 1` | 总路线图冻结；`Gate-F` 缺口与 veto inventory 明确；不得有 implementation ahead of truth | `P0` 修复结果、阶段 1 closure、遗留风险单 | 公众登录、组织范围、认证上传、治理路由、对象裁决等前置缺口已关闭并签收 | 任一 veto 未关闭；ghost route 被误写成 runnable；对象真相未裁清 |
| `阶段 2` | `阶段 1 closure` 成立；交易 canonical path 与最小 read corridor 已冻结；owner split 明确 | 展览交易主链 app-facing transport 最小闭环证据包 | backend + BFF + mobile 的最小 transport 证据齐；不再依赖 placeholder；stage2 closure 冻结 | transport 仍是 ghost route；读链未闭环；状态/审计对不上 |
| `阶段 3` | `阶段 2 closure` 成立；Admin 使用 `Server` Admin API 直连边界已冻结；最小治理对象与权限边界已冻结 | Admin 最小运营与治理闭环证据包 | review / appeal / governance 的最小工作台、动作权限、审计链与受控 API handoff 成立；stage3 closure 冻结 | `apps/admin` 仍基本空白；关键治理动作无台席承接；BFF 被错误夹入 Admin 主链 |
| `阶段 4` | `阶段 3 closure` 成立；消息单一 active object 裁决已冻结；`message/index` 最小 contract 已冻结 | 单一对象真相结论、`message/index` 最小闭环证据、routeTarget 一致性报告 | `forum inbox` 与 `message/index` 不再双主线并存；message/index 既不伪活跃也不语义漂移；stage4 closure 冻结 | 双 active object 复活；placeholder 被当真 transport；routeTarget 漂移 |
| `阶段 5` | `阶段 1~4 closure` 成立；`profile` 边界、`my_project` 真相与包边界已冻结 | `我的楼功能本体 Round 1` 一致性收口验收 | hub / organization / certification / my_project 的 owner、route、consumer、error semantics 一致；stage5 closure 冻结 | `profile` 继续吞并他楼 truth；command family 仍 404；integration 未通过 |
| `阶段 6` | `阶段 5 closure` 成立；membership rules、contracts、truth carrier、surface direction 已冻结 | `membership package` 执行闭环签收 | entitlement / quota / paid-membership summary 可执行可审计；stage6 closure 冻结 | 复用旧 `membershipStatus` 语义；支付/保障 scope 偷跑进来 |
| `阶段 7` | `阶段 6 closure` 成立；信用/保证金/交易保障规则已冻结 | credit / deposit / guarantee 执行闭环证据 | 约束、保障记录、处罚/申诉/审计链与交易链绑定成立；stage7 closure 冻结 | 与交易链脱节；约束不可追踪；无审计或无申诉承接 |
| `阶段 8` | `阶段 7 closure` 成立；支付/账单/服务费 contracts 与结算规则已冻结 | payment / billing / service-fee 最小结算闭环签收 | 支付流转、账单核对、服务费核算、失败回执和审计留痕通过；stage8 closure 冻结 | 账单无真相 owner；结算状态不可追踪；服务费无审计 |
| `阶段 9` | `阶段 8 closure` 成立；V2.3 IA 重整与边界范围已冻结 | 私域操作系统整理结果、承接分层图、性能报告 | 导航可达性、首屏负载、私域分层与 truth owner 边界稳定；stage9 closure 冻结 | IA 重整引入第二真源；hidden buildings 暴露；把重整偷换成新业务包 |
| `阶段 10` | `阶段 1~9 closure` 全部成立；发布前门禁全部 Go；回滚/观测/审计/环境基线齐备 | release-prep 签收、launch 回执、上线后 90 天平台化运营结案 | 首发放行完成，90 天指标与 incident 收口达标，形成正式完工结论 | 任一 veto gate 失败；无回滚能力；观测缺失；高优先级事故无处置闭环 |

## 2. 统一阶段结构（以后每阶段都必须具备）

每个阶段文书必须显式包含以下 9 段，缺一即视为阶段不完整：

1. 阶段目标
2. 阶段前置
3. 当前主阻塞
4. judgment
5. dispatch
6. implementation
7. verification
8. closure
9. next route

## 3. 阶段通用进入规则（全阶段适用）

- 规则 1：
  - 未提交《阶段门禁核查表》，不得进入新阶段。
- 规则 2：
  - 若存在 failed veto gate，阶段结论必须是 `No-Go`。
- 规则 3：
  - 必须按
    `SSOT -> contracts -> backend truth -> BFF -> frontend/admin`
    的顺序推进。
- 规则 4：
  - 上一阶段未形成 `closure`，下一阶段不得抢跑。

## 4. 阶段通用退出规则（全阶段适用）

- 规则 1：
  - 必须有 formal closure 文书。
- 规则 2：
  - 必须有结果校验签收：
    - `PASS`
    - 或 `PASS WITH RISK + retained risk`
- 规则 3：
  - 必须明确写出：
    - 当前阶段完成度
    - 下一步唯一动作
    - 下一步执行角色
    - 下一步进入条件
- 规则 4：
  - 任何“接近完成”“差不多可用”但无证据链闭环，不得视为退出。

## 5. 阶段停机触发（Hard Stop）

- 触发 1：
  - 出现第二真源或 contract-first 顺序破坏。
- 触发 2：
  - 出现 BFF 持久化业务真相或第二状态机。
- 触发 3：
  - 出现未授权并行主线。
- 触发 4：
  - 出现 release 行为早于阶段门禁放行。
- 触发 5：
  - 出现文件职责混写与长度门禁 veto。
- 触发 6：
  - 总控只给 judgment 不给 next route，导致阶段悬空。

## 6. 当前阶段的进退状态（阶段 3）

- 当前阶段：
  - `阶段 3｜Admin 最小运营与治理闭环`
- 已满足进入条件：
  - 是
  - 依据是 `stage2 closure` 已冻结，且 `stage3_stage_gate_checklist_addendum.md` 已冻结为 `Go for stage3 controller review`
- 已满足退出条件：
  - 否
  - 当前还没有：
    - stage3 controller review spec bundle
    - stage3 dispatch
    - stage3 execution evidence
    - stage3 closure
- 当前允许动作：
  - 只允许 `阶段 3 controller review` 的总控文书 authoring
- 当前禁止动作：
  - 禁止直接进入 `阶段 3 implementation`
  - 禁止切到 `阶段 4~10`

## 7. 阶段不悬空机制（本轮强制输出）

1. 当前阶段完成度：
   - `judgment 完成`
2. 当前下一步唯一动作：
   - `输出并冻结《阶段3 Admin 最小运营与治理闭环 controller review spec bundle》`
3. 下一步执行角色：
   - `总控`
4. 下一步进入条件：
   - 本总表、总路线图、主线裁决单、派工矩阵四件套已冻结
   - `stage3 stage gate` 仍为 `Go for controller review`
   - 未新增 veto 级反证
