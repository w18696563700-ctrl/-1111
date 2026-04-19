---
owner: Codex 总控
status: frozen
purpose: 冻结“我的楼”首页摘要对象、页级状态对象、纯导航对象与下游功能状态卡的正式统计口径，并限定本轮文案纠偏范围。
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_support.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_sections.dart
  - apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart
  - apps/mobile/lib/features/profile/presentation/profile_personal_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/forum/forum_author_profile_pages.dart
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/server/src/modules/profile/profile.controller.ts
---

# 《我的楼口径修订裁决单 V1》

## 1. 裁决结论

- 经复核，现有资料整体可信，原有大方向判断无需翻案。
- 当前需要修订的重点不是功能真伪，而是：
  - 对象分类
  - 统计口径
  - 文案表达
  三者的对齐方式。
- 自本裁决生效后，“我的楼”相关内容统一按四类对象口径管理，并附一项文案纠偏范围。
- 禁止继续将首页摘要对象、页级状态对象、纯导航对象与下游功能状态卡混写混算。

## 2. 四类对象口径

### 2.1 页级状态元素

- 指首页页面级状态表达对象。
- 当前共 `2` 个：
  - 页头状态线
  - 顶部状态条

### 2.2 首页入口摘要状态

- 指首页入口行中带状态摘要的对象。
- 当前共 `9` 个：
  - 我的公司
  - 成员管理
  - 我的会员
  - 我的信用与约束
  - 我的申诉记录
  - 支付与账单状态
  - 我的项目
  - 项目工作台
  - 我的论坛

### 2.3 纯导航入口

- 指首页中仅承接跳转说明、不承担状态表达的入口。
- 当前共 `2` 个：
  - 企业展示入驻
  - 设置

### 2.4 下游功能状态卡

- 指分布于各下游页面或页内 sheet 中的功能状态卡。
- 当前共 `11` 张：
  - 个人资料
  - 我的公司
  - 公司与组织
  - 公司认证与我的身份
  - 成员管理
  - 我的会员
  - 我的信用与约束
  - 支付与账单状态
  - 我的申诉记录
  - 我的论坛
  - 设置
- 该口径独立于首页可见对象口径，不得与首页统计口径合并计算。
- 其中 `成员管理` 不同渲染态下仍视为同一张卡，不得重复计数。

## 3. 首页统计正式口径

- 首页可见对象共 `13` 个，其中：
  - `2` 个页级状态元素
  - `9` 个首页入口摘要状态
  - `2` 个纯导航入口
- 如仅统计带状态的对象，则为 `11` 个。
- 禁止将该口径表述为：
  - `首页 11 个功能入口`

## 4. 文案纠偏范围

- 本轮仅冻结以下两项文案纠偏，不扩大到其他对象：

### 4.1 个人资料

- 统一表述为：
  - `简介入口当前未开放`
- 禁止表述为：
  - `简介能力未做`
  - `简介能力不存在`

### 4.2 我的论坛

- 统一表述为：
  - `我的论坛页不承接公域作者主页`
- 禁止表述为：
  - `作者主页未做`
  - `整个 app 没有作者主页`

## 5. 本轮不做事项

- 不推翻原有整体判断。
- 不新增后端、BFF、前端能力。
- 不把首页对象与下游功能状态卡混算。
- 不把文案纠偏扩大为全站完成度重评。

## 6. 执行边界

- 总控：
  - 发布口径裁决。
- 文书冻结 Agent：
  - 按本裁决生成正式表稿。
- 前端 Agent：
  - 仅处理已冻结文案纠偏。
- BFF / 后端 Agent：
  - 本轮只做真源核对，不扩功能。
- 结果校验 Agent：
  - 分别校验首页对象口径与下游功能状态卡口径。
- 联调发布 Agent：
  - 本轮不进入发布动作。

## 7. Formal Conclusion

- 前一版材料可以作为冻结底稿入库。
- 但必须先经过本裁决定义的：
  - 四类对象口径修订
  - 文案纠偏范围冻结
  才能进入正式稿。

## 8. 当前下一步唯一动作

- 当前阶段完成度：
  - `口径裁决 closure 完成`
- 当前下一步唯一动作：
  - 冻结《我的楼对象口径与文案准确性总表 V1》
- 下一步执行角色：
  - `总控文书冻结`
- 下一步进入条件：
  - 本裁决单已冻结，不再继续讨论首页对象与下游功能状态卡的混算问题
