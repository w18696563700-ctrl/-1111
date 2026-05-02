---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-02
purpose: >
  Freeze the minimum unlock boundary for public-resource file/access so the
  existing public resource catalog can produce signed download URLs without
  creating a second download protocol or weakening owner-private attachment
  access.
inputs_canonical:
  - docs/00_ssot/public_resource_download_closure_and_prepublish_button_day1_boundary_freeze_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_shared_file_access_contract_drift_repair_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project-attachment-file-access.service.ts
  - apps/bff/src/routes/file/file.service.ts
---

# 公共资料 file/access 最小解锁边界冻结单

## 1. 总裁决

- 当前是否允许进入 Server 最小实现：`Go`
- 当前是否允许 BFF 拥有签名真相：`No-Go`
- 当前是否允许新增下载接口：`No-Go`
- 当前是否允许改 Flutter 下载 UI：`No-Go，本轮只解锁云端 file/access`
- 当前是否允许改数据库结构：`No-Go`
- 当前是否允许直接手改云端公共资料数据：`No-Go`

## 2. 当前问题真相

Day 1 只读核实已经确认：

1. 云端 `GET /api/app/project/public-resources` 返回三类真实公共资料。
2. 三条资源都带有 `fileAssetId`。
3. `GET /api/app/file/access?fileAssetId=...&mode=download` 统一返回：
   - `404 FILE_ACCESS_NOT_FOUND`
   - Server 原因：`Current project attachment binding is unavailable for file access.`

根因：

- 当前 Server `file/access` 实现只识别 `project_attachments.file_asset_id`。
- 公共资料目录的正式 carrier 是 `project_public_resources.file_asset_id`。
- 因此公共资料目录和 shared `file/access` 没有真实闭合。

## 3. 本轮只做什么

当前最小闭环：

1. 在 Server `file/access` 中补最小 `public_resource` 分支。
2. 公共资料下载仍复用：
   - `GET /api/app/file/access`
   - `fileAssetId`
   - `mode=download`
3. Server 只对满足以下条件的公共资料返回 signed URL：
   - `project_public_resources.file_asset_id = fileAsset.id`
   - `visibility = app_shared`
   - `published_at is not null`
   - `resource_category in contract_template / process_guide / other_resource`
   - MIME 属于既有公共资料 contract 允许集合
4. 兼容现有 Flutter 不传 `accessScope` 的调用：
   - 如果找不到 owner-private project attachment binding；
   - 再尝试识别已发布 app-shared public resource binding；
   - 未命中则仍返回原 `FILE_ACCESS_NOT_FOUND`。
5. 支持显式 `accessScope=public_resource`：
   - 该 scope 只走公共资料分支；
   - 不回落到 owner-private 附件。
6. BFF 只透传 query 与整形响应，不签 URL、不生成业务真相。

## 4. 本轮不做什么

- 不新增 `/api/app/project/public-resources/download`。
- 不新增 OSS 直连字段。
- 不让 Flutter 使用 objectKey。
- 不把公共资料补写进 `project_attachments`。
- 不改公共资料 Admin 发布能力。
- 不改项目附件 owner-private 权限。
- 不改 bid_material 权限。
- 不做 App 内保存 / 分享 UI。
- 不做预发布按钮文案治理。
- 不做信用分扣减或恢复。

## 5. Contracts 冻结

### 5.1 App-facing path

保持：

```text
GET /api/app/file/access
```

### 5.2 Query

保持最小兼容：

```text
fileAssetId: string
mode: download
```

新增可选 scope：

```text
accessScope?: owner_private | bid_material | public_resource
```

兼容规则：

- `accessScope` 省略时，Server 先按既有 owner-private project attachment 规则处理。
- 如果 owner-private binding 不存在，Server 可以按公共资料 binding 做只读 fallback。
- 显式 `accessScope=public_resource` 时，只允许公共资料 binding。

### 5.3 Response

保持既有 response：

```ts
type FileAccessResponse = {
  fileAssetId: string;
  mode: 'preview' | 'download';
  accessUrl: string;
  fileName: string;
  mimeType: string;
  expiresAt: string;
  contentLengthBytes?: number;
};
```

继续禁止：

- `objectKey`
- `bucket`
- OSS credential
- upload session secret

## 6. Server 规则冻结

公共资料分支必须：

1. 先验证当前 session。
2. 要求当前 actor 已登录。
3. 查询 `FileAsset`。
4. 查询 `ProjectPublicResource` 是否存在有效绑定。
5. 校验 `visibility/category/publishedAt/mimeType`。
6. 由 `UploadPublicUrlService` 生成 signed URL。
7. 返回 `fileName` 使用公共资料 row 的 `file_name`，不从 object key 推断。

公共资料分支不得：

- 读取 `project_attachments` 权限当作公共资料权限。
- 对任意 `FileAsset` 放行。
- 对 unpublished / hidden resource 放行。
- 对 contract 外 MIME 放行。

## 7. BFF 规则冻结

BFF 继续：

- 接收 App-facing `/api/app/file/access`。
- 转发到 Server `/server/file/access`。
- 保留 `accessScope` 参数透传。
- 移除 `objectKey` 等非 contract 字段。

BFF 不得：

- 签 OSS URL。
- 读取数据库判断公共资料。
- 把 Server 404 改写成成功。

## 8. 验收标准

本轮通过条件：

1. 本地 Server 测试证明公共资料 `fileAssetId` 可以返回 signed URL。
2. 本地 Server 测试证明 hidden/unpublished/invalid MIME 不会返回 signed URL。
3. BFF 测试证明 `accessScope=public_resource` 可透传。
4. 云端部署后，三条真实公共资料 `fileAssetId` 均能返回 `accessUrl`。
5. owner-private 与 bid_material 既有测试不回归。

## 9. 四类判断

| 判断 | 结论 |
|---|---|
| 哪个更稳 | Server 增加专用 public_resource 分支，BFF 只透传 |
| 哪个更省成本 | Server 自动 fallback 到公共资料 binding，兼容现有 Flutter |
| 哪个更适合当前阶段 | 自动 fallback + 显式 scope 双支持，避免立刻改 Flutter |
| 哪个风险更大 | 放宽通用 FileAsset 访问或把公共资料伪造成项目附件 |

## 10. 下一步

允许进入实现：

- Server 最小分支
- BFF 透传测试
- 本地构建测试
- 云端 bounded deployment
- 云端三条真实资源只读联调
