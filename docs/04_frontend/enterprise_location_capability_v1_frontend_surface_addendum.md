---
owner: Codex 总控
status: active
purpose: Freeze the frontend surface for enterprise location capability V1, including workbench UX, detail-page consumption, map-card display rules, and failure-state handling.
layer: L5 Frontend
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/enterprise_location_capability_v1_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
---

# 企业位置能力 V1 前端承接冻结说明

## 1. 工作台交互规则

- 工作台必须同时提供两条入口：
  - `用当前位置填入`
  - `文字地址填写并解析`
- 两条入口都必须收口到同一套 `location` candidate。
- 前端只负责：
  - 发起定位
  - 收集地址文本
  - 调用 app-facing resolve
  - 预览候选位置
  - 保存到既有 `basic` 提交
- 前端不得把本地 geocode 结果长期当成正式企业位置真值。

## 2. 工作台显示规则

- 有 `resolved` 坐标：
  - 显示地图预览卡
  - 显示解析后的地址与行政区
- `text_only`
  - 显示地址文本
  - 明确当前仅保存文本地址，尚未解析为地图点位
- `failed`
  - 显示待校正或解析失败提示
- `not_provided`
  - 显示受控空态

## 3. 详情页展示规则

- 三类详情页共用一套位置展示骨架：
  - `所在地区`
  - `公开地址`
  - `服务区域`
  - `地图卡`
- `geoStatus = resolved` 且有坐标：
  - 展示真实地图卡
- `geoStatus = text_only`
  - 只展示地址卡
  - 不得出现假地图
- `geoStatus = failed`
  - 展示待校正说明
- `not_provided`
  - 展示受控空态

## 4. 视觉规则

- 地图卡必须从属于位置模块，不得变成页面主导物。
- 服务区域与企业地理位置必须并列但分开表达。
- 无坐标时不得保留可点击地图按钮或看似可用的底图。

## 5. Runtime truth rule

- 前端只消费：
  - `workbench.basic.location`
  - `detail.location`
- 不再长期依赖：
  - 旧的 `province / city / address` 零散字段自行拼装地图显示

## 6. Anti-revert

- 后续线程不得再把企业位置能力退回成：
  - 只有 `详细地址辅助动作`
  - 只有 `用当前位置回填`
  - 只有“地图能力暂未接通”的永久占位
- 若 provider gate 未成立：
  - 必须保持真实降级
  - 不得伪装地图可用
