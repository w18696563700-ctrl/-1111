---
owner: Codex 总控
status: active
purpose: Record the cloud release and verification receipt for both-organization project-create eligibility repair.
layer: L0 SSOT
created_at: 2026-04-27
---

# 《both 主体创建项目资格云端修复回执》

## 1. 当前最小闭环

- 修复对象：
  - `organizationType=both`
  - 当前成员角色为 `supplier_admin / supplier_member(scoped)`
  - 企业认证 `approved`
  - 创建项目被旧 `buyer_role_not_allowed` 前置硬拦截
- 新规则：
  - `both` 主体企业认证通过后可创建项目；
  - 纯 `supplier` 主体仍不可创建项目；
  - `demand/buyer` 主体仍要求买方侧发布角色。

## 2. 云端 release

- Server previous：
  - `/srv/releases/server/20260427001500-forum-interaction-inbox`
- Server current：
  - `/srv/releases/server/20260427004218-both-org-project-create-eligibility`
- BFF previous：
  - `/srv/releases/bff/20260427001500-forum-interaction-inbox/apps/bff`
- BFF current：
  - `/srv/releases/bff/20260427004218-both-org-project-create-eligibility/apps/bff`
- 运行态：
  - `exhibition-server = active`
  - `exhibition-bff = active`
  - PM2 legacy route processes stopped and no longer own `3000/3001`

## 3. Verification

- Local:
  - `corepack pnpm --dir apps/server build` passed
  - `corepack pnpm --dir apps/bff build` passed
  - `node --test apps/server/test/project-publish-eligibility.test.cjs` passed `22/22`
  - `node --test apps/bff/test/project-create-eligibility-error-mapping.test.cjs` passed `7/7`
- Cloud release:
  - Server build passed
  - Server eligibility test passed `22/22`
  - BFF runtime dist test passed `7/7`
  - BFF temporary port boot probe passed
  - `GET /health/server/live` through Nginx returned `200`
  - `GET /health/bff/live` through Nginx returned `200`
  - local tunnel `127.0.0.1:8080/health/bff/live` returned `200`
- Target read-only shell projection:
  - `organizationType=both`
  - `roleKeys=["supplier_admin"]`
  - `certificationStatus=approved`
  - `projectCreateEligibility.canCreateProject=true`

## 4. 需要保留但暂不开通

- 不开放纯 `supplier` 主体创建项目。
- 不开放未认证主体创建项目。
- 不用 BFF 或 Flutter 持有第二套创建资格真相。
- 不在真实用户账号下写入测试项目作为验收证据。

## 5. 后续扩展位

- 可补专用 cloud smoke：只读检查 `shell/context.projectCreateEligibility`，写链路继续由显式开关控制。
- 可把当前 systemd + release current 流程固化成单一 `deploy_server_release.sh / deploy_bff_release.sh`。

## 6. Judgment

- 更稳：Server 继续做唯一资格真源。
- 更省成本：复用现有 `organizationType=both` 与 shell projection。
- 更适合当前阶段：只修当前主体误拦截，不重开创建页交易流。
- 风险更大：只改前端 guard 或放开全部 supplier 角色。
