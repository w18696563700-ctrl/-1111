---
owner: Codex 总控
status: frozen
purpose: Freeze the Round 1 increment-dispatch judgment for the actual `我的楼` functionality body, narrowing the current active action back to feature-body progression instead of release-prep or launch language.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_backend_bff_implementation_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-read.service.ts
  - apps/server/src/modules/profile/profile.controller.ts
---

# 《我的楼功能本体 Round 1 增量施工派工判断》

## 1. 当前唯一目标

- 当前唯一目标是：
  - 把 `我的楼` 从“边界已冻结 + 入口已存在”推进到“最小功能本体真实成立”
- 当前唯一主线只限：
  - `我的楼` 首层 hub
  - `我的公司`
  - `认证与成员身份`
  - `我的项目`
  - `我的论坛`
  - `设置`
- 当前不是：
  - `release-prep gate judgment`
  - `launch approval`
  - `closure conclusion`
  - 其他业务板块主线切换

## 2. 当前已成立功能本体

- `我的楼` 首层 hub 已成立为最小可用入口页：
  - 顶部个人摘要
  - `我的公司`
  - `认证与成员身份`
  - `我的项目`
  - `我的论坛`
  - `设置`
  - 当前实现见：
    - [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart)
- `我的公司` 已成立为真实只读摘要页，而不是空白占位：
  - 已消费当前组织摘要与当前认证摘要
  - 已形成最小公司信息与认证资料读取面
  - 当前实现见：
    - [profile_detail_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart)
    - [app-profile-read.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/app-profile-read.controller.ts)
    - [profile-read.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.service.ts)
    - [profile.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts)
- `我的论坛` 已成立为真实个人论坛资产入口与二级资产页：
  - 已消费我的帖子 / 评论 / 收藏 / 关注 / 草稿
  - 当前实现见：
    - [profile_forum_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart)
- `设置` 已成立为最小 app-native 设置页：
  - 已有账号与安全、通知、隐私与权限、界面与显示、通用等分组
  - 但仍是最小消费面，不是完整设置中心
  - 当前实现见：
    - [profile_detail_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart)
- `我的项目` 已成立为 `我的楼` 下的真实私域入口链：
  - `我的楼 -> 我的项目`
  - grouped list：`进行中 / 历史项目`
  - detail：`publicProject + privateProgress`
  - `formalCompletionStatus / evaluationStatus` 用户语言已成立
  - owner surface 当前只到本地 `管理当前` shell，不落 action execution
  - 当前实现见：
    - [my_project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart)
    - [my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart)

## 3. 当前缺口清单

- `认证与成员身份` 还没有成为真正的 bounded 功能页：
  - 当前 `我的楼` 首层入口直接跳到 `认证状态`
  - 还没有形成真实的“认证与成员身份”聚合页
  - 当前只成立：
    - `certification/current` 读取
    - 受控 `session center` 壳
- Package 1 当前缺的不是“总理念”，而是办理链未做实：
  - 当前前端明确写死：
    - 组织创建 / 加入 / 切换待开放
    - refresh / logout / security devices 待开放
  - 当前实现见：
    - [profile_organization_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart)
    - [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)
- Package 1 的 app-facing route family 当前没有做实到可消费闭环：
  - 当前 BFF / Server 已真实存在的 profile family 主要是：
    - `GET /api/app/profile/index`
    - `GET /api/app/profile/organization/mine`
    - `GET /api/app/profile/certification/current`
    - `POST /server/profile/certification/submit`
    - `POST /server/profile/certification/resubmit`
  - 当前未见真实 materialized 的 app-facing BFF / Server 闭环：
    - `organization/create`
    - `organization/join-by-code`
    - `organization/switch`
    - `security/devices`
    - `security/devices/{deviceId}/revoke`
    - `organization/members/*`
- `我的公司` 当前是真实只读页，但不是“办理页”：
  - 当前能看组织与认证摘要
  - 但不能完成组织承接动作闭环
- `我的项目` 当前已把列表消费、单项目双区、状态语言、handoff 关系做实：
  - 当前真正还缺的是：
    - `我的楼` 首层入口上的 live summary
    - 而不是再重做 list/detail 主体
- `设置` 当前是最小分组页，不是完整账号与安全中心：
  - 会话与设备当前仍是受控壳
  - 各设置组大多仍是静态承载，不是完整可执行设置系统

## 4. 本轮必做项

- 必做 1：
  - 把 `认证与成员身份` 从“当前认证状态入口”推进成真正的 bounded 聚合页
  - 该页只承接：
    - 当前组织状态
    - 当前成员身份
    - 当前认证状态
    - 组织承接动作 handoff
    - 认证提交 / 重提 handoff
- 必做 2：
  - 把 Package 1 推进到真实 app-facing consumption，而不是继续停在 formal surface
  - 本轮必须真正施工的最小链条为：
    - `organization/create`
    - `organization/join-by-code`
    - `organization/switch`
    - `certification/submit`
    - `certification/resubmit`
  - 当前不要求扩到 admin review，也不要求扩到 person-real-name 第二套体系
- 必做 3：
  - 把 `我的公司` 从“只读摘要页”推进到“可导向真实组织承接动作的公司页”
  - 当前目标不是做管理后台，而是：
    - 从公司页能明确进入组织状态 / 认证办理链
- 必做 4：
  - 把 `我的楼 -> 我的项目` 首层入口补成真实私域入口摘要
  - 当前只允许补：
    - `ongoingProjects.length`
    - `historicalProjects.length`
    - 受控摘要文案
  - 当前不允许在 hub 首层重做第二个 my-project dashboard

## 5. 本轮冻结占位项

- `会话与设备` 保持受控壳：
  - 当前不把 refresh / logout / devices / revoke 做成完整安全中心
  - 只有在 app-facing routes 真正做实后，才允许从壳转成真实消费页
- `我的公司` 的成员管理、角色变更、成员禁用继续冻结：
  - 不做公司管理控制台
  - 不做完整成员后台
- `我的项目` owner manage shell 继续保持 shell：
  - 不落推广 / 编辑 / 下架 / 删除执行链
- `设置` deeper families 继续保持最小承载：
  - 不做完整通知、隐私、显示、存储中心
- 正式附件列表继续冻结在 `我的项目` 主线外：
  - 不混入 list/detail

## 6. 战略保留项

- 会员系统
- 信用 / 保证金系统
- 支付 / 账单系统
- 完整治理后台
- 完整安全中心与风险中心
- richer forum 主线
- `我的项目` richer 私域状态、附件、治理、动作矩阵

## 7. 角色派工矩阵

- `总控`
  - 负责把本判断单收成当前活跃主线依据
  - 负责输出 Round 1 前端 / 后端 / BFF / 文书冻结 / 结果校验口令
  - 负责确保当前主线不再漂回 `release-prep`
- `总控文书冻结`
  - 负责把本判断单、派工边界、owner split、阅读顺序收口为正式引用链
  - 不得新增 scope
- `前端 Agent`
  - 负责：
    - `认证与成员身份` bounded 聚合页
    - `我的公司` 与组织承接 / 认证办理 handoff
    - `我的楼 -> 我的项目` live summary
  - 不得：
    - 把 `profile` 写成 truth owner
    - 把 `我的项目`、`项目工作台`、公域项目浏览混同
- `后端 Agent`
  - 负责：
    - `Server` truth 下的 `organization/create`
    - `organization/join-by-code`
    - `organization/switch`
    - `certification/submit`
    - `certification/resubmit`
    - 仅限当前 organization-centered truth
  - 不得：
    - 新造第二 identity / certification / eligibility truth
    - 扩到 admin governance 主线
- `BFF Agent`
  - 负责：
    - `/api/app/profile/organization/*` 当前最小 handoff family
    - `/api/app/profile/certification/submit|resubmit` shaping
    - 继续只做 app-facing shaping 与错误归一
  - 不得：
    - 持有业务真相
    - 创建第二状态机
- `结果校验 Agent`
  - 负责：
    - 校验 Package 1 是否从 formal surface 真正进入 bounded consumption
    - 校验 `我的项目` hub 入口摘要是否仍未漂成 dashboard
    - 校验 `我的公司 / 认证与成员身份 / 设置` 是否没有越界成治理中心
- `联调发布 Agent`
  - 当前轮不提前介入 release-prep
  - 只在 implementation receipts 与结果校验通过后，才回到真实拓扑联调

## 8. 结果校验重点

- 是否把 `profile` 入口 owner 写成 truth owner
- 是否把 Package 1 formal surface 误写成 runtime fully open
- 是否把 `我的项目` 和 `项目工作台` / 公域项目浏览混同
- 是否把 `organization/create|join|switch` 做成第二套组织真相
- 是否把 `certification submit|resubmit` 做成第二套认证状态机
- 是否把 `我的公司` 漂成管理后台
- 是否把 `设置` 漂成完整安全中心或 IM 设置页
- 是否把 `我的项目` 首层摘要做成第二 dashboard
- 是否误开放 hidden building

## 9. Gate Recommendation

- 当前 gate recommendation：
  - `Go` for `我的楼功能本体 Round 1` bounded increment dispatch
  - `No-Go` for `release-prep`
  - `No-Go` for `launch approval`
  - `No-Go` for `closure`
- 当前通过的真实含义是：
  - 可以进入角色级 Round 1 派工口令输出
  - 不能把本判断单写成上线或收尾口径

## 10. Next Unique Action

- 下一轮唯一动作：
  - 先输出《我的楼 Round 1 后端派工口令》
- 原因固定为：
  - 当前最先阻塞 `我的楼功能本体` 的不是前端样式，而是 Package 1 关键 app-facing truth path 尚未做实
