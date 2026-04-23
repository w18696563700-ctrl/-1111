---
owner: Codex 总控
status: frozen
purpose: >
  Reassess whether Trading IM may reopen the same bounded object chain for a
  docs-only `participant-card minimum + formal-info live alignment` package,
  while granting neither Server/BFF implementation unlock nor direct runtime
  execution.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_round_a_stage_gate_checklist_addendum.md
  - docs/00_ssot/d16_d18_core_mobile_participant_card_stage_gate_checklist_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - apps/server/src/modules/trading_im/trading-im.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-formal-info.query.service.ts
  - apps/bff/src/routes/trading_im/trading-im.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-formal-info.service.ts
---

# 《Trading IM participant-card minimum / G0B reentry 阶段门禁核查表》

## 1. Scope

- 本文书只回答：
  - `Trading IM Round A` 是否允许针对 `participant-card minimum` 重新进入 docs-only 冻结链
  - 是否允许继续 authoring `L0/L2/L3/L4` 最小文书
  - 当前是否允许直接开始 `apps/server` / `apps/bff` implementation
- 本文书不是：
  - implementation unlock grant
  - implementation dispatch send
  - direct runtime execution
  - result verification pass
  - release judgment

## 2. Reentry Object

- 当前 reentry 对象固定为：
  - `Trading IM Round A / participant-card minimum`
  - `formal-info live alignment as existing-path closure`
- 当前对象不是：
  - general chat expansion
  - stranger DM
  - group chat
  - order/contract/dispute full conversation
  - public credit scoring surface
  - participant full profile center

## 3. Passed Gates

- same-object continuity gate：
  - 通过
  - 当前对象仍严格挂在 `Trading IM Round A` 下，不是 successor-object switch。
- bounded-scope gate：
  - 通过
  - 当前只补最小只读 `participant-card`，不重开聊天主线。
- existing-anchor gate：
  - 通过
  - 现有仓库已经存在：
    - bid-thread participant relation anchor
    - enterprise listing summary anchor
    - enterprise review summary anchor
    - target-enterprise formal-info query anchor
- no-second-truth gate：
  - 通过
  - 当前目标明确为 query projection，不新建 `participant_card` table，不发明第二状态机。
- formal-info-path continuity gate：
  - 通过
  - 本轮明确复用既有 `formal-info` canonical path，不重造第二 `formal-info` route family。

## 4. Failed Gates

- Server implementation unlock gate：
  - 未通过
  - 当前只允许 docs-only 续冻，不允许直接进入 Server implementation。
- BFF implementation unlock gate：
  - 未通过
  - 当前只允许 docs-only 续冻，不允许直接进入 BFF implementation。
- cloud runtime closure gate：
  - 未通过
  - live `formal-info` 现态仍是 router `404`，尚未闭合为受控业务响应。
- contract materialization gate：
  - 未通过
  - 当前还没有 `participant-card` 的正式 L2 contract 冻结与生成物同步。

## 5. Veto Gates

- `No trading flow implementation` 仍然有效。
- 不得把 docs-only reentry 偷换成 implementation unlock。
- 不得在未冻结 `participant-card` schema 前直接改 `apps/server` / `apps/bff`。
- 不得把 `formal-info` live gap 伪装成“代码已存在即可视为闭合”。

## 6. Current Fact Base

- local source fact：
  - `formal-info` 的 Server/BFF path 本地源码已存在。
  - `participant-card` path / contract / query service 当前不存在。
- runtime fact：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
    当前 live 仍返回 router `404`。
- current thread participant fact：
  - 当前 thread detail 只暴露 `participantRole + organizationId`。
  - 当前未暴露 company summary / review summary / formal-info summary。

## 7. Reentry Judgment

- 当前结论：
  - `G0B reentry stage gate checklist = 通过`
- 当前通过的仅限：
  - `Go for L0 truth freeze authoring`
  - `Go for L2 contracts freeze authoring`
  - `Go for L3 backend truth freeze authoring`
  - `Go for L4 BFF surface freeze authoring`
- 当前不得偷换成：
  - `Go for Server implementation`
  - `Go for BFF implementation`
  - `Go for cloud alignment execution`

## 8. Formal Conclusion

- `Trading IM participant-card minimum / G0B reentry = Pass for docs-only freeze continuation`
- `Go for L0/L2/L3/L4 docs-only freeze`
- `No-Go for Server implementation`
- `No-Go for BFF implementation`
- `No-Go for result verification`
- `No-Go for release-prep`

## 9. Next Unique Action

- 下一步唯一动作：
  - 输出 `participant-card minimum` 的：
    - L0 truth freeze
    - L2 contract freeze
    - L3 backend truth freeze
    - L4 BFF surface freeze
