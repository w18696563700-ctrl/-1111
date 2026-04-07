---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface boundary for forum content governance and report submission so the client may expose bounded report entry and controlled governance messages without becoming a moderation console or a messages-side harassment center.
layer: L3 Frontend
---

# Forum Content Governance And Report Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum content governance and report minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the bounded ordinary-user report entry surface
  - the current controlled governance-message surface
  - the explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve moderation console
  - approve messages-side harassment controls

## Current Publish-governance Surface
- Frontend remains on the current mainline:
  - `draft/save -> publish`
- Current ordinary-user governance outcomes remain only:
  - 发布成功
  - 需修改后再试
  - 当前内容暂不可发布
  - 已进入受控治理处理
- Frontend must not expose:
  - raw risk tags
  - raw model output
  - moderator or ticket-routing internals

## Current Report Entry Boundary
- The minimum ordinary-user report surface may appear only on:
  - post detail
  - comment item or comment detail
- The minimum report form may expose only:
  - bounded report reason selection
  - optional detail text
  - submit action
- Minimum reason labels correspond only to:
  - 广告 / 导流
  - 辱骂 / 人身攻击
  - 引战 / 煽动冲突
  - 刷屏 / 灌水
  - 搬运 / 抄袭
  - 其他

## Current Report Result Boundary
- Minimum report-submit result meanings remain only:
  - 举报已提交
  - 已存在处理中举报
- Frontend must not imply:
  - 举报即下线
  - 举报后马上得到处理结论
  - ordinary user may inspect a moderation queue

## Private-message Harassment Explicit Split
- `私信骚扰` does not belong to this forum package.
- Frontend must not add under forum:
  - DM blacklist
  - mute user
  - stranger-message controls
  - harassment settings center
- These belong to a later dedicated `messages` package only.

## Current Explicit Non-goals
- No moderation console
- No report history center for ordinary users
- No messages harassment UI
- No DM block / mute / blacklist UI
- No second review state machine
- No binary media moderation UI

## Formal Conclusion
- Current formal conclusion:
  - frontend may expose only bounded publish-governance outcomes and a minimum
    ordinary-user report-submit entry
  - malicious-report handling remains invisible as an internal governance path
    rather than a user-side punishment UI
  - private-message harassment remains explicitly outside forum and belongs to a
    later `messages` package

## Next Unique Action
- After backend and BFF truth land, dispatch frontend Agent last to wire:
  - bounded report entry
  - bounded report-submit result surface
  - continued publish-governance message handling
