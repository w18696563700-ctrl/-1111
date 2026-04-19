---
title: rating entry submit minimal truth E5 addendum
status: frozen
owner: codex-control
last_updated: 2026-04-12
---

# 《E5 评价入口与提交最小真值补充冻结单》

## 1. Purpose

本补充单只解冻 `GET /api/app/rating/entry` 与 `POST /api/app/rating/submit`
的最小 `Server` truth/command 闭环。

## 2. Allowed Truth Surface

- `Server` 首次引入最小 `rating` truth carrier。
- 当前只允许：
  - buyer 组织范围内的 completed 订单评价入口读取
  - 同一评价 carrier 的单次提交
- 当前只允许状态迁移：
  - `eligible -> submitted`

## 3. Persistence And Projection

- 当前最小持久化继续复用：
  - `public.ratings`
- 当前最小可读状态只承认：
  - persisted `draft` -> app-facing `eligible`
  - persisted `submitted` -> app-facing `submitted`
- `my-project.privateProgress.evaluationStatus` 允许最小承接：
  - formally completed 且最新 rating 为 `submitted` 时返回 `submitted`
  - formally completed 且未提交时返回 `eligible`
- `workbench.extension_boundary.ratingEntryState` 允许最小承接：
  - `controlled_unavailable`
  - `eligible`
  - `submitted`

## 4. Hard Boundary

- 不批准：
  - rating list
  - rating detail
  - rating history
  - rating workspace
  - rating template
  - rich text / image upload
  - resubmit / withdraw / dispute linkage
  - second review or moderation workflow

## 5. Error Boundary

- entry 不可达统一返回：
  - `RATING_ENTRY_UNAVAILABLE`
- submit body 非法统一返回：
  - `RATING_SUBMIT_INVALID`
- submit 非法状态统一返回：
  - `RATING_INVALID_STATE`
