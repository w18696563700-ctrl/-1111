# Profile Factory Display Entry Published Change Routing Contract Compatibility Addendum

## Contract Impact
- No app-facing API shape changes.
- No new route family is introduced.
- Existing app-facing routes are reused:
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`

## Client Decision Rule
- The profile entry may call generic factory workbench first to discover `enterpriseId` and `latestApplication.applicationStatus`.
- The profile entry may call published-change status as a lightweight gate before navigating.
- Navigation target selection is client-only behavior; route contracts stay backward compatible.
