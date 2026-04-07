---
owner: Codex 总控
status: draft
purpose: Freeze the minimum forum content-governance and report-rule package for ad, abuse, flamebait, spam, plagiarism, and malicious-report handling without opening a second publish path, a second moderation truth root, or a messages-side harassment package.
layer: L0 SSOT
---

# 论坛内容治理与举报最小规则包边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the minimum governance-rule package for forum content issues
  - the minimum report-rule package for post/comment reporting
  - the minimum boundary between forum-local governance carriers and the
    existing cross-cutting `ReviewTask` baseline
  - the explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - approve moderation console
  - approve private-message harassment handling inside forum

## 2. Capability Package Name
- Current capability package name:
  - `forum content governance and report minimum package`
- This package covers only:
  - ad / solicitation handling
  - abuse / insult handling
  - flamebait / conflict-incitement handling
  - spam / flood handling
  - plagiarism / repost handling
  - malicious-report handling
- It does not cover:
  - private-message harassment
  - DM block / mute / stranger-message rules

## 3. Governance Carriers Stay Reused
- Forum governance carriers remain:
  - `ForumReport`
  - `ForumRiskFlag`
  - `ForumModerationCase`
- Cross-cutting escalation carrier remains:
  - `ReviewTask`
- This package must not create:
  - a second moderation truth tree
  - a second ticket truth tree
  - a second user-side publish corridor

## 4. Minimum Rule Family

### 4.1 广告 / 导流 / 招揽
- Minimum meaning:
  - explicit solicitation, contact diversion, off-platform transaction诱导, or
    repeated commercial content inside ordinary forum publish
- Minimum handling boundary:
  - curable / context-missing case may resolve to `supplement_required`
  - explicit ad or diversion may resolve to `restricted`
  - repeated, organized, or high-severity ad behavior may resolve to
    `ticket_required`

### 4.2 辱骂 / 人身攻击
- Minimum meaning:
  - direct insult, humiliation, degrading language, or targeted abusive attack
- Minimum handling boundary:
  - curable wording may resolve to `supplement_required`
  - direct attack may resolve to `restricted`
  - repeated, targeted, or escalated abuse may resolve to `ticket_required`

### 4.3 引战 / 煽动冲突
- Minimum meaning:
  - deliberate conflict incitement, group antagonism bait, or repeated
    provocation designed to escalate dispute
- Minimum handling boundary:
  - curable provocation may resolve to `supplement_required`
  - explicit conflict incitement may resolve to `restricted`
  - repeated cross-thread conflict manufacture may resolve to `ticket_required`

### 4.4 刷屏 / 灌水 / 重复发布
- Minimum meaning:
  - repeated or near-duplicate content, abnormal publish frequency, or topic
    occupation by flood-like author behavior
- Minimum handling boundary:
  - content-side spam may resolve to `restricted`
  - repeated or suspicious-pattern spam may resolve to `ticket_required`
- Current rule meaning:
  - forum spam is a governance issue
  - later rate-limit / anti-abuse implementation may re-enter separately
  - this package does not by itself approve a second public anti-abuse console

### 4.5 搬运 / 抄袭 / 冒充原创
- Minimum meaning:
  - reposted or copied content presented as original, or material lacking
    required source/attribution under the current publish boundary
- Minimum handling boundary:
  - curable attribution gap may resolve to `supplement_required`
  - blatant copy-as-own may resolve to `restricted`
  - evidence conflict, repeated repost abuse, or copyright-governance dispute
    may resolve to `ticket_required`

### 4.6 恶意举报
- Minimum meaning:
  - repeated false reporting, retaliatory reporting, duplicate report flooding,
    or report usage intended to harass rather than truthfully flag content risk
- Minimum handling boundary:
  - malicious reporting never auto-hides the target by itself
  - malicious-report suspicion may open reporter-side `ForumRiskFlag`
  - severe or repeated malicious reporting may escalate into `ReviewTask`
    through `ticket_required`

## 5. Forum Report Minimum Rule
- `ForumReport` remains:
  - clue truth
  - not final verdict truth
- Minimum report rule:
  - one report does not directly mutate target visibility
  - report review must stay under `Server` control
  - duplicate active reports from the same actor against the same target must
    not create unlimited parallel truth rows
- Minimum target scope:
  - `ForumPost`
  - `ForumComment`
- This package does not approve:
  - report queue for ordinary users
  - user-side report history center
  - instant “举报即下线” semantics

## 6. Current Decision-category Reuse Rule
- Content-governance outcomes stay anchored to the existing decision family:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- Current rule meaning:
  - ordinary content issues stay inside the current publish and review boundary
  - escalated issues hand off to the existing governance-ticket baseline
  - forum does not create a second custom severity ladder for app-facing users

## 7. App-facing Simplicity Rule
- Ordinary users may see only bounded Chinese outcomes such as:
  - 发布成功
  - 需修改后再试
  - 当前内容暂不可发布
  - 已进入受控治理处理
  - 举报已提交
  - 已存在处理中举报
- Ordinary users must not see:
  - raw risk tags
  - moderator notes
  - governance routing internals
  - Admin console semantics

## 8. Explicitly Outside This Freeze
- Private-message harassment handling
- DM block / mute / blacklist package
- Messages-side anti-harassment controls
- Moderation console
- Human-review UI expansion
- Appeal workflow expansion
- Image/video binary moderation completion
- OCR / ASR / frame moderation completion
- A second publish path
- A second report or moderation truth root

## 9. Formal Conclusion
- Current formal conclusion:
  - forum now has a minimum formal governance-rule package for ad, abuse,
    flamebait, spam, plagiarism, and malicious-report handling
  - `ForumReport`, `ForumRiskFlag`, `ForumModerationCase`, and `ReviewTask`
    remain the only approved governance carriers in this package
  - malicious reporting is a governed reporter-side risk issue, not an
    automatic content takedown command
  - private-message harassment is explicitly outside forum and must re-enter
    under the `messages` building

## 10. Next Unique Action
- After this L0/L2/L3 package is frozen, the natural execution order is:
  1. backend Agent
  2. `BFF` Agent
  3. frontend Agent
