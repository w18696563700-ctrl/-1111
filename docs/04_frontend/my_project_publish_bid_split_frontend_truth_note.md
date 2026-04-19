---
owner: Codex 总控
status: frozen
purpose: >
  Record the Flutter-side classification repair for My Project so owner-side
  published projects are not mixed with supplier-side bid records before the
  dedicated my-bids backend surface is opened.
layer: L5 Frontend
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/04_frontend/bid_award_bridge_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
---

# 《我的项目：我的发布 / 我的竞标分类前端承接记录》

## 1. Current Allowed Surface

- Flutter `我的项目` 当前先拆成两个一级分类：
  - `我的发布`
  - `我的竞标`
- `我的发布` 继续消费现有 `GET /api/app/my/projects`。
- `我的竞标` 当前只展示受控未接通状态，不伪造竞标列表。

## 2. Boundary

- 当前不得把 `GET /api/app/my/projects` 的 owner 项目伪装成 supplier bid records。
- 当前不得在 Flutter 本地编造 `my bids` DTO、状态机或持久化列表。
- 完整 `我的竞标` 需要后续正式打开 `GET /api/app/my/bids` 的合同、BFF 和 Server truth。

## 3. User-Facing Conclusion

- 先完成导航分类，避免注册用户同时是发布方和供应商时迷路。
- 真正的竞标历史列表仍需要云端接口补齐后才能展示真实记录。
