---
owner: Codex 总控
status: draft
purpose: Freeze the formal L3 Admin governance-workbench module surface, controlled object families, query boundary, and governance-action boundary.
layer: L3 Admin
---

# Admin Governance Surface Matrix

## Scope
- This file freezes the formal `L3 Admin` governance-workbench surface only.
- It applies only to the following controlled Admin modules:
  - `review`
  - `project_review`
  - `template_config`
  - `audit`
  - `ticketing`
- It does not define implementation, page prototype, Admin frontend routing,
  Server API implementation, or cloud execution steps.
- It does not add any app-facing path or second business-truth root.

## Canonical Admin Module Surface
- `Admin` is a controlled governance console only.
- `Admin` works only through controlled `Server` Admin APIs.
- `Admin` does not talk to `BFF`.
- `Admin` does not own business truth, state transitions, or a second audit
  system.
- `Admin` may read, govern, and route already-existing `Server` truth only
  within the module boundaries below.
- Actor grants remain governed by the existing permission truth; this file does
  not create a second role system.

| Module | Primary governance role | Controlled object families |
|---|---|---|
| `review` | generic review workbench for controlled governance review tasks | `ReviewTask`, `Organization`, `FileAsset`, `Evidence`, and attached review-subject refs already materialized by `Server` |
| `project_review` | controlled project review workbench | `Project`, project-linked `ReviewTask`, project-linked `Evidence`, project-linked `FileAsset`, and organization summary refs required for project review context |
| `template_config` | controlled template and rule configuration workbench | `Template`, `TemplateVersion`, `TemplateField`, `TemplateRule`, and controlled template grouping refs |
| `audit` | controlled audit search and verification workbench | `AuditLog` and the linked `object_type` / `object_id` / `object_no` evidence anchors required for audit investigation |
| `ticketing` | controlled governance case-routing and follow-up workbench | `Dispute`, dispute-linked or rating-appeal-linked governance case refs, related `Order` / `Contract` / `Inspection` / `Rating` anchors, and attached `Evidence` / `FileAsset` refs |

## Module Boundaries

### 1. review
- Controlled object families:
  - `ReviewTask`
  - `Organization`
  - `FileAsset`
  - `Evidence`
  - attached review-subject refs already materialized by `Server`
- Read/query boundary:
  - list and filter existing review tasks
  - read review-subject snapshot, attached evidence refs, and current review
    status summary already provided by `Server`
  - read prior review decision history when already exposed by controlled
    `Server` Admin APIs
- Governance action boundary:
  - decide an existing `ReviewTask`
  - request supplement on an existing `ReviewTask`
  - approve or reject an existing `ReviewTask`
- Explicitly not in current scope:
  - direct mutation of underlying business truth outside the controlled review
    decision boundary
  - project-publication governance that belongs to `project_review`
  - template editing that belongs to `template_config`
  - audit-row mutation that belongs outside Admin action scope

### 2. project_review
- Controlled object families:
  - `Project`
  - project-linked `ReviewTask`
  - project-linked `Evidence`
  - project-linked `FileAsset`
  - organization summary refs required by project review
- Read/query boundary:
  - list and filter project review candidates
  - read project submission bundle, attached evidence refs, and current project
    review summary already exposed by `Server`
  - read project review history already recorded by governance truth
- Governance action boundary:
  - approve an existing project review item
  - reject an existing project review item
  - request supplement or correction on an existing project review item
- Explicitly not in current scope:
  - direct project publishing outside the controlled review decision boundary
  - bid, order, contract, milestone, or inspection workflow mutation
  - template configuration or audit export ownership

### 3. template_config
- Controlled object families:
  - `Template`
  - `TemplateVersion`
  - `TemplateField`
  - `TemplateRule`
  - controlled template grouping refs
- Read/query boundary:
  - list templates and versions
  - read template schema, rule set, grouping metadata, and publish history
  - compare draft and published template versions already exposed by `Server`
- Governance action boundary:
  - create or edit a draft template version
  - publish a new template version
  - archive or deprecate a template version
  - adjust controlled template grouping metadata
- Explicitly not in current scope:
  - retroactive rewrite of historical order, project, inspection, rating, or
    dispute snapshots
  - direct runtime config or feature-flag control
  - direct mutation of live business instances outside template-governance truth

### 4. audit
- Controlled object families:
  - `AuditLog`
  - linked `object_type`
  - linked `object_id`
  - linked `object_no`
  - linked trace and request correlation refs already exposed by `Server`
- Read/query boundary:
  - search, filter, and inspect append-only audit records
  - read audit detail for a given object, actor, request, or trace correlation
  - export controlled read-only audit slices when the controlled `Server` Admin
    API exposes that capability
- Governance action boundary:
  - query only
  - inspect only
  - controlled read-only export only
- Explicitly not in current scope:
  - editing or deleting audit rows
  - creating a second audit store
  - using Admin to bypass append-only audit rules
  - direct business-state mutation through the audit module

### 5. ticketing
- Controlled object families:
  - `Dispute`
  - dispute-linked governance case refs
  - rating-appeal-linked governance case refs when such cases are already
    materialized by `Server`
  - related `Order`, `Contract`, `Inspection`, and `Rating` anchors
  - attached `Evidence` and `FileAsset` refs
- Read/query boundary:
  - list and filter governance case bundles
  - read linked dispute or appeal context, attached evidence refs, and current
    handling summary already materialized by `Server`
  - read case follow-up history and routing history when already exposed through
    controlled `Server` Admin APIs
- Governance action boundary:
  - classify an existing governance case
  - assign or route an existing governance case
  - append follow-up handling notes through the controlled `Server` governance
    path
  - close a handled governance case only when the underlying `Server` truth
    supports that controlled action
- Explicitly not in current scope:
  - direct rewrite of `Dispute`, `Rating`, `Order`, `Contract`, or `Inspection`
    truth outside the controlled governance path
  - creating a second dispute or appeal truth layer in Admin
  - direct platform-side resolution semantics without `Server` truth ownership

## Boundary with Permission / Audit / Backend Truth
- Boundary with `docs/00_ssot/permission_matrix.md`:
  - role grants and actor eligibility remain owned by the permission matrix
  - this file defines module surface only and does not mint new Admin roles
  - `operator` remains `Server`-internal only and is not an Admin UI role
- Boundary with `docs/02_backend/audit_log_spec.md`:
  - must-audit actions, required audit fields, and append-only rules remain
    owned by the audit-log spec
  - every Admin governance action still requires audit attribution through the
    controlled `Server` path
- Boundary with `docs/02_backend/service_boundaries.md`:
  - `Server` remains the only business-truth owner
  - `Admin` continues to use controlled `Server` Admin APIs directly
  - this file does not let Admin bypass domain-service boundaries
- Boundary with `docs/05_admin/admin_ssot.md`:
  - `admin_ssot.md` governs Admin truth location, directory allow-list, and
    non-truth boundaries
  - this file governs the formal Admin governance module surface and module-level
    action boundaries

## Non-goals
- No implementation plan
- No Admin frontend route implementation
- No Server Admin API implementation
- No direct database access model
- No new app-facing path
- No new `L2 Contracts`
- No second business-truth root in `Admin`
- No implementation unlock by this file alone
