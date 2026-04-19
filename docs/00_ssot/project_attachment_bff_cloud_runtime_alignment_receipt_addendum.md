---
owner: Codex 总控
status: recorded
purpose: >
  Record the bounded cloud-only BFF runtime alignment that exposed the
  app-facing project attachment routes for `我的项目详情 -> 项目详情文书区`,
  including the failed intermediate release, rollback, final active release,
  and ingress verification results.
layer: L0 SSOT
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
  - apps/bff/src/routes/my_project/my-project.module.ts
  - apps/bff/src/routes/my_project/my-project-attachment.controller.ts
  - apps/bff/src/routes/my_project/my-project-attachment.service.ts
  - apps/bff/src/routes/my_project/my-project-attachment.read-model.ts
---

# 项目附件 BFF 云端运行时对齐执行回执

## 1. Incident

- `2026-04-14` 用户在 `我的项目详情 -> 项目详情文书区` 点击 `上传并形成正式附件` 后，Flutter 控制台出现：
  - `POST /api/app/my/projects/{projectId}/attachments status=404`
- 同窗口确认到：
  - 本地 Flutter 通过 `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` 访问云端
  - 不是本地伪 BFF / Server

## 2. Root Cause

- 本地仓库源码已包含：
  - `MyProjectAttachmentController`
  - `MyProjectAttachmentService`
- 首轮排查时曾看到旧 release `20260414010700` 缺失附件运行时产物。
- 继续核查后确认，真正的 active cloud BFF release 实际已切到：
  - `/srv/releases/bff/20260414171252/apps/bff`
- 该 active release 的真实运行时产物位于：
  - `dist/apps/bff/src/routes/my_project`
- 该位置的 `my-project.module.js` 未注册附件控制器，且不存在：
  - `my-project-attachment.controller.js`
  - `my-project-attachment.service.js`
  - `my-project-attachment.read-model.js`
- 同时 cloud current `Server` release 已包含：
  - `ProjectAttachmentController`
- 因此 live `404` 的根因不是 Flutter 本地或 Server 缺失，而是：
  - BFF app-facing 附件路由未部署到当前 active runtime

## 3. Execution

- 首次修复尝试：
  - 新建 release `20260414170325`
  - 覆盖附件相关 source
  - 在云机执行 `npm run build`
- 首次尝试失败原因：
  - 云机 BFF 构建环境缺失完整 TypeScript build 依赖
  - 且该 release 根未携带 `packages/contracts`
  - 导致 BFF 启动时报 `Cannot find module '../../../../packages/contracts/src/generated/app-api.types'`
- 第二次尝试：
  - 新建 release `20260414170745`
  - 覆盖了附件相关运行时产物
  - 但后续核查确认该 release 并不是实际 active service 所在 release
- 最终修复策略：
  - 基于真实 active release `20260414171252` 新建 `20260414174134`
  - 仅覆盖 `apps/bff/src/routes/my_project` 内：
    - `my-project.module.ts`
    - `my-project-attachment.controller.ts`
    - `my-project-attachment.service.ts`
    - `my-project-attachment.read-model.ts`
  - 仅覆盖 `dist/apps/bff/src/routes/my_project` 内对应运行时产物
  - 补充 `dist/main.js -> dist/apps/bff/src/main.js` 启动 shim
  - 不再运行云机全量 `nest build`

## 4. Active Runtime After Repair

- 当前 active BFF release：
  - `/srv/releases/bff/20260414174134/apps/bff`
- 当前 symlink：
  - `/srv/apps/bff/current -> /srv/releases/bff/20260414174134/apps/bff`
- 当前 service：
  - `exhibition-bff.service = active`
- 当前运行入口补充事实：
  - `systemd` 仍以 `ExecStart=/usr/bin/node dist/main.js` 启动
  - 该批 release 原始产物只有 `dist/apps/bff/src/main.js`
  - 本次已补 `dist/main.js` shim，避免重启后再次出现 `MODULE_NOT_FOUND`

## 5. Verification

- service 校验：
  - `exhibition-bff.service = active`
  - `cwd = /srv/releases/bff/20260414174134/apps/bff`
- direct cloud 校验：
  - `GET http://127.0.0.1:3000/api/app/my/projects/97779e2d-50a0-4038-a0d8-1ee3b4d9d122/attachments`
  - `POST http://127.0.0.1:3000/api/app/my/projects/97779e2d-50a0-4038-a0d8-1ee3b4d9d122/attachments`
  - 当前都不再返回 `404`
  - 当前未鉴权探测返回 `401 AUTH_SESSION_INVALID`
- ingress/tunnel 校验：
  - `GET http://127.0.0.1:8080/api/app/my/projects/97779e2d-50a0-4038-a0d8-1ee3b4d9d122/attachments`
  - `POST http://127.0.0.1:8080/api/app/my/projects/97779e2d-50a0-4038-a0d8-1ee3b4d9d122/attachments`
  - 当前都不再返回 `404`
  - 当前未鉴权探测返回 `401 AUTH_SESSION_INVALID`

## 6. Conclusion

- 本轮云端 BFF 对齐已完成。
- `我的项目详情 -> 项目详情文书区` 的 app-facing 附件路由当前已在 live cloud runtime 生效。
- 后续若再次出现 `404 Cannot GET/POST /api/app/my/projects/{projectId}/attachments`：
  - 应先检查 active BFF release 是否偏离 `20260414174134` 之后的有效版本
  - 应先检查 `dist/main.js` shim 是否仍在
  - 不得直接回退为“Flutter 本地问题”结论
