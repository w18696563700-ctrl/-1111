---
owner: 后端 Agent（云端）
status: implemented_not_deployed
purpose: Record the backend truth implementation result for the project publish minimum corridor only, limited to the four frozen internal truth paths and local source-level verification.
layer: L0 SSOT 配套文书
implementation_date_local: 2026-04-02
inputs_canonical:
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_truth_map_and_preclosure_addendum.md
  - docs/00_ssot/control_priority_ruling_round0_global_veto_vs_project_publish_board_freeze_chain_addendum.md
  - docs/01_contracts/openapi.yaml
execution_scope:
  - apps/server/src/**
  - no BFF change
  - no Flutter change
  - no Admin change
  - no infra change
  - no Nginx/systemd/pm2/current/release change
  - no migration execution
  - no deploy
  - no release
---

# 项目发布最小走廊后端真相实现回执

## 1. 实现范围

本轮只实现以下四条 internal truth paths：

- `POST /server/projects`
- `GET /server/projects/{projectId}`
- `POST /server/uploads/init`
- `POST /server/uploads/confirm`

本轮未进入且未触碰：

- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `infra/**`
- `docs/01_contracts/openapi.yaml`
- active runtime 部署链
- migration execution

## 2. 改动文件清单

### 2.1 module wiring / runtime config / migration authoring

- `apps/server/src/app.module.ts`
- `apps/server/src/core/runtime-config.service.ts`
- `apps/server/src/core/migrations/migrations.ts`

### 2.2 append-only audit support

- `apps/server/src/modules/audit/project-publish-audit-log.entity.ts`
- `apps/server/src/modules/audit/project-publish-audit.module.ts`
- `apps/server/src/modules/audit/project-publish-audit.service.ts`

### 2.3 project truth

- `apps/server/src/modules/project/entities/project.entity.ts`
- `apps/server/src/modules/project/project.errors.ts`
- `apps/server/src/modules/project/project.presenter.ts`
- `apps/server/src/modules/project/project-query.service.ts`
- `apps/server/src/modules/project/project-write.service.ts`
- `apps/server/src/modules/project/project.controller.ts`
- `apps/server/src/modules/project/project.module.ts`

### 2.4 upload truth

- `apps/server/src/modules/upload/entities/upload-session.entity.ts`
- `apps/server/src/modules/upload/entities/file-asset.entity.ts`
- `apps/server/src/modules/upload/upload.errors.ts`
- `apps/server/src/modules/upload/upload.presenter.ts`
- `apps/server/src/modules/upload/upload-storage.service.ts`
- `apps/server/src/modules/upload/upload-write.service.ts`
- `apps/server/src/modules/upload/upload.controller.ts`
- `apps/server/src/modules/upload/upload.module.ts`

## 3. four-path implementation mapping

| frozen internal truth path | 本轮实现位置 | 实现结果 |
|---|---|---|
| `POST /server/projects` | `modules/project/project.controller.ts` + `project-write.service.ts` | 已实现 create command entry；request 按 frozen `ProjectCreateRequest` 校验；success 固定 `202 + { projectId }` |
| `GET /server/projects/{projectId}` | `modules/project/project.controller.ts` + `project-query.service.ts` + `project.presenter.ts` | 已实现 detail read entry；返回共享 `ProjectReadModel`；未新增 detail-only 第二模型 |
| `POST /server/uploads/init` | `modules/upload/upload.controller.ts` + `upload-write.service.ts` + `upload-storage.service.ts` | 已实现 shared upload init truth；只发放 `uploadSessionId + directUpload + confirm` |
| `POST /server/uploads/confirm` | `modules/upload/upload.controller.ts` + `upload-write.service.ts` | 已实现 shared upload confirm truth；confirm 成功后才创建 `FileAsset` truth reference 并返回 `fileAssetId` |

## 4. persistence / validation / audit 说明

### 4.1 persistence

本轮新增的持久化对象：

- `project`
  - 最小 project truth
  - 字段包含 `projectNo/title/buildingType/budgetAmount/description/state/summary`
- `upload_session`
  - shared upload init/confirm corridor session
  - 持有 `businessType/businessId/fileKind/objectKey/directUpload*`
- `file_asset`
  - confirm 成功后创建的共享 `FileAsset` truth record
  - `objectKey` 仅作为 storage location 落库，不升格为 business truth
- `project_publish_audit_log`
  - append-only audit support
  - 记录 project create、upload init、upload confirm、file asset create

### 4.2 validation

`POST /server/projects`

- 强校验 `title`
- 强校验 `buildingType`
- 强校验 `budgetAmount > 0`
- `description` 保持可选
- create 后默认写入 `state=published`
  - 原因：当前 frozen `ProjectState` 不包含 `draft`

`POST /server/uploads/init`

- request body 必须为 object
- 强校验 `businessType/businessId/fileKind/mimeType/size/checksum`
- 仅接受：
  - `businessType=project`
  - `fileKind=evidence`
- `businessId` 允许 `null`
- `businessId` 为字符串时会校验 project 是否存在

`POST /server/uploads/confirm`

- 强校验 `uploadSessionId`
- session 不存在时返回 confirm-required 家族错误
- confirm 只在此步骤创建 `FileAsset`
- 已确认 session 会复用既有 `fileAssetId`

### 4.3 audit

append-only audit 已落到 `project_publish_audit_log`：

- `project_created`
- `upload_init_requested`
- `upload_confirmed`
- `file_asset_created`

本轮 audit 记录携带：

- `aggregateType`
- `aggregateId`
- `eventType`
- `actorId/userId/organizationId`
- `requestId/traceId`
- `payload`

## 5. migration 文件是否新增

- 结论：`未新增独立 migration 文件`
- 处理方式：
  - 在既有 `apps/server/src/core/migrations/migrations.ts` 中新增 migration authoring：
    - `20260402_project_publish_minimum_corridor_truth`
- 本轮没有执行 migration。

## 6. 本地或测试级验证结果

### 6.1 已完成验证

1. 安装 `apps/server` 本地依赖用于纯编译验证：
   - `npm install --no-package-lock`
   - 未修改 package manifest
   - 未部署
2. 编译验证：
   - `npm run build`
   - 结果：通过
3. 编译产物验证：
   - `node -e "const { AppModule } = require('./dist/app.module') ..."`
   - 结果：`AppModule:ok`
4. migration export 验证：
   - `node -e "const { serverMigrations } = require('./dist/core/migrations/migrations') ..."`
   - 结果包含：
     - `20260401_enterprise_hub_v1_truth`
     - `20260402_project_publish_minimum_corridor_truth`

### 6.2 本轮未完成的验证

- 未启动本地 Nest 进程
- 未执行 DB migration
- 未做真实 PostgreSQL 写入验证
- 未做 `curl` 级 runtime 验收
- 未做 BFF 集成回归

这些缺口保持未完成，是因为本轮明示禁止：

- deploy
- release
- migration execution
- BFF / 联调实施

## 7. 未完成项与后续依赖

本轮完成的是 source truth implementation，不等于 active runtime 闭环。后续仍依赖：

1. DB 阶段
   - 执行 `20260402_project_publish_minimum_corridor_truth` migration
   - 核验表结构实际落地
2. BFF 阶段
   - 把 app-facing corridor 接回当前四条 internal truth paths
   - 复核错误透传/归一语义
3. 联调阶段
   - 验证 `POST /api/app/project/create`
   - 验证 `GET /api/app/project/detail`
   - 验证 `POST /api/app/file/upload/init`
   - 验证 `POST /api/app/file/upload/confirm`
4. 部署阶段
   - 将源码构建结果进入受控 runtime
   - 不在本轮处理

## 8. 对 BFF 阶段的输入

当前后端 truth 已提供给 BFF 阶段的明确输入：

- `POST /server/projects`
  - 吃 frozen `ProjectCreateRequest`
  - 只回 `202 + { projectId }`
- `GET /server/projects/{projectId}`
  - 回共享 `ProjectReadModel`
- `POST /server/uploads/init`
  - 只回共享三段上传 strategy
- `POST /server/uploads/confirm`
  - 只在 confirm 成功时回 `fileAssetId`

当前可直接复用的服务端语义：

- `PROJECT_CREATE_INVALID`
- `AUTH_RESOURCE_UNAVAILABLE`
- `FILE_UPLOAD_INIT_INVALID`
- `FILE_UPLOAD_CONFIRM_REQUIRED`

当前 upload binding 口径已经固化为：

- `businessType=project`
- `fileKind=evidence`

当前 BFF 不应做的事情保持不变：

- 不新增第二条 project family
- 不新增第二条 upload family
- 不把 `objectKey` 升格为 business truth
- 不把 admin/bid/order/contract 等后链混入当前 corridor

## 9. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首版。完成四条 internal truth path 的 server source implementation、module wiring、append-only audit support、migration authoring 与本地编译级验证；未部署、未发版、未执行 migration。 |
