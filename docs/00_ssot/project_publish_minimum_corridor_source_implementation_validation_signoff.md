---
owner: 结果校验 Agent
status: active
purpose: Independent source-level validation signoff for the project publish minimum corridor implementation pack only.
layer: L0 SSOT
---

# 项目发布最小走廊源码实施包独立签收

## 1. 签收范围

本次签收对象仅限 source-level implementation pack，不包含部署、发版、联调实施、迁移执行、Nginx 改动或 runtime 切换。

本次签收范围固定为：

- 后端 truth 实现
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
  - `POST /server/uploads/init`
  - `POST /server/uploads/confirm`
- BFF corridor mapping
  - `POST /api/app/project/create` -> `POST /bff/project/create` -> `POST /server/projects`
  - `GET /api/app/project/detail` -> `GET /bff/project/detail?projectId=...` -> `GET /server/projects/{projectId}`
  - `POST /api/app/file/upload/init` -> `POST /bff/file/upload/init` -> `POST /server/uploads/init`
  - `POST /api/app/file/upload/confirm` -> `POST /bff/file/upload/confirm` -> `POST /server/uploads/confirm`
- 前端消费对齐
  - `/exhibition/projects/create`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `upload init -> direct upload -> confirm`
  - 对 internal `/server/uploads/confirm` drift 采取 fail-closed

本次不签收：

- bid / order / contract / milestone / inspection / rating / dispute 的实现完成度
- tunnel 联调结果
- PostgreSQL 真实写入结果
- OSS / MinIO / CORS / signature 运行态可用性
- 部署后 active runtime 与 repo source 的一致性

## 2. 结论依据表

| 依据对象 | 独立核验结论 |
| --- | --- |
| `docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md` | 四条 internal truth path 与四条 app-facing corridor 已冻结，且明确禁止扩到 bid/order/contract/milestone/inspection/rating/dispute。 |
| `docs/01_contracts/openapi.yaml` | 已存在 `POST /api/app/project/create`、`GET /api/app/project/detail`、`POST /api/app/file/upload/init`、`POST /api/app/file/upload/confirm` 以及对应 `POST /server/projects`、`GET /server/projects/{projectId}`、`POST /server/uploads/init`、`POST /server/uploads/confirm` 的合同条目。 |
| `apps/server/src/app.module.ts` + `apps/server/src/modules/project/**` + `apps/server/src/modules/upload/**` | `ProjectModule` 与 `UploadModule` 已进入 `AppModule` import graph；四条 internal truth path 已在 controller/service 层真实落地。 |
| `apps/bff/src/routes/routes.module.ts` + `apps/bff/src/routes/project/**` + `apps/bff/src/routes/file/**` | `ProjectModule` 与 `FileUploadModule` 已进入 `RoutesModule` import graph；四条 corridor mapping 已在 source 中真实挂载。 |
| `apps/mobile/lib/features/exhibition/**` + `apps/mobile/lib/shell/navigation/app_router.dart` | `/exhibition/projects/create`、project create/detail、upload init/confirm 仍只消费 `/api/app/*` canonical paths；未引入 Flutter 直连 `Server`。 |
| `apps/mobile/test/project_publish_minimum_corridor_alignment_test.dart` | 仅对 internal confirm endpoint drift 做 fail-closed，测试覆盖明确且与本轮唯一补丁点一致。 |
| 本轮结果校验实测 | `flutter test test/project_publish_minimum_corridor_alignment_test.dart`、`flutter test test/shell_app_test.dart --plain-name "project create success carries real projectId to detail"`、`flutter test test/shell_app_test.dart --plain-name "project create page reuses upload init-direct-confirm chain after success"` 均通过。 |

## 3. 后端签收结论

### 3.1 路径是否在 source 中落地并挂载

结论：已落地，且已挂载到当前 source module graph。

独立证据：

- `apps/server/src/app.module.ts`
  - 已 import `ProjectModule`
  - 已 import `UploadModule`
- `apps/server/src/modules/project/project.controller.ts`
  - `@Controller('server/projects')`
  - `@Post()` 对应 `POST /server/projects`
  - `@Get(':projectId')` 对应 `GET /server/projects/{projectId}`
- `apps/server/src/modules/upload/upload.controller.ts`
  - `@Controller('server/uploads')`
  - `@Post('init')`
  - `@Post('confirm')`

### 3.2 语义是否与冻结走廊一致

结论：基本一致。

已核验到的 source-level 事实：

- `ProjectWriteService.createProject`
  - 仅消费 `title`、`buildingType`、`budgetAmount`、`description`
  - success 返回经 `ProjectPresenter.toAcceptedResponse` 收口的 `{ projectId }`
  - 未扩为 full read model
- `ProjectQueryService.getProjectById`
  - 返回 `ProjectPresenter.toReadModel`
  - 读模型字段保持在 `projectId/projectNo/title/buildingType/budgetAmount/state/summary`
- `UploadWriteService.initUpload`
  - 仅接受 `businessType=project`
  - 仅接受 `fileKind=evidence`
  - 生成 three-step upload directive
- `UploadWriteService.confirmUpload`
  - 仅在 confirm 阶段创建 `FileAsset`
  - `objectKey` 仅作为 storage location 落库

### 3.3 是否越界到后链

结论：未发现本轮后端 implementation pack 越界去实现 bid/order/contract/milestone/inspection/rating/dispute 的新 truth path。

说明：

- `ProjectPresenter` 中存在对 `bidding_closed`、`converted_to_order` 等 state label 的兜底文案，但未伴随新增后链 controller / service path。
- `apps/server/src/core/migrations/migrations.ts` 中仍并存其他 family 的既有迁移定义，但本轮新增 migration key 聚焦 `20260402_project_publish_minimum_corridor_truth`。

### 3.4 后端签收结论

结论：后端 truth 实现 source-level 签收通过。

保留项：

- migration 仅已 authoring，未执行
- 未做真实 PostgreSQL 写入验证
- 未做 runtime `curl` 级验收

## 4. BFF 签收结论

### 4.1 四条 corridor mapping 是否在 source 中落地

结论：已落地，且在当前 `RoutesModule` 中已真实挂载。

独立证据：

- `apps/bff/src/routes/routes.module.ts`
  - 当前 import graph 为 `EnterpriseHubModule + ProjectModule + FileUploadModule`
- `apps/bff/src/routes/project/project.controller.ts`
  - `@Controller('bff/project')`
  - `@Post('create')`
  - `@Get('detail')`
- `apps/bff/src/routes/project/project.service.ts`
  - create 转发到 `POST /server/projects`
  - detail 转发到 `GET /server/projects/{projectId}`
- `apps/bff/src/routes/file/file-upload.controller.ts`
  - `@Controller('bff/file')`
  - `@Post('upload/init')`
  - `@Post('upload/confirm')`
- `apps/bff/src/routes/file/file.service.ts`
  - init 转发到 `POST /server/uploads/init`
  - confirm 转发到 `POST /server/uploads/confirm`

### 4.2 是否引入新的 canonical drift

结论：未发现新的 canonical drift；相反，source 已主动收口 drift。

已核验到的 source-level 事实：

- `ProjectService` 只承认 `GET /bff/project/detail?projectId=...`
  - 未升格 `GET /bff/project`
  - 未升格 `GET /bff/project/:projectId`
  - 未升格 `POST /bff/project`
- `FileService` 将 `Server` internal upload confirm 统一重写为 app-facing `FILE_UPLOAD_CONFIRM_ENDPOINT = '/api/app/file/upload/confirm'`
- 旧 `FileModule` 与 `FileController` 仍在 repo 中，但未进入当前 `RoutesModule`
  - 因此本轮没有顺手把 `file/index`、`file/access` 重新带回当前最小走廊挂载图

### 4.3 BFF build 风险是否已消失

结论：未消失，仍为保留风险。

本次签收只确认 source-level route graph 与 mapping 真实存在，不确认本地 BFF build 已完成。现有 receipt 也明确记录当前缺少正式本地 build 验证。

### 4.4 BFF 签收结论

结论：BFF corridor mapping source-level 签收通过，但保留 `build 未正式验证` 风险。

## 5. 前端签收结论

### 5.1 当前是否仍只消费 app-facing canonical paths

结论：是。

独立证据：

- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
  - `projectCreate = '/api/app/project/create'`
  - `projectDetail = '/api/app/project/detail'`
  - `uploadInit = '/api/app/file/upload/init'`
  - `uploadConfirm = '/api/app/file/upload/confirm'`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
  - create 仍走 `ExhibitionCanonicalPaths.projectCreate`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
  - detail 仍走 `ExhibitionCanonicalPaths.projectDetail`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_upload_service.dart`
  - init 仍走 `ExhibitionCanonicalPaths.uploadInit`
  - confirm 仍走 `directive.confirmEndpoint`
  - 但会先校验 `directive.confirmEndpoint == ExhibitionCanonicalPaths.uploadConfirm`
- 对 `apps/mobile/lib/**` 与 `apps/mobile/test/**` 的只读搜索中，未发现任何生产消费代码直接调用 `/server/projects` 或 `/server/uploads/*`
  - 唯一命中是回归测试中人为注入的 drift fixture

### 5.2 `/exhibition/projects/create` 是否仍走冻结 continuation

结论：是。

独立证据：

- `apps/mobile/lib/shell/navigation/app_router.dart`
  - 已注册 `ExhibitionRoutes.projectCreate => ProjectCreatePage()`
  - 已注册 `ExhibitionRoutes.projectDetail => ProjectDetailPage(...)`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - 提交动作仍调用 `ExhibitionConsumerLayer.instance.createProject(...)`
  - success continuation 仍只读取 `projectId`
  - 创建成功后继续进入：
    - `查看项目详情`
    - `文件资料继续承接`
  - 未跳转到 bid/order/contract/milestone/inspection/rating/dispute 新链路

### 5.3 前端最小补丁是否必要且范围最小

结论：必要，且范围最小。

理由：

- 如果没有 `exhibition_upload_service.dart` 中的 confirm endpoint 守卫，前端会被动接受上游返回的 internal `/server/uploads/confirm`，这会把 internal truth path 泄漏到 app-facing 消费层。
- 当前补丁只做了两件事：
  - 在 upload init 解析后新增 canonical confirm endpoint 校验
  - 增加 `project_publish_minimum_corridor_alignment_test.dart` 回归测试
- create/detail 主流程与项目页 UI 结构未被放大改写。

### 5.4 fail-closed 是否真实存在

结论：真实存在，且已被本次结果校验复跑验证。

本次独立复测结果：

- `flutter test test/project_publish_minimum_corridor_alignment_test.dart`
  - 通过
- `flutter test test/shell_app_test.dart --plain-name "project create success carries real projectId to detail"`
  - 通过
- `flutter test test/shell_app_test.dart --plain-name "project create page reuses upload init-direct-confirm chain after success"`
  - 通过

### 5.5 前端签收结论

结论：前端消费对齐 source-level 签收通过。

说明：

- 当前前端对 internal confirm drift 的处理是 fail-closed，而不是容错放行。
- 这意味着如果后续 runtime 仍返回 internal endpoint，上传会被阻断；这是正确暴露部署漂移，不是前端缺陷。

## 6. 是否允许进入联调验证轮

结论：允许进入受限的“项目发布最小走廊联调验证轮”。

限制条件：

- 只允许验证当前四条 corridor path 与 `/exhibition/projects/create` continuation
- 不得借此扩展到 bid/order/contract/milestone/inspection/rating/dispute
- 不得把 source-level 签收误写为“已部署”或“已发布”
- 必须保留本文件中的保留风险清单

给出该结论的原因：

- 后端四条 internal truth path 已在 source/module graph 中存在
- BFF 四条 mapping 已在 source/module graph 中存在
- Flutter 仍只消费 `/api/app/*`
- 前端对 internal confirm drift 已 fail-closed
- 定向 source-level 回归测试已实际通过

## 7. 保留风险清单

以下风险仍必须保留到联调或部署阶段处理：

1. `apps/bff` 仍缺正式本地 build 验证
   - 当前只能确认 source route graph 存在，不能确认本地构建产物稳定可产出
2. `apps/server` 尚未执行 migration，未做真实 PostgreSQL 写入验证
   - 当前只确认 migration 已 authoring、entity/service/controller 已落地
3. 运行态若未部署到本轮冻结口径，前端会因 fail-closed 拒绝 internal `/server/uploads/confirm`
   - 这会把 runtime drift 显性化
4. 真实 OSS / MinIO 签名、CORS、对象存储可达性尚未实测
   - 当前 `UploadStorageService` 只在 source 中形成 direct-upload directive，未完成真实对象存储链验证
5. `/api/app/* -> /bff/*` 与 `/bff/* -> /server/*` 的 tunnel/runtime rewrite 仍未在本签收轮实测
   - 本次签收只证明 source prerequisites 已具备

## 8. 当前阶段建议：通过 / 有条件通过 / 不通过

结论：有条件通过。

理由：

- source-level implementation pack 已满足进入受限联调验证轮的源码前提
- 当前未发现 implementation pack 越界到 bid/order/contract/milestone/inspection/rating/dispute
- 当前未发现新的 canonical drift
- 但 build、migration、真实 PostgreSQL、真实对象存储、runtime rewrite 仍全部属于后续验证项，尚不能视为闭环完成

## 9. 修订记录

| 日期 | 动作 | 说明 |
| --- | --- | --- |
| 2026-04-02 | 新增 | 结果校验 Agent 完成项目发布最小走廊 source-level implementation pack 的独立签收。 |
