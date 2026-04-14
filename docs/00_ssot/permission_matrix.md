---
owner: Codex 总控
status: active
purpose: Freeze role and object-permission baseline.
layer: L1 Domain
---

# Permission Matrix

## Roles
- `buyer_admin`
- `buyer_member(scoped)`
- `supplier_admin`
- `supplier_member(scoped)`
- `platform_reviewer`
- `platform_support`
- `platform_super_admin`
- `operator` (server-internal only, not an app-facing role)

## High-level Matrix
| Action | buyer_admin | buyer_member | supplier_admin | supplier_member | platform roles |
|---|---|---|---|---|---|
| Create project | allow | scoped | deny | deny | observe/review |
| View invited project | allow | scoped | allow | scoped | allow |
| Submit bid | eligible by org-type + dual-cert | scoped eligible by org-type + dual-cert | eligible by org-type + dual-cert | scoped eligible by org-type + dual-cert | observe |
| Award order | allow | scoped | deny | deny | observe |
| Confirm contract | allow | scoped | allow | scoped | observe |
| Submit milestone | deny | scoped view | allow | scoped | observe/review |
| Submit inspection | allow | scoped | allow | scoped | observe/review |
| Submit inspection recheck | deny | deny | allow | scoped | deny |
| Submit rating | allow | scoped | deny | deny | deny |
| Open dispute | allow | scoped | allow | scoped | process |
| Withdraw dispute | allow | scoped | allow | scoped | deny |
| View instance todo | allow | scoped | allow | scoped | deny |
| Consume instance todo routeTarget | allow | scoped | allow | scoped | deny |
| View registered instance entry | allow | scoped | allow | scoped | deny |
| Consume registered instance entry | allow | scoped | allow | scoped | deny |

## Bid Submit Gate
- 旧规则：
  - `Submit bid` 以前置 `supplier_* roleKey` 作为硬门槛。
  - 因此即使当前主体已经完成企业认证与我的认证，只要当前成员角色仍显示为 `buyer_*`，也会在入口前被直接拒绝。
- 新规则：
  - `Submit bid` 不再以前置 `supplier_* roleKey` 作为入口硬门槛。
  - 当前 active app-facing membership 只要同时满足以下条件，即可继续进入竞标主链：
    - `organizationType` 属于 `supplier` 或 `both`
    - 企业认证 `approved`
    - 我的认证 `approved`
    - `qualifiedForCurrentActor = true`
- 仍然保持不变：
  - `organizationType` 属于 `buyer` / `demand` / `platform` 时，禁止参与竞标
  - `owner_relation_not_allowed`
  - 项目必须处于 `published`
  - `lockedToOtherActor`
  - 其他后续真实业务规则
- 解释边界：
  - `buyer_admin` / `buyer_member(scoped)` 在 `organizationType=both` 下不再因为角色名本身被前置硬拦截。
  - 该变化只影响 `Submit bid` 准入主门槛，不改写其他动作的既有 role-gated truth。

## Internal-only Controlled Actions
- `InspectionDecisionApplicationService.applyInspectionDecision`
  - trigger role: `operator`
  - exposure: server-internal only
  - not app-facing
  - not a BFF capability

## Dispute Withdraw Scoped Rule
- `POST /api/app/dispute/withdraw` is app-facing, but it is not a general
  buyer/supplier action.
- Allowed roles:
  - `buyer_admin`
  - `buyer_member` with scope
  - `supplier_admin`
  - `supplier_member` with scope
- Additional withdraw gates:
  - only the opener side may withdraw
  - organization scope must match `openedByOrganizationId`
- Explicitly not allowed:
  - `operator`
  - `platform_reviewer`
  - `platform_support`
  - `platform_super_admin`
  - missing role header
  - any actor outside opener-side scope

## Instance Todo Visibility And routeTarget Consumption
- `instance_todo` is the only currently frozen todo-touchpoint carrier.
- `instance_todo` is not a second business truth or a general-purpose message center.
- Visibility and routeTarget consumption must follow existing instance access truth
  and may not invent a second permission system.
- `registered instance entry` is the L1 domain-level permission name for the same
  already-approved instance-entry consumption boundary referenced by
  `instance_todo`.
- Viewing or consuming a registered instance entry must not create any new actor
  eligibility beyond the already-existing instance entry truth.

### Allowed roles
- `buyer_admin`
  - may view `instance_todo` only when the referenced instance already belongs to the
    buyer side and the existing instance entry is already consumable by that actor
- `buyer_member(scoped)`
  - may view `instance_todo` only when the referenced instance belongs to the buyer
    side and the actor scope already covers that instance
- `supplier_admin`
  - may view `instance_todo` only when the referenced instance already belongs to the
    supplier side and the existing instance entry is already consumable by that actor
- `supplier_member(scoped)`
  - may view `instance_todo` only when the referenced instance belongs to the supplier
    side and the actor scope already covers that instance

### Building boundary
- Allowed consumer buildings for registered instance entry consumption:
  - `exhibition`
  - `messages`
- Explicitly denied as registered-entry consumer buildings:
  - `renovation`
  - `custom_furniture`
  - `profile`
  - `admin`

### Consumption principle
- Registered instance entry consumption eligibility must strictly follow the
  existing instance entry consumption truth.
- Registered instance entry consumption must not create a new role grant, a new
  scope grant, or a second permission system.
- If an actor cannot directly consume the existing signed instance entry, that
  actor must not receive or consume the corresponding registered instance entry.

### routeTarget rule
- `routeTarget` consumption must not exceed the same actor's existing instance-entry
  consumption boundary.
- If an actor cannot consume the referenced instance entry directly, that actor must
  not receive or consume the corresponding `instance_todo`.

### Explicitly not allowed
- `operator`
- `platform_reviewer`
- `platform_support`
- `platform_super_admin`
- missing role header

### Not visible / not consumable cases
- missing role header
- missing actor identity
- missing organization scope
- scope does not match the referenced instance
- the actor cannot already consume the referenced instance entry directly
- the registration item points to an unsigned or unapproved instance entry
- the registration item points to an unfrozen canonical path
- the registration item points to a building outside the allowed building set
- any actor outside the buyer/supplier instance scope

## Admin Scope
- `Admin` uses `Server` Admin APIs only.
- Review and audit access must be explicit and traceable.

## Hidden Building Rule
- `renovation` and `custom_furniture` permissions and route keys must exist even while hidden.
