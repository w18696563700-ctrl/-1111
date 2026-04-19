---
owner: Codex frontend execution receipt
status: pass
stage: factory_detail_optimization_remediation
package: A_frontend
updated_at_local: 2026-04-18
---

# 《工厂详情优化修复 frontend execution receipt V1.1》

## 1. 修改文件清单

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

## 2. 当前对象内已完成的前端收口

- 工厂详情 live path 继续走 `EnterpriseDetailRelayoutSurface`，正文独立“企业画册”区块不再对 `factory` 渲染。
- 工厂 Hero 继续按冻结优先级消费：
  - `boardProfile.showcaseImageUrls`
  - `visualGallery.albumImageUrls`
  - fallback
- 工厂 Hero 底部摘要继续只保留：
  - 地区
  - 认证
  - 厂房面积
  - 团队规模
- 页面内继续不展示：
  - `月产能`
  - 原始英文资质状态词
  - 正文重复画册
- `cases=[]` 空态继续显示：
  - `暂无公开案例`

## 3. 本轮前端新增修复点

- 工厂“核心能力”区移除了双列结构下方额外追加的摘要 pill 行。
- 当前工厂能力区正式收口为：
  - 左列：工艺类型 + 核心产品
  - 右列：设备清单
- 设备清单继续保持：
  - 每列 3 个
  - 列内纵向排列
  - 超过后横向扩列

## 4. analyze / test 结果

已执行：

```bash
cd apps/mobile
flutter analyze \
  lib/features/exhibition/data/enterprise_hub_consumer_layer.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_company_hero_overlay.dart \
  lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
flutter test test/enterprise_hub_routes_test.dart --plain-name "factory detail route uses hero overlay, hides duplicate gallery, and renders empty-case copy"
```

结果：

- `flutter analyze`: PASS
- `flutter test ...factory detail route uses hero overlay...`: PASS

## 5. 当前剩余非前端阻断项

- 云端 `8080` 运行态尚未反映本轮 `BFF / Server` 修复：
  - 工厂地区真值仍显示 `四川省 / 成都市`
  - 工厂详情仍未输出展示型 `showcaseImageUrls`
  - `formal-info` app-facing 仍返回 `404`
- 这些项不属于本轮 Flutter 本地实现阻断，但会阻塞 Gate 3 / Gate 4。

## 6. 前端结论

- `A 单 / frontend bounded fix`：
  - `PASS`
- 当前可正式移交：
  - `结果校验 Agent`
- 当前不可单独宣称：
  - `全链路收口完成`
