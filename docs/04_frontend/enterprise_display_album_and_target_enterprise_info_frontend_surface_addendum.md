---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side surface for album-style enterprise detail pages, workbench brand-assets alignment, and the gated target-enterprise formal-info bottom sheet.
layer: L3 Frontend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_album_and_target_enterprise_info_bff_surface_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_sections.dart
  - apps/mobile/lib/features/profile/presentation/profile_certification_truth_support.dart
---

# 企业展示详情画册化与目标企业信息查看 Frontend Surface 冻结单

## 1. Scope

- 当前前端只冻结：
  - 三类企业详情页画册化版式
  - 工作台品牌素材录入区
  - `查看企业信息` 入口卡与底部弹层
- 当前不覆盖：
  - 筛选 UI 改造
  - 认证中心页面改造
  - Admin 审核页

## 2. Detail Layout Rule

- 三类企业详情页当前统一骨架固定为：
  - 顶部首屏
  - 企业画册横滑区
  - `查看企业信息` 入口卡
  - 核心能力摘要区
  - 详细介绍区
  - 案例展示区
  - 联系方式区

- 当前前端必须把原来的字段清单式回读改成：
  - 视觉主从分明
  - 图片优先
  - 文本按类型分组

## 3. Type-specific Projection Rule

- 公司详情当前优先突出：
  - `exhibitionTypes`
  - `serviceItems`
  - `serviceCities`
  - `maxProjectScale`
  - `qualificationDesc`

- 工厂详情当前优先突出：
  - `factoryName`
  - `processTypes`
  - `coreProducts`
  - `equipmentList`
  - `plantAreaSqm`
  - `monthlyCapacityDesc`
  - `warehouseCapability`
  - `transportCapability`
  - `deliveryRadiusDesc`

- 供应商详情当前优先突出：
  - `supplyCategories`
  - `supplyMode`
  - `coreProductsOrServices`
  - `responseSlaDesc`
  - `deliveryRange`

## 4. Visual-gallery Rule

- 当前详情页必须优先消费：
  - `visualGallery.albumImageUrls`
  - `visualGallery.source`

- 当前前端必须支持：
  - 横向滑动
  - 按工作台确认后的上传顺序展示
  - 页码或指示点
  - 头图标题区和底部信息胶囊不得拦截横向翻页手势
  - 桌面模拟器或无触摸环境下必须保留一个显式的点击翻页入口
  - 无图空态
  - 加载态
  - 图片失败态

- 当前前端不得：
  - 把 `cases[]` 标题列表伪装成企业画册
  - 直接展示裸 `fileAssetId`
  - 以视觉浮层覆盖的方式让头图在桌面调试态失去翻页能力

## 5. Target-enterprise Formal-info Entry Rule

- 详情页画册区底部必须固定出现：
  - `查看企业信息` 入口卡

- 当前入口卡规则固定为：
  - 默认可见
  - 未满足双重认证时显示锁定态
  - 满足双重认证时允许点击

- 当前前端可使用 shell/context 已有字段做显示态预判：
  - `certificationStatus`
  - `personalCertificationStatus`
  - `personalCertificationQualified`
  - `personalCertificationLockedToOtherActor`

正式裁决：

- 上述字段只用于前端入口状态与提示文案。
- 真正读取权限仍以云端返回为准。
- 前端不得仅依赖本地判断放行读取。

## 6. Bottom-sheet Rule

- `查看企业信息` 点击后当前必须以：
  - 底部弹层
  形式展示，不新开一条认证业务主路由。

- 弹层字段固定为：
  - 认证主体
  - 统一社会信用代码
  - 法定代表人
  - 企业类型
  - 住所
  - 注册资本
  - 成立日期
  - 营业期限
  - 经营范围
  - 当前认证状态

- 当前弹层展示规则固定为：
  - 可以复用现有正式认证资料字段组件风格
  - 不得跳去当前用户自己的 `公司认证与我的身份`
  - 不得展示 OCR preview 原始内容

## 7. Workbench Brand-assets Rule

- 工作台当前必须把“展示标识”升级为品牌素材组，至少承接：
  - `Logo`
  - `企业画册`

- 当前品牌素材组必须支持：
  - `Logo` 单图
  - `企业画册` 最多 `6` 张
  - 本地预览
  - 删除与替换

- 当前 factory profile 既有：
  - `showcaseImageFileAssetIds`
  继续保留在工厂画像区，
  不与统一企业画册组件混用字段名。

## 8. Non-goals

- 不改任何筛选交互
- 不把 `profile` 家族页面嵌入 `exhibition`
- 不新开第二条企业认证提交链

## 9. Formal Conclusion

- 当前前端正式职责固定为：
  - 三类企业详情页画册化
  - `查看企业信息` 入口卡与底部弹层
  - 工作台品牌素材与展示详情字段对齐
- 当前前端仍必须保持：
  - `Flutter App -> BFF` 单链路
  - 筛选功能零改动
  - 不复用当前用户私域认证页面当目标企业详情读取入口
