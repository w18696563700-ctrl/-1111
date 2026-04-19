---
owner: Codex 总控
status: active
purpose: >
  Turn the current workbench-split idea into an executable round-1 Flutter
  change table, file by file, while keeping the already-frozen my-project,
  project-detail document zone, and public-resource download zone authority
  unchanged.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_support.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_text.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
---

# 《发布项目工作台拆分第一轮前端可实施改造表》

## 1. 当前轮目标

- 本表只服务：
  - `apps/mobile` 第一轮入口、文案、可见性、兼容壳改造
- 本表不服务：
  - `apps/server`
  - `apps/bff`
  - contracts
  - docs truth 改写
- 当前轮完成目标固定为：
  - 把 `我的项目` 进一步收为 owner continuation 主入口
  - 把 `发布项目工作台` 降成兼容壳
  - 不破坏创建资格校验和既有兼容路由

## 2. 当前轮硬边界

- `ExhibitionRoutes.workbench` 保留。
- `app_router.dart` 中 workbench route 保留。
- `project_create_page.dart` 继续允许读取 workbench summary 中的
  `canCreateProject`。
- `我的项目详情` 中的 `项目详情文书区` 与 `公共资源下载区`
  不得迁回 workbench。
- 本轮不允许把 workbench 路由直接删除。
- 本轮不允许改 `Server/BFF/contracts`。

## 3. 推荐执行顺序

1. 先删一级入口和显性按钮
2. 再改 owner-facing 和 bid-guard 文案
3. 再把 workbench 缩成薄兼容壳
4. 最后统一补测试

## 4. 文件级改造表

| 文件 | 改什么 | 风险 | 是否需要联调 | 是否影响测试 |
| --- | --- | --- | --- | --- |
| `apps/mobile/lib/features/profile/presentation/profile_page.dart` | 删 `我的资产/常用入口` 中的 `发布项目工作台` 一级入口，只保留 `我的项目` | 低；只影响入口暴露，不影响底层 route | 否 | 是；`profile_page_test.dart`、`profile_private_operating_system_pages_test.dart`、`profile_payment_billing_pages_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/profile/presentation/profile_page_support.dart` | 删除 `发布项目工作台入口` 摘要文案，改成只总结 `我的项目` 私域资产 | 低；纯文案 | 否 | 是；同 profile 相关测试会断旧摘要 |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart` | 首页推荐空态不再传 `onOpenWorkbench` 作为首选 fallback；保留 `创建项目` 或改成 `进入我的项目` | 低到中；涉及 section 组件参数和空态交互 | 否 | 是；`exhibition_home_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart` | 删空态里的 `回到发布项目工作台` 次按钮；空态文案只指向 `去发布项目` 或 `进入我的项目` | 低；纯空态 CTA 收口 | 否 | 是；`exhibition_home_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart` | owner 侧继续处理区删 `打开发布项目工作台` 按钮；说明文案从“进入我的项目或发布项目工作台”收成只指向 `我的项目` | 低到中；owner 详情页 CTA 会变化 | 否 | 是；`exhibition_mainline_flow_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart` | guard loading copy 从“检查发布项目工作台资格”改成“检查当前创建资格” | 低；纯文案 | 否 | 是；创建页 widget tests |
| `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` | 保留 `loadWorkbench()` 和 `canCreateProject` 读取，但所有 `回到发布项目工作台 / 发布项目工作台资格` 文案和按钮改成 `返回我的项目 / 查看认证状态 / 去完善组织 / 当前创建资格`；不得删 workbench query 依赖 | 中；这里是当前唯一真实 `canCreateProject` guard 依赖点，容易误伤创建资格链 | 否，但建议真人冒烟 | 是；`project_showcase_filter_create_refactor_test.dart`、`exhibition_mainline_flow_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart` | 把 `回到发布项目工作台` 全部改成更准确的去向：壳层失败回 `项目展示` 或当前详情，供应商角色不符回认证/组织入口，owner 阻断继续回 `我的项目` | 中；guard 去向不能一刀切，否则会把供应商链误导回发布方页面 | 否 | 是；`bid` 相关测试、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart` | 如页面本身还透出 `回到发布项目工作台`，同步改成 guard 新去向文案 | 低到中；依赖 guard copy 一致性 | 否 | 是；`shell_app_test.dart`、相关 bid tests |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart` | 把 workbench 页收成薄兼容壳：保留刷新、最小 CTA、必要 banner；不再像“四容器说明墙” | 中；workbench 仍是兼容路由，不能空壳到失去 guard/reentry 语义 | 否 | 是；`exhibition_home_test.dart`、`shell_app_test.dart`、`project_attachment_corridor_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart` | 隐藏 `边界能力` 整块；`订单承接` 无 `activeOrderId` 时不显示空卡；`履约承接` 无 `activeMilestoneId` 时不显示空卡；保留 `project_chain` 的最小兼容承接 | 中；要避免把 workbench 做成空白页，同时不能误露旧说明墙 | 否 | 是；workbench 相关 widget tests |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart` | 第一轮不改 canonical route title，不改数据结构；只允许把 summary copy 往“兼容壳”方向收薄 | 低；建议少改，防止第二步重命名和第一步入口收口互相打架 | 否 | 可能；若 copy 变化则影响 `exhibition_home_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_text.dart` | 收掉过重的 `发布项目工作台` 说明性文案，保留最小受控失败提示；但页名重命名建议推迟到第二步 | 低到中；纯 copy，但影响较多断言 | 否 | 是；`exhibition_home_test.dart`、`shell_app_test.dart` |
| `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart` | 第一轮不改；保留 `ExhibitionRoutes.workbench` | 低；本轮应明确 `不动` | 否 | 否，除非误改 |
| `apps/mobile/lib/shell/navigation/app_router.dart` | 第一轮不删 workbench route；建议仅保留现有注册，不做标题改名 | 低；本轮应明确 `不动` | 否 | 否，除非误改 |
| `apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts` | 第一轮不改；它当前仍提供 `canCreateProject`、active order/milestone 锚点 | 中；若另一线程顺手改这里，会直接打断创建 guard 和兼容壳 | 是；这里只需约束别动，不需联调开发 | 间接影响全链冒烟 |

## 5. 当前轮不建议进入的文件

- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - 当前已经承接：
    - `项目详情文书区`
    - `公共资源下载区`
  - 第一轮拆 workbench 不应动这里的区位归属
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
  - 当前已和 `项目详情文书区` truth 对齐
  - 不属于本轮入口拆分改造面

## 6. 当前轮联调判断

- 严格意义上：
  - 不需要 `Server/BFF/contracts` 联调
- 但需要：
  - 本地真人冒烟
  - development-stage 路由与 CTA 复核
- 冒烟重点固定为：
  - `我的楼 -> 我的项目`
  - 首页空态 CTA
  - owner 公域详情继续处理区
  - 创建 guard
  - 竞标 guard
  - workbench 兼容壳最小承接

## 7. 当前轮测试影响面

- 直接会受影响的测试家族包括：
  - `apps/mobile/test/profile_page_test.dart`
  - `apps/mobile/test/profile_private_operating_system_pages_test.dart`
  - `apps/mobile/test/profile_payment_billing_pages_test.dart`
  - `apps/mobile/test/exhibition_home_test.dart`
  - `apps/mobile/test/exhibition_mainline_flow_test.dart`
  - `apps/mobile/test/shell_app_test.dart`
- 可能受间接影响的测试包括：
  - `apps/mobile/test/project_attachment_corridor_test.dart`
    - 仅当 workbench 兼容壳结构改太狠时

## 8. 总控建议

- 这轮交给我统筹，确实会更有规划。
- 原因不是“我会写代码”，而是我现在已经同时握着：
  - `我的项目` authority
  - `预发布列表` authority
  - `项目详情文书区` authority
  - `公共资源下载区` truth chain
- 所以第一轮拆 workbench 时，能明确守住：
  - `我的项目详情` 是 owner continuation 主面
  - 文书区和公共资源区不得回流到 workbench
  - workbench 只降级成兼容壳，而不是被另一线程误删成断链点
