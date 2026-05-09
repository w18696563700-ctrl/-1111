---
owner: Codex 总控
status: active
purpose: Freeze the bounded truth for the Flutter-only clean-card refinement of factory and supplier recommendation/list cards.
layer: L0 SSOT
based_on:
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/company_detail_public_visual_refinement_truth_freeze_addendum.md
freeze_date_local: 2026-05-05
---

# 《工厂 / 供应商清爽版推荐卡与列表卡 truth freeze》

## 1. Current Minimum Closure

本轮最小闭环只覆盖 Flutter 展示层：

1. 展览首页 `工厂` 推荐卡清爽化。
2. 展览首页 `供应商` 推荐卡清爽化。
3. 工厂列表卡同步清爽化。
4. 供应商列表卡同步清爽化。

本轮不改推荐算法、企业展示真值、详情页真值、BFF、Server、OpenAPI、数据库、云端部署或云端运行配置。

## 2. Field Keep / Hide Map

| 卡片信息 | 首页工厂/供应商推荐卡 | 工厂/供应商列表卡 | 规则 |
| --- | --- | --- | --- |
| 头像 / Logo | 保留，来自 `EnterpriseHubListItem.logoUrl` | 保留，来自 `EnterpriseHubListItem.logoUrl` | 无图使用现有首字 fallback |
| 名称 | 保留，来自 `name` / factory display helper | 保留，来自 `EnterpriseCard` 现有标题 helper | 不改 business truth |
| 地区 | 保留，来自 `provinceName / cityName` | 保留，来自 `provinceName / cityName` | 去重后展示 |
| 摘要 | 保留 1-2 行，来自 `enterpriseBoardCardSummaryText` 或 `shortIntro` fallback | 保留 1-2 行，来自现有 summary helper | 无摘要用现有受控文案 |
| 右侧箭头 | 保留 | 保留 | 表示整卡可点击 |
| `优秀工厂 / 优秀供应商` badge | 隐藏 | 隐藏 | 不删除字段，只是不在卡片列表面展示 |
| 底部 chips | 隐藏 | 隐藏 | 不删除 `certificationLabel / caseCount / boardHighlights` 等字段 |
| `查看工厂详情 / 查看供应商详情` 文案 CTA | 隐藏 | 不新增 | 整卡点击进入详情 |

## 3. Interaction Freeze

- 首页工厂 / 供应商推荐卡必须保持整卡点击进入既有详情 route。
- 工厂 / 供应商列表卡必须保持整卡点击进入既有详情 route。
- 隐藏文字 CTA 后，语义上仍应保持 button / tappable card。
- 不新增二级 route，不改底部导航。

## 4. Sync Scope

同步范围：

- Home `factory` recommendation card.
- Home `supplier` recommendation card.
- Factory board list card.
- Supplier board list card.

本轮不强制同步 company list card。若共享组件会影响公司列表，必须使用定向参数 / variant，只对 `factory` 和 `supplier` 启用清爽模式。

## 5. Explicit Non-goals

- 不删除模型字段。
- 不删除接口字段。
- 不改 `EnterpriseHubListItem` parser。
- 不改 BFF / Server / OpenAPI / generated contracts。
- 不新增评分、评价、案例、资质、联系人或推荐规则。
- 不把本地截图或 widget test 当成云端发布证明。

## 6. Gate Decision

- Gate 0 read-only scan: Pass.
- Gate 1 truth freeze: Pass for Flutter-only clean-card implementation.
- Allowed next stage:
  - Flutter presentation edits under the frontend allowlist.
  - Targeted widget tests.
  - Computer Use visual verification after user hot-starts and logs in.
- Not allowed:
  - BFF / Server / contracts / DB / cloud edits.
