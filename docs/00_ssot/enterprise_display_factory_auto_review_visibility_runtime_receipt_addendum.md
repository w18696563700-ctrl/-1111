---
owner: Codex 总控
status: recorded
purpose: Record the 2026-04-18 factory workbench auto-review, status-note surfacing, and list-visibility runtime repair for the enterprise display corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_factory_workbench_and_exhibition_surface_addendum.md
---

# 《优秀工厂工作台自动审核与列表可见性运行回执》

## 1. Scope

本回执只记录以下闭环：
- 优秀工厂首次申请自动审核
- 自动审核未命中时的审核说明透传
- 优秀工厂列表可见性的 recommendation slot 补齐
- 历史 submitted 工厂申请的运维补审

## 2. Runtime release

### 2.1 Server

- previous current:
  - `/srv/releases/server/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2`
- intermediate current:
  - `/srv/releases/server/20260418200948-enterprise-factory-auto-review-status-note`
- active current:
  - `/srv/releases/server/20260418201959-enterprise-factory-auto-slot`
- restart:
  - `systemctl restart exhibition-server`
- active check:
  - `systemctl is-active exhibition-server = active`

### 2.2 BFF

- previous current:
  - `/srv/releases/bff/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2/apps/bff`
- active current:
  - `/srv/releases/bff/20260418200948-enterprise-factory-auto-review-status-note/apps/bff`
- restart:
  - `systemctl restart exhibition-bff`
- active check:
  - `systemctl is-active exhibition-bff = active`

## 3. Behavior freeze

### 3.1 Factory application auto-review

- Factory application submit / read catch-up must no longer stop at `submitted` when all of the following are true:
  - `applyBoardType = factory`
  - `primaryBoardType = factory`
  - `enterpriseStatus = unpublished`
  - at least one case has `caseCoverFileAssetId` or `caseMediaFileAssetIds`
- In that satisfied path, system truth must converge to:
  - `applicationStatus = approved`
  - `reviewerId = system:auto-review`
  - factory listing `enterpriseStatus = published`
  - factory listing `displayStatus = visible`

### 3.2 Factory list visibility

- Factory publication alone is not enough for the exhibition-side excellent-factory list.
- The active list also depends on `enterprise_recommendation_slot`.
- Therefore factory auto-review repair must also ensure a valid active slot when a free position exists.
- This round freezes:
  - auto-created factory slot uses `sourceType = auto_review`
  - active slot window uses `now -> now + 30 days`
  - first free position among `1,2,3` is selected

### 3.3 Status explanation

- `manual_review_required` must not remain silent.
- App-facing application status and factory workbench latestApplication must surface `reviewNote`.
- Mobile status panels must prioritize `reviewNote` over raw `rejectionReason` codes when both exist.

## 4. Historical operation catch-up executed

Target application:
- `applicationId = 4b780989-240f-47bc-86c9-5d35a8433673`
- `enterpriseId = a9b46040-956e-44fd-8e35-e3c533687e27`

Operational repair executed on 2026-04-18:
- application updated from `submitted` to `approved`
- listing updated from `unpublished + hidden` to `published + visible`
- active factory recommendation slot inserted:
  - `slotPosition = 2`
  - `slotStatus = active`
  - `sourceType = auto_review`

Result snapshot after operation:
- `applicationStatus = approved`
- `reviewNote = auto-review ops catch-up v1`
- `enterpriseStatus = published`
- `displayStatus = visible`

## 5. No-regression guard

后续任何代码或运行态调整，不得再出现以下回退：
- 工厂满足自动审核条件却继续停在 `submitted`
- 工厂自动通过后没有进入 `published + visible`
- 工厂列表仍要求人工额外补 slot 才能看见，但系统未自动处理该依赖
- `manual_review_required` 继续不透出 `reviewNote`
