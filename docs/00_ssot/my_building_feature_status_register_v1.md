---
title: 我的楼功能状态总表 V1
status: active
owner: Codex Control
scope: my_building
created_at: 2026-04-09
updated_at: 2026-04-14
---

# 我的楼功能状态总表 V1

## A. 适用范围

本表按 [功能状态总表 V1 模板](feature_status_register_v1_template.md) 首次登记当前 `我的楼` 已上墙 family 的真实状态与运行边界。

本轮覆盖：

- `我的楼聚合页`
- `个人资料`
- `我的公司`
- `公司与组织`
- `成员管理`
- `公司认证与我的身份`
- `我的会员`
- `我的信用与约束`
- `支付与账单状态`
- `我的申诉记录`
- `我的项目`
- `项目工作台`
- `我的论坛`
- `设置`

## B. 当前验证基线

- 本地源码与文书基线按 2026-04-09 当前工作区扫描确认。
- 云端 app-facing smoke 于 `2026-04-09 20:47 CST` 复验通过：
  - `GET /api/app/profile/index = 200`
  - `GET /api/app/profile/organization/mine = 200`
  - `GET /api/app/profile/organization/members = 200`
  - `GET /api/app/profile/certification/current = 200`
  - `GET /api/app/profile/membership/current = 200`
  - `GET /api/app/profile/credit-and-constraints/status = 200`
  - `GET /api/app/profile/payment-and-billing-status/status = 200`
  - `GET /api/app/profile/governance/appeals = 200`
- 运行时当前观察到的真实状态：
  - `我的会员` 当前为已开放读取但空摘要
  - `我的信用与约束` 当前为 `handoff_required`
  - `支付与账单状态` 当前为 `handoff_required`
  - `我的申诉记录` 当前返回空列表
- 本地隔离 runtime 于 `2026-04-14 02:47 CST` 追加复验：
  - 同一多组织用户默认 current organization 未命中 payment/billing truth 时：
    - `GET /api/app/profile/payment-and-billing-status/status = 404 PAYMENT_STATUS_UNAVAILABLE`
    - `GET /api/app/profile/payment-and-billing-status/explanation = 404 PAYMENT_STATUS_UNAVAILABLE`
    - `GET /api/app/profile/payment-and-billing-status/handoff = 404 PAYMENT_STATUS_UNAVAILABLE`
  - 同一 token 串行执行 `POST /api/app/profile/organization/switch` 后：
    - `GET /api/app/shell/context = organizationId 4b79f76f-9d60-4a70-bf05-6fbb51dd4f01`
    - `GET /api/app/profile/payment-and-billing-status/status = 200`
    - `GET /api/app/profile/payment-and-billing-status/explanation = 200`
    - `GET /api/app/profile/payment-and-billing-status/handoff = 200`
  - `sessions.organization_id` 与 payment/billing seed truth 均与上述串行结果一致
  - 当前运行结论：
    - 该功能不是断链
    - `default current-org unavailable -> switch -> success` 的 app-facing continuity 已成立
- 云端 project/forum runtime 于 `2026-04-09 21:25 CST` 追加复验：
  - `GET /api/app/my/projects = 500`
  - `GET /api/app/exhibition/workbench = 500`
  - `GET /api/app/forum/me/posts = 404`
  - `GET /api/app/forum/me/comments = 404`
  - `GET /api/app/forum/me/bookmarks = 404`
  - `GET /api/app/forum/me/follows = 404`
  - `GET /api/app/forum/draft/list = 500`
- 当前运行 blocker 观察：
  - `我的项目` 当前 live 读取阻断在 `/server/my/projects` 上游 `500`
  - `项目工作台` 当前 live 读取阻断在 `/server/exhibition/workbench` 上游 `500`
  - `我的论坛` 当前 me-assets app-facing surface 未完整生效，且 `draft/list` 上游 `500`

## C. 口径说明

- 本表内部 `功能状态` 采用模板冻结值。
- App 状态页对用户统一显示简化口径：
  - `受控可用 -> 部分可用`
  - `阻断中 -> 处理中`
- “部分可用”表示当前已具备真实能力，但不是完整业务闭环。

## D. 当前总表

| 功能模块 | 子功能 | 功能状态 | 文书状态 | 当前已完成 | 当前未完成 | 当前阻断项 | 当前依赖项 | 入口是否已挂出 | 真相 owner | 证据链接 | 最近验证时间 | 下次开启条件 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 我的楼 | 聚合页 | 受控可用 | 已解锁实施 | 已完成常用入口聚合、私域整理状态条、公司/会员/信用/支付摘要入口与既定 first-level 顺序保留 | 不承接跨楼重写、统一业务操作台或更大范围工作台合并 | 无 | `shell/context`、`profile/index`、下游各 bounded family 读取 | 是 | Server | [my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md](my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md)、[profile_page.dart](../../apps/mobile/lib/features/profile/presentation/profile_page.dart) | 2026-04-09 20:47 CST | 未来 cross-building shell rewrite 主线正式解锁 |
| 我的楼 | 个人资料 | 受控可用 | 已解锁实施 | 已完成个人资料摘要、头像与昵称独立入口、我的公司 handoff、会话与设备入口 | 当前不扩成综合资料编辑器；简介编辑、实名身份链与更大范围资料治理未开放 | 无 | 当前会话、shell 资料摘要、头像与昵称审核链 | 是 | Server | [profile_ia_cleanup_boundary_freeze_addendum.md](profile_ia_cleanup_boundary_freeze_addendum.md)、[personal_minimal_edit_boundary_freeze_addendum.md](personal_minimal_edit_boundary_freeze_addendum.md)、[profile_personal_page.dart](../../apps/mobile/lib/features/profile/presentation/profile_personal_page.dart) | 2026-04-09 20:47 CST | 更丰富资料编辑或实名主线正式解锁 |
| 我的楼 | 我的公司 | 受控可用 | 已解锁实施 | 已完成当前公司摘要、当前组织现状、认证资料摘要，以及进入 `公司与组织 / 公司认证与我的身份` 的后续入口 | 不在本页重复铺设完整组织办理后台；创建/加入/切换组织与认证办理继续在下游页承接 | 无 | 当前会话、当前组织上下文、认证当前态读取 | 是 | Server | [profile_ia_cleanup_boundary_freeze_addendum.md](profile_ia_cleanup_boundary_freeze_addendum.md)、[account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](../02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)、[profile_company_page.dart](../../apps/mobile/lib/features/profile/presentation/profile_company_page.dart) | 2026-04-09 20:47 CST | 更大范围公司工作台或跨组织治理后台正式解锁 |
| 我的楼 | 公司与组织 | 受控可用 | 已解锁实施 | 已完成当前组织读取、编辑当前组织、再创建一个组织、加入组织与切换当前公司/组织 | 当前不扩成综合治理后台；不承接认证审核、项目治理或跨组织风控 | 无 | 当前会话、组织真值、壳层当前组织切换 | 是 | Server | [my_building_functionality_body_round1_organization_members_bounded_unlock_dispatch_addendum.md](my_building_functionality_body_round1_organization_members_bounded_unlock_dispatch_addendum.md)、[account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md](../04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md)、[profile_organization_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart) | 2026-04-09 20:47 CST | 更大范围公司操作台与跨组织治理主线解锁 |
| 我的楼 | 成员管理 | 受控可用 | 已解锁实施 | 已完成当前组织成员列表、最小角色调整与禁用处理 | 当前不承接邀请审批、批量操作、审计台或复杂权限编排 | 无 | 当前组织上下文、成员真值、角色变更与禁用写链路 | 是 | Server | [my_building_functionality_body_round1_organization_members_bounded_unlock_dispatch_addendum.md](my_building_functionality_body_round1_organization_members_bounded_unlock_dispatch_addendum.md)、[profile_member_management_sheet.dart](../../apps/mobile/lib/features/profile/presentation/profile_member_management_sheet.dart) | 2026-04-09 20:47 CST | 成员治理与审计主线解锁 |
| 我的楼 | 公司认证与我的身份 | 受控可用 | 已解锁实施 | 已完成公司与组织入口、认证办理入口、当前公司/组织、当前成员身份与当前认证状态回显 | 当前不承接统一企业后台，不扩成全量资质中心或多轮审核工作台 | 无 | 当前组织上下文、认证真值、营业执照上传与最小审核链 | 是 | Server | [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](../02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)、[account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md](../04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md)、[profile_identity_access_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart) | 2026-04-09 20:47 CST | 认证治理后台或更大范围企业主体管理主线解锁 |
| 我的楼 | 我的会员 | 受控可用 | 已归档 | 已完成会员当前态、权益摘要、配额摘要、说明页、配额说明页与升级引导页读取 | 当前不承接购买、续费、下单、支付与账单闭环 | 无 | 会员真值、组织 scope、后续支付系统 | 是 | Server | [my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md](my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md)、[membership_entitlement_v1_backend_truth_addendum.md](../02_backend/membership_entitlement_v1_backend_truth_addendum.md)、[profile_membership_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart) | 2026-04-09 20:47 CST | 支付 MVP 主线解锁 |
| 我的楼 | 我的信用与约束 | 受控可用 | 已归档 | 已完成信用、保证金与交易保障姿态的状态、说明、衔接与依赖读取 | 当前不承接真实保证金缴纳、资金冻结、支付执行或结算 | 无 | 信用/保证金/交易保障真值，以及 `V2.2 支付与账单` 依赖 | 是 | Server | [my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md](my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md)、[credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md](../02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md)、[profile_credit_constraints_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_credit_constraints_pages.dart) | 2026-04-09 20:47 CST | 支付/账单执行闭环解锁 |
| 我的楼 | 支付与账单状态 | 受控可用 | 已归档 | 已完成 bounded read-only 的支付状态、账单引用、规则说明、处理与衔接、后续依赖读取；default current-org unavailable 的 mobile 解释层、切换组织引导、本地测试、同 token 串行 app-facing continuity 复核与母文件正文吸收均已完成 | 当前仍不承接下单、支付 provider、回调、结算、发票、税务与财务后台 | 无 | 当前组织 scope、payment/billing truth、后续财务依赖 | 是 | Server | [my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md](my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md)、[my_building_v22_payment_billing_v11_usability_closure_control_dispatch_addendum.md](my_building_v22_payment_billing_v11_usability_closure_control_dispatch_addendum.md)、[my_building_v22_payment_billing_v11_usability_result_verification_conclusion_addendum.md](my_building_v22_payment_billing_v11_usability_result_verification_conclusion_addendum.md)、[payment_billing_v1_backend_truth_addendum.md](../02_backend/payment_billing_v1_backend_truth_addendum.md)、[my_building_effective_truth_mother_file_v1.md](my_building_effective_truth_mother_file_v1.md) | 2026-04-14 02:47 CST | 未来 payment / billing execution 主线正式解锁 |
| 我的楼 | 我的申诉记录 | 受控可用 | 已归档 | 已完成当前账号申诉列表与最小详情只读回显 | 当前不承接新建申诉、补充材料、多轮沟通或治理处理台 | 无 | 当前 actor scope、申诉真值、治理详情读取 | 是 | Server | [cs030_my_appeal_history_p2a_completion_filing_addendum.md](cs030_my_appeal_history_p2a_completion_filing_addendum.md)、[cs030_my_appeal_history_p2a_backend_truth_addendum.md](../02_backend/cs030_my_appeal_history_p2a_backend_truth_addendum.md)、[profile_governance_appeal_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_governance_appeal_pages.dart) | 2026-04-09 20:47 CST | 申诉写链路或治理处理台主线解锁 |
| 我的楼 | 我的项目 | 阻断中 | 已解锁实施 | 已完成 `我的楼 -> 我的项目` handoff、当前组织 scope 下 list/detail carrier，以及 `publicProject + privateSummary` 展示结构 | 当前 live 读取未稳定返回；不替代项目工作台、公域项目浏览或完整项目治理后台 | `/api/app/my/projects` 当前上游 `500` | 当前组织 scope、private progress 投影、我的项目读取链路 | 是 | Server | [my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md](my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md)、[my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md](../02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md)、[my_project_list_page.dart](../../apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart) | 2026-04-09 21:25 CST | `/api/app/my/projects` live smoke 恢复 `200` 并通过读取校验 |
| 我的楼 | 项目工作台 | 阻断中 | 已解锁实施 | 已完成私域继续处理页、四容器摘要消费边界、刷新入口与既定 handoff 说明 | 当前 live 工作台摘要未稳定返回；不替代我的项目、公域项目浏览或第二工作台状态机 | `/api/app/exhibition/workbench` 当前上游 `500` | workbench summary truth、project/order/fulfillment container 投影 | 是 | Server | [my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md](my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md)、[flutter_screen_map.md](../04_frontend/flutter_screen_map.md)、[exhibition_page.dart](../../apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart) | 2026-04-09 21:25 CST | `/api/app/exhibition/workbench` live smoke 恢复 `200` 并通过摘要校验 |
| 我的楼 | 我的论坛 | 阻断中 | 已解锁实施 | 已完成一层 `我的论坛` handoff、二层资产页，以及帖子/评论/收藏/关注/草稿读取 wiring | 当前 me-assets app-facing surface 未完整生效，草稿读取也未稳定返回；不扩成第二论坛首页 | `/api/app/forum/me/*` 当前 `404`，`/api/app/forum/draft/list` 当前上游 `500` | forum me-assets surface、draft truth、当前会话 carrier | 是 | Server | [forum_navigation_building_ownership_boundary_addendum.md](forum_navigation_building_ownership_boundary_addendum.md)、[forum_frontend_implementation_surface_addendum.md](../04_frontend/forum_frontend_implementation_surface_addendum.md)、[profile_forum_pages.dart](../../apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart) | 2026-04-09 21:25 CST | forum me-assets 与 `draft/list` live smoke 全部通过 |
| 我的楼 | 设置 | 受控可用 | 已解锁实施 | 已完成账号与安全、通知、隐私与权限、界面与显示、通用、存储空间、关于我们等 app-native 分组 | 当前不提供独立通知开关、隐私写链路、缓存管理或系统级显示设置接管 | 无 | 当前会话、当前账号摘要、app-native 设置分组边界 | 是 | Server | [profile_my_building_compact_hub_frontend_surface_addendum.md](../04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md)、[profile_settings_page.dart](../../apps/mobile/lib/features/profile/presentation/profile_settings_page.dart) | 2026-04-09 20:47 CST | 真实设置写链路与系统联动能力正式解锁 |

## E. App 文案对齐规则

本表对应的 App 口径统一如下：

- 入口摘要优先说清楚“部分可用”，不再把空摘要误写成“暂不可用”。
- 状态页统一补充 6 行：
  - 功能名称
  - 当前功能状态
  - 当前已完成
  - 当前未完成
  - 当前依赖项
  - 后续开启条件
- 状态页继续允许展示当前真实 runtime 数据，但不得把 future handoff 伪装成“已完成闭环”。

## F. 后续补齐顺序

下一轮优先推进：

1. 修复 `我的项目` live 读取 `500`
2. 修复 `项目工作台` live 读取 `500`
3. 补齐 `我的论坛` me-assets app-facing surface 与 `draft/list` runtime
4. 继续扩充个人资料 richer edit 与设置真实写链路的状态登记
