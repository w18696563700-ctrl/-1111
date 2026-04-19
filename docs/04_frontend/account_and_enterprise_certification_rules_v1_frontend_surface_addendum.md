---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side consumption and page-family boundary for Package 1 account access, organization handoff, certification consumption, and bounded device security under the current App truth system.
layer: L3 Frontend
---

# 《账户与企业认证规则 V1》Frontend Surface Addendum

## Scope
- This addendum applies only to the Package 1 frontend surface for:
  - login and session bootstrap
  - organization handoff
  - organization and company summary consumption
  - certification current, submit, and resubmit
  - bounded personal-certification current and submit under the same `profile` family
  - bounded device-security read and revoke
- This addendum does not by itself:
  - unlock `apps/mobile` implementation
  - create a second identity truth
  - create a second standalone certification center
  - create a second governance center under `profile`

## Alignment Basis
- This addendum is aligned against:
  - [frontend_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/frontend_ssot.md)
  - [profile_my_building_compact_hub_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md)
  - [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
  - [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)

## Current Building Ownership
- `profile` remains the only current primary building for:
  - current account summary
  - current organization summary
  - certification current / submit / resubmit
  - device list and revoke
- `exhibition` may consume only:
  - bounded eligibility-blocked copy
  - bounded shell-context and certification cues already shaped by `BFF`
- `messages` does not become an identity or certification owner in this package.

## Current Page-family Freeze
- The current accepted frontend page family for Package 1 is limited to:
  - login page
  - OTP verify page
  - first-login organization fork
  - organization create page
  - organization join page
  - organization switch entry
  - certification current page
  - certification submit page
  - certification resubmit page
  - personal certification submit page under the existing certification family
  - company detail entry under `profile`
  - device list page
- The frontend must not create:
  - a second enterprise-center outside `profile`
  - a person-real-name review console outside the existing certification family
  - a risk-center page family
  - a full governance-center page family

## Consumption Boundary
- Flutter App continues to consume `BFF` only.
- Flutter App must not call `Server` directly.
- Flutter App may consume only the current Package 1 route family under:
  - `/api/app/auth/*`
  - `/api/app/shell/context`
  - `/api/app/profile/index`
  - `/api/app/profile/organization/*`
  - `/api/app/profile/certification/*`
  - `/api/app/profile/security/devices*`
- Flutter App must not consume:
  - `/server/admin/*`
  - bare `/auth/*`
  - bare `/organizations/*`
  - bare `/me/*`

## Shell And Guard Order Freeze
- Current frontend guard order remains:
  1. shell bootstrap
  2. login
  3. session refresh
  4. organization
  5. hidden building
  6. role and object permission
  7. certification
- Frontend must not:
  - treat certification as the first gate
  - synthesize approved certification locally
  - synthesize organization scope locally

## Profile Surface Rule
- `我的楼` may show:
  - current account summary
  - `我的公司`
  - certification or membership summary entry
  - settings entry
- `我的公司` handoff remains under the existing `profile` family.
- Certification surface remains bounded to:
  - current state
  - submit
  - resubmit
  - current personal-certification truth
  - personal-certification submit
  - current reject-reason projection when already supplied by `BFF`
- `profile` must not become:
  - admin review console
  - security-event console
  - second public-author tree

## Organization Edit Surface Rule
- `编辑当前组织` 在已存在正式认证资料时，必须拆成两块：
  - `认证主体信息`
  - `组织运营信息`
- `认证主体信息` 只能来自当前 `certification/current` formal truth，只读显示：
  - 认证主体
  - 统一社会信用代码
  - 法定代表人
  - 企业类型
  - 住所
  - 注册资本
  - 成立日期
  - 营业期限
  - 经营范围
- `编辑当前组织` 不得再把以下字段作为可编辑输入暴露：
  - 认证主体名称
  - 统一社会信用代码
  - 营业执照
  - 其他已进入 formal certification truth 的营业执照主字段
- `组织运营信息` 当前只承接最小可编辑字段：
  - 所在省
  - 所在市
  - 联系人
  - 联系电话
- 若要修改认证主体或营业执照主字段，当前只能经由 `更正认证资料` 入口，不得在组织编辑页形成第二条写链。

## Device Security Surface Rule
- Device-security surface remains bounded to:
  - current device list
  - revoke current or selected device
- Frontend must not expose:
  - device trust scoring internals
  - admin-side `security-events`
  - raw internal risk tags

## Exhibition-side Consumption Rule
- `exhibition` may consume only bounded blocked-state copy such as:
  - 当前需先登录
  - 当前需先完成组织承接
  - 当前企业认证未完成
  - 当前我的认证未完成
  - 当前我的认证已锁定其他账号
  - 当前认证审核中
  - 当前认证未通过，请按驳回原因补充后重试
  - 当前权限不足
- `exhibition` must not own:
  - certification submit UI
  - organization create/join UI
  - a second eligibility state machine

## Explicit Non-goals
- No implementation unlock by this addendum alone
- No second governance center under `profile`
- No person-real-name review family outside the existing certification family
- No `Server` direct call from Flutter App
- No `BFF`-bypass auth or certification path
- No admin route exposure in Flutter App

## Formal Conclusion
- Current formal conclusion:
  - Package 1 frontend surface is bounded to login, shell bootstrap, organization handoff, certification consumption, bounded personal-certification consumption, and device-security consumption under `profile`
  - `profile` remains the primary current-user and current-organization entry building for this package
  - `exhibition` may consume only bounded blocked-state copy and eligibility cues
  - current frontend freeze is docs-only and does not unlock implementation
