---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side implementation truth for the current forum delivery round, including command/query families, object ownership, and the approved first-release scope.
layer: L3 Backend
---

# Forum Server Implementation Truth Addendum

## Scope
- This addendum applies only to the current forum implementation round.
- It freezes only:
  - the approved Server-side forum application surface
  - the current command and query families
  - the current object and interaction ownership split
  - the first-release forum delivery scope
- It does not by itself:
  - approve moderation console implementation
  - approve ranking or recommendation truth
  - approve ad-slot or resource-slot implementation
  - rewrite the existing forum domain baseline

## Server Ownership Stays Unchanged
- `Server` remains the only owner of:
  - `ForumTopic`
  - `ForumPost`
  - `ForumComment`
  - `ForumBookmark`
  - `ForumFollow`
  - `ForumDraft`
  - `ForumReport`
  - `ForumRiskFlag`
  - `ForumModerationCase`
- `Server` also remains the only owner of the publish-eligibility,
  visibility, moderation, and engagement write truth for forum.

## Current First-release Implementation Surface
- The current implementation round may expose and implement only:
  - `square / local / following` forum feed reads
  - topic metadata reads for classify / select / filter
  - optional topic detail read as a secondary route, not a first-level home
    entry
  - post detail read
  - post comment-list read
  - post comment create
  - post like toggle
  - post bookmark toggle
  - topic follow toggle
  - post draft save / list / delete
  - publish from existing draft
  - forum search
  - forum me-assets reads
  - forum-originated interaction inbox reads for the `messages` building

## Current Feed Truth
- The current forum main browsing chain is post-centric.
- `square / local / following` feed reads must return ordered forum post feed
  items, not topic-home carriers.
- Topic remains internal taxonomy only and must appear through:
  - publish-time selection
  - post-title labeling
  - list-level filtering
- Topic must not be reintroduced as a first-level browsing owner.

## Current Command Families
- Current first-release write families are:
  - `forum_draft_save`
  - `forum_draft_delete`
  - `forum_publish`
  - `forum_post_comment_create`
  - `forum_post_like_toggle`
  - `forum_post_bookmark_toggle`
  - `forum_topic_follow_toggle`
- Current first-release command boundaries:
  - new post publishing must continue through draft -> publish
  - attachment binding still follows `init -> direct upload -> confirm`
  - direct post publish without draft is not approved
  - comment draft truth may remain Server-owned but is not required to be
    surfaced in the current app-facing round

## Current Query Families
- Current first-release read families are:
  - `forum_feed_query`
  - `forum_topic_metadata_query`
  - `forum_topic_detail_query`
  - `forum_post_detail_query`
  - `forum_post_comment_query`
  - `forum_search_query`
  - `forum_me_assets_query`
  - `forum_interaction_inbox_query`
- `forum_interaction_inbox_query` may project forum-originated interaction
  events for the `messages` building, but must not turn `messages` into a
  second forum object tree owner.

## Current Me-assets Boundary
- The current me-assets implementation surface covers only:
  - my posts
  - my comments
  - my bookmarks
  - my follows
  - drafts
- These remain actor-scoped query projections only.
- They must not become:
  - a second forum browse tree
  - profile truth ownership

## Current Interaction Boundary
- Current first-release interaction scope is:
  - like on post
  - bookmark on post
  - comment on post or on comment
  - follow on topic
- Topic follow truth remains topic-bound.
- The current round does not require:
  - author-follow truth
  - comment-like truth
  - reaction-pack expansion

## Notification And Inbox Boundary
- Forum-originated replies, likes, and follows may feed the current interaction
  inbox read model.
- The read model consumed by `messages` is still a forum-originated projection,
  not a replacement for forum post or comment truth.
- Quick actions from the inbox, if later exposed, must still write through the
  same forum command families and must not create a second message-owned forum
  write tree.

## Current Non-goals
- No moderation console or report-processing surface
- No ranking or recommendation truth
- No ad-slot or resource-slot work
- No cross-domain transaction handoff
- No new forum path family outside the frozen app-facing family

## Formal Conclusion
- Current Server conclusion:
  - forum implementation may proceed on the approved command and query
    families above
  - forum remains post-centric in the main browse chain
  - topic remains internal taxonomy only
  - `messages` and `profile` consume bounded projections only
- Current meaning:
  - L3 Backend implementation truth for the current forum round
- Current non-approved meaning:
  - no moderation-console approval
  - no ranking / ads / recommendation approval
