# 公共资料 file/access 最小解锁云端验收回执

状态：Go

## 1. 本轮目标

解锁公共资料下载区使用既有 `GET /api/app/file/access` 获取下载授权的最小闭环。

本轮只解决：
- 公共资料 `fileAssetId` 可通过 `file/access` 换取下载 `accessUrl`。
- 旧 Flutter 客户端未传 `accessScope` 时，Server 在找不到项目私有附件绑定后可安全 fallback 到公共资料绑定。
- 新客户端可显式传 `accessScope=public_resource`。

## 2. 范围冻结

涉及范围：
- SSOT：新增公共资料 `file/access` 最小解锁边界。
- contracts：新增 `public_resource` access scope。
- Server：新增公共资料文件授权分支。
- BFF：不拥有签名真相，仅确认透传 `accessScope`。
- 云端联调：已部署到阿里云 active runtime 并通过隧道验证。

非目标：
- 不做 Flutter App 内下载、保存到文件、分享面板。
- 不新增下载接口。
- 不补假公共资料。
- 不修改数据库结构。
- 不修改 Nginx、系统服务定义、对象存储配置。
- 不改变项目私有附件、竞标资料附件、上传三步流。

## 3. 实际产出物

文书：
- `docs/00_ssot/public_resource_file_access_minimal_unlock_boundary_freeze_addendum.md`
- `docs/01_contracts/public_resource_file_access_scope_contract_addendum.md`
- `docs/00_ssot/public_resource_file_access_minimal_unlock_cloud_runtime_receipt.md`

contracts：
- `docs/01_contracts/openapi.yaml`
- `packages/contracts/openapi/openapi.bundle.json`

Server：
- `apps/server/src/modules/project/project-attachment-file-access.service.ts`
- `apps/server/test/project-attachment-corridor.test.cjs`

BFF：
- `apps/bff/test/file-access-forwarding.test.cjs`

## 4. 云端发布回执

Server release：
- `20260502135031-public-resource-file-access`

当前 Server runtime：
- `/srv/apps/server/current -> /srv/releases/server/20260502135031-public-resource-file-access`
- `exhibition-server.service` active
- Server 监听 `3001`

回滚点：
- `/srv/shared/rollback-server-before-20260502135031-public-resource-file-access.txt`
- 内容指向：`/srv/releases/server/20260502052616-sincerity-internal-no-freeze`

BFF：
- 未部署新 BFF runtime。
- 原因：BFF 既有 `GET /api/app/file/access` 已透传 `accessScope`，签名真相仍在 Server。

## 5. 云端接口验证

验证入口：
- 隧道：`http://127.0.0.1:8080`
- 测试账号：已使用用户提供测试账号登录验证，未在文书保存 token。

公共资料目录：
- `GET /api/app/project/public-resources` 返回 200。
- 返回 3 条公共资料：
  - `展览定制之家-合同模板`
  - `进度安排表（模板）`
  - `投标补充资料（样例）`

file/access 验证：

| fileAssetId | scope | status | 结果 |
| --- | --- | --- | --- |
| `44495c89-c1aa-4b1d-ab4f-04846f469968` | omitted fallback | 200 | 返回 `accessUrl` |
| `44495c89-c1aa-4b1d-ab4f-04846f469968` | `public_resource` | 200 | 返回 `accessUrl` |
| `eb7333c2-f32d-4537-b1fe-311f00038509` | omitted fallback | 200 | 返回 `accessUrl` |
| `eb7333c2-f32d-4537-b1fe-311f00038509` | `public_resource` | 200 | 返回 `accessUrl` |
| `ab575588-89fd-4c8e-bf94-685cf45ab7c9` | omitted fallback | 200 | 返回 `accessUrl` |
| `ab575588-89fd-4c8e-bf94-685cf45ab7c9` | `public_resource` | 200 | 返回 `accessUrl` |

额外验证：
- 公共资料 `preview + accessScope=public_resource` 返回 400 `FILE_ACCESS_INVALID`，符合本轮只开放 download 的边界。
- 未登录访问返回 401 `AUTH_SESSION_INVALID`。
- 合同模板签名 URL 可实际下载，HTTP 200，文件大小 `41603` bytes，content type 为 DOCX。

## 6. 测试结果

Server 聚焦测试：
- 命令：`node --test test/project-attachment-corridor.test.cjs test/project-public-resource-corridor.test.cjs`
- 结果：31 pass / 0 fail

BFF 聚焦测试：
- 命令：`node --test test/file-access-forwarding.test.cjs test/project-public-resource-service.test.cjs`
- 结果：8 pass / 0 fail

## 7. 风险与结论

已解决风险：
- 公共资料目录有资源但 `file/access` 返回 `FILE_ACCESS_NOT_FOUND`。
- 公共资料下载授权误依赖项目私有附件绑定。
- BFF 拥有签名或文件业务真相。

未解决但不阻塞：
- Flutter 仍未实现 App 内下载、保存到文件、分享面板。
- Flutter 公共资料下载按钮如仍走旧浏览器逻辑，需要下一轮前端闭环治理。

阻塞项：
- 无。

结论：
- Go。本轮公共资料 `file/access` 最小解锁完成。
- 下一轮唯一建议动作：回到 Flutter 公共资料下载闭环，实现 App 内下载后打开 / 分享 / 保存到文件。
