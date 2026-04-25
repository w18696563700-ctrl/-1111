---
title: Project Counterparty Rating Avatar Sheet Day11 Day12 Status Correction Receipt
status: receipt
execution_date_local: 2026-04-25
scope:
  - planned 2026-05-11 avatar subject card
  - planned 2026-05-12 rating UI
---

# 《头像主体卡 / 评价 UI Day-11 Day-12 状态更正回执》

## 1. 总控结论

- `2026-05-11 头像主体卡`：本地 Flutter 工程闭环已完成。
- `2026-05-12 评价 UI`：原“提交仍走旧 rating/submit，只带 orderId”的判断已过期。
- 当前项目沟通头像主体卡的评价提交走新路由：
  - `POST /api/app/project-counterparty-rating/submit`
- 当前提交 payload 已包含：
  - `orderId`
  - `projectId`
  - `rateeOrganizationId`
  - `scoreLabel`
  - `commentText`

## 2. Flutter 落点

- 头像点击入口：
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart`
  - `CircleAvatar` 外层 `InkWell` 调用 `onOpenSubjectCard`
- 打开主体卡：
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
  - `_openSubjectCard` 调用 `showCounterpartConversationSubjectSheet`
- 主体卡与评价 UI：
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart`
  - 展示对方主体、组织 ID、当前项目、评价订单、项目状态
  - 未结束项目展示不可评价原因
  - 已结束且 `ratingEntry.canRate` 时展示星级、标签、备注、提交按钮
- 新提交链路：
  - `CounterpartConversationConsumerLayer.submitProjectCounterpartyRating`
  - canonical path: `/api/app/project-counterparty-rating/submit`

## 3. 旧 rating 页面边界

- `apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart` 仍存在旧 `RatingEntryPage`。
- 旧页面仍走 `/api/app/rating/submit`，只带 `orderId`。
- 该旧页面不是本轮头像主体卡入口，不得用于否定 Day-12 新评价 UI 链路。
- 当前判断应区分：
  - 订单详情旧评价入口：`/api/app/rating/submit`
  - 项目沟通头像主体卡双方互评：`/api/app/project-counterparty-rating/submit`

## 4. 验证

- `cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart`
  - 9 passed
- `cd apps/bff && node --test test/project-counterparty-rating-transport.test.cjs`
  - 5 passed
- `cd apps/server && node --test test/project-counterparty-rating.test.cjs`
  - 6 passed

## 5. Remaining Gate

- 本回执只证明本地 Flutter/BFF/Server 工程链路。
- 未完成真实登录态云上 completed-order 提交验收。
- 未完成 Computer Use 双账号点击验收。
- 未完成真实提交后信用 shadow/ledger 云上数据核验。
