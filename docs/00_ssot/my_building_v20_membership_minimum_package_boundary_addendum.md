---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum package boundary for My Building V2.0 paid membership so `profile / 我的楼` may introduce membership as a bounded private capability without silently widening into guarantee, payment, billing, invoice, settlement, or full private operating-system execution.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - apps/mobile/lib/core/boot/app_shell_context.dart
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/navigation/profile_routes.dart
  - apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
---

# 《我的楼 V2.0 付费会员最小 package 边界冻结单》

## 1. Scope

本冻结单只覆盖：

- `我的楼 V2.0`
- `paid membership`
- `entitlement / quota`
- `我的会员` 入口
- 会员状态与权益说明
- 首屏最小摘要字段
- membership 最小 route family 方向

本冻结单不覆盖：

- `V2.1` 信用 / 保证金 / 交易保障
- `V2.2` 支付 / 账单 / 服务费 runtime
- `V2.3` 我的楼完整私域操作系统整理
- implementation unlock
- release-prep
- launch approval

## 2. Upstream Boundary Intake

### 2.1 当前我的楼边界

`我的楼` 当前仍然是：

- compact current-user hub
- private identity and asset center
- entry aggregation surface

`我的楼` 当前不是：

- second forum homepage
- second dashboard
- public author homepage
- generic IM container

当前首层 bounded entry family 仍然承接：

- personal profile
- my company
- certification / identity status handoff
- my project
- my forum
- settings

补充冻结：

- `我的项目` 已经是 `我的楼` 下的正式首层私域入口，不得在 V2.0 文书里遗漏。
- `我的发票抬头` 的旧入口语义已被 `我的公司` 替代，后续不得回退。

### 2.2 当前 Package 1 边界

当前 Package 1 已冻结的 identity 主线仍然是：

- organization-centered
- `Server` is the only truth owner
- `BFF` only shapes and must not own identity / certification / eligibility / review truth
- Flutter App currently consumes bounded `/api/app/*` identity-family routes under the existing constitution

### 2.3 当前我的项目边界

`我的项目` 当前继续保持：

- independent private path family
- `进行中 / 历史项目`
- `publicProject + privateProgress`
- not equivalent to `项目工作台`

V2.0 membership 不得回写或吞并这条现有私域项目主线。

### 2.4 当前 formal-truth 规则

当前 formal truth 仍然必须遵守：

`docs/00_ssot -> docs/01_contracts -> docs/02_backend / 03_bff / 04_frontend / 05_admin -> apps`

## 3. Addendum Role

本冻结单的作用只有一个：

**把 V2.0 限定为“付费会员规则与最小 membership package”，防止它在第一轮就 silently 扩成保证金、账单、支付、发票、结算、信用处罚或经营后台。**

也就是说：

- 本冻结单允许 `我的会员` 进入 `我的楼`
- 但不允许 `我的会员` 借名义吞并 `V2.1 / V2.2 / V2.3`

## 4. Current Package Objective

`V2.0` 当前唯一目标是建立：

- 付费会员主体基线
- 会员等级结构
- entitlement 类型
- quota 类型
- 刷新周期
- `我的会员` 入口
- 会员状态页
- 权益说明页
- 升级引导页
- 首屏最小摘要字段
- 最小 membership route family

它不负责：

- 支付下单
- 会员订单
- 账单中心
- 发票中心
- 保证金
- 违约裁定
- 信用处罚
- 结算
- dispute / governance 逻辑
- 私域操作系统完整 IA 收口

## 5. Membership Role Freeze

### 5.1 付费会员不是 identity truth

付费会员不解决：

- 你是谁
- 你是否是企业认证主体
- 你是否有交易资格
- 你是否已缴纳保证金
- 你是否已完成支付

付费会员只解决：

- 商业权益
- 费率档位
- 曝光等级
- quota
- 优先权
- 付费会员状态展示

### 5.2 付费会员不得替代认证

当前冻结：

- 认证仍然由 Package 1 truth family 承接
- 付费会员不得替代企业认证
- 付费会员不得替代组织 scope
- 付费会员不得替代交易资格 gate

### 5.3 付费会员不得替代保证金与交易保障

当前冻结：

- 竞标资格与保证金属于 `V2.1`
- 付费会员不得直接等价于“可竞标”
- 付费会员不得直接等价于“已具备交易保障资格”

## 6. Membership Subject Freeze

### 6.1 当前最小商业主体基线

当前 V2.0 首轮正式冻结：

- 付费会员默认建立在企业认证主体之上

### 6.2 当前主体解释

当前冻结：

- 注册用户 ≠ 付费会员用户
- 个人实名 ≠ 企业认证
- 企业认证是当前交易主体主资格层
- 付费会员是在企业认证主体之上的商业权益层

### 6.3 首轮购买资格基线

当前 V2.0 的默认规则冻结为：

- 付费会员默认建立在企业认证主体之上
- 个人实名用户当前不直接作为首轮付费会员购买主体
- 如后续要允许个人实名用户购买付费会员，必须通过后续 package re-entry 单独冻结

## 7. Entry Ownership Freeze

### 7.1 我的楼入口 ownership

当前冻结：

- `我的会员` 未来属于 `我的楼 / profile` 的入口 owner
- 但 paid membership truth owner 不自动归 `profile`

### 7.2 No Building Drift

`我的会员` 当前不得挂到：

- `exhibition`
- `messages`
- a new building
- hidden building

### 7.3 No Semantic Rollback

未来账单 / 发票能力即便进入 `我的楼`，也不得恢复旧入口语义：

- `我的发票抬头`

`我的公司` 继续保持：

- company / organization identity handoff entry

## 8. Naming Collision Freeze

### 8.1 当前 Package 1 字段保护

当前正式写死：

- 现有 Package 1 里的 `membershipStatus` 继续只表示 **organization membership truth**
- 它不是 `paid membership` 字段
- V2.0 不得复用该字段名表达“付费会员状态”

### 8.2 付费会员命名规则

V2.0 后续 contracts / BFF / Flutter 若引入新字段，必须使用与 Package 1 明确不冲突的 paid-membership 命名族。

当前允许的方向示例：

- `paidMembershipTier`
- `paidMembershipEntitlementsSummary`
- `paidMembershipQuotaSummary`
- `paidMembershipNextRefreshAt`

### 8.3 Explicit Prohibition

当前明确禁止：

- 用现有 `membershipStatus` 承接付费会员状态
- 让 shell / BFF / Flutter 出现“组织成员身份”与“付费会员身份”语义混线

## 9. Minimum Route Strategy Freeze

### 9.1 Shell Summary Rule

`shell/context` 当前只允许扩展最小 paid-membership summary carrier，不得承接完整 membership system。

当前允许的最小字段方向为：

- `paidMembershipTier`
- `paidMembershipEntitlementsSummary`
- `paidMembershipQuotaSummary`
- `paidMembershipNextRefreshAt`

### 9.2 Profile Route-family Direction

当前 V2.0 的 route strategy 正式冻结为：

- membership detail family should preferentially live under:
  - `/api/app/profile/membership/*`

### 9.3 Explicit Non-goals For Route Strategy

当前明确不允许：

- 把完整会员系统塞回 `shell/context`
- 把 membership family 挂到 `exhibition`
- 把 membership family 挂到 `messages`
- 在 V2.0 内引入 payment / billing / invoice / guarantee route family

## 10. First-screen Load Boundary

### 10.1 What May Reach First-level Summary

V2.0 只允许把以下 paid-membership 信息以**最小摘要**形式进入 `我的楼` 首层：

- 当前会员等级
- 当前费率档位
- 当前权益摘要
- 当前剩余额度摘要
- 下次刷新时间

### 10.2 What Must Stay Out Of First Screen

以下内容不得以重负载形式进入首屏，必须只进入二级页或懒加载页：

- 会员权益明细
- quota 细项
- 升级价格明细
- 账单明细
- 支付记录
- 保证金详情
- 信用处罚详情
- 经营辅助深层模块

### 10.3 Goal

当前首屏目标仍然是：

- private identity confirmation
- key status hint
- key asset summary
- bounded secondary handoff

而不是：

- dashboard
- operation console
- business center

## 11. Included Scope

V2.0 当前正式允许纳入的对象只有：

1. 付费会员主体基线
2. 会员等级框架
3. entitlement 类型
4. quota 类型
5. 刷新周期规则
6. `我的会员` 入口
7. 会员状态页
8. 权益说明页
9. 升级引导页
10. shell 最小摘要字段
11. `/api/app/profile/membership/*` 最小 family 方向

## 12. Excluded Scope

V2.0 当前正式排除：

- 支付下单
- 会员订单
- 账单中心
- 发票
- 保证金
- 赔付
- dispute
- governance
- 信用处罚
- 结算
- 服务费实际结算执行
- 私域操作系统全量 IA 重整

## 13. Current Meaning

本冻结单当前的含义是：

- V2.0 只允许先建立最小 paid-membership package
- 它是 `我的楼` 的合法下一包
- 但它不是 `V2.1 / V2.2 / V2.3` 的替代
- 也不授予任何 implementation unlock

## 14. Formal Conclusion

当前正式结论：

- `V2.0 paid membership` 作为 `我的楼` 下一个最小合法 package 正式成立
- `我的会员` 作为 `profile` 入口 owner 方向正式成立
- `shell/context` 仅承接最小 paid-membership 摘要
- `/api/app/profile/membership/*` 作为最小 family 方向正式成立
- 现有 `membershipStatus` 继续保留为 Package 1 organization membership truth，不得复用
- `V2.1 / V2.2 / V2.3` 明确排除，不得混入首轮 package

## 15. Next Unique Action

下一步唯一动作：

- 冻结《我的楼 V2.0 付费会员 entitlement 与 quota 规则冻结单》

不得直接进入：

- contracts
- backend implementation
- BFF implementation
- frontend implementation
- payment / guarantee / billing package
