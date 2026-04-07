---
owner: Codex 总控
status: draft
purpose: Freeze the V1 enterprise-hub field contract, state families, and app-facing/admin-facing API contract package after aligning with the current App truth boundaries.
layer: L2 Contracts
---

# Enterprise Hub V1 Fields States API Contract Addendum

## Scope
- This addendum freezes the implementation-facing contract package for
  `展链库 V1`.
- It defines:
  - entity fields
  - state families
  - list/detail payload shape
  - application payload shape
  - app-facing path family
  - admin-facing path family
- It does not:
  - approve code implementation by itself
  - modify current `openapi.yaml` in this file
  - generate contract outputs

## Contract Ownership
- App-facing contracts remain inside `/api/app/exhibition/enterprise-hub/*`.
- Admin-facing contracts remain inside `/server/admin/exhibition/enterprise-hub/*`.
- Home first-screen card summaries remain under:
  - `GET /api/app/exhibition/home`

## Board Enum
- `company`
- `factory`
- `supplier`

## Core Listing Truth

### enterprise_listing
- `id: string`
- `organizationId: string`
- `primaryBoardType: company | factory | supplier`
- `secondaryCapabilities: Array<company | factory | supplier>`
- `name: string`
- `shortIntro: string`
- `fullIntro?: string`
- `logoFileAssetId?: string`
- `coverFileAssetId?: string`
- `provinceCode: string`
- `provinceName: string`
- `cityCode: string`
- `cityName: string`
- `address?: string`
- `foundedAt?: string`
- `teamSizeRange?: 1_10 | 11_30 | 31_100 | 101_300 | 300_plus`
- `cooperationModes: string[]`
- `legalNameSnapshot?: string`
- `unifiedSocialCreditCodeSnapshot?: string`
- `verificationStatusSnapshot?: unverified | pending | verified | failed`
- `enterpriseStatus: unpublished | published | offline | frozen`
- `displayStatus: hidden | visible`
- `contactVisible: boolean`
- `publishedAt?: string`
- `createdAt: string`
- `updatedAt: string`

## Board-specific Profiles

### enterprise_profile_company
- `enterpriseId: string`
- `exhibitionTypes: string[]`
- `serviceItems: string[]`
- `serviceCities: string[]`
- `teamSize?: number`
- `maxProjectScale?: string`
- `averageDeliveryCycleDays?: number`
- `knownClients?: string[]`
- `qualificationDesc?: string`
- `projectManagementCapability?: string`
- `onsiteExecutionCapability?: string`
- `boardScoreCompany?: number`
- `updatedAt: string`

### enterprise_profile_factory
- `enterpriseId: string`
- `processTypes: string[]`
- `coreProducts: string[]`
- `equipmentList?: string[]`
- `plantAreaSqm?: number`
- `monthlyCapacityDesc?: string`
- `urgentOrderCapability?: none | 24h | 48h | 72h | custom`
- `urgentCycleDesc?: string`
- `warehouseCapability?: boolean`
- `transportCapability?: none | partner_only | self_owned | self_and_partner`
- `maxOrderCapacityDesc?: string`
- `productionQualificationDesc?: string`
- `deliveryRadiusDesc?: string`
- `boardScoreFactory?: number`
- `updatedAt: string`

### enterprise_profile_supplier
- `enterpriseId: string`
- `supplyCategories: string[]`
- `supplyMode: string[]`
- `coreProductsOrServices: string[]`
- `responseSlaDesc?: string`
- `stockStatusDesc?: string`
- `deliveryRange?: string`
- `aftersalesPolicy?: string`
- `partnerCasesDesc?: string`
- `supplyQualificationDesc?: string`
- `boardScoreSupplier?: number`
- `updatedAt: string`

## Shared Support Tables

### enterprise_case
- `id: string`
- `enterpriseId: string`
- `boardType: company | factory | supplier`
- `title: string`
- `exhibitionType?: string`
- `city?: string`
- `eventTime?: string`
- `summary: string`
- `caseCoverFileAssetId: string`
- `caseMediaFileAssetIds: string[]`
- `isFeatured: boolean`
- `sortOrder?: number`
- `caseStatus: draft | pending_review | approved | rejected | hidden`
- `reviewNote?: string`
- `createdAt: string`
- `updatedAt: string`

### enterprise_certification_snapshot
- `id: string`
- `enterpriseId: string`
- `certificationType: business_license | factory_proof | service_capability_proof | brand_authorization | project_proof | other`
- `certificationName: string`
- `certificationFileAssetId: string`
- `certStatus: pending | approved | rejected`
- `reviewerId?: string`
- `reviewNote?: string`
- `verifiedAt?: string`

### enterprise_service_area
- `id: string`
- `enterpriseId: string`
- `areaType: registered_location | service_area | delivery_area | project_area`
- `provinceCode: string`
- `provinceName: string`
- `cityCode?: string`
- `cityName?: string`

### enterprise_contact
- `id: string`
- `enterpriseId: string`
- `contactName: string`
- `mobile?: string`
- `wechat?: string`
- `phone?: string`
- `email?: string`
- `position?: string`
- `isPrimary: boolean`
- `visibleToPublic: boolean`

### enterprise_application
- `id: string`
- `enterpriseId: string`
- `applyBoardType: company | factory | supplier`
- `applicantName: string`
- `applicantMobile: string`
- `submittedMaterialSnapshot?: object`
- `applicationStatus: draft | submitted | under_review | revision_required | approved | rejected`
- `rejectionReason?: string`
- `submittedAt?: string`
- `reviewedAt?: string`
- `reviewerId?: string`

### enterprise_review_summary
- `enterpriseId: string`
- `avgScore?: number`
- `reviewCount?: number`
- `keywordTags?: string[]`
- `deliveryScore?: number`
- `qualityScore?: number`
- `communicationScore?: number`
- `lastUpdatedAt?: string`

### enterprise_recommendation_slot
- `id: string`
- `boardType: company | factory | supplier`
- `slotPosition: 1 | 2 | 3`
- `enterpriseId: string`
- `startAt: string`
- `endAt: string`
- `sourceType: manual | score_based | campaign`
- `scoreSnapshot?: number`
- `slotStatus: pending | active | expired | disabled`
- `createdAt: string`

## State Families

### application_status
- `draft`
- `submitted`
- `under_review`
- `revision_required`
- `approved`
- `rejected`

### enterprise_status
- `unpublished`
- `published`
- `offline`
- `frozen`

### display_status
- `hidden`
- `visible`

### case_status
- `draft`
- `pending_review`
- `approved`
- `rejected`
- `hidden`

### cert_status
- `pending`
- `approved`
- `rejected`

### slot_status
- `pending`
- `active`
- `expired`
- `disabled`

## Required-field Rules

### Before application submit
- `name`
- `primaryBoardType`
- `shortIntro`
- `provinceCode`
- `provinceName`
- `cityCode`
- `cityName`
- at least one public or primary contact
- at least one certification snapshot
- at least one board profile
- at least one case

### Company profile minimum
- `exhibitionTypes`
- `serviceItems`
- `serviceCities`

### Factory profile minimum
- `processTypes`
- `coreProducts`

### Supplier profile minimum
- `supplyCategories`
- `supplyMode`
- `coreProductsOrServices`

## List Query Contract

### GET /api/app/exhibition/enterprise-hub/enterprises
Query:
- `boardType` required
- `keyword?`
- `provinceCode?`
- `cityCode?`
- `certifiedOnly?`
- `sortBy?`
- `page?`
- `pageSize?`
- company-only:
  - `exhibitionType?`
  - `serviceCity?`
  - `caseCountRange?`
  - `reputationLevel?`
- factory-only:
  - `processType?`
  - `plantAreaRange?`
  - `urgentCapability?`
  - `warehouseCapability?`
- supplier-only:
  - `supplyCategory?`
  - `supplyMode?`
  - `responseLevel?`

### List response shape
- `recommended: EnterpriseListItem[]`
- `items: EnterpriseListItem[]`
- `pagination`

### EnterpriseListItem
- `enterpriseId: string`
- `boardType: company | factory | supplier`
- `name: string`
- `logoUrl?: string`
- `provinceName: string`
- `cityName: string`
- `primaryBoardLabel: string`
- `secondaryCapabilityLabels: string[]`
- `shortIntro: string`
- `certificationLabel?: string`
- `caseCount: number`
- `avgScore?: number`
- `keywordTags?: string[]`
- `boardHighlights: object`

## Detail Contract

### GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}
Query:
- `boardType` required

### Detail response shape
- `header`
- `basicInfo`
- `boardProfile`
- `serviceAreas`
- `cases`
- `certifications`
- `reviewSummary`
- `contacts`

### header
- `enterpriseId`
- `name`
- `logoUrl?`
- `primaryBoardType`
- `secondaryCapabilities`
- `shortIntro`
- `provinceName`
- `cityName`
- `verificationStatus`

### basicInfo
- `legalName?`
- `foundedAt?`
- `teamSizeRange?`
- `fullIntro?`

## Recommendation Contract

### GET /api/app/exhibition/enterprise-hub/recommendations
Query:
- `boardType` required

### Recommendation response shape
- `boardType`
- `slots: EnterpriseListItem[]`

## Application-side Contracts

### POST /api/app/exhibition/enterprise-hub/applications
Request:
- `applyBoardType`
- `applicantName`
- `applicantMobile`
- `enterprise`

Response:
- `applicationId`
- `enterpriseId`
- `applicationStatus`

### PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic
Updates only:
- listing basic fields
- intro fields
- location fields
- contact visibility and cooperation modes

### PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/company
### PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory
### PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/supplier

### POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases

### POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit
Submit-time checks must reject when any required listing, contact,
certification, board-profile, or case requirement is missing.

### GET /api/app/exhibition/enterprise-hub/applications/{applicationId}
Returns:
- `applicationId`
- `enterpriseId`
- `applyBoardType`
- `applicationStatus`
- `rejectionReason?`
- `submittedAt?`
- `reviewedAt?`

## Admin-facing Contracts

### GET /server/admin/exhibition/enterprise-hub/applications
Query:
- `applicationStatus?`
- `boardType?`
- `provinceCode?`
- `keyword?`
- `page?`
- `pageSize?`

### GET /server/admin/exhibition/enterprise-hub/applications/{applicationId}
Must expose:
- listing basic info
- board profile data
- cases
- certification snapshots
- contacts
- review history

### POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review
Request:
- `action: approved | revision_required | rejected`
- `reviewNote`

### POST /server/admin/exhibition/enterprise-hub/enterprises/{enterpriseId}/publish
Allowed only when:
- related application is approved
- enterprise status is `unpublished`

### POST /server/admin/exhibition/enterprise-hub/enterprises/{enterpriseId}/offline
### POST /server/admin/exhibition/enterprise-hub/enterprises/{enterpriseId}/freeze

### POST /server/admin/exhibition/enterprise-hub/recommendation-slots
### GET /server/admin/exhibition/enterprise-hub/recommendation-slots

## Error-code Family
- `ZLK_INVALID_BOARD_TYPE`
- `ZLK_MISSING_REQUIRED_FIELDS`
- `ZLK_INVALID_STATE_TRANSITION`
- `ZLK_ENTERPRISE_NOT_FOUND`
- `ZLK_APPLICATION_NOT_FOUND`
- `ZLK_PROFILE_NOT_COMPLETED`
- `ZLK_CASE_NOT_FOUND`
- `ZLK_CERTIFICATION_NOT_FOUND`
- `ZLK_ENTERPRISE_NOT_APPROVED`
- `ZLK_PERMISSION_DENIED`
- `ZLK_DUPLICATE_RECOMMENDATION_SLOT`
- `ZLK_CERTIFICATION_REQUIRED`
- `ZLK_CONTACT_REQUIRED`
- `ZLK_CASE_REQUIRED`
- `ZLK_INTERNAL_ERROR`

## Non-goals
- no online order placement
- no online payment
- no online contract signing
- no IM consultation
- no deep map capability
- no complex ranking expansion
- no deep public review system
- no multi-board simultaneous public exposure

## Contract Conclusion
- `展链库 V1` now has a frozen contract-ready package for fields, state
  families, app-facing paths, and admin-facing paths.
- The next change step may update:
  - `docs/01_contracts/openapi.yaml`
  - `packages/contracts/**`
- No implementation file should outrun this contract package.
