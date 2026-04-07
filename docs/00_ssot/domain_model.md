---
owner: Codex 总控
status: draft
purpose: Freeze core domain objects, building model, and platform pre-embed object shapes.
layer: L1 Domain
---

# Domain Model

## Core Product Shape
- One `Shell`
- Five `Buildings`
- One `BFF`
- One modular monolith `Server`
- One truth chain: contracts -> persistence -> implementation -> runtime audit

## Core Domain Objects
| Object | Purpose |
|---|---|
| `Organization` | business主体 and collaboration boundary |
| `Project` | pre-award demand container |
| `Bid` | supplier proposal and quote container |
| `Order` | post-award master container |
| `Contract` | contract and structured clauses |
| `Milestone` | fulfillment step |
| `Evidence` | proof abstraction for file-backed evidence |
| `Inspection` | acceptance and rectification container |
| `ChangeOrder` | approved delta to price or duration |
| `Rating` | order-bound evaluation |
| `Dispute` | order-bound dispute and governance case |
| `ReviewTask` | review workflow node |
| `AuditLog` | append-only high-risk action record |
| `FileAsset` | file truth record |
| `ForumTopic` | forum taxonomy and posting container |
| `ForumPost` | forum primary content truth |
| `ForumComment` | forum discussion reply truth |
| `ForumBookmark` | actor-bound saved-post truth |
| `ForumFollow` | actor-bound topic follow truth |
| `ForumDraft` | author-owned content draft truth |
| `ForumModerationCase` | forum governance case truth |
| `ForumReport` | forum content report truth |
| `ForumRiskFlag` | forum content risk signal truth |

## M1 Flow Objects
- `Project`
- `Bid`
- `Order`
- `Milestone`

## V1 Completion Add-ons
- `Contract`
- `Inspection`
- `Rating` entry
- `Dispute` entry

## Forum Feature Objects
- `ForumTopic`
- `ForumPost`
- `ForumComment`
- `ForumBookmark`
- `ForumFollow`
- `ForumDraft`
- `ForumModerationCase`
- `ForumReport`
- `ForumRiskFlag`

Forum remains a cross-building feature family only:
- it is not a sixth building
- BFF may aggregate forum read models and publish handoff only
- Server remains the sole owner of topic, post, attachment binding, draft, and
  moderation truth

## Geo Pre-embed Model
Shared location model must reserve:
- `lat`
- `lng`
- `coord_system`
- `provider`
- `address_snapshot`
- `poi_id`
- `city_code`
- `district_code`

## Live Pre-embed Model
Server must reserve:
- `live_provider`
- `live_room`
- `live_binding`
- `live_session`
- `live_event`
- `live_replay_asset`

## Map Adapter Principle
- Provider-specific behavior must stay behind a `Map Provider Adapter`.
- Business modules consume normalized geo data only.
