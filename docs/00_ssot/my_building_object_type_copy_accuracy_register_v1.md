---
owner: Codex 总控
status: frozen
purpose: 冻结“我的楼”首页对象与下游功能状态卡的对象类型、当前文案准确性、真源类型与本轮动作，作为后续文案纠偏和结果校验的统一口径表。
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_caliber_revision_ruling_v1.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_support.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_sections.dart
  - apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart
  - apps/mobile/lib/features/profile/presentation/profile_personal_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_company_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_member_management_sheet.dart
  - apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_credit_constraints_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_payment_billing_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_governance_appeal_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_settings_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/forum/forum_author_profile_pages.dart
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/server/src/modules/profile/profile.controller.ts
---

# 《我的楼对象口径与文案准确性总表 V1》

## 1. 表字段冻结

- 对象名称
- 对象类型
- 当前文案
- 文案是否准确
- 更准确的中文
- 真源类型
- 证据文件
- 本轮动作

## 2. 总表

| 对象名称 | 对象类型 | 当前文案 | 文案是否准确 | 更准确的中文 | 真源类型 | 证据文件 | 本轮动作 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 页头状态线 | 页级状态元素 | `认证状态 + 会员状态` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_sections.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 顶部状态条 | 页级状态元素 | `当前会话暂不可用 / 正在同步私域整理引用 / 账号摘要暂未完整返回 / 私域整理引用当前暂不可用 / 当前为私域整理视图` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的公司（首页入口） | 首页入口摘要状态 | `当前会话暂不可用 / 组织摘要当前暂不可用 / 部分可用...` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 成员管理（首页入口） | 首页入口摘要状态 | `当前会话暂不可用 / 当前公司组织上下文暂不可用 / 部分可用...` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的会员（首页入口） | 首页入口摘要状态 | `部分可用 / 当前组织上下文不可用 / 当前未开通会员 / 权益摘要...` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的信用与约束（首页入口） | 首页入口摘要状态 | `summaryStatus / creditConstraintStatus / depositPostureStatus / transactionGuaranteeEligibilityStatus / 依赖 / 更新时间` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的申诉记录（首页入口） | 首页入口摘要状态 | `部分可用：查看当前账号的申诉记录与裁决结果` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_page.dart` | 保持 |
| 支付与账单状态（首页入口） | 首页入口摘要状态 | `summaryStatus / paymentStatus / billingReferenceStatus / 依赖 / 更新时间` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的项目（首页入口） | 首页入口摘要状态 | `当前组织项目列表与项目详情入口 · 进行中 X 个 / 历史 X 个` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 项目工作台（首页入口） | 首页入口摘要状态 | `当前组织项目资产摘要与项目工作台入口 · 进行中 X 个 / 历史 X 个` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 我的论坛（首页入口） | 首页入口摘要状态 | `帖子 / 评论 / 关注 / 收藏 / 草稿` 五项计数 | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 企业展示入驻（首页入口） | 纯导航入口 | `选择公司、工厂、供应商或个人/团队展示入口` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`、`apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 保持 |
| 设置（首页入口） | 纯导航入口 | `账号与安全、通知、隐私与权限等` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_page.dart` | 保持 |
| 个人资料（状态卡） | 下游功能状态卡 | `当前不扩成综合资料编辑器；简介编辑、实名身份与更大范围资料治理仍未开放。` | 需修正 | `简介入口当前未开放；实名身份与更大范围资料治理仍未开放。` | 预埋未开放 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_personal_page.dart`、`apps/bff/src/routes/profile/app-profile-command.controller.ts`、`apps/server/src/modules/profile/profile.controller.ts` | 文案纠偏 |
| 我的公司（状态卡） | 下游功能状态卡 | `已完成当前公司摘要、当前组织现状、认证资料摘要，以及进入公司与组织、公司认证与我的身份的后续入口。` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_company_page.dart` | 保持 |
| 公司与组织（状态卡） | 下游功能状态卡 | `已完成当前组织读取、编辑当前组织、再创建一个组织、加入组织与切换当前公司/组织。` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart` | 保持 |
| 公司认证与我的身份（状态卡） | 下游功能状态卡 | `已完成公司与组织入口、认证办理入口、当前公司/组织、当前成员身份与当前认证状态回显。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart` | 保持 |
| 成员管理（状态卡） | 下游功能状态卡 | `已完成当前组织成员列表、最小角色调整与禁用处理。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_member_management_sheet.dart` | 保持 |
| 我的会员（状态卡） | 下游功能状态卡 | `已完成会员当前态、权益摘要、配额摘要、说明页、配额说明页与升级引导页读取。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart` | 保持 |
| 我的信用与约束（状态卡） | 下游功能状态卡 | `已完成信用、保证金与交易保障姿态的状态、说明、衔接与依赖读取。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_credit_constraints_pages.dart` | 保持 |
| 支付与账单状态（状态卡） | 下游功能状态卡 | `已完成支付状态、账单引用、规则说明、处理与衔接、后续依赖读取。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_payment_billing_pages.dart` | 保持 |
| 我的申诉记录（状态卡） | 下游功能状态卡 | `已完成当前账号申诉列表与最小详情只读回显。` | 准确 | 保持现状 | 动态接口 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_governance_appeal_pages.dart` | 保持 |
| 我的论坛（状态卡） | 下游功能状态卡 | `当前不扩成第二论坛首页，也不承接公域作者主页或额外状态机。` | 需修正 | `我的论坛页不承接公域作者主页，也不扩成第二论坛首页或额外状态机。` | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart`、`apps/mobile/lib/features/exhibition/presentation/forum/forum_author_profile_pages.dart` | 文案纠偏 |
| 设置（状态卡） | 下游功能状态卡 | `已完成账号与安全、通知、隐私与权限、界面与显示、通用、存储空间、关于我们等 app-native 分组。` | 准确 | 保持现状 | 静态文案 | `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`、`apps/mobile/lib/features/profile/presentation/profile_settings_page.dart` | 保持 |

## 3. 当前下一步唯一动作

- 当前阶段完成度：
  - `对象口径与文案准确性表 closure 完成`
- 当前下一步唯一动作：
  - 前端仅处理 `个人资料` 与 `我的论坛` 两处文案纠偏
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - 本表已冻结，结果校验不得再把首页对象与下游功能状态卡混算
