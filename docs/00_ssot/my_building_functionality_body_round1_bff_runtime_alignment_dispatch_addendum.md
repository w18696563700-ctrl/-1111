---
owner: Codex 总控
status: frozen
purpose: Freeze the single next bounded action after failed integration verification: active BFF runtime alignment for the canonical profile command family.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - docs/00_ssot/my_building_functionality_body_round1_integration_verification_review_conclusion_addendum.md
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/bff/src/routes/profile/profile-command.controller.ts
  - apps/bff/src/routes/profile/profile-read.module.ts
---

# 《我的楼功能本体 Round 1 BFF runtime alignment 派工单》

## 1. Current Single Action

- Current single action is:
  - active BFF runtime alignment for the canonical `profile command family`
- Current action is not:
  - new feature expansion
  - integration verification rerun
  - `release-prep`
  - `launch approval`
  - `closure`

## 2. Bounded Target

- Current bounded target is only:
  - make active `:80 -> :3000` app-facing runtime materially expose
    - `POST /api/app/profile/organization/create`
    - `POST /api/app/profile/organization/join-by-code`
    - `POST /api/app/profile/organization/switch`
    - `POST /api/app/profile/certification/submit`
    - `POST /api/app/profile/certification/resubmit`
- Current bounded target also requires:
  - direct `/bff/profile/*` endpoints to stop returning raw Express `Cannot POST`

## 3. Explicit Limits

- No new scope
- No new package
- No new truth family
- No Server change unless separately re-dispatched
- No release-prep language
