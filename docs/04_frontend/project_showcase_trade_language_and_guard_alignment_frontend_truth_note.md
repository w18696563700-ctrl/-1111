---
owner: Codex 总控
status: active
purpose: >
  Record the current Flutter-side trade-language alignment for the public
  project showcase chain, including state vocabulary, type labels, list
  filters, bid action naming, guard behavior, and the current live
  dual-certification bid-eligibility truth across shell, profile, and bid
  handoff.
layer: L5 Frontend
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/dual_certification_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_private_progress_support.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
---

# 项目展示链路状态词与竞标守卫 frontend truth note

## 1. Scope

- 本说明只覆盖当前 `展览楼 -> 项目展示 / 项目详情 / 竞标提交 / 竞标结果 / 我的项目阶段标签` 的前端可见词与守卫口径。
- 本说明不扩写：
  - `BFF / Server` 业务真值
  - order / contract / inspection / rating 状态机
  - 新增后端认证模型

## 2. 当前执行边界

- 本次开发执行环境固定为：
  - 本地只修改 `apps/mobile`
  - `BFF / Server` 继续以云上 active runtime 为准
- 当前默认联调隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 后续线程不得因为本地没有起 `BFF / Server`，就把这次状态词、筛选和守卫统一误判成异常漂移。

## 3. 当前统一词表

- 公域 `project.state` 当前前端可见词统一为：
  - `published` -> `竞标中`
  - `bidding_closed` -> `投标已结束`
  - `awarded` -> `已授标`
  - `converted_to_order` -> `已被承接`
- `我的项目` 中原 `已发布` 阶段当前同步改为：
  - `竞标中`
- `我的项目` 中 `竞标中` 阶段当前下一步文案统一为：
  - 列表卡 / 摘要卡：
    - `查看详情 / 补充资料`
  - 详情摘要：
    - `优先补充资料；当前详情页不再单独展示阶段动作。`
- 详情动作文案当前统一为：
  - `继续竞标` -> `立即参与竞标`
  - `查看投标结果` -> `查看竞标结果`

## 4. 当前类型可见词

- `project detail` 中原 `建筑类型` 标签当前统一改为：
  - `项目类型`
- canonical `buildingType` 当前前端可见词统一为：
  - `exhibition` -> `会展`
  - `renovation` -> `装修`
  - `custom_furniture` -> `定制`
- 创建页当前仍保留：
  - `会展 / 展厅 / 商业活动 / 会议 / 路演 / 美陈 / 纯安装 / 其他`
  作为场景选择入口
- 当前规则固定为：
  - 创建页场景选择入口可以更细
  - 列表与详情页只展示 canonical 可见词
  - 后续线程不得把这两层词表再次混成彼此冲突的展示结果

## 5. 当前列表筛选

- `项目展示` 列表当前筛选组合固定为：
  - `城市 / 状态 / 类型 / 面积 / 金额`
- 当前 `状态` 与 `类型` 筛选先按前端本地消费收口：
  - `状态` 使用统一后的公域词表
  - `类型` 基于当前 payload 中的 canonical `buildingType` 生成
- 当前不把这次前端本地筛选直接写成：
  - 云上 `BFF / Server` 已新增对应 query truth

## 6. 当前竞标守卫

- `立即参与竞标` 与 `查看竞标结果` 当前统一先走同一套前端守卫：
  - 登录
  - 组织
  - 组织类型
  - 企业认证
  - 我的认证
- 当前项目态限制固定为：
  - `立即参与竞标` 仅在 `published` 可继续
  - `查看竞标结果` 仅在 `awarded / converted_to_order` 可继续
- 当前双重认证口径固定为：
  - 当前组织类型必须属于 `supplier / both`
  - 企业认证必须已通过
  - 我的认证必须已通过
  - 我的认证不得锁定到其他账号
  - 若 `shell/context` 已给出 `personalCertificationQualified=false`，当前账号也不得继续取得竞标资格
- 守卫失败时当前优先引导到：
  - 登录入口
  - `公司认证与我的身份`
  - 当前项目详情
- 当前不得再把守卫失败默认静默打回：
  - `项目展示` 列表

## 7. Dual-cert Live Rule

- `个人认证 + 企业认证` 双重认证当前已经是 live truth，不再是未来升级项。
- 当前落点固定为：
  - `公司认证与我的身份` 中的 `当前我的认证`
  - `我的认证真值`
  - `提交我的认证`
- 当前真值来源固定为：
  - `shell/context` 中的 `personalCertificationStatus / personalCertificationQualified / personalCertificationLockedToOtherActor`
  - `profile/certification/current` 中 nested `personalCertification`
- 当前写链固定为：
  - `init -> direct upload -> confirm -> OCR -> submit`
- 后续线程不得再把“双重认证”描述为：
  - 只在前端文案层提示
  - 只靠本地假字段模拟
  - 尚未上线的 future-only freeze

## 8. Anti-revert Rule

- 后续线程当前不得把以下行为当成“误改”直接回退：
  - 把 `竞标中` 改回 `已发布`
  - 把 `已被承接` 改回 `已转为订单`
  - 把 `立即参与竞标` 改回 `继续竞标`
  - 把 `查看竞标结果` 改回 `查看投标结果`
  - 去掉 `状态 / 类型` 筛选
  - 把守卫失败重新改回“直接回项目展示列表”
  - 把竞标资格改回只检查企业认证
  - 把竞标资格改回“必须先切到 `supplier_* roleKey` 才能进入”
  - 删除 `shell/context` 中的 `personalCertification*` 承接
  - 删除 `shell/context.organizationType` 这个最小组织类型投影
  - 移除 `公司认证与我的身份` 中的 `当前我的认证 / 我的认证真值`
- 原因固定为：
  - 这些改动已经由当前用户明确确认
  - 当前目标就是：
    - 词表统一
    - 展示链路更直观
    - 竞标入口和结果入口不再误导
    - 双重认证资格不再停留在假口径

## 9. 本地执行证据

- 当前修改文件：
  - [exhibition_home_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart)
  - [project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart)
  - [project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart)
  - [my_project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart)
  - [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart)
  - [bid_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart)
  - [bid_submit_guard_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart)
  - [bid_submit_sections_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart)
  - [exhibition_payload_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart)
  - [my_project_stage_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart)
  - [my_project_private_progress_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_private_progress_support.dart)
  - [exhibition_status_messages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart)
- 当前认证承接与冻结基线：
  - [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)
  - [account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md)
  - [profile_dual_certification_bid_guard_frontend_truth_note.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md)
- 当前已通过定向验证：
  - `flutter test test/exhibition_mainline_flow_test.dart test/showcase_cloud_handoff_test.dart test/shell_app_test.dart test/my_project_private_carry_test.dart test/bid_award_bridge_test.dart`

## 10. Formal Conclusion

- 当前 `项目展示` 链路正式记为：
  - `trade language aligned`
  - `state and type filters visible`
  - `bid entry and result actions renamed`
  - `guard fallback no longer silently returns to showcase list`
  - `dual-cert bid eligibility live`
  - `organization-type blocker explicit`
- 后续若用户要求再次改这条链路，不得只改代码不改文书；至少必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
  - `docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md`
