---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L5 Flutter consumption boundary for `项目名称申请查看`,
  covering the home-card summary swap, public masked-title consumption, the
  request CTA, and the bounded messages review-thread handoff.
layer: L5 Frontend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/02_backend/project_name_access_request_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_name_access_request_bff_surface_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
---

# 《项目名称申请查看 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖 Flutter 消费面：
  - 首页红框项目卡片
  - 公域项目列表
  - 公域项目详情
  - 消息楼 `项目沟通` lane
  - owner 受控 review thread 页面 / sheet
- 本冻结单不覆盖：
  - generic chat input
  - local permission engine
  - owner private workspace overhaul

## 2. Home Card Consumption

- 首页红框卡片当前正式固定为展示：
  - `搭建地`
  - `项目面积`
  - `进场时间`
- Flutter 消费字段固定为：
  - `cityName`
  - `areaSqm`
  - `plannedStartAt`
- 当前明确禁止：
  - 继续把摘要位当成纯文案 summary
  - 为这 3 个字段新造本地真义

## 3. Public Title Consumption

- 公域项目列表与详情页当前必须优先消费：
  - `displayTitle`
  - `nameAccess`
- 当前正式写死：
  - 当 `nameAccess.status != visible` 时
  - Flutter 只显示 `displayTitle`
  - Flutter 不得回退到本地 `title / exhibitionName / brandName`

## 4. Request CTA Consumption

- 未授权 non-owner 的详情页当前允许展示：
  - `申请查看项目名称`
- CTA enablement 只取决于：
  - `nameAccess.canRequest`
- 状态文案只允许承接：
  - `requestable`
  - `pending`
  - `rejected`
- Flutter 当前不得：
  - 本地推断 owner 权限矩阵
  - 本地伪造审批通过结果

## 5. Messages Lane Consumption

- `MessagesPage` 的 `项目沟通` lane 当前允许出现：
  - `project_name_access_thread` interaction card
- interaction card 当前只允许承接：
  - requester / counterpart summary
  - seed summary
  - updatedAt
  - 进入 review thread 的 handoff

## 6. Review Thread Consumption

- review thread 当前允许使用线程式页面壳，但正式固定为：
  - no composer
  - no free typing
  - no attachment send
  - no read receipt / typing / online
- 页面只允许消费：
  - `system_seed`
  - `system_notice`
- owner-side 当前允许在受控卡片上打开：
  - approve / reject sheet
- requester-side 当前只允许查看申请状态与结果，不允许在此页继续衍生私聊

## 7. Owner Fallback Entry

- 为避免消息楼以外没有回收口，Flutter 当前允许在 owner 私域项目页增加一个 bounded fallback：
  - `项目名称查看申请`
- 该入口只允许消费：
  - `GET /api/app/my/projects/{projectId}/name-access/pending`
- 它不是主入口，主入口仍是消息楼会话化承接

## 8. Frontend No-Go

- 不得 direct-to-Server
- 不得 local chat truth
- 不得 local review state machine
- 不得把 review thread 做成 generic DM center
- 不得继续读旧 `message/index`

## 9. Stage Conclusion

- `项目名称申请查看` 的 L5 frontend consumption boundary 现正式冻结。
- 当前已形成：
  - `L0 -> L5` Day-1 完整文书链
- 下一步只允许：
  - `Go for gate judgment and implementation sequencing`
- 当前仍：
  - `No-Go for implementation`

