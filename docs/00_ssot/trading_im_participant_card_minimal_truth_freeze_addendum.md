---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L0 truth boundary for Trading IM participant-card, admitting
  only a bounded read-only company card for admitted bid-thread participants and
  explicitly excluding general profile expansion, direct credit scoring surfaces,
  and any second truth owner.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_g0b_reentry_stage_gate_checklist_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
---

# 《Trading IM participant-card minimum 真相冻结补充单》

## 1. Scope

- 本冻结单只覆盖 `Trading IM participant-card minimum`。
- 本轮唯一定位固定为：
  - 挂在 `projectId + bidId + participantOrganizationId` 上的只读合作方名片
  - 服务于 `bid thread` 内头像 / 公司名点击后的受控摘要查看
  - 其目标是让 admitted thread participant 在平台内看到最小可信公司摘要
- 本轮不是：
  - profile building takeover
  - enterprise public detail full-page replacement
  - public credit scoring center
  - transaction history center
  - generic company card framework

## 2. Business Anchor

- 当前 canonical business anchor 固定为：
  - `projectId`
  - `bidId`
  - `participantOrganizationId`
- `participant-card` 只对当前 bid-thread admitted participants 成立。
- 它不是裸 `organizationId` 公共资料读取入口。

## 3. Visibility Boundary

- 可查看者最小范围固定为：
  - current actor is an admitted participant of the targeted `projectId + bidId` thread
- 不得查看者：
  - unrelated viewer
  - unrelated bidder
  - unrelated buyer organization
  - forum actor without thread relation
  - app-facing Admin operator

## 4. Data Family

- 当前允许展示的数据族仅限：
  - thread participant relation
  - enterprise summary
  - bounded review summary
  - bounded formal-info summary
- 当前允许展示的最小语义：
  - 这是谁
  - 当前在此 thread 中扮演什么角色
  - 其公开企业摘要是什么
  - 其 bounded review summary 是什么
  - 其最小正式认证摘要是什么

## 5. Excluded Scope

- 本轮明确排除：
  - full enterprise detail page
  - contact info expansion
  - live chat profile center
  - public credit score / risk score
  - payment / billing / guarantee / deposit
  - full cooperation-history list
  - order / contract / dispute private data
  - editable profile surface

## 6. Formal-Info Relation

- `participant-card` 中的 formal-info 只允许使用 bounded summary。
- 它必须来源于目标 participant organization 的 formal truth。
- 它不得读取当前查看者自己的 certification truth。
- 它不得重造第二 `formal-info` route family。
- 既有 canonical path 继续保留：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

## 7. Truth Ownership

- Server remains the only truth owner for:
  - admitted thread participant judgment
  - target participant organization resolution
  - enterprise summary selection
  - bounded review summary selection
  - bounded formal-info summary selection
- BFF only owns transport, shaping, and controlled error mapping.
- Flutter only consumes the projection.

## 8. Persistence Boundary

- `participant-card` is query projection only.
- 本轮明确 No-Go：
  - `participant_card` table
  - participant-card write command
  - participant-card state machine
  - participant-card audit log as a second object family

## 9. Formal Conclusion

- `Trading IM participant-card minimum` 作为 `Round A` 的 bounded read-only child object 现正式冻结。
- 当前状态：
  - `Go for L2 contracts freeze`
  - `Go for L3 backend truth freeze`
  - `Go for L4 BFF surface freeze`
  - `No-Go for implementation`
