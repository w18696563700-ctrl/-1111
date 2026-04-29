# Platform Pricing Day 11 Cloud Validation Receipt

## Scope

Stage: Day 11 cloud validation through the Aliyun tunnel.

This stage validates the currently deployed Aliyun BFF/Server surface through `127.0.0.1:8080`. It is validation only. It does not deploy, restart, rollback, migrate, or modify cloud runtime.

Tunnel observed:

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

Local port `8080` was already listening through an `ssh` process.

## Authentication Context

Cloud login validation completed through:

```http
POST /api/app/auth/password/login
```

Result:

- Status: 200.
- `shellBootstrapState`: `authenticated`.
- Shell context returned current user and organization.
- Current organization type: `both`.
- Certification status: `approved`.
- Project create eligibility: `canCreateProject = true`.
- Visible buildings: `exhibition`, `messages`, `profile`.

Credentials and tokens are not recorded in this receipt.

## Pricing Route Validation

Project list validation:

```http
GET /api/app/project/list?page=1&pageSize=5
```

Result:

- Status: 200.
- Cloud returned 5 project items.
- Sample project: `a541e9ac-1c0f-4224-a399-25c6b8a7f310`.

New pricing summary route validation:

```http
GET /api/app/project/a541e9ac-1c0f-4224-a399-25c6b8a7f310/pricing-summary
```

Result:

- Status: 404.
- Body: `Cannot GET /api/app/project/a541e9ac-1c0f-4224-a399-25c6b8a7f310/pricing-summary`.

Assessment:

- This is a veto blocker.
- The deployed cloud BFF does not expose the new project-scoped pricing route family required by FP1/FP2 and FP3/FP4.
- The current cloud deployment is behind the local implementation and cannot validate the new 200/4000 pricing mainline.

## Project Publish And Bid Chain

Execution decision:

- Not executed beyond read-only project list and pricing route probe.

Reason:

- The new pricing route family is missing in cloud.
- Continuing into project publish or bid submit write chains would create cloud test data against a known mismatched deployment.
- A real publish-chain result from this deployment would not be valid evidence for the new pricing rules.

Gate impact:

- Project true publish chain: blocked by missing cloud pricing route.
- Bid authorization chain: blocked by missing cloud pricing route.

## Enterprise Hub Validation

Company board:

- `GET /api/app/exhibition/enterprise-hub/company/workbench`: 200.
- `GET /api/app/exhibition/enterprise-hub/company/enterprises?page=1&pageSize=3`: 200.
- `GET /api/app/exhibition/enterprise-hub/company/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9`: 200.
- `GET /api/app/exhibition/enterprise-hub/company/recommendations`: 200.
- Sample company: `重庆坤特展览展示有限公司`.

Factory board:

- `GET /api/app/exhibition/enterprise-hub/factory/workbench`: 200.
- `GET /api/app/exhibition/enterprise-hub/factory/enterprises?page=1&pageSize=3`: 200.
- `GET /api/app/exhibition/enterprise-hub/factory/enterprises/a9b46040-956e-44fd-8e35-e3c533687e27`: 200.
- `GET /api/app/exhibition/enterprise-hub/factory/recommendations`: 200.
- Sample factory: `重庆海川展览工厂`.

Supplier board:

- `GET /api/app/exhibition/enterprise-hub/supplier/workbench`: 200.
- `GET /api/app/exhibition/enterprise-hub/supplier/enterprises?page=1&pageSize=3`: 200.
- `GET /api/app/exhibition/enterprise-hub/supplier/enterprises/c0576f5c-854c-4b78-9f93-6d57e55d8b47`: 200.
- `GET /api/app/exhibition/enterprise-hub/supplier/recommendations`: 200.
- Sample supplier: `重庆坤特展览展示有限公司`.

Assessment:

- Company/factory/supplier cloud home, list, detail, and recommendation surfaces are available.
- This part passes cloud validation.

## Forum And Message Validation

Forum read surfaces:

- `GET /api/app/forum/feed?page=1&pageSize=5`: 200.
- `GET /api/app/forum/topic/list?page=1&pageSize=5`: 200.
- `GET /api/app/forum/me/index`: 200.
- `GET /api/app/forum/interaction/inbox?tab=replies&page=1&pageSize=5`: 200.
- `GET /api/app/forum/interaction/inbox?tab=likes&page=1&pageSize=5`: 200.
- `GET /api/app/forum/interaction/inbox?tab=follows&page=1&pageSize=5`: 200.

Forum reversible action validation:

- Sample post: `ac2e788d-4d5e-4b0d-a0e4-ca708927d963`.
- `POST /api/app/forum/post/like` with `like`: 202.
- `POST /api/app/forum/post/like` with `unlike`: 202.
- `POST /api/app/forum/post/bookmark` with `add`: 202.
- `POST /api/app/forum/post/bookmark` with `remove`: 202.
- Final post detail returned `viewerHasLiked = false` and `viewerHasBookmarked = false`, matching the initial state.

Message read surface:

- `GET /api/app/message/interactions?page=1&pageSize=5`: 200.
- Returned project communication lane and counterpart conversation card.

Assessment:

- Forum login-state read/action chain passes.
- Message interaction read surface passes.

## Veto Gates

Failed veto gate:

- Cloud BFF does not expose `/api/app/project/:projectId/pricing-summary`.

Blocked by this veto:

- New 200 yuan project authenticity sincerity cloud validation.
- New 4000 yuan bid service fee authorization cloud validation.
- Project true publish-chain validation under the new pricing mainline.
- Bid submit-chain validation under the new pricing mainline.
- Release-prep.

## Boundary Confirmation

Touched in this stage:

- Read-only cloud probes.
- Login session establishment.
- Reversible forum like/bookmark actions, restored to initial state.
- Execution receipt documentation.

Not touched in this stage:

- Cloud deployment.
- Cloud process restart.
- Cloud rollback.
- Cloud migration.
- Server/BFF source on Aliyun.
- Local application code.

## Gate Result

Day 11 result: No-Go.

Allowed next stage:

- Day 12 final acceptance with explicit No-Go.
- A separate cloud deployment/route parity stage, if approved.

Not allowed:

- Release-prep.
- Production launch.
- Claiming the new pricing mainline is cloud-validated.
