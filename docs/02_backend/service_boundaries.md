---
owner: Codex 总控
status: draft
purpose: Freeze Server domain ownership, adapter boundaries, and cross-service responsibilities.
layer: L3 Backend
---

# Server Service Boundaries

## Core Rule
- `Server` is the only business truth owner.
- `BFF` never owns business truth.
- `Admin` uses controlled `Server` Admin APIs directly.

## Domain Ownership
| Domain | Owns |
|---|---|
| `identity` / `organization` | user, session, organization, membership context |
| `project` / `bidding` / `order` / `contract` | demand, proposal, award, order, contract truth |
| `milestone` / `evidence` / `inspection` / `change_order` | fulfillment and acceptance truth |
| `rating` / `dispute` / `review` / `audit` | governance truth |
| `forum` / `forum_search` | topic, post, draft, publish eligibility, moderation, and search truth |
| `membership` / `message` / `config` / `notification` | platform service truth |

## Adapter Rules
- `platform_map` owns provider adapters such as Gaode.
- `platform_geo` owns normalized location modeling and geo snapshots.
- `platform_live` owns live capability adapters and replay asset normalization.
- Provider details must not leak into `project`, `order`, `milestone`, or `review` modules.

## Cross-service Boundary
- `Flutter App -> BFF`
- `Admin -> Server`
- `BFF -> Server`
- `Server -> PostgreSQL / Redis / OSS / adapters`

## Forbidden
- Business modules reading another domain table directly without a domain service boundary
- Any controller-level state transition
- Provider-specific map SDK logic outside `platform_map`
- `BFF` or `Admin` owning forum topic, post, draft, moderation, or search truth
