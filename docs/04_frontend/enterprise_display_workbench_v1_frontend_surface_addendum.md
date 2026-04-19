---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side surface for the enterprise display workbench V1 as the formal landing after enterprise-display board selection.
layer: L3 Frontend
freeze_date_local: 2026-04-10
inputs_canonical:
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
---

# 企业展示工作台 V1 Frontend Surface 冻结单

## 1. Scope

- 当前前端只冻结：
  - `/exhibition/enterprise/apply`
  - `/exhibition/enterprise/application-status`
  - 工作台内的五段式资料维护与提交面
  - shared upload corridor 在企业展示工作台内的复用

## 2. Entry Rule

- 当前工作台不是公域企业列表入口。
- `企业展示入驻` 当前先进入对应的公开企业列表。
- 工作台 route 当前允许作为：
  - 次级维护页
  - 续办页
  - 状态回跳页

## 3. Workbench Layout Rule

- 工作台首屏必须优先呈现：
  - 联系人
  - 基础资料
  - 板块画像
  - 案例资料
  - 提交动作
- 当前不得继续使用：
  - 顶部状态 chip 堆叠
  - 单独的“当前申请状态”说明卡
  - 冗长的工作台导语块

## 4. Field Rule

- 基础资料页面必须覆盖当前 contract 字段面：
  - `name`
  - `logoFileAssetId`
  - `shortIntro`
  - `fullIntro`
  - `province/city code + name`
  - `address`
  - `foundedAt`
  - `teamSizeRange`
  - `cooperationModes`
  - `contactVisible`
- 但当前前端表现必须改为：
  - `Logo` 通过真实图片上传承接
  - 不再提供 `头图` 上传位
  - 不再以裸 `FileAssetId` 文本输入框作为主 happy path
  - `fullIntro` 必须提供 `2000` 字以内的多行介绍输入
  - 基础资料内不得重复铺设认证同步卡、营业执照上传状态卡或 OCR 成功状态卡
  - `注册城市` 必须以只读选择式外观显示，并以我的公司 organization 真值回填
  - `注册城市` 当前不得点击后跳去别页，工作台内只承接真值显示
  - `成立日期` 必须以只读选择式外观显示，并以营业执照 OCR 真值回填
  - `成立日期` 当前必须按中文日期显示，日期选择器必须按中文环境呈现
  - `详细地址` 必须保留手填输入，并提供当前位置回填按钮
  - `cooperationModes` 必须以可点选标签承接，不再使用逗号分隔文本框
  - 联系人已填写时，首次上传图片或首次保存资料可自动补建草稿
  - 联系人输入本身不代表已建草稿，`创建草稿` 按钮留在联系人区底部
- 板块画像页面必须完整覆盖：
  - company profile
  - factory profile
  - supplier profile
  的现有 contract 字段
- 其中 factory 页面必须额外提供：
  - 最多 `6` 张工厂实景图上传与预览
- 案例录入页面必须覆盖：
  - title
  - exhibitionType
  - city
  - eventTime
  - summary
  - caseCoverFileAssetId
  - caseMediaFileAssetIds
  - isFeatured
- 案例图片当前必须支持：
  - 最多 `6` 张
  - 本地预览
  - 封面默认首图兜底
- 案例城市与举办日期当前必须使用点选，不再允许手写主 happy path

## 5. Certification Rule

- 工作台当前不得再用“认证不通过就整页拦截”。
- 当前必须改为：
  - 页面可进入
  - 提交按钮受 blocker 控制
  - 当提交按钮不可用时，页面内必须直接展示 blocker 中文列表，不允许只给灰按钮不解释
  - 认证失败或提交失败只给一次性反馈，不在页内重复挂结果卡

## 6. Board Rule

- 当 server 返回现有 listing boardType 时：
  - 前端必须锁定板块选择，不允许继续切换
- 只有在当前 organization 尚未建立 listing 时，前端才允许选择 `公司 / 工厂 / 供应商`

## 7. Non-goals

- 不在工作台里嵌入上传器复杂编排
- 不在工作台里提供发布/下线按钮
- 不在工作台里暴露 `个人/团队`
- 不把企业案例升级成论坛动态流

## 8. Formal Conclusion

- 当前正式结论：
  - `/exhibition/enterprise/apply` 已冻结为真正可测试的企业展示工作台页面
  - 它不是公开展示入口，而是企业展示资料维护页
  - 它当前直接复用企业认证主线与 shared upload corridor
