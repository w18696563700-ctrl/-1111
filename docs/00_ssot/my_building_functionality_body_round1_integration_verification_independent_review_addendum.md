---
owner: 联调发布 Agent
status: frozen
purpose: Record the failed development-stage integration verification for `我的楼功能本体 Round 1`, freezing that the app-facing profile command family is not yet materially closed on the active runtime.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_result_verification_rerun_review_conclusion_addendum.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
---

# 《我的楼功能本体 Round 1 development-stage integration verification 回执单》

## 1. Verification Conclusion

- Scope executed:
  - `我的楼功能本体 Round 1 development-stage integration verification`
- Current result:
  - `not passed`
- Current stage must remain:
  - `integration verification`
- Current stage must not advance to:
  - `release-prep`
  - `launch approval`
  - `closure`

## 2. Verified Topology

- Verified path:
  - `http://127.0.0.1:8080 -> 47.108.180.198:80 -> Nginx -> BFF:3000 -> Server:3101`
- Current freeze points remain citable:
  - `/srv/apps/bff/current -> /srv/releases/bff/20260404160902/apps/bff`
  - `/srv/apps/server/current -> /srv/releases/server/20260404013000`

## 3. Positive Runtime Evidence

- `POST /api/app/auth/otp/login = 200`
- `GET /api/app/shell/context = 200`
- `GET /api/app/profile/index = 200`
- `GET /api/app/profile/organization/mine = 200`
- `GET /api/app/profile/certification/current = 200`
- `GET /api/app/my/projects = 200`
- `GET /api/app/my/projects/{projectId} = 200`
- `GET /api/app/my/projects/{projectId}` still returns:
  - `publicProject + privateProgress`
  - `viewerProjectRelation`
- hidden buildings remain closed

## 4. Blocking Runtime Evidence

- Current canonical profile command family is not materially closed on the active app-facing runtime:
  - `POST /api/app/profile/organization/create = 404`
  - `POST /api/app/profile/organization/join-by-code = 404`
  - `POST /api/app/profile/organization/switch = 404`
  - `POST /api/app/profile/certification/submit = 404`
  - `POST /api/app/profile/certification/resubmit = 404`
- Current direct hit to active BFF also fails:
  - `POST http://127.0.0.1:3000/bff/profile/organization/create = 404`
- Returned shape is raw Express `Cannot POST ...`, not the frozen app-facing normalized error family.

## 5. Risk Classification

- Current veto:
  - active app-facing profile command family is not materialized on the runtime currently serving `:80 -> :3000`
- Current non-veto retained risks:
  - `shell/context` and `profile/index` certification carrier consistency remains weaker than dedicated profile reads
  - stale PM2 runtime registry drift remains present but is not the active `:80` path

## 6. Gate Recommendation

- Recommendation:
  - `No-Go` for `我的楼功能本体 Round 1 development-stage integration verification`
- Stage position:
  - stay in `integration verification`
- Still `No-Go` for:
  - `release-prep`
  - `launch approval`
  - `closure`
