---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption rule for displaying project publish time on
  exhibition home project recommendation cards.
layer: L5 Flutter App
freeze_date_local: 2026-04-30
---

# Project List PublishedAt Home Card Frontend Note

## 1. UI Placement

展览首页项目推荐卡片在底部动作行左侧显示：

- `发布 M月D日 HH:mm`

位置对应项目卡片信息宫格下方、`进入项目详情` 左侧。

## 2. Consumption Rule

Flutter 只消费 `publishedAt`：

- 有合法时间时展示。
- 无字段或无法解析时隐藏。
- 不用 `plannedStartAt`、`createdAt` 或本地时间兜底。

## 3. Boundary

本轮不改：

- 首页 tab 结构
- 项目列表排序
- 项目详情页
- 发布流程
- 竞标和交易链路
