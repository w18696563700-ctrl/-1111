---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface for a compact my-building hub so the profile tab can present a clean current-user summary, profile entry, company detail entry, my-project handoff, bounded forum assets, and app-native settings without becoming a second forum home.
layer: L3 Frontend
---

# 我的楼简洁聚合页前端界面冻结单

## 1. Scope
- This addendum applies only to the current frontend surface refinement for:
  - `我的楼简洁聚合页`
- It freezes only:
  - the page-family shape of the `profile` hub
  - the formal handoff from avatar to personal profile
  - the company-detail entry rule
  - the my-project entry handoff rule
  - the app-native settings grouping rule
- It does not by itself:
  - approve implementation completion
  - approve new backend schema
  - approve a public profile surface
  - approve a second forum homepage

## 2. My-building Home Surface
- The top-level `我的楼` page should feel:
  - concise
  - clean
  - grouped
  - WeChat-like in structure, but still native to this app
- The minimum current page tree may include only:
  - top profile summary block
  - my company entry
  - certification or membership summary entry
  - my project entry
  - my forum entry
  - settings entry
- The current first-level page must keep `设置` as the bottom-most entry family.
- `我的项目` may appear only as a bounded private-project entry handoff from `我的楼`.
- Frontend must not present `我的项目` as:
  - a replacement for `项目工作台`
  - `profile` becoming the project truth owner
- The page must not be presented as:
  - a dense operations dashboard
  - a second forum feed
  - a mixed public-private social homepage

## 3. Avatar And Personal Profile Handoff
- Tapping the avatar or the top summary block must hand off to:
  - a personal profile page inside the existing `profile` family
- The personal profile page in this package may show only app-relevant identity information and entry rows.
- The page must explicitly remove:
  - `拍一拍`
  - `来电铃声`
- Frontend must not keep consumer-IM-only entries just because they resemble WeChat.

## 4. My Company Entry Rule
- The old entry label:
  - `我的发票抬头`
  must not remain as the formal user-facing entry in this package.
- It must be replaced by:
  - `我的公司`
- Tapping `我的公司` must hand off to:
  - a company detail page under the existing `profile` family
- The company detail page may consume only bounded company or organization detail already allowed by profile truth.

## 5. Settings Surface Rule
- Tapping `设置` may enter a richer settings page.
- The settings page should stay list-based and compact.
- The current approved settings groups are limited to app-native families such as:
  - account and security
  - notifications
  - privacy and permissions
  - interface and display
  - general
  - storage
  - about
- The settings page must not include:
  - chat-only product settings
  - audio-call product settings unrelated to this app
  - decorative consumer-social features without current product meaning

## 6. Forum Asset Aggregation Rule
- `我的楼` must expose one bounded first-level forum entry only:
  - `我的论坛`
- The first-level `我的论坛` row may show only a restrained subtitle summary such as:
  - post, comment, favorite, follow, or draft counts
- Tapping `我的论坛` may enter a second-level page that exposes:
  - `我的帖子`
  - `我的评论`
  - `我的收藏`
  - `我的关注`
  - `草稿箱`
- These remain personal forum asset shortcuts and summaries only.
- The first-level page must not duplicate the full forum asset list once `我的论坛` exists.
- They must not transform the `profile` building into:
  - a browse feed
  - a second forum page tree owner

## 7. Frontend Consumption Discipline
- Frontend continues to consume `BFF` output only.
- Frontend must not call `Server` directly.
- Frontend must not invent:
  - unapproved profile-private fields
  - project truth ownership under `profile`
  - a second forum state machine
  - a second public-author tree under `profile`

## 8. Current Explicit Non-goals
- No public author homepage under `profile`
- No `拍一拍`
- No `来电铃声`
- No `我的发票抬头` as the retained formal entry label
- No project-truth ownership transfer into `profile`
- No second forum homepage
- No app-unrelated settings families
- No admin-style company management console

## 9. Formal Conclusion
- Current formal conclusion:
  - `我的楼` is approved only as a docs-frozen compact current-user hub surface
  - avatar tap must hand off to a personal profile page
  - `拍一拍` and `来电铃声` are removed from the approved personal-profile surface
  - `我的发票抬头` is replaced by `我的公司`
  - `我的项目` may hand off from `我的楼` only as a bounded private-project entry
  - forum assets must collapse into one first-level `我的论坛` entry with second-level expansion
  - `设置` must stay at the bottom of the first-level page
  - `设置` may be expanded only through app-native settings groups
  - forum assets remain bounded shortcuts rather than a second forum home
  - `profile` stays an entry owner only and does not become the project truth owner
- Current meaning:
  - L3 frontend truth for the compact my-building hub only
  - this addendum alone does not unlock frontend implementation

## 10. Next Unique Action
- Freeze the current owner/status matrix for the `我的楼` mainline so:
  - building owner
  - route owner
  - page owner
  - truth owner
  may be cited separately without mixing entry handoff and truth ownership
