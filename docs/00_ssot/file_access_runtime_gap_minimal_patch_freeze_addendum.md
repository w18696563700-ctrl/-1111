---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum runtime gap patch for app-facing `GET /api/app/file/access`
  forwarding to Server `GET /server/file/access`, limited to the owner-private
  project attachment read path.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - apps/server/AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/project_public_resource_download_zone_shared_file_access_contract_drift_repair_addendum.md
  - docs/01_contracts/project_detail_document_zone_and_public_resource_download_contract_freeze_addendum.md
  - docs/02_backend/project_detail_document_zone_and_public_resource_download_backend_truth_addendum.md
  - docs/03_bff/project_detail_document_zone_and_public_resource_download_bff_surface_addendum.md
  - apps/bff/src/routes/file/file.service.ts
  - apps/server/src/modules/project/project-attachment.service.ts
  - apps/server/src/modules/upload/upload-public-url.service.ts
---

# 《file/access 运行时补洞冻结单》

## 1. 当前结论

- 当前最小闭环固定为：
  - `Flutter App -> BFF GET /api/app/file/access -> Server GET /server/file/access`
  - 入参只接受：
    - `fileAssetId`
    - `mode=preview | download`
  - Server 只读取既有真值：
    - `file_asset`
    - `project_attachments`
    - `project`
  - Server 校验当前登录主体必须是该项目 owner 组织。
  - Server 只返回 `FileAccessResponse`。
- 当前更稳、更省成本、最适合本阶段的是：
  - 只补 Server 读路径源码基线。
- 当前风险更大的是：
  - 改上传链
  - 改 BFF 签名逻辑
  - 让 Flutter 拼 OSS URL
  - 暴露 `objectKey`
  - 新增附件状态机或新表。

## 2. Runtime Gap

- 当前缺口固定为：
  - BFF 已有 `GET /api/app/file/access`。
  - BFF 当前按既有 contract 转发到 `/server/file/access`。
  - Server source 当前缺少 owner-private project attachment 的
    `GET /server/file/access` 源码基线。
- 当前补洞对象不是：
  - 上传初始化
  - direct upload
  - upload confirm
  - `project_attachments` bind/list/delete
  - 公共资源目录
  - Admin template resource center。

## 3. 最小语义冻结

- `fileAssetId` 是本次访问授权的唯一业务锚点。
- `objectKey` 只允许 Server 内部用于调用存储签名服务。
- `objectKey` 不得出现在：
  - BFF response
  - Flutter response model
  - app-facing contract
  - UI 文案或日志证据单的业务真相字段。
- `mode` 当前只允许：
  - `preview`
  - `download`
- `preview` 和 `download` 当前共用同一个 signed object access URL 生成能力；
  语义差异保留给客户端展示/打开方式，不在 Server 形成第二套签名协议。

## 4. Server 读路径冻结

- Server `GET /server/file/access` 必须执行以下最小步骤：
  1. 解析并校验 `fileAssetId + mode`。
  2. 读取 `file_asset`。
  3. 读取 `project_attachments`，确认该 `fileAssetId` 已绑定为正式项目附件。
  4. 读取 `project`。
  5. 使用既有当前会话与组织资格服务确认当前组织。
  6. 校验 `project.organization_id === current organization id`。
  7. 调用 `UploadPublicUrlService.buildObjectAccessUrl(fileAsset.objectKey)`。
  8. 返回 `FileAccessResponse`。
- `FileAccessResponse` 固定为：
  - `fileAssetId`
  - `mode`
  - `accessUrl`
  - `fileName`
  - `mimeType`
  - `expiresAt`
  - optional `contentLengthBytes`
- 当前允许用 `project_attachments.fileName` 作为正式展示文件名。
- 当前允许用 `file_asset.mimeType` 与 `file_asset.size` 作为访问响应的技术字段。

## 5. 权限与错误边界

- owner 权限校验固定为 Server 执行，BFF 不做业务 owner 判断。
- 非 owner 不得拿到 signed URL。
- 未绑定到 `project_attachments` 的 `fileAssetId` 不得通过该路径访问。
- 当前错误码最小映射固定为：
  - 参数错误：`FILE_ACCESS_INVALID`
  - 文件或绑定不存在：`FILE_ACCESS_NOT_FOUND`
  - 非 owner：`FILE_ACCESS_PERMISSION_DENIED`
  - 签名 URL 生成失败：`FILE_ACCESS_UNAVAILABLE`
- 当前不得为了兼容测试绕过：
  - current session verification
  - organization scope
  - project owner check。

## 6. 不改上传链

- 当前明确不改：
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
  - direct upload URL 生成
  - upload session
  - `FileAsset` 创建逻辑
  - `project_attachments` bind/list/delete
  - DB schema
  - OSS bucket/object layout。

## 7. 需要保留但暂不开通

- 保留 shared `file/access` 继续服务其它 bounded attachment family 的扩展位。
- 保留公共资源下载区复用 `file/access` 的扩展位。
- 保留文档预览方式差异化扩展位。
- 暂不开通：
  - 通用文件中心
  - public file browser
  - objectKey debug endpoint
  - BFF 自签名
  - Flutter 直连 OSS。

## 8. 后续扩展位

- BFF smoke 测试可在下一阶段补齐，证明 BFF 仍只转发并不拥有签名逻辑。
- Flutter 可在下一阶段把 `FILE_ACCESS_FAILED` 兜底文案改为中文可理解提示。
- 云上发布必须是 Server-only release：
  - 记录当前 Server 回滚点
  - 不动 BFF current
  - health 通过
  - `file/access` preview/download 返回 200。

## 9. 阶段门禁核查表

- 已通过门禁：
  - `真相冻结门禁`：本单已冻结最小运行时语义。
  - `单通道门禁`：Flutter 仍只访问 BFF，BFF 仍转发 Server。
  - `Server truth owner 门禁`：owner 校验与 signed URL 生成由 Server 完成。
  - `objectKey 不外露门禁`：`objectKey` 仅为 Server 内部输入。
  - `上传链不变门禁`：本轮不改 init / direct upload / confirm / bind。
- 失败门禁：
  - 无。
- 否决门禁：
  - 若实现新增表、改状态机、绕过 owner 校验、暴露 `objectKey`，直接 No-Go。
  - 若实现改 BFF 签名或 Flutter 拼 OSS URL，直接 No-Go。
- 下一阶段允许：
  - Day2 本地 Server source 最小实现。
  - Day2 单元测试。
- 下一阶段不允许：
  - 云上发布
  - BFF current 切换
  - Server 状态机/DB schema 改动
  - 上传链改动。
