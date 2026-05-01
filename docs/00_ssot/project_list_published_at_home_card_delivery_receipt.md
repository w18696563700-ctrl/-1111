---
owner: Codex 总控
status: delivered
purpose: Record the bounded implementation, cloud deployment, and validation
  receipt for showing project publish time on exhibition home project cards.
layer: L0 SSOT
receipt_date_local: 2026-04-30
---

# Project List PublishedAt Home Card Delivery Receipt

## 1. Scope

本轮只完成展览首页项目卡片的公开发布时间显示：

1. Server `ProjectPresenter.toShowcaseListItem` 输出 `publishedAt`。
2. BFF `GET /api/app/project/list.items[]` 校验并透传 `publishedAt`。
3. Flutter 首页项目卡片在底部动作行左侧显示 `发布 M月D日 HH:mm`。

## 2. Cloud Release

Rollback target:

- Server: `/srv/releases/server/20260430151108-payment-finance-day10-18`
- BFF: `/srv/releases/bff/20260430205400-route-target-canonicalpath-bff/apps/bff`

New active runtime:

- Server: `/srv/releases/server/20260430205647-project-list-published-at`
- BFF: `/srv/releases/bff/20260430205647-project-list-published-at/apps/bff`

Runtime status after switch:

- `systemctl is-active exhibition-server = active`
- `systemctl is-active exhibition-bff = active`

## 3. Validation

Local regression:

- `npm --prefix apps/bff run build`
- `npm --prefix apps/server run build`
- `node --test apps/bff/test/project-showcase-filter-create-refactor.test.cjs`
- `node --test apps/bff/test/project-detail-bid-candidates.test.cjs`
- `node --test apps/bff/test/project-lifecycle.test.cjs`
- `node --test apps/server/test/project-showcase-public-filtering.test.cjs`
- `flutter test test/exhibition_home_test.dart`

Cloud route smoke through the approved tunnel:

- `GET http://127.0.0.1:8080/api/app/project/list?page=1&pageSize=1`
- observed `items[0].publishedAt = 2026-04-30T12:30:19.054Z`

## 4. Boundary

本轮未做：

1. 不新增排序、筛选或状态。
2. 不用 `createdAt` 或 `plannedStartAt` 冒充发布时间。
3. 不改项目详情、我的项目、竞标、支付或消息楼流程。
4. 不扩展首页卡片为交易工作台。

## 5. Judgment

- 更稳：Server 真源 `publishedAt` -> BFF 透传 -> Flutter 只显示。
- 更省成本：不新增接口，只补既有项目列表字段。
- 更适合当前阶段：首页信息补齐，不触碰交易状态机。
- 风险更大：只改 Flutter 或用计划进场时间伪造发布时间。
