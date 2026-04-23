---
owner: Codex 总控
status: active
purpose: Freeze the Server implementation dispatch for `Trading IM participant-card minimum`.
layer: L0 SSOT
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/trading_im_participant_card_minimal_bounded_implementation_dispatch_bundle_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
---

# 《Trading IM participant-card minimum Server implementation dispatch》

```text
你是后端 Agent（当前仓库 Server 侧），本轮不是重开 trading_im 全量扩展，只实现 `participant-card minimum` 已冻结好的最小只读 query。

【唯一目标】
1. materialize `GET /server/trading-im/bid/thread/participant-card`
2. 先证明当前查看者是 admitted thread participant
3. 只输出 frozen contract 中的:
   - participantRole
   - enterpriseSummary
   - reviewSummary
   - formalInfoSummary
4. 不新增 `participant_card` table / write command / lifecycle

【强制阅读】
- docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
- docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
- docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
- apps/server/src/modules/trading_im/**
- apps/server/src/modules/enterprise_hub/**

【只允许处理的范围】
- apps/server/src/modules/trading_im/**
- 与 enterprise summary / review summary / bounded formal summary projection 直接相关的最小 supporting touch

【禁止事项】
- 不得新建第二聊天状态机
- 不得新增 participant_card persistence
- 不得输出联系方式 / 原始评价 / 风险分 / 附件真值
- 不得接管 formal-info 全页读取路径

【完成标准】
- `GET /server/trading-im/bid/thread/participant-card` 本地可读
- admitted participant 可读，非 admitted fail-close
- targeted test 通过
```
