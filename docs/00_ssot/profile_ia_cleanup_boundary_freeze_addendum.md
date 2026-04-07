---
owner: Codex 总控
status: frozen
purpose: Freeze the single bounded `Profile IA cleanup` package so the current `我的楼 / 我的公司 / 认证` surfaces may be simplified around human-readable naming, non-duplicated actions, and stable handoff semantics without drifting into profile-editing, OCR, or review-system expansion.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_sections.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_widgets.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_member_management_sheet.dart
  - apps/mobile/lib/features/profile/presentation/profile_page_support.dart
  - apps/mobile/lib/features/profile/presentation/profile_visible_copy.dart
  - apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart
  - apps/server/src/modules/profile/profile-certification-write.service.ts
  - apps/server/src/modules/review/organization-review.controller.ts
---

# `Profile IA cleanup` 边界冻结单

## 1. Scope

- 本轮唯一对象只限：
  - `我的楼`
  - `个人资料`
  - `我的公司`
  - `公司与组织`
  - `公司认证与我的身份`
  - `成员管理`
- 本轮唯一目标只限：
  - 清理用户当前看不懂的命名
  - 清理同义重复动作
  - 对齐入口名称与落地页标题
  - 修正“看起来像能点、实际上没有对应含义”的入口语义
- 本轮明确不是：
  - 昵称编辑实现
  - 头像上传实现
  - 营业执照上传实现
  - OCR 识别
  - 身份证上传或实名包
  - 自动审核 / 风控判真 / 审核后台
  - `contracts / server / bff` 业务边界改动

## 2. Current Accepted Baseline

- `我的楼` 当前顶部摘要卡是主个人入口，点击后进入个人资料页，这条主 handoff 已存在。
- 个人资料页顶部 `当前用户` 卡当前只是摘要展示，不是资料编辑器，也没有昵称/头像编辑实现。
- `我的公司` 页当前存在两套同义动作：
  - 一排 inline 按钮
  - 一组 `继续办理` 列表
- `组织办理` 与 `组织承接` 当前同时存在，命名不统一，也不属于用户语言。
- `认证与成员身份` 当前把两层概念混写在一个入口里，解释成本高。
- `组织成员` 当前真实能力是：
  - 查看成员列表
  - 做最小角色调整与禁用
  - 它不是泛化的组织治理后台
- 企业认证当前仍是手填 `legalName / uscc / licenseFileId` 的最小提交流，上传/OCR/审核简化不属于本包。

## 3. Execution Ownership And Write Boundary

- 本轮唯一执行者固定为：
  - `Frontend Agent`
- 本轮唯一允许写入范围固定为：
  - `apps/mobile/lib/features/profile/presentation/**`
  - `apps/mobile/lib/features/profile/navigation/**`
- 本轮允许的变更类型只限：
  - route wiring refinement
  - `onTap` 语义修正
  - 页面标题文案修正
  - 列表结构重组
  - section 标题与辅助文案修正
  - 删除重复动作
- 本轮明确不得新增：
  - API
  - consumer contract
  - 上传流
  - 新字段
  - 新的 profile 编辑命令

## 4. Frozen IA Decisions

### 4.1 个人入口语义

- `我的楼` 顶部用户卡继续作为：
  - 唯一主个人入口
- 该入口必须明确表现为：
  - 可点击
  - 会进入 `个人资料`
- `个人资料` 页顶部 `当前用户` 卡冻结为：
  - 个人摘要卡
  - 非编辑器
  - 非头像上传入口
- 本轮必须消除的误导固定为：
  - 不得让用户以为点击头像或摘要卡即可立刻编辑昵称与头像
- 若昵称/头像尚未开放，本轮只允许通过 IA 表达澄清：
  - `当前资料摘要`
  - 或等价的人话提示
- 本轮不得伪造：
  - `编辑个人资料`
  - `上传头像`
  - `修改昵称`

### 4.2 我的公司页删重规则

- `我的公司` 页必须只保留：
  - 一套主动作
  - 一套辅助导航列表
- 当前冻结的结构规则是：
  - `提交认证 / 重新提交认证` 可保留为唯一 primary CTA
  - `公司与组织 / 公司认证与我的身份 / 成员管理` 只允许保留在一组列表里
- 当前必须删除的重复结构是：
  - 与下方列表表达同义的一排 inline 按钮
- 当前明确不允许把删重做成：
  - 同样的动作从按钮换成 chip 再出现一次
  - 标题不同但跳转相同的假删重

### 4.3 命名统一映射

- 本轮冻结后的用户语言映射如下：
  - `组织办理` -> `公司与组织`
  - `组织承接` -> `公司与组织`
  - `认证与成员身份` -> `公司认证与我的身份`
  - `组织成员` -> `成员管理`
- 当前补充冻结如下：
  - `办理入口` -> `可进行的操作`
  - `切换组织` -> `切换当前公司/组织`
- 以上映射适用于：
  - 页面标题
  - section 标题
  - 列表项标题
  - CTA 文案
  - 空态引导文案

### 4.4 标题一致性规则

- 同一个概念在不同页面不得出现：
  - 入口叫 A
  - 落地页标题叫 B
  - 按钮再叫 C
- 当前冻结后的标题关系如下：
  - `我的楼` 中进入组织相关能力的入口标题统一为 `公司与组织`
  - `我的公司` 页里指向该页的动作标题也统一为 `公司与组织`
  - 该落地页页面标题统一为 `公司与组织`
  - 成员相关入口统一为 `成员管理`
  - 认证相关入口统一为 `公司认证与我的身份`

### 4.5 用户理解模型

- 本轮冻结后的用户理解模型必须收口为 5 个问题：
  - 我是谁
  - 我的公司是什么
  - 我在公司里是什么身份
  - 这家公司是否完成认证
  - 我能否查看和管理成员
- 本轮不得继续把以下概念混成一团：
  - 公司信息
  - 组织切换
  - 认证状态
  - 成员身份
  - 成员管理

## 5. Explicit In-scope

- `我的楼` 顶部卡片的点击语义澄清
- `个人资料` 页顶部摘要卡的非编辑语义澄清
- `我的公司` 页重复动作删除
- `我的公司 / 公司与组织 / 公司认证与我的身份 / 成员管理` 的命名统一
- 页面标题、列表项标题、按钮标题、空态 CTA 标题的一致化
- 保留项 / 删除项对照表输出要求

## 6. Explicit Out-of-scope

- 昵称编辑
- 头像上传
- 个人资料编辑 command
- 营业执照上传
- OCR 预填
- 身份证上传
- 个人实名
- 自动审核
- 风险判真
- Admin 审核台
- `contracts / server / bff` truth 修改
- 企业认证流程简化本体

## 7. Frozen Keep-Remove Table

- 保留：
  - `我的楼` 顶部用户卡作为个人入口
  - `我的公司` 页 company summary
  - `提交认证 / 重新提交认证` primary CTA
  - 一组统一命名后的辅助导航列表
- 删除：
  - `我的公司` 页与辅助导航列表同义的 inline 按钮组
  - `组织办理 / 组织承接` 并行存在
  - `组织成员` 这一内部味过重的用户标签
- 替换：
  - `认证与成员身份` 用 `公司认证与我的身份` 替换
  - `组织成员` 用 `成员管理` 替换

## 8. Acceptance Standard

- 用户首次进入 `我的楼` 时，必须能区分：
  - `个人资料`
  - `我的公司`
  - `公司与组织`
  - `公司认证与我的身份`
  - `成员管理`
- `我的公司` 页不得再出现同义重复动作。
- 同一跳转链路上，不得再出现：
  - 入口名与页面标题不一致
  - 页面标题与 CTA 名称不一致
- 本轮交付后，不得新增任何超出 `Profile IA cleanup` 的功能债。

## 9. Independent Review Requirement

- 下一轮独立复核必须至少包含：
  - 页面入口矩阵
  - 保留项 / 删除项对照表核对
  - 跳转前后标题一致性核对
  - 关键页面截图证据
  - 非功能越界核对

## 10. Formal Conclusion

- 当前正式结论固定为：
  - `Profile IA cleanup` 已完成单包边界冻结
  - 当前只允许进入前端单包执行
  - 当前不允许扩到昵称头像、OCR、身份证、审核系统
- 当前 freeze type 固定为：
  - `Profile IA cleanup boundary freeze only`

## 11. Next Unique Action

- 当前唯一下一步固定为：
  - 向 `Frontend Agent` 下发 `Profile IA cleanup` 执行口令
