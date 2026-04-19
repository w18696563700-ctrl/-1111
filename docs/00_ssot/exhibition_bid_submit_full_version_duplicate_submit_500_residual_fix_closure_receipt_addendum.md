---
owner: Codex 总控
status: frozen
purpose: >
  Record the local source repair, staging release evidence, and A/B/C
  verification closure for the exhibition bid-submit duplicate-submit
  residual defect so later threads do not reopen the same 500 path or
  misread staging closure as production release.
layer: L0 SSOT
freeze_date_local: 2026-04-15
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_defect_sheet_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
---

# 《竞标提交页满分版重复提交 500 残余缺陷修复收口回执》

## 1. Current Object

- defect id:
  - `EXH-BID-FULL-RESIDUAL-001`
- current scope:
  - `apps/server/**`
  - `apps/bff/**`
  - `staging verification only`
- current no-go:
  - `apps/mobile/**`
  - `production current`
  - `80 production entry`

## 2. Local Source Closure

- `Server` 当前已补成显式 duplicate submit 业务规则：
  - [bid-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid-write.service.ts)
  - [bid.errors.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/bid.errors.ts)
  - [bid.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/bid/entities/bid.entity.ts)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
- 当前 local truth 固定为：
  - `bid_no` 不再允许退化成 `project_no` 镜像编号
  - `same organization + same project` 重复提交必须先命中业务冲突
  - 持久层唯一约束只做显式规则兜底，不再把 `23505` 直接漏给 App
- `BFF` 当前已补成受控 app-facing 归一化：
  - [bid.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/bid/bid.service.ts)
  - [bid-submit-error-mapping.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/bid-submit-error-mapping.test.cjs)
- 当前 BFF canonical 结果固定为：
  - `HTTP 409`
  - `code = BID_DUPLICATE_SUBMISSION`
  - message:
    - `当前项目已提交过投标，请勿重复提交。`

## 3. Local Build And Test

- `cd apps/server && npm run build`
  - `PASS`
- `cd apps/server && node --test test/bid-submit.test.cjs`
  - `PASS`
  - `6/6`
- `cd apps/bff && npm run build`
  - `PASS`
- `cd apps/bff && node --test test/bid-submit-error-mapping.test.cjs`
  - `PASS`
  - `6/6`

## 4. Staging Active Runtime

- verified host:
  - `47.108.180.198`
- current app-facing entry:
  - `http://127.0.0.1:3100`
- current release pointers:
  - `server -> /srv/releases/server/20260414235030`
  - `bff -> /srv/releases/bff/20260414235030/apps/bff`
- current service state:
  - `exhibition-server = active`
  - `exhibition-bff = active`
  - `nginx = active`
- current `systemd` active-enter evidence:
  - `exhibition-server = Tue 2026-04-14 23:25:13 CST`
  - `exhibition-bff = Tue 2026-04-14 23:25:17 CST`

## 5. Verification Matrix

### 5.1 Scenario A

- inherited same-day accepted evidence remains valid:
  - `POST /api/app/bid/submit -> 202 Accepted`
  - `projectId = 5020e1fe-0c49-44c0-8b04-cae5174b59d1`
  - `bidId = dce5f2a4-8d4a-41bc-bbe4-d995bfad6d8d`
  - 3 个附件已真实写入：
    - `52eb61c9-a40f-4cd2-bba1-3d4a9820707b`
    - `809abb1b-6166-402d-bd94-439cb841afc1`
    - `80329664-0a7c-4c14-8c51-23197592b5a3`

### 5.2 Scenario B

- same organization + same project second submit live rerun:
  - response:
    - `HTTP 409 Conflict`
    - `code = BID_DUPLICATE_SUBMISSION`
    - message:
      - `当前项目已提交过投标，请勿重复提交。`
- same-org DB evidence:
  - `project_id = 5020e1fe-0c49-44c0-8b04-cae5174b59d1`
  - `bidder_organization_id = 674095ed-7463-42a4-bc7f-7e28190a8c1f`
  - row count:
    - `1`

### 5.3 Scenario C

- second supplier identity chain was newly created on staging:
  - `organization_id = 4baf9aad-bc50-4f64-992f-1a285d58b607`
  - `user_id = 0fa2e143-284d-443f-9777-63ee08deb260`
  - `session_id = 53c3cd3c-729d-4103-8810-43868613df69`
- real upload corridor:
  - `project_understanding -> direct=200 -> fileAssetId=60be0844-5cb4-4267-88d7-f1ad6cafbbfc`
  - `quote_sheet -> direct=200 -> fileAssetId=0a9c09ca-8c98-44dd-85dd-e1757c7ec4bd`
  - `schedule_plan -> direct=200 -> fileAssetId=336bf0cc-a145-44fc-82be-fc112efb9c8b`
- submit result:
  - `POST /api/app/bid/submit -> 202 Accepted`
  - `bidId = 8f05d8ad-ee7a-4eb4-a982-e1c7d3d2f812`
- new bid row evidence:
  - `bid_no = BID-20260415033246-5897AF`
  - `quote_amount = 2888.00`
  - `project_understanding_file_asset_id = 60be0844-5cb4-4267-88d7-f1ad6cafbbfc`
  - `quote_sheet_file_asset_id = 0a9c09ca-8c98-44dd-85dd-e1757c7ec4bd`
  - `schedule_plan_file_asset_id = 336bf0cc-a145-44fc-82be-fc112efb9c8b`
- project-level DB total after scenario C:
  - `2`
- current project bid rows now prove:
  - original supplier bid remains `dce5f2a4-8d4a-41bc-bbe4-d995bfad6d8d`
  - second supplier bid now coexists as `8f05d8ad-ee7a-4eb4-a982-e1c7d3d2f812`
  - current active runtime no longer uses `bid_no` collision to reject a second supplier

## 6. Journal And Risk Check

- `journalctl -u exhibition-server --since '2026-04-15 11:25:00'`
  - no `23505`
  - no `bids_bid_no_key`
- current residual defect closure means:
  - staging duplicate submit path is no longer a fake-green `500`
  - multi-supplier same-project submit no longer fails because of `bid_no` accidental collision
- current retained no-go:
  - production remains untouched
  - mobile remains unchanged in this residual round

## 7. Stage Gate Checklist

- passed gates:
  - `Server duplicate submit controlled conflict`
  - `BFF 409/BID_DUPLICATE_SUBMISSION normalize`
  - `staging scenario B live rerun`
  - `staging scenario C live rerun`
- failed gates:
  - `none in current residual scope`
- veto gates:
  - `production release still not allowed from this receipt`
  - `frontend rework still not allowed from this receipt`
- next stage allowed:
  - `Go for production decision prep only if a separate release gate is raised`
  - `No-Go for direct production push from this document`

## 8. Formal Conclusion

- `EXH-BID-FULL-RESIDUAL-001` 当前正式结论固定为：
  - `closed on staging`
  - `production untouched`
- 当前 authoritative closure 只覆盖：
  - local source repair
  - staging runtime verification
  - duplicate submit controlled rejection
  - second-supplier same-project coexistence
- 后续若要继续，只允许开启：
  - 独立 production release gate
  - 独立 production smoke and rollback checklist
