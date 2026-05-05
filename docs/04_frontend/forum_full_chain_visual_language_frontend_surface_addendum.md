---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-only visual language and shared component boundary for the current forum full-chain UI refinement, without changing BFF, Server, OpenAPI, generated contracts, database truth, or forum business rules.
layer: L3 Frontend
---

# Forum Full-chain Visual Language Frontend Surface Addendum

## Correction Note
- This addendum is a corrective freeze for the current forum visual-unification
  round.
- The implementation work must be treated as incomplete until this frontend
  surface boundary and the later verification receipt both pass.
- This addendum does not approve any BFF, Server, OpenAPI, generated-contract,
  database, cloud-runtime, or business-rule change.

## Current Minimum Closed Loop
- This round may refine only the Flutter presentation chain for:
  - forum publish page
  - forum feed list
  - post detail page
  - post comment display and input surface
  - author public-post card projection where it shares the same post card
  - exhibition-home forum recommendation channel
- The user-facing goal is to make the same forum content read consistently
  across publish, browse, detail, comments, author posts, and home
  recommendation.
- The frontend must continue to consume existing BFF-shaped view models only.

## Retained But Not Opened
- Retain existing entry points and extension space for:
  - author profile navigation
  - post like
  - post bookmark
  - comment submit
  - attachment references
  - share/report UI entry where already frozen elsewhere
- Do not open or expand:
  - new BFF route
  - new Server route
  - new OpenAPI field
  - new generated type
  - new database table
  - new fake recommendation model
  - new media preview source
  - new bottom navigation route

## Shared Component Freeze
- This round may introduce or reuse shared Flutter presentation components:
  - `ForumPostCard`
  - `ForumCategoryBadge`
  - `ForumAuthorRow`
  - `ForumStatsRow`
  - `ForumAttachmentPreview`
  - `ForumActionBar`
  - `ForumCommentCard`
  - `ForumCommentInputBar`
- These components are presentation adapters only.
- They must not own:
  - post truth
  - author truth
  - interaction truth
  - comment truth
  - attachment truth
  - routing truth beyond callbacks supplied by the page

## Field-source Freeze
- Feed cards may display only fields already available from existing
  Flutter-side forum view models, including:
  - post id
  - title
  - excerpt or body-derived preview
  - category label
  - author display name
  - author organization label where present
  - author avatar URL where present
  - publish or update time where present
  - reply count, like count, bookmark state, and view count where present
  - attachment references where present
- Post detail may display only existing detail fields and existing engagement
  projection.
- Comment cards may display only existing comment item fields and existing
  author projection.
- Attachment preview may show only real attachment metadata, filename, MIME
  type, size, or existing reachable preview information.

## No-fake-data Rules
- Do not add fake posts.
- Do not add fake cover images.
- Do not add fake reply counts.
- Do not add fake like counts.
- Do not add fake bookmark counts.
- Do not add fake view counts.
- Do not add fake author avatars.
- Do not add fake comments.
- If no real image or preview URL exists, use a neutral local visual treatment
  instead of fabricating a network image.

## Visual Rules
- Use the existing app visual tokens and local shared visual primitives where
  possible.
- Forum cards should use a consistent hierarchy:
  - category badge
  - title
  - excerpt
  - author row
  - stats row
  - optional attachment preview
  - page-appropriate action row
- Gold may be used for current selection, primary CTA, and restrained brand
  emphasis.
- Destructive or unavailable actions must not use gold filled buttons.
- Loading, empty, unavailable, and failure states must stay explicit and must
  not be hidden for visual cleanliness.

## Page-specific Freeze
- Publish page:
  - may align category, title, body, attachment, draft, and publish controls to
    the shared visual language
  - must keep existing publish and draft semantics
  - must not change upload protocol or attachment business truth
- Forum feed list:
  - may use the shared post card
  - must keep existing tab and filter semantics
  - must not invent local or following posts
- Post detail page:
  - may use shared author, stats, attachment, action, comment, and input
    components
  - must keep existing detail and comment read/write boundaries
  - must not move comment truth into messages or profile
- Exhibition-home recommendation channel:
  - may reuse the compact forum post card
  - must use real forum feed results only
  - must not create a separate recommendation truth

## Explicit Non-goals
- No BFF change.
- No Server change.
- No OpenAPI change.
- No generated-contract change.
- No database change.
- No cloud deployment or restart.
- No direct Server call from Flutter.
- No bottom navigation change.
- No second Flutter forum state machine.
- No business-rule reinterpretation.
- No fake or seeded visual content.

## Stage Gate
- Gate 0, read-only scan:
  - must identify current Flutter pages, shared components, field sources, and
    dirty worktree risk.
- Gate 1, frontend surface freeze:
  - this addendum is the required frontend boundary for the current UI round.
- Gate 2, implementation:
  - allowed only inside Flutter presentation files and directly related Flutter
    tests.
- Gate 3, independent verification:
  - run scoped `flutter analyze`
  - run targeted Flutter tests covering forum routes, publish media UI, forum
    interaction loop, and exhibition-home forum panel where applicable
  - run scoped `git diff --check`
- Gate 4, runtime receipt:
  - not part of this round.
  - Cloud runtime must not be claimed from local Flutter checks.

## Risk Judgment
- Steadiest path:
  - keep this round Flutter-only, componentize the visual layer, and preserve
    all existing BFF-shaped field truth.
- Lowest-cost path:
  - replace duplicated cards and action rows with shared presentation widgets
    without changing contracts or route structure.
- Best fit for the current stage:
  - finish the visual-language alignment locally, verify with scoped Flutter
    checks, then decide separately whether a cloud-runtime read receipt is
    needed.
- Highest-risk path:
  - mixing this UI cleanup with BFF/Server/OpenAPI/database changes or adding
    fake images and fake engagement numbers to match the reference image.

## Formal Conclusion
- This round is approved only as a Flutter presentation-layer visual
  unification.
- Existing field truth, interaction truth, attachment truth, and route truth
  remain owned by their previously frozen layers.
- The reference image is design direction, not data truth.
- Any missing field must remain omitted, degraded, or explicitly unavailable;
  it must not be faked in Flutter.
