---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day 5 cloud BFF release receipt and Day 6 Server necessity verdict
  for the `/api/app/my/bids` contract-drift repair.
layer: L0 SSOT
freeze_date_local: 2026-04-29
inputs_canonical:
  - docs/00_ssot/my_bids_list_contract_drift_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_bids_list_project_no_preview_runtime_gap_truth_freeze_addendum.md
  - docs/01_contracts/my_bids_list_project_no_preview_contract_refinement_addendum.md
  - docs/03_bff/my_bids_list_project_no_preview_bff_surface_refinement_addendum.md
  - docs/04_frontend/my_bids_list_project_no_preview_frontend_consumption_note.md
  - docs/00_ssot/my_bids_list_day4_flutter_regression_report_addendum.md
---

# My Bids List Day 5 / Day 6 Cloud Release Receipt Addendum

## 1. Scope Verdict

本回执只覆盖 `GET /api/app/my/bids` 的 BFF 字段透传修复：

1. BFF 必须透传 `projectNo`。
2. BFF 必须透传 `proposalSummaryPreview`。
3. Flutter 继续严校验，不把字段降级成 optional。
4. Server 仍是字段真源，BFF 不重算业务真值。

本回执不覆盖：

1. 新增竞标摘要入口。
2. 新增 my bids 工作台。
3. 修改 Server 状态机。
4. 修改竞标、支付、订单、消息楼业务边界。

## 2. Stage Gate Result

| Stage | Verdict | Evidence |
| --- | --- | --- |
| Day 4 Flutter regression | Passed | My-bids targeted tests passed, shell main-chain tests passed, and full `my_project_private_carry_test.dart` passed. |
| Day 5 Cloud BFF release | Passed | BFF new release built, BFF transport test passed, service restarted, health checks passed, authenticated JSON verified, UI verified. |
| Day 6 Server patch | Not needed | Cloud Server source and dist already output `projectNo` and `proposalSummaryPreview`. |

Next stage is allowed for this bounded fix. A later round may register the `snapshotReadable` direct bid-summary entry, but it is outside this repair.

## 3. Cloud Release

Previous BFF release:

- `/srv/releases/bff/20260429013340-membership-fee-runtime-alignment/apps/bff`

New BFF release:

- `/srv/releases/bff/20260429040649-my-bids-project-no-preview-bff/apps/bff`

Active Server release:

- `/srv/releases/server/20260429013340-membership-fee-runtime-alignment`

Runtime status after release:

- `exhibition-bff`: active
- `exhibition-server`: active
- `/srv/apps/bff/current` points to the new BFF release

Rollback handle:

- Previous BFF release is recorded at `/srv/releases/bff/20260429040649-my-bids-project-no-preview-bff/PREV_BFF_RELEASE.before-switch`.

## 4. Cloud Build And Test Evidence

Cloud command family:

```bash
cd /srv/releases/bff/20260429040649-my-bids-project-no-preview-bff/apps/bff
npm run build
node --test test/my-bid-transport.test.cjs
```

Result:

- BFF build passed.
- `my-bid-transport.test.cjs` passed 3/3:
  - route materialization
  - service forwarding and response shaping
  - read-model required-field guard for `projectNo` and `proposalSummaryPreview`

## 5. Runtime Artifact Evidence

Cloud BFF current source and dist contain the required guards:

- `/srv/apps/bff/current/src/routes/my_bid/my-bid.read-model.ts`
  - `projectNo: readRequiredString(record.projectNo, 'projectNo')`
  - `proposalSummaryPreview: readRequiredString(record.proposalSummaryPreview, 'proposalSummaryPreview')`
- `/srv/apps/bff/current/dist/apps/bff/src/routes/my_bid/my-bid.read-model.js`
  - runtime JS includes the same required-field reads

Cloud Server current source and dist already contain the Server truth fields:

- `/srv/apps/server/current/src/modules/my_bid/my-bid.query.service.ts`
  - `projectNo: project.projectNo`
  - `proposalSummaryPreview: this.previewProposalSummary(bid.proposalSummary)`
- `/srv/apps/server/current/dist/modules/my_bid/my-bid.query.service.js`
  - runtime JS includes the same fields

## 6. Health And Auth Boundary

BFF health checks through the existing tunnel returned healthy:

- `GET http://127.0.0.1:8080/health/bff/live` -> `200`, `status: ok`
- `GET http://127.0.0.1:8080/health/bff/ready` -> `200`, `status: ready`

Unauthenticated `GET http://127.0.0.1:8080/api/app/my/bids` returned controlled `401 AUTH_SESSION_INVALID`.

Actor-hint-only curl also returned controlled `401 AUTH_SESSION_INVALID` from Server because the cloud whitelist test session is not enabled. This is the expected current-session gate and was not bypassed.

## 7. Authenticated JSON Evidence

A user-approved test account was used through the normal password-login path. The access token was used only in memory for this verification and was not recorded.

Verification flow:

1. `POST /api/app/auth/password/login` -> `200`, `shellBootstrapState: authenticated`.
2. `GET /api/app/my/bids` with `Authorization: Bearer <redacted>` -> `200`.
3. Response had `items.length = 1`.

First item field presence:

| Field | Present |
| --- | --- |
| `bidId` | yes |
| `projectId` | yes |
| `projectNo` | yes |
| `projectTitle` | yes |
| `quoteAmount` | yes |
| `proposalSummaryPreview` | yes |
| `submittedAt` | yes |
| `outcomeState` | yes |
| `canOpenBidThread` | yes |
| `canOpenBidResult` | yes |
| `snapshotReadable` | yes |

Sanitized first item sample:

```json
{
  "projectNo": "EXH-2026-D93841",
  "projectTitle": "教育装备展 - 新东方教育",
  "quoteAmount": 185000,
  "proposalSummaryPreview": "交给我做，没问题！",
  "outcomeState": "published",
  "canOpenBidThread": true,
  "canOpenBidResult": false,
  "snapshotReadable": true
}
```

## 8. UI Integration Evidence

Computer Use verified the logged-in Flutter window:

1. Entered `我的` -> `我的项目`.
2. Switched from `我的发布` to `我的竞标`.
3. The page no longer showed:
   - `当前竞标列表暂不可用`
   - `contract drift`
   - `重新读取` as the only available action
4. The page displayed real bid items with:
   - project title
   - project number
   - quote amount
   - proposal summary preview
   - `沟通与投标`
5. Tapping `沟通与投标` opened the bid thread page and displayed:
   - project id
   - bid id
   - thread status `open`
   - participant cards
   - message composer

BFF runtime log also recorded:

- `GET /server/my/bids upstream_status=200`

## 9. Final Verdict

The bounded `/api/app/my/bids` contract-drift repair is closed:

1. The most stable path was BFF-only field透传修复.
2. The lowest-cost path was no Flutter downgrade and no Server patch.
3. The current-stage fit is correct because it preserves Server truth and Flutter strict contract gates.
4. The riskier path would have been making Flutter fields optional or adding a second read model/status machine.

Server Day 6 patch is explicitly not required.
