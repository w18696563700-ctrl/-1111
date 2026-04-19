---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum midstream platformization closure for exhibition bidding so later rounds can author the next contract package without overstating the current bid bridge into a fully completed bidding platform, payment layer, or governance stack.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
  - docs/02_backend/bid_award_bridge_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/bid_award_bridge_bff_surface_freeze_addendum.md
  - docs/04_frontend/bid_award_bridge_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段最小闭环冻结文书》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的最小闭环
- 本轮只承接 4 个对象：
  1. `seat / 抢席 / 超时释放`
  2. `bid package completeness`
  3. `buyer compare` 的最小稳定消费面
  4. `loser feedback` 的最小稳定消费面
- 本轮不是：
  - 完整竞标平台完成结论
  - 支付结算启动
  - 完整交易治理启动
  - implementation unlock
  - release approval

## 2. 当前真相

- 当前已经成立的是：
  - `project publish`
  - `project detail/public board`
  - 最小 `bid submit`
  - 最小 `bid award`
  - 最小 `order/contract seed bridge`
- 当前尚未成立的是：
  - 真正的 `seat lock runtime`
  - `bid package completeness workspace`
  - `buyer compare console / board`
  - 稳定的 `loser feedback` 消费面
- 当前必须明确：
  - 既有 bridge 文书只证明 `Bid -> Award -> Order Conversion -> Contract Seed`
    的骨架方向和最小 contract/backend/BFF/frontend 边界已经冻结
  - 它们不等于：
    - seat 已经 runtime 成立
    - compare 已经稳定运行
    - loser feedback 已经有完整消费面
    - 完整竞标平台已完成

## 3. 本轮范围

### 3.1 `seat`

- 本轮只冻结：
  - `seat` 的最小业务含义
  - `lock / release / timeout` 的最小业务语义
- `seat` 的正式语义固定为：
  - 在 buyer 比选中，为当前可提交、可比较的投标实体保留一个最小受控占位
  - 它是竞标中段的交易节奏控制对象
  - 它不是支付、结算、保证金对象

### 3.2 `bid package completeness`

- 本轮只冻结：
  - 结构化完整性的最小维度
- 正式语义固定为：
  - 判断当前投标是否满足最小可比较、可定标、可留痕的结构化材料完整性
- 当前不得扩写成：
  - 复杂方案编排系统
  - 全量方案工作台

### 3.3 `buyer compare`

- 本轮只冻结：
  - 最小可比较消费面
- 正式语义固定为：
  - buyer 能稳定读取同一项目下候选 bid 的最小可比较字段集合
  - 支撑后续 winner decision 的最小消费前置
- 当前不得扩写成：
  - full scoring console
  - 多维治理控制台

### 3.4 `loser feedback`

- 本轮只冻结：
  - 最小稳定消费面
- 正式语义固定为：
  - 让未中标方能稳定读取最小结果与最小理由
  - 不再停留在“静默落选”或纯服务端留痕
- 当前不得扩写成：
  - 完整投标后反馈系统
  - 多轮申诉与仲裁系统

## 4. 本轮明确不做什么

- 报名费 / 占位费支付
- 保证金
- 节点付款
- 电子签
- 完整 buyer compare console
- 复杂评分引擎
- 合同文件 / version 治理
- milestone 计划与变更
- inspection 历史详情
- dispute 证据与处理台
- rating 信用沉淀
- 平台审核台 / 风险规则台 / 争议介入台
- 信用画像 / 推荐排序 / 曝光权重
- 支付结算平台

## 5. 当前缺口

- `seat`：
  - 当前只有概念性空缺，没有正式 runtime truth、timeout truth、release truth
- `bid package completeness`：
  - 当前只具备最小 `bid submit` 请求承接，尚无结构化完整性 carrier
- `buyer compare`：
  - 当前没有稳定 compare surface，也没有 buyer 最小 compare 读层
- `winner decision`：
  - 虽有最小 `BidAward` bridge blueprint，但 compare 支撑面不足，仍不是完整 buyer compare 决策面
- `loser feedback`：
  - 当前仅有 loser disposition 的最小留痕方向，尚未形成稳定 app-facing 消费面

## 6. 最小对象矩阵

| 对象 | 当前真相 | 本轮是否进入冻结 | 进入后只冻结到哪一层 | 明确不做到哪一层 |
|---|---|---|---|---|
| `seat` | 未成立 runtime truth | 是 | 最小业务含义、lock/release/timeout 语义、与 bid lifecycle 的最小关系 | 不做到支付、保证金、收费占位、完整资源调度 |
| `bid package completeness` | 未成立 workspace / structured completeness truth | 是 | 最小结构化完整性维度 | 不做到复杂方案编排、全量方案管理、文档治理中心 |
| `buyer compare` | 未成立稳定 compare surface | 是 | 最小稳定消费面 | 不做到完整 compare console、复杂评分引擎、治理控制台 |
| `winner decision` | 已有最小 bridge blueprint，但消费支撑不完整 | 是 | 作为 compare 后的最小稳定决策落点 | 不做到 buyer-side 全量 award governance |
| `loser feedback` | 仅有最小 loser disposition 方向 | 是 | 最小稳定消费面 | 不做到完整反馈系统、申诉系统、争议治理 |
| `bid submit` | 已成立最小 continuation | 否，沿用既有真相 | 保持最小提交 continuation | 不重开 bid submit scope |
| `bid award` | 已有 bridge blueprint / freeze chain | 否，沿用既有真相 | 保持最小 winner / loser / order conversion precursor truth | 不写成完整竞标平台已闭环 |
| `order/contract seed` | 已成立最小 bridge 骨架 | 否，沿用既有真相 | 保持 downstream seed bridge | 不扩到 payment / settlement / governance |

## 7. 阶段顺序裁决

### 7.1 正式包序

- `Package A`：
  - `seat + bid package completeness`
- `Package B`：
  - `buyer compare + winner decision 最小稳定消费面`
- `Package C`：
  - `loser feedback 最小稳定消费面`

### 7.2 顺序理由

- `Package A` 必须先过：
  - 没有 `seat` 的 lock / timeout / release 语义，后续 compare 与定标无法稳定承接“当前哪些 bid 是活跃候选”
  - 没有 `bid package completeness`，compare 面会退化成非结构化拼接，winner decision 也无法稳定落点
- `Package B` 必须等待 `Package A`：
  - compare 的前提是候选 bid 已被最小 seat 语义和完整性语义约束
  - winner decision 不能先于 compare 稳定消费面冻结
- `Package C` 必须最后：
  - loser feedback 必须锚定稳定的 winner decision 结果
  - 否则会把 loser feedback 写成先验文案或静态占位

## 8. 合规与发布门禁

- 当前文书只允许进入下一轮 freeze authoring。
- 当前文书不允许进入：
  - runtime ready
  - release ready
  - implementation unlock
- 当前文书不等于：
  - `seat lock runtime` 已通
  - compare 已稳定运行
  - loser feedback 已稳定运行
  - 支付 / 结算已打开

## 9. No-Go 边界

- 不得把本轮写成完整竞标平台完成
- 不得把 `seat` 直接等价成收费 / 支付能力
- 不得把 `buyer compare` 写成完整评分与治理控制台
- 不得把 `loser feedback` 写成完整反馈系统
- 不得顺手把交易中段和平台治理全部带入
- 不得把既有 bridge freeze 写成这些能力已经运行态成立

## 10. 门禁

### 10.1 Passed Gates

- skeleton-first gate：
  - passed
  - 当前对象建立在已冻结的 `project transaction skeleton` 与 `bid-award bridge` 之上
- scope discipline gate：
  - passed
  - 当前只承接竞标中段最小闭环，不拉入支付、结算、治理、信用
- no-new-mainline gate：
  - passed
  - 当前对象是现有交易骨架的中段补齐，不是独立业务主线

### 10.2 Failed Gates

- runtime proof gate：
  - failed
  - `seat / completeness / compare / loser feedback` 均未有运行态闭环
- release-prep gate：
  - failed
- production-release gate：
  - failed

### 10.3 Veto Gates

- 不得把 `seat` 写成支付或保证金能力
- 不得把 `buyer compare` 写成完整 compare console
- 不得把 `loser feedback` 写成完整投标后反馈系统
- 不得跳过 contract freeze 直接进入实现派工

## 11. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 contract freeze》`

## 12. 裁决

- `《展览竞标平台化中段最小闭环冻结文书》是否可入库：是`
