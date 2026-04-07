---
owner: Codex 总控
status: draft
purpose: Freeze the newly adopted forum user-visible content, Simplified Chinese copy, unfinished-feature presentation, and visible-sample governance rules for the current implementation-governance stage without mislabeling the board as verified, released, or closed.
layer: L0 SSOT
---

# 论坛正式可见内容与中文化规则冻结单

## 1. Scope
- This addendum applies only to the current user-visible layer of the
  `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the visible-post account rule
  - the Simplified Chinese copy rule
  - the unfinished-feature presentation rule
  - the current unapproved boundary for attachment / location / AI review
  - the visible-feed cleanup rule
- It does not by itself:
  - approve implementation completion
  - approve result verification
  - approve integration release
  - approve board closure

## 2. Current Formal Visible-post Account Rule
- In the current forum development stage, for user-visible sample posts,
  demonstration posts, and formally presented posts, the preferred publishing
  account must be:
  - `18696563700`
- The purpose of this whitelist-account rule is:
  - keep later edit / delete / my-posts continuity under a stable account owner
  - avoid presenting visible sample content under drifting temporary actors
- This current rule means:
  - future visible sample-content landing should prioritize `18696563700`
  - visible-content replacement should follow the same whitelist-account rule
- This current rule does not mean:
  - all currently visible posts have already been migrated
  - the full publish mainline is already restored
  - publish completion may be claimed ahead of truth

## 3. Current Formal Simplified Chinese Rule
- The current forum official user-visible layer must use:
  - `简体中文`
- This current Simplified Chinese rule applies at least to:
  - list titles
  - topic labels
  - first-level navigation
  - internal classifications
  - publish page
  - draft box
  - search page
  - forum interaction center in `messages`
  - forum asset entry in `profile`
  - snackbar
  - toast
  - bottom sheet
  - modal / dialog
  - empty state
  - error state
  - helper text
- The current user-visible layer must not continue to expose:
  - English test titles
  - raw slug text
  - raw topic key text
  - raw technical error wording
  - half-English half-Chinese buttons or prompts
- If current upstream or runtime still returns raw technical or key-based text,
  the current visible layer rule is:
  - do not present that raw text as final user-facing copy
  - convert it into controlled Simplified Chinese user-facing wording instead

## 4. Current Unfinished-feature Presentation Rule
- Any unfinished forum capability in the current user-visible layer may be
  handled only in one of these three ways:
  - hidden
  - disabled
  - tappable only with a controlled Simplified Chinese prompt
- The current visible layer must not show:
  - dead buttons that look clickable but do nothing
  - empty buttons with no response and no explanation
  - raw technical blockers exposed directly to ordinary users
- Current visible handling therefore must prefer:
  - honest but controlled degraded presentation
  - minimal user-understandable Simplified Chinese guidance
  - no fake completion wrapping

## 5. Current Publish-page Attachment / Location / AI-review Boundary
- The current publish page may keep:
  - image entrance visual slot
  - video entrance visual slot
- But the current board still must not write these capabilities as completed:
  - direct image or video upload during draft stage and formal draft binding
  - automatic post location truth
  - AI review as a publish gate
- These three capabilities are currently frozen only as:
  - not yet approved for implementation
  - requiring a separate future total-control freeze before implementation may
    begin
- The current mainline remains:
  - `draft/save -> publish`
- Therefore the current board must not reinterpret the visible publish surface
  as:
  - direct post publish
  - attachment chain completed
  - location truth completed
  - AI review gate completed

## 6. Current Formal Feed Cleanup Rule
- In the current forum official visible feed, the following content must not
  remain as long-term formal visible content:
  - English test titles
  - raw slug or raw topic label text
  - technical sample-post names
- The current cleanup execution principle is:
  - replace visible content with Simplified Chinese content
  - place replacement content under the whitelist-account rule above
- The current formal meaning is:
  - this cleanup rule is frozen as an execution requirement
  - this document does not claim that all cleanup has already been completed

## 7. Current Explicitly Non-approved Meanings
- This addendum is a current visible-layer governance freeze only.
- It is not:
  - integration passed
  - release passed
  - online completion
  - closure passed
- It also does not approve:
  - direct post publish
  - draft attachment direct-upload binding
  - automatic post-location truth
  - AI review gate
  - long-term visible English test content
  - raw slug or topic-key exposure as formal user-facing copy

## 8. Current Execution Direction Only
- Current next execution direction is:
  - frontend continues Simplified Chinese cleanup and unfinished-control
    tightening
  - after runtime recovery, visible sample posts should be landed or replaced
    under the whitelist-account rule using `18696563700`
- This execution direction is not equal to:
  - implementation completion
  - release approval
  - closure approval

## 9. Formal Conclusion
- Current formal conclusion:
  - the forum visible layer now has a frozen whitelist-account rule for visible
    sample content
  - the forum visible layer now has a frozen Simplified Chinese-only rule
  - unfinished functions may appear only as hidden, disabled, or controlled
    Simplified Chinese prompted entry points
  - attachment direct binding, automatic location truth, and AI review gate are
    still outside the approved current implementation boundary
  - visible English test content, raw slug text, raw topic-key text, and
    technical sample-post names must not remain as long-term formal visible
    content
- Current freeze type:
  - forum visible-content and copy governance freeze only

## 10. Next Unique Action
- Continue only with frontend visible-layer Chinese cleanup and unfinished-entry
  tightening, then land visible sample-content replacement under the
  whitelist-account rule after runtime recovery.
