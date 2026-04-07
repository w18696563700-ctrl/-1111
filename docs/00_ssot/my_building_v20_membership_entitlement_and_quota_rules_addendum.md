---
owner: Codex 总控
status: frozen
purpose: Freeze the entitlement, quota, tier, summary, and entry rules for My Building V2.0 paid membership as a bounded private capability package under profile.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - apps/mobile/lib/core/boot/app_shell_context.dart
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/navigation/profile_routes.dart
  - apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart
---

# 《我的楼 V2.0 付费会员 entitlement 与 quota 规则冻结单》

## 1. Scope

本冻结单只覆盖：

- `我的楼 V2.0 paid membership`
- 会员等级框架
- entitlement family
- quota family
- 首屏摘要字段
- 会员状态页 / 权益说明页 / 升级引导页
- 最小 shell summary 方向
- 最小 membership route direction

本冻结单不覆盖：

- `V2.1` 保证金 / 违约 / 赔付
- `V2.2` 支付 / 账单 / 发票 / 结算
- `V2.3` 私域操作系统整理
- implementation unlock
- 实际支付执行
- 交易信息完整可见性 package

## 2. Upstream Basis

本规则冻结基于以下现行前提：

- `我的楼` 仍是 compact current-user hub
- `我的项目` 仍是首层正式私域入口，且不得被 membership 文书覆盖
- `我的会员` 可以作为新的 bounded first-level entry family 合法进入 `我的楼`
- Package 1 仍 organization-centered
- 企业认证主体是当前交易主资格层
- paid membership 不能替代认证、保证金或支付真相
- 当前 Package 1 的 `membershipStatus` 仍表示 organization membership truth，不得被付费会员复用

## 3. Subject-layer Rule

### 3.1 Current Commercial Subject Baseline

当前 V2.0 首轮正式冻结的商业主体基线为：

- 企业认证主体可成为付费会员购买主体

### 3.2 Planning-layer Subject Model

为 V2 总案讨论，当前允许保留以下候选层级模型：

- 注册用户
- 个人实名用户
- 企业认证用户
- 付费会员用户

说明：

- 该四层模型当前可作为 V2 planning baseline
- 但首轮 package 真正正式依赖的最小主体，仅冻结到“企业认证主体可购买付费会员”
- `个人实名用户` 当前不作为 V2.0 首轮强依赖真值层

### 3.3 Formal Interpretation

当前正式解释为：

- 注册用户：基础账号层
- 企业认证用户：交易主体资格层
- 付费会员用户：商业权益层

`个人实名用户` 当前只保留为候选层级方向，不在本文件中被提升为 V2.0 首轮强依赖 package truth。

### 3.4 Non-equivalence Rule

当前正式写死：

- 注册用户 ≠ 付费会员用户
- 个人实名 ≠ 企业认证
- 会员 ≠ 认证
- 会员 ≠ 保证金
- 会员 ≠ 支付
- 会员 ≠ 最终交易资格

## 4. Membership Purchase Rule

### 4.1 Current Purchase Baseline

当前 V2.0 正式冻结：

- 付费会员默认仅建立在企业认证主体之上
- 个人实名用户当前不直接作为首轮付费会员购买主体

### 4.2 Re-entry Rule

若后续要允许个人实名用户购买付费会员，必须：

- 通过后续 package re-entry
- 单独冻结新的 subject rule
- 不得通过本文件直接扩大

## 5. Tier Structure Freeze

### 5.1 Current Accepted Tier Structure

当前正式接受以下 3 档结构：

1. 免费认证版
2. 标准会员
3. 专业会员

`旗舰 / KA 版` 当前只做战略预留，不进入首轮冻结。

### 5.2 Free Certified Tier

免费认证版当前承接：

- 基础发布资格前提中的会员维度
- 基础竞标资格前提中的会员维度
- 基础曝光
- 基础排序
- 默认费率档位

说明：

- “发布 / 竞标是否成立”的最终 gate 仍取决于企业认证、组织 scope 与后续交易保障规则
- 免费认证版不是对交易资格的单独替代

### 5.3 Standard Membership Tier

标准会员当前承接：

- 费率减免
- 更高排序
- 更多商机提醒
- 更多曝光位
- 更高额度档位
- 更高展示权重

### 5.4 Professional Membership Tier

专业会员当前承接：

- 更低费率档位
- 更高排序
- 更高曝光
- 人工撮合优先
- 客服优先
- 更多席位与经营辅助能力预留

### 5.5 Reserved KA Tier

当前战略预留：

- KA / 旗舰会员层级存在方向
- 但不进入 V2.0 首轮 package 冻结

## 6. Entitlement Freeze

### 6.1 Current Entitlement Family

V2.0 当前正式冻结的 entitlement family 只包括：

1. 当前会员等级
2. 当前权益摘要
3. 当前费率档位
4. 当前剩余额度摘要
5. 刷新时间 / 周期
6. 升级引导资格

### 6.2 Entitlement Exclusions

当前明确排除：

- 保证金状态
- 账单记录
- 发票
- 退款 / 退回
- 信用处罚
- 争议裁定
- 支付执行状态
- 结算状态

## 7. Quota Freeze

### 7.1 Current Accepted Quota Types

V2.0 当前可接受的 quota family 包括：

- 查看额度
- 商机提醒额度
- 优先曝光额度
- 人工撮合次数额度
- 成员席位额度

### 7.2 Current Rule

当前正式写死：

- quota 可以作为 paid-membership family 的一部分
- quota 细项当前只需冻结“类型”，不冻结完整 rich workflow
- quota 当前只以“最小摘要 + 说明页”进入首轮 package

### 7.3 Refresh Rule

当前正式建议：

- 日额度：自然日刷新
- 月度权益：按月度周期
- 年度权益：按会员周期
- 不做复杂额度结转

## 8. Visibility Principle Freeze

### 8.1 Current Meaning

本文件当前不冻结完整的项目可见字段矩阵，也不冻结跨 `exhibition / bid / attachment` 的完整 visibility package。

### 8.2 Principle Only

本文件当前只冻结以下原则：

- 注册用户 ≠ 全量交易信息浏览主体
- paid membership 不自动等价于“全部交易级信息完全开放”
- 交易级信息最终如何解锁，仍需在后续跨域 package 中单独冻结

### 8.3 Explicit Non-goal

当前不在本文件中冻结：

- 哪些项目字段属于公开层
- 哪些附件何时可见
- 哪一步解锁联系方式
- 哪一步解锁正式竞标入口

## 9. My Building Entry Rule

### 9.1 Current First-level Entry

V2.0 完成后，`我的楼` 允许新增：

- `我的会员`

### 9.2 First-level Summary Only

首层 `我的会员` 当前只允许展示：

- 当前会员等级
- 当前费率档位
- 当前权益摘要
- 当前剩余额度摘要
- 下次刷新时间

### 9.3 Second-level Pages

后续可拆出的二级页包括：

- 会员状态页
- 权益说明页
- 配额说明页
- 升级引导页

### 9.4 First-screen Load Rule

当前正式写死：

- 会员详情不得在首屏重负载展开
- 权益明细、额度明细、购买明细只能在二级页或懒加载页出现
- `我的楼` 首屏不得因 membership 演化成第二 dashboard

## 10. Minimal Shell Summary Rule

### 10.1 Allowed Summary Fields

`shell/context` 当前只允许承接最小 paid-membership summary 字段方向：

- `paidMembershipTier`
- `paidMembershipEntitlementsSummary`
- `paidMembershipQuotaSummary`
- `paidMembershipNextRefreshAt`

### 10.2 Explicit Prohibition

当前明确禁止：

- 在 `shell/context` 内承接完整 membership center
- 在 `shell/context` 内承接 billing / payment / guarantee 明细
- 通过 shell 扩展把首屏拖成经营大盘
- 复用现有 Package 1 `membershipStatus` 表达 paid membership

## 11. Minimal Route Direction Rule

### 11.1 Accepted Direction

V2.0 当前最小 route family 方向冻结为：

- `/api/app/profile/membership/*`

### 11.2 Scope Of This Family

该 family 未来只允许优先承接：

- current membership
- entitlement summary
- quota summary
- upgrade guidance
- membership explanation

### 11.3 Explicit Non-goals

当前明确不允许：

- payment route family 混入
- billing route family 混入
- guarantee route family 混入
- invoice family 混入

## 12. Candidate Commercial Parameter Appendix

### 12.1 Current Meaning

以下价格、费率、封顶值等内容：

- 可以被写入当前 planning baseline
- 可以用于评审与后续 package 拆分
- 但当前仍属于候选商业参数
- 不属于现行冻结运行参数

### 12.2 Candidate Parameter Register

当前认可的候选参数集为：

- 免费认证企业默认费率：`3.0%`
- 标准会员年费：`2999`
- 标准会员费率：`2.5%`
- 专业会员年费：`6999`
- 专业会员费率：`2.0%`
- KA / 旗舰预留费率：`1.5%`
- 单笔服务费封顶：保留机制，不在本文件冻结具体数值

### 12.3 Protection Rule

Codex 后续不得把以上候选参数误写成：

- 当前正式 SSOT 费率
- 当前正式上线价格
- 当前正式 launch 参数

如需固化为正式参数，必须在后续对应 package 中再次冻结。

## 13. Non-goals

当前正式非目标：

- 会员购买支付执行
- 会员订单
- 账单中心
- 发票中心
- 保证金系统
- 违约与赔付
- dispute / governance
- 结算
- 私域操作系统全量整理
- 交易信息字段矩阵的完整解锁规则

## 14. Formal Conclusion

当前正式结论：

- V2.0 已冻结为 `我的楼` 下的最小 paid-membership package
- 付费会员主体基线、等级结构、entitlement family、quota family、最小摘要字段和 route 方向已形成
- `个人实名用户` 当前仅保留为 planning-layer 候选层级，不构成首轮强依赖冻结对象
- 价格、费率、封顶值仍为候选商业参数
- 交易保障、支付、账单、发票、信用处罚、跨域 visibility 细则均明确排除在首轮 package 外

## 15. Next Unique Action

下一步唯一动作：

- 冻结《membership_entitlement_v1_contracts_addendum.md》

不得直接进入：

- backend implementation
- BFF implementation
- frontend implementation
- payment package
- guarantee package
