---
owner: Codex 总控
status: frozen
purpose: Freeze the single next bounded action after the BFF runtime-alignment pass: active Server runtime alignment for the canonical profile organization command family.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - docs/00_ssot/my_building_functionality_body_round1_bff_runtime_alignment_review_conclusion_addendum.md
  - apps/server/src/modules/profile/profile.controller.ts
  - apps/server/src/modules/profile/profile.module.ts
---

# 《我的楼功能本体 Round 1 Server runtime alignment 派工单》

## 1. Current Single Action

- Current single action is:
  - active Server runtime alignment for `/server/profile/organization/*`
- Current action is not:
  - new feature expansion
  - integration verification rerun
  - `release-prep`
  - `launch approval`
  - `closure`

## 2. Bounded Target

- Current bounded target is only:
  - make active `:3101` runtime materially expose:
    - `POST /server/profile/organization/create`
    - `POST /server/profile/organization/join-by-code`
    - `POST /server/profile/organization/switch`
- Current bounded target does not require new functionality.
- Current bounded target only requires active runtime to align with already-existing local source and current frozen truth.

## 3. Explicit Limits

- No new scope
- No new package
- No new truth family
- No BFF change unless separately re-dispatched
- No release-prep language
