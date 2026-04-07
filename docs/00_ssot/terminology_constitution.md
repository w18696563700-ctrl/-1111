---
owner: Codex 总控
status: draft
purpose: Freeze formal product and engineering terminology.
layer: L0 SSOT
---

# Terminology Constitution

## Formal Product Terms
- `Flutter App`: the only mobile app client.
- `Admin`: the Next.js operations console.
- `BFF`: the only app-facing aggregation layer.
- `Server`: the only business truth owner.
- `Shell`: the shared mobile shell for all buildings.
- `Building`: a top-level business building under the shell.

## Five Buildings
- `exhibition`
- `renovation`
- `custom_furniture`
- `messages`
- `profile`

## First Release Visibility
- Visible: `exhibition`, `messages`, `profile`
- Hidden but pre-embedded: `renovation`, `custom_furniture`

## Cross-building Feature Families
- `forum`

`forum` is an app-facing feature family, not a sixth shell building.
Freezing `forum` does not:
- change the five-building architecture
- expose a new shell building
- reopen hidden buildings
- allow BFF to own community truth or a second routing system

## Core Business Objects
- `Organization`
- `Project`
- `Bid`
- `Order`
- `Contract`
- `Milestone`
- `Evidence`
- `Inspection`
- `ChangeOrder`
- `Rating`
- `Dispute`
- `ReviewTask`
- `AuditLog`
- `FileAsset`
- `ForumTopic`
- `ForumPost`
- `ForumDraft`

## Platform Capability Pre-embeds
- `live`
- `geo`
- `map`

These are platform capabilities, not buildings, and stay feature-flagged off by default.

## Platform Pre-embed Boundary
- `live`, `geo`, and `map` are platform-capability names only.
- They are not shell buildings.
- Freezing these capability names does not:
  - add any app-facing path
  - open any business page
  - enable any end-user feature
  - change first-release building visibility
- `renovation` and `custom_furniture` remain hidden pre-embedded buildings only.
- Platform capability pre-embed may exist in truth before any implementation,
  runtime wiring, or feature enablement round is separately approved.
