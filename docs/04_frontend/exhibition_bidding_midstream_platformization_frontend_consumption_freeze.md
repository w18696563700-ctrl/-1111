---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum L5 Flutter consumption boundary for exhibition bidding midstream platformization so later implementation dispatch proceeds on a single meaning for seat rendering, completeness rendering, buyer compare consumption, and loser feedback consumption without inflating the corridor into a full bidding console or second state machine.
layer: L5 Frontend
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/01_contracts/exhibition_bidding_midstream_platformization_contract_freeze.md
  - docs/02_backend/exhibition_bidding_midstream_platformization_backend_truth_persistence_freeze.md
  - docs/03_bff/exhibition_bidding_midstream_platformization_bff_surface_freeze.md
  - docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md
  - docs/00_ssot/source_of_truth_map.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
---

# 《展览竞标平台化中段 frontend consumption freeze》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的最小 frontend consumption
- 本轮只承接：
  - `seat`
  - `bid package completeness`
  - `buyer compare` 最小稳定消费面
  - `loser feedback` 最小稳定消费面
- 本轮不是：
  - 完整竞标平台前端完成
  - 实现派工
  - release-ready

## 2. 当前真相

- frontend 只允许消费 `BFF` app-facing surface。
- frontend 不得自己发明：
  - `seat` truth
  - completeness truth
  - compare truth
  - loser feedback truth
- frontend 只允许做：
  - route / page / section consumption
  - state rendering
  - CTA gating
  - error presentation
  - visibility consumption
- frontend 不得形成第二套状态机。
- 当前既有 exhibition route 常量已存在：
  - `/exhibition/my/projects/detail`
  - `/exhibition/bids/submit`
  - `/exhibition/projects/detail`
- 当前必须明确：
  - 本轮不新开建筑级导航
  - 本轮不把既有 page shell 写成 runtime 已通

## 3. Frontend Consumption Boundary

- Flutter 在本轮的唯一职责固定为：
  - consume `BFF` projection
  - render controlled state
  - gate CTA by app-facing state
  - present controlled error / fallback
  - consume already-trimmed visibility
- Flutter 明确不得：
  - 自建 `seat` truth
  - 自建 completeness truth
  - 自建 compare truth
  - 自建 loser feedback truth
  - 本地猜测 winner / loser
  - 本地补业务状态推进
  - 扩成完整 compare console
  - 扩成完整反馈系统

## 4. 页面 / 区块落点 Freeze

### 4.1 `seat` 落点

- buyer 侧主落点固定为：
  - 既有 `/exhibition/my/projects/detail`
  - 以内嵌 compare 区块或 compare section 承接
- bidder 侧附属落点固定为：
  - 既有 `/exhibition/bids/submit`
  - 只显示当前 bid 的最小 seat 状态提示
- public：
  - 不可见

### 4.2 `bid package completeness` 落点

- bidder 侧主落点固定为：
  - 既有 `/exhibition/bids/submit`
  - 以只读 completeness section 承接
- buyer 侧附属落点固定为：
  - `/exhibition/my/projects/detail` 的 compare section 内
  - 只显示每个 comparable bid 的 completeness badge
- public：
  - 不可见

### 4.3 `buyer compare` 落点

- `buyer compare` 主落点固定为：
  - 既有 `/exhibition/my/projects/detail`
  - 作为 buyer 私域 compare section / compare mode
- 本轮裁决：
  - 不新开独立 compare route family
  - 不新开建筑级导航入口
- bidder：
  - 不可见
- public：
  - 不可见

### 4.4 `loser feedback` 落点

- `loser feedback` 主落点固定为：
  - 既有 `/exhibition/bids/submit?projectId={projectId}&mode=result`
  - 复用当前 `bidSubmitWithProjectId(..., mode: 'result')` 语义
- 本轮裁决：
  - 不新开独立 result route family
  - 不新开 supplier workspace
- losing bidder：
  - 可见
- winning bidder：
  - 不作为本轮 loser feedback 消费对象
- public：
  - 不可见

## 5. CTA / Interaction Freeze

### 5.1 本轮进入的最小 CTA

- `seat lock`
  - buyer 私域 CTA
  - 固定挂在 `/exhibition/my/projects/detail` 的 compare section 内
  - 最小文案语义：
    - `锁定候选席位`
- `seat release`
  - buyer 私域 CTA
  - 固定挂在 `/exhibition/my/projects/detail` 的 compare section 内
  - 最小文案语义：
    - `释放候选席位`
- completeness 只读 / 引导态
  - bidder 侧在 `/exhibition/bids/submit` 显示只读 completeness 状态
  - 可有最小引导 CTA：
    - `补齐报价`
    - `补齐方案摘要`
  - 该 CTA 只回到既有 bid submit 字段区，不新开 completeness 工作台
- `buyer compare` 进入 / 返回
  - 进入 CTA：
    - `/exhibition/my/projects/detail` 中的 `查看比选`
  - 返回 CTA：
    - compare section 中的 `返回项目概览`
  - 仍在同一路由壳内，不扩成独立 console
- `loser feedback` 进入 / 查看
  - 进入 CTA：
    - `/exhibition/bids/submit` 中的 `查看结果`
  - 查看承接：
    - `/exhibition/bids/submit?projectId={projectId}&mode=result`

### 5.2 本轮仍然 No-Go 的 CTA

- compare 评分录入
- compare 排序治理
- loser feedback 回复 / 申诉 / 追问
- payment / deposit / guarantee CTA
- e-sign CTA

## 6. 页面状态矩阵

| 状态 | 最小前端表达 | 角色边界 |
|---|---|---|
| `idle` | 显示最小 section shell，不伪造数据 | buyer / bidder 私域；public 不暴露私域 section |
| `loading` | 显示 skeleton / loading 文案，不伪造成功态 | buyer / bidder 私域 |
| `empty` | 显示受控空态，如“暂无可比较候选”或“暂无结果” | buyer compare / loser feedback 私域 |
| `success` | 渲染最小 projection，不扩成 console | buyer / losing bidder 私域 |
| `timeout` | seat 表达为已超时，CTA 退回可重新锁定或只读失效态 | buyer 私域 |
| `unauthorized / forbidden` | 显示受控不可操作或无权限态，不暴露真值细节 | buyer / bidder 私域 |
| `not_visible` | 直接不展示该 section 或显示最小隐藏态 | public；以及非目标角色 |
| `stale / released seat` | 显示席位已失效 / 已释放，不保留伪 locked 态 | buyer 私域 |
| `completeness_insufficient` | 显示不完整 badge + 最小引导，不伪装成 compare ready | bidder 私域；buyer compare 行内可见 badge |
| `compare_not_ready` | 显示当前不可比选 / 候选不足 / 材料未齐 | buyer 私域 |
| `feedback_not_available` | 显示结果暂不可读，不伪造空成功 | bidder 私域 |
| `fallback / timeout` | 显示 generic unavailable / retry later，不本地猜后端真相 | buyer / bidder 私域 |

补充裁决：

- `timeout`
  - 只允许 buyer 侧在 seat / compare 消费面出现
- `completeness_insufficient`
  - buyer 与 bidder 都可见，但 public 不可见
- `compare_not_ready`
  - 只允许 buyer 侧出现
- `feedback_not_available`
  - 只允许 bidder 私域出现

## 7. 文案与边界 Freeze

- `seat` 不得被写成：
  - `已付款`
  - `已收费占位`
  - `保证金已锁定`
- completeness 不得被写成：
  - `完整方案工作台已完成`
- compare 不得被写成：
  - `评分系统`
  - `评分控制台`
- loser feedback 不得被写成：
  - `完整反馈中心`
  - `投标后沟通系统`
- 不得出现会误导为：
  - `交易中段完整化已完成`
  的文案

## 8. Route / Navigation Freeze

- 本轮进入的 route 固定为：
  - 既有 `/exhibition/my/projects/detail`
  - 既有 `/exhibition/bids/submit`
  - 既有 `/exhibition/bids/submit?projectId={projectId}&mode=result`
  - 既有 `/exhibition/projects/detail`
- route 角色固定如下：
  - `/exhibition/my/projects/detail`
    - buyer 私域
    - 承接 `seat + buyer compare`
  - `/exhibition/bids/submit`
    - bidder 私域
    - 承接 completeness 只读 / 引导态
  - `/exhibition/bids/submit?mode=result`
    - bidder 私域
    - 承接 loser feedback 最小消费面
  - `/exhibition/projects/detail`
    - public / optional-auth detail
    - 不承接 private `seat / completeness / compare / loser feedback`
- 本轮明确不开放：
  - 独立 compare route family
  - 独立 result route family
  - 新建筑级导航

## 9. Error / Fallback Consumption Freeze

- `BID_SEAT_INVALID`
  - 前端落为受控 seat 不可用态
- `BID_SEAT_INVALID_STATE`
  - 前端落为 seat 状态不允许 CTA
- `BID_SEAT_CONFLICT`
  - 前端落为席位冲突态
- `BID_SEAT_TIMEOUT`
  - 前端落为超时态，不保留 locked 假象
- `BID_PACKAGE_COMPLETENESS_INVALID`
  - 前端落为 `completeness_insufficient`
- `BID_PACKAGE_COMPLETENESS_UNAVAILABLE`
  - 前端落为 generic unavailable 或最小 completeness unavailable
- `BID_COMPARE_INVALID`
  - 前端落为 `compare_not_ready`
- `BID_COMPARE_UNAVAILABLE`
  - 前端落为 generic unavailable
- `BID_RESULT_INVALID`
  - 前端落为 `feedback_not_available`
- `BID_RESULT_UNAVAILABLE`
  - 前端落为 generic unavailable
- frontend 明确不得：
  - 自行推断后端真值
  - 将 unavailable 伪装成成功
  - 将 forbidden 伪装成空态成功

## 10. Visibility Consumption Freeze

- buyer：
  - 可见 `seat`
  - 可见 `buyer compare`
  - 可见 compare 行内 completeness
  - 不消费 loser feedback 私域结果
- winning bidder：
  - 不作为本轮 loser feedback 目标角色
  - completeness 只在自己的 bid submit 页可见
- losing bidder：
  - 可见自己的 loser feedback
  - 可见自己的 completeness 只读 / 引导态
- public：
  - 不可见 `seat`
  - 不可见 completeness
  - 不可见 compare
  - 不可见 loser feedback
- frontend 只消费 BFF trim 后结果，不自行重算业务可见性。

## 11. Runtime Hard-gate Input

- `docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md`
  是本轮后续实现、验证、联调的并行硬门禁输入。
- 这不是建议项。
- 后续 frontend 实现、smoke、联调、release-prep 都不得跳过该 checklist。

## 12. 合规与发布门禁

- 当前文书只允许进入：
  - `implementation dispatch authoring`
- 当前文书不允许进入：
  - direct implementation
  - integration
  - `release-prep`
  - production release
- 当前必须继续保持：
  - frontend 不得把 placeholder 页面写成 runtime 已通
  - 双 private corridor 不得破坏既有 public detail / bid submit 主链

## 13. No-Go 边界

- 不得把本轮写成完整竞标平台前端完成
- 不得把 `seat` 写成支付 / 保证金 UI
- 不得把 completeness 写成完整方案工作台
- 不得把 compare 写成完整评分控制台
- 不得把 loser feedback 写成完整反馈系统
- 不得顺手带入合同 / 履约 / 争议 / 支付相关页面
- 不得新开建筑级导航

## 14. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 implementation dispatch freeze》`

## 15. 裁决

- `《展览竞标平台化中段 frontend consumption freeze》是否可入库：是`
