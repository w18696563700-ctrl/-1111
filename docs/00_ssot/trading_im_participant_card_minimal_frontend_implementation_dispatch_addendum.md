---
owner: Codex 总控
status: active
purpose: Freeze the Flutter implementation dispatch for `Trading IM participant-card minimum`.
layer: L0 SSOT
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/trading_im_participant_card_minimal_bounded_implementation_dispatch_bundle_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
---

# 《Trading IM participant-card minimum Flutter implementation dispatch》

```text
你是前端 Agent（仅本地 Flutter），本轮只做 bid thread 内头像 / 公司名点击后的只读合作方名片，不重做消息楼、不重做 profile。

【唯一目标】
1. BidThreadPage participant row 变为可点击
2. 点击后读取 `GET /api/app/exhibition/trading/participant-card`
3. 打开 read-only participant-card sheet / page
4. 展示：
   - 公司名 / logo
   - participant role
   - 认证摘要
   - bounded review summary
   - 静态提示：合作前建议查看对方企查查信息

【禁止事项】
- 不得接管 formal-info 全页
- 不得扩成 editable profile
- 不得扩成 generic DM profile drawer

【完成标准】
- thread 内点击参与方可打开只读名片
- widget test 覆盖点击与受控失败
```
