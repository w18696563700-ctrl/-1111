---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side surface delta for the current factory-detail remediation round, including hero deduplication, showcase-first hero rendering, four-metric summary rules, and case/qualification copy fixes.
layer: L3 Frontend
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
  - docs/04_frontend/enterprise_display_album_and_target_enterprise_info_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
---

# 工厂详情优化修复 Frontend Surface 冻结单 V1.1

## 1. Scope

- 当前前端只冻结：
  - 工厂详情 Hero 去重与 overlay 结构
  - 工厂 Hero 图源优先级消费
  - 工厂正文企业画册隐藏
  - 首屏四指标缺值规则
  - `月产能` 移除
  - 核心能力双列与设备清单硬规则
  - 资质摘要与案例空态文案修正

## 2. Hero Rule

- 工厂详情 Hero 当前必须对齐公司同类 overlay 结构。
- Hero 当前承担：
  - 首图主视觉
  - 厂名
  - badge / 认证态
  - 首屏四指标

## 3. Hero Source Rule

- 工厂详情 Hero 消费优先级固定为：
  1. `showcaseImageUrls`
  2. `visualGallery.albumImageUrls`
  3. fallback

正式裁决：

- 前端不得直接消费 `showcaseImageFileAssetIds`。
- 若当前云端仅返回 `fileAssetId` 而未返回展示 URL，则前端不得自行拼接临时图片地址。

## 4. Dedup Rule

- 工厂详情正文独立 `企业画册` 区块必须隐藏。
- 图下白卡不再重复承载首屏摘要信息。
- 页面内不再出现 `月产能`。

## 5. Hero Summary Rule

- 首屏底部安全区当前只允许：
  - 地区
  - 认证
  - 厂房面积
  - 团队规模
- 无值项隐藏并自动重排，不留空卡槽。

## 6. Capability Rule

- 核心能力当前按双列结构处理：
  - 左列：工艺类型 + 核心产品
  - 右列：设备清单
- 设备清单每列固定 `3` 个，超过后横向扩列。

## 7. Copy Rule

- 资质摘要不允许出现 `approved` 等英文状态词。
- `cases=[]` 时展示：
  - `暂无公开案例`
- 不允许把“无案例”写成“未接通”。

## 8. Formal Conclusion

- 当前前端正式职责固定为：
  - 工厂详情结构去重
  - 工厂 Hero 图源按冻结优先级消费
  - 首屏四指标与缺值规则落实
  - 文案纠偏与核心能力重排
