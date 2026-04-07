# 项目发布最小走廊前端消费回执

## 1. 核对范围

- 页面范围：`/exhibition/projects/create`
- 接口范围：`POST /api/app/project/create`
- 接口范围：`GET /api/app/project/detail`
- 上传范围：`POST /api/app/file/upload/init`
- 上传范围：direct upload
- 上传范围：`POST /api/app/file/upload/confirm`
- 输入依据仅使用以下文书与代码：
- `docs/00_ssot/project_publish_minimum_corridor_frontend_consumption_verification_gate_checklist_addendum.md`
- `docs/00_ssot/project_publish_minimum_corridor_bff_implementation_receipt.md`
- `docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md`
- `docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md`
- `docs/01_contracts/openapi.yaml`
- `apps/mobile/lib/**`

## 2. zero-delta 对齐结论

- 结论：未直接达到 `zero-delta aligned`。
- 结论：存在 1 处具体 source-level 错位，已执行最小补丁；当前状态为 `minimal patch applied`。
- 补丁前核对结果：
- `create` 页面仍走 `POST /api/app/project/create`，且成功 continuation 仍只依赖 `{ projectId }`。
- `detail` continuation 仍走 `GET /api/app/project/detail?projectId=...`。
- upload 三段链仍走 `POST /api/app/file/upload/init` -> direct upload -> `POST /api/app/file/upload/confirm`。
- upload binding 仍为 `businessType=project`、`fileKind=evidence`。
- 唯一错位点：前端此前会被动接受 upload init 响应中的任意 `confirm.endpoint`，没有在 source level 强制收敛到 app-facing canonical path `/api/app/file/upload/confirm`；因此若 BFF 或运行态错误返回 internal `/server/uploads/confirm`，前端会继续消费该错位路径。
- 补丁后结论：项目发布最小走廊前端消费已收敛到 app-facing canonical paths，且对 internal confirm endpoint drift 采取 fail-closed。

## 3. 改动文件清单

- `apps/mobile/lib/features/exhibition/data/services/exhibition_upload_service.dart`
- `apps/mobile/test/project_publish_minimum_corridor_alignment_test.dart`

## 4. create/detail/upload 三段链消费结论

- create：
- 当前 `ExhibitionActionService.createProject` 仍调用 `POST /api/app/project/create`。
- 当前 create 成功态仍由 `projectId` 驱动后续页面 continuation；前端未把额外业务字段作为成功前提。
- detail：
- 当前 `ExhibitionLoadService.loadProjectDetail` 仍调用 `GET /api/app/project/detail`，并通过 `projectId` query 继续读取详情。
- 当前 create 页面成功后仍跳转到 detail continuation，而非引入其它新路由族。
- upload：
- 当前附件上传仍为三段链：`upload init` -> `direct upload` -> `upload confirm`。
- 当前附件上传请求仍绑定 `businessType=project`、`fileKind=evidence`。
- 本次补丁只在 upload init 成功解析后增加 app-facing confirm endpoint 守卫；未改动 create、detail、direct upload 主流程。

## 5. 当前是否仍只消费 app-facing canonical paths

- 是，但这是在本次最小补丁之后成立。
- `create` 仍消费 `/api/app/project/create`。
- `detail` 仍消费 `/api/app/project/detail`。
- `upload init` 仍消费 `/api/app/file/upload/init`。
- `upload confirm` 现已被显式限制为 `/api/app/file/upload/confirm`。
- 当前前端不会再接受 internal `/server/uploads/confirm` 作为可继续消费的 confirm endpoint。

## 6. 测试或验证结果

- source-level 核对已完成，核对结论来自 `apps/mobile/lib/**` 与冻结文书、OpenAPI 合同比对。
- 新增最小测试：
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/project_publish_minimum_corridor_alignment_test.dart`
- 结果：通过。
- 复核现有 corridor 相关行为：
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create success carries real projectId to detail"`
- 结果：通过。
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create page reuses upload init-direct-confirm chain after success"`
- 结果：通过。
- 验证缺口：
- 本轮未进行 tunnel 联调，也未进行真实 BFF/OSS 运行态 direct upload 验证。
- 因此本回执证明的是前端 source-level 消费对齐与最小测试对齐，不宣称云端联调已完成。

## 7. 未完成项与后续依赖

- 仍需在真实 tunnel 与真实 BFF/OSS 上做一次运行态走廊验证，确认 `upload init` 返回的 `confirm.endpoint` 确为 `/api/app/file/upload/confirm`。
- 仍需确认运行态 direct upload 目标、header、CORS、对象存储签名在当前环境可用；本轮未覆盖该基础设施链路。
- 若 BFF 运行态尚未部署到本轮冻结口径，前端现在会按 fail-closed 拒绝 internal confirm endpoint，这会暴露部署漂移而不是掩盖漂移。

## 8. 修订记录

- `2026-04-02`：完成项目发布最小走廊前端消费核对。
- `2026-04-02`：确认 create/detail/upload binding 主链已对齐。
- `2026-04-02`：发现 upload confirm endpoint 缺少 app-facing canonical path 守卫。
- `2026-04-02`：在 `apps/mobile/lib/features/exhibition/data/services/exhibition_upload_service.dart` 增加最小守卫，拒绝 internal `/server/uploads/confirm` 漂移。
- `2026-04-02`：新增 `apps/mobile/test/project_publish_minimum_corridor_alignment_test.dart` 作为最小回归测试。
