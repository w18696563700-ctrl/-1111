# 《项目发布最小走廊｜BFF implementation 回执》

## 1. 实现范围

本轮仅在本地 `apps/bff/src/**` 施工，目标是把项目发布最小走廊的 app-facing corridor 收口到已冻结的四条 internal truth path：

- `POST /api/app/project/create`
- `GET /api/app/project/detail`
- `POST /api/app/file/upload/init`
- `POST /api/app/file/upload/confirm`

本轮未改：

- `apps/server/**`
- `apps/mobile/**`
- `apps/admin/**`
- `infra/**`
- live runtime / Nginx / systemd / current / release
- deploy / restart / reload / 发版

## 2. 改动文件清单

新增：

- `apps/bff/src/routes/project/project.module.ts`
- `apps/bff/src/routes/project/project.controller.ts`
- `apps/bff/src/routes/project/project.service.ts`
- `apps/bff/src/routes/file/file-upload.module.ts`
- `apps/bff/src/routes/file/file-upload.controller.ts`

修改：

- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/src/routes/file/file.service.ts`

## 3. 四条 corridor path 的 BFF mapping 表

| app-facing path | BFF source path | BFF controller | internal truth path | 当前结果 |
| --- | --- | --- | --- | --- |
| `POST /api/app/project/create` | `POST /bff/project/create` | `ProjectController.createProject` | `POST /server/projects` | 已在本地 repo source 挂载 |
| `GET /api/app/project/detail?projectId=...` | `GET /bff/project/detail?projectId=...` | `ProjectController.getProjectDetail` | `GET /server/projects/{projectId}` | 已在本地 repo source 挂载 |
| `POST /api/app/file/upload/init` | `POST /bff/file/upload/init` | `FileUploadController.initUpload` | `POST /server/uploads/init` | 已在本地 repo source 挂载 |
| `POST /api/app/file/upload/confirm` | `POST /bff/file/upload/confirm` | `FileUploadController.confirmUpload` | `POST /server/uploads/confirm` | 已在本地 repo source 挂载 |

## 4. request / response shaping 说明

### 4.1 project create

- BFF canonical source path 固定为 `POST /bff/project/create`。
- BFF 仅把 body 作为对象转发到 `POST /server/projects`，不在 BFF 侧扩写 bid/order 后链语义。
- success body 被收口为固定 `{ projectId }`，不透传为 full `ProjectReadModel`。
- error 继续走 controlled failure：
  - `400` fallback 到 `PROJECT_CREATE_INVALID`
  - 其余上游失败 fallback 到 `PROJECT_CREATE_FAILED`

### 4.2 project detail

- BFF canonical source path 固定为 `GET /bff/project/detail?projectId=...`。
- query `projectId` 被拼接到 `GET /server/projects/{projectId}`，不引入 compatibility alias：
  - 未采用 `POST /bff/project`
  - 未采用 `GET /bff/project`
  - 未采用 `GET /bff/project/:projectId`
- BFF success body 被整形成共享 `ProjectReadModel`：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
- detail failure 继续沿用 `AUTH_RESOURCE_UNAVAILABLE` 受控失败家族，不新增第二套 detail 错误码。

### 4.3 upload init

- `POST /bff/file/upload/init` 继续映射到 `POST /server/uploads/init`。
- success 继续返回三段式 upload handoff：
  - `uploadSessionId`
  - `directUpload`
  - `confirm.endpoint=/api/app/file/upload/confirm`
- 本轮修正了 BFF 本地 source 的 frozen upload binding：
  - 保留 `businessType`
  - 保留 `fileKind`
  - `businessId` 字段必须存在，但允许 `null`
  - 不再在 BFF 侧擅自把 `businessId` 恢复成强制非空
- `objectKey` 未被升格为 business truth。

### 4.4 upload confirm

- `POST /bff/file/upload/confirm` 继续映射到 `POST /server/uploads/confirm`。
- app-facing confirm endpoint 仍由 init response 固定暴露为 `/api/app/file/upload/confirm`。
- 本轮未把 internal `/server/uploads/confirm` 直接暴露给 Flutter App。
- confirm failure 继续保持 controlled failure，不吞掉 upstream `404/invalid`。

## 5. repo/runtime drift 收口说明

本轮只收口 repo source，不触碰 runtime。

本轮前：

- 本地 `apps/bff/src/routes/routes.module.ts` 只挂 `EnterpriseHubModule`
- 本地 repo source 不足以代表 current minimum corridor 的 project/file upload 挂载面

本轮后：

- 本地 repo source 已真实存在并挂载：
  - `POST /bff/project/create`
  - `GET /bff/project/detail`
  - `POST /bff/file/upload/init`
  - `POST /bff/file/upload/confirm`
- `RoutesModule` 现在直接 imports：
  - `EnterpriseHubModule`
  - `ProjectModule`
  - `FileUploadModule`

为避免顺手把 `file/index` 与 `file/access` 一起带回挂载面，本轮没有直接把旧 `FileModule` 挂回 `RoutesModule`，而是新增了只承接 upload corridor 的 `FileUploadModule`。因此，本轮收口的是最小 corridor 触点，不是整个 file family。

仍然存在的 drift：

- active runtime 未变，因为本轮未部署、未发版
- runtime 是否与本地 source 完全一致，仍需后续发版前再次比对

## 6. build / 测试级验证结果

已完成：

- 源码级 route graph 核对完成
- 四条 corridor 的 source 挂载链已可读
- request / response shaping 已按 frozen contract 对照实现
- `apps/bff/src/routes/file/file.service.ts` 已压回 `446` 行，未越过 `450` 行门禁

未完成：

- `apps/bff` 本地 `build` 未能在当前工作区完成

阻塞证据：

- `pnpm --dir apps/bff build` 失败：当前 shell 不存在 `pnpm`
- `npm run build` 失败：当前工作区不存在 `nest` 可执行文件
- `npx tsc -p apps/bff/tsconfig.build.json --noEmit` 失败：当前工作区未安装 `typescript`

结论：

- 本轮无法给出“build 通过”的正式结论
- 当前只能给出“源码已实现 + 工具链缺失导致未完成本地编译验证”的回执

## 7. 未完成项与后续依赖

- 需要在可用的 BFF 本地依赖环境中重新执行：
  - `pnpm install` 或等价依赖准备
  - `pnpm --dir apps/bff build` 或等价 build
- 需要后续发版轮把本地 source 与 active runtime 再做一次一对一比对
- 若后续要恢复完整 file family，需要单独评估 `file/index`、`file/access` 是否应进入冻结 corridor；本轮未放行

## 8. 对前端阶段的输入

前端继续只使用已冻结的 app-facing canonical path：

- `POST /api/app/project/create`
- `GET /api/app/project/detail?projectId=...`
- `POST /api/app/file/upload/init`
- `POST /api/app/file/upload/confirm`

当前前端可依赖的响应约束：

- project create：`202 + { projectId }`
- project detail：共享 `ProjectReadModel`
- upload init：`uploadSessionId + directUpload + confirm.endpoint=/api/app/file/upload/confirm`
- upload confirm：继续走 `fileAssetId` 确认链，不使用 `objectKey` 作为业务真相

## 9. 修订记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
| v0.1 | 2026-04-02 | 首版。完成 minimum-corridor BFF source 收口，实现 project create/detail 与 upload init/confirm 的本地 repo 映射；未部署，未发版；本地 build 因工具链缺失未完成。 |
