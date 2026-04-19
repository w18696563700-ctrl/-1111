---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 Flutter surface direction for enterprise-display three-board independence, including independent entry routing, case-library semantics, and removal of in-workbench board switching.
layer: L4 Frontend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart
---

# 《企业展示三板块独立化 frontend surface freeze》

## 1. Scope

- 当前 frontend freeze 只覆盖：
  - `我的公司展示`
  - `我的工厂展示`
  - `我的供应商展示`
  - 对应私有 route / workbench / case library / case editor 的独立方向
- 当前保留但不实现：
  - `我的个人/团队展示`
- 当前明确不包含：
  - 新 public list/filter 设计
  - 新 Admin 页面
  - 非企业展示对象扩面

## 2. Entry Rule

- `我的资产` 中四个入口继续固定为：
  - `我的公司展示`
  - `我的工厂展示`
  - `我的供应商展示`
  - `我的个人/团队展示`
- 其中：
  - 前三项进入正式独立化主线
  - `个人/团队` 继续只保留受控占位，不得伪造正式榜单或工作台
- 对当前 bounded object 而言：
  - 本文件优先于旧的“单一企业展示入驻入口 / bottom sheet 选板块”解释
  - profile 四入口是当前唯一受控私有入口真相

## 3. Route and Workbench Rule

- company / factory / supplier 下一轮必须具备独立 route identity。
- 允许共享底层表单 section 或 widget，但不得继续共享：
  - workbench route identity
  - case editor route identity
  - page title / stage semantics
- 当前共享 workbench 壳层中的 board switcher 只视为过渡实现。
- 下一轮正式裁决：
  - 进入哪个板块入口
  - 就固定停留在哪个板块
  - 不再允许在工作台内切板块

## 4. Case Library Rule

- company / factory / supplier 必须拥有各自独立的：
  - 案例库
  - 新增案例入口
  - 继续编辑入口
  - 删除案例入口
- UI 上不得继续只给统一“案例库”心智，而应承接板块专属语义。
- 私有 case editor 不得继续只靠共享 `/enterprise/cases/editor` 表达全部板块语义。

## 5. Upload Semantics Rule

- Flutter 侧必须显式区分三类案例上传语义：
  - 公司案例图片
  - 工厂案例图片
  - 供应商案例图片
- 工厂实景图继续保持工厂专属上传语义。
- 即使底层仍复用统一 upload init / confirm 页面与客户端能力，前端也不得继续把三类案例图片都写成同一板块无差别语义。

## 6. Published-change Symmetry Rule

- company / factory / supplier 的已发布展示入口策略必须对齐。
- 当前只有工厂入口优先探测 published-change corridor，不是正式完成态。
- 下一轮正式裁决：
  - 三板块都必须在“草稿态 / 已发布变更态”之间采用一致入口判定规则
  - 不得长期只给 factory 特例

## 7. Allowed Future Write Set

- 下一轮 frontend bounded implementation 允许写入：
  - `apps/mobile/lib/features/profile/presentation/profile_page.dart`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
  - 与上述直接相关的 frontend tests

## 8. Anti-revert

- 不得把三板块独立化退化成“仅 profile 列表三行文案不同”。
- 不得保留 in-workbench board switcher 作为长期主路径。
- 不得为 `个人/团队展示` 临时伪造正式私有工作台。
- 不得通过 Flutter 自创第二套 board truth 去弥补 backend media ownership 缺失。

## 9. Formal Conclusion

- 当前 frontend surface 已冻结为：
  - 三板块独立 entry / route / workbench / case editor 方向
  - 板块专属案例库与上传语义
  - published-change 对称入口规则
  - `个人/团队` 继续 placeholder only
