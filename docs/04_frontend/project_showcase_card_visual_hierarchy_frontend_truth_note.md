---
owner: Codex 总控
status: active
purpose: >
  Record the current Flutter-side visual hierarchy and anti-revert rule for
  the exhibition project showcase compact card, plus the current local/frontend
  versus cloud/backend execution boundary, so later threads do not treat the
  approved compact layout as accidental drift.
layer: L5 Frontend
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_list_filter_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart
---

# 项目展示卡片视觉层级 frontend truth note

## 1. Scope

- 本说明只覆盖当前 `展览楼 -> 项目展示列表` 的紧凑卡片：
  - 标题 / 状态区
  - 主信息区
  - 时间与主动作区
- 本说明不改写：
  - `project/detail`
  - `project/create`
  - `my/projects`
  - `BFF / Server` payload 语义

## 2. 当前执行边界

- 本次开发执行环境固定为：
  - 本地可直接修改与验证的只有 `apps/mobile`
  - `BFF / Server` 以云上 active runtime 为准
- 后续线程不得把“本地没有 `BFF / Server`”误写成当前前端改动不可信的理由。
- 当前云上联调入口固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 这条隧道当前只用于：
  - runtime 验证
  - active payload 观察
  - frontend 与云上链路联调
- 不得把本地 repo 中尚未运行的 `BFF / Server source` 直接当成 live truth 覆盖当前联调观察。

## 3. 当前已确认卡片版式

- 卡片顶部固定为：
  - 左侧 `展会标题`
  - 右侧 `状态 pill`
- 主信息区固定承接：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
- 主信息区当前必须保持：
  - 字号与字重高于旧版普通正文
  - `金额` 比其他主信息再高一级强调
- 卡片底部固定为一行：
  - 左侧 `时间`
  - 右侧 `查看详情`
- `时间` 当前属于次级信息：
  - 不再单独占一整行
  - 不与主信息区抢层级
- `查看详情` 当前属于轻量主动作：
  - 继续保留按钮形态
  - 不再独占新一行

## 4. 结构性实现约束

- 本轮同时确认：
  - `project_list_page.dart` 不再继续塞入卡片与筛选子组件实现
  - 卡片与筛选子组件已拆分到独立 part 文件
- 当前拆分不是机械拆行，而是为了同时满足：
  - 页面主责任收口
  - `Flutter App AGENTS` 的文件长度门禁
- 后续线程不得无理由把这些子组件再并回超长页面文件。

## 5. Anti-revert Rule

- 后续线程当前不得把以下行为当成“误改”直接回退：
  - 把 `展会 / 品牌 / 金额 / 面积 / 地点` 缩回旧的统一正文级字体
  - 把 `时间` 恢复成独立一整行
  - 把 `查看详情` 恢复成位于时间下方的单独一行按钮
  - 把已拆出的卡片 / 筛选子组件重新并回 `project_list_page.dart`
- 原因固定为：
  - 这些改动已经由当前用户明确确认
  - 它们同时服务于：
    - 信息层级收口
    - 卡片纵向压缩
    - 文件责任边界收口

## 6. 本地执行证据

- 当前修改文件：
  - [project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart)
  - [project_showcase_card_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart)
  - [project_list_filter_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_list_filter_widgets.dart)
  - [exhibition_trade_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart)
- 当前已验证：
  - `flutter test test/exhibition_mainline_flow_test.dart test/project_showcase_filter_create_refactor_test.dart test/exhibition_home_test.dart`
  - 结果：`通过`

## 7. Formal Conclusion

- 当前项目展示卡片视觉层级正式记为：
  - `primary fields enlarged`
  - `amount emphasized`
  - `time + detail action merged into one row`
  - `page file split retained`
- 后续若用户要求继续改版，不得只改代码不改文书；至少必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
