---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-02
purpose: >
  Freeze the Day 1 boundary and readonly cloud verification result for the
  public resource download closure, prepublish button copy governance, and
  published-withdraw credit-risk prompt round.
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_closure_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_file_access_cloud_runtime_alignment_receipt_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
---

# 公共资料下载闭环与预发布按钮治理 Day 1 边界冻结单

## 1. 总裁决

- 本轮 Day 1 裁决：`No-Go for Day 2 public-resource app-local download implementation`
- No-Go 原因：
  - 云端 `GET /api/app/project/public-resources` 能返回三类公共资料目录；
  - 但目录内三条真实 `fileAssetId` 调用 `GET /api/app/file/access?mode=download` 均返回 `404 FILE_ACCESS_NOT_FOUND`；
  - 错误源来自 Server：`Current project attachment binding is unavailable for file access.`
- 当前只允许：
  - 记录边界冻结与只读核实结果；
  - 输出最小解锁建议；
  - 不继续进入 Flutter 下载闭环施工。
- 当前不允许：
  - 不改 Flutter 下载逻辑冒充下载闭环；
  - 不改 BFF / Server；
  - 不补云端假资源；
  - 不改数据库；
  - 不新增接口；
  - 不实现信用分真实扣减。

## 2. 本轮目标

本轮原目标为：

1. 公共资料下载从浏览器打开升级为 App 内下载后打开 / 分享 / 保存。
2. 公共资料三类展示和不可用态更清晰。
3. 预发布列表按钮去重。
4. `作废删除` 改为 `作废并归档`。
5. 已发布项目撤回到预发布时增加信用分风险提示。

Day 1 只读核实后，本轮必须先停在：

- `公共资料下载云端真相阻塞`
- `需要 Server file/access 对 public_resource fileAsset 放行的正式解锁`

## 3. 本轮范围

当前最小闭环：

- 核对公共资料合同边界：
  - `GET /api/app/project/public-resources`
  - `GET /api/app/file/access` with `mode=download`
- 核对云端真实目录：
  - `contract_template`
  - `process_guide`
  - `other_resource`
- 核对 Flutter 当前下载实现：
  - 当前成功拿到 `accessUrl` 后走外部打开。
- 核对预发布按钮和撤回文案代码位置。

需要保留但暂不开通：

- Flutter App 内本地下载与保存。
- 预发布按钮去重实现。
- `作废并归档` 文案实现。
- 已发布撤回信用风险提示实现。

后续扩展位：

- Server `file/access` 支持 `public_resource` access scope。
- BFF 透传 `accessScope=public_resource` 或 Server 自动识别公共资源 fileAsset。
- App 内下载记录 / 已下载列表。
- 信用分账本、扣分、恢复、申诉。

## 4. 只读核实结果

### 4.1 SSOT / Contracts

- 现有 contract 已冻结三类公共资源：
  - `contract_template` => `合同模板`
  - `process_guide` => `流程图与说明`
  - `other_resource` => `公共资料`
- 现有 contract 已冻结下载复用：
  - `GET /api/app/file/access`
  - query: `fileAssetId`, `mode=download`
- 现有 closure 文书显示旧公共资料对象链曾被封账归档；本轮属于重新打开的体验闭环，不应直接沿用旧 pass 结论。

### 4.2 Flutter 当前实现

- `project_public_resource_support.dart`
  - `_openProjectPublicResourceUrl(...)` 使用 `launchUrlString(..., LaunchMode.externalApplication)`。
  - 当前是外部打开，不是 App 内保存。
- `project_public_resource_widgets.dart`
  - `_downloadResource(...)` 先请求 `requestProjectPublicResourceDownload(...)`。
  - 成功后直接打开 `access.accessUrl`。
- `bid_submit_template_download_support.dart`
  - 投标提交模板下载区复用同一外部打开逻辑。

### 4.3 云端目录核实

通过隧道：

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

只读登录使用已授权测试账号，令牌未记录。

`GET http://127.0.0.1:8080/api/app/project/public-resources` 返回 `200`，目录内存在三类资源：

| category | title | fileAssetId |
|---|---|---|
| `contract_template` | `展览定制之家-合同模板` | `44495c89-c1aa-4b1d-ab4f-04846f469968` |
| `process_guide` | `进度安排表（模板）` | `eb7333c2-f32d-4537-b1fe-311f00038509` |
| `other_resource` | `投标补充资料（样例）` | `ab575588-89fd-4c8e-bf94-685cf45ab7c9` |

### 4.4 云端 file/access 核实

以下三条均返回 `404 FILE_ACCESS_NOT_FOUND`：

```text
GET /api/app/file/access?fileAssetId=44495c89-c1aa-4b1d-ab4f-04846f469968&mode=download
GET /api/app/file/access?fileAssetId=eb7333c2-f32d-4537-b1fe-311f00038509&mode=download
GET /api/app/file/access?fileAssetId=ab575588-89fd-4c8e-bf94-685cf45ab7c9&mode=download
```

统一错误：

```json
{
  "statusCode": 404,
  "code": "FILE_ACCESS_NOT_FOUND",
  "message": "当前附件不存在或暂不可用。",
  "details": {
    "originalMessage": "Current project attachment binding is unavailable for file access."
  },
  "source": "server"
}
```

### 4.5 Server / BFF 代码核实

- BFF `FileService.getAccess(...)` 只转发到 `/server/file/access`，不拥有签名真相。
- Server `ProjectAttachmentFileAccessService.getAccess(...)` 当前会：
  - 查 `file_asset`
  - 再查 `project_attachments` 中是否存在 `fileAssetId` 绑定
  - 若不存在项目附件绑定，则返回 `FILE_ACCESS_NOT_FOUND`
- 当前公共资料目录使用 `project_public_resources.file_asset_id`，不是 `project_attachments.file_asset_id`。
- 因此当前云端真实问题是：
  - `project_public_resources` 目录和 `file/access` 权限/绑定规则没有闭合。

## 5. 子代理派工表

| 角色 | 状态 | 回执 |
|---|---|---|
| 总控 Agent | 已执行 | 完成只读核实、云端探查、边界裁决 |
| 文书冻结 Agent | 总控兼任 | 输出本冻结单 |
| 前端只读 Agent | 总控兼任 | 确认 Flutter 当前外部打开逻辑 |
| BFF 只读 Agent | 总控兼任 | 确认 BFF 仅透传 file/access |
| Server 只读 Agent | 总控兼任 | 确认 Server 只认 project attachment binding |
| 结果校验 Agent | 总控兼任 | 裁决 Day 2 不允许进入 |
| Computer Use 联调 Agent | 未进入 | Day 1 云端接口已阻塞，未到真机联调门槛 |

说明：本轮尝试开只读子代理失败，原因是 agent thread limit reached；因此由总控 Agent 兼任只读核实。

## 6. 风险点

| 风险 | 是否阻塞 | 说明 |
|---|---|---|
| 公共资料有目录但无法生成 accessUrl | 阻塞 | App 内下载没有真实 URL，Flutter 无法凭空下载 |
| 继续只改 Flutter | 阻塞 | 只能把 404 文案换一种展示，不是下载闭环 |
| 直接改云端 DB 绑定到 project_attachments | 阻塞 | 会污染业务真相，把公共资源伪装成项目附件 |
| 直接放宽通用 file/access | 阻塞 | 可能越权暴露任意 FileAsset |
| 预发布按钮文案修正 | 不阻塞技术上可做 | 但按本轮阶段顺序，Day 2 下载闭环未放行，暂不顺手改 |
| 撤回信用风险提示 | 不阻塞技术上可做 | 真实扣分仍需下一轮信用账本冻结 |

## 7. 解锁建议

最小解锁路径：

1. 先冻结 `public_resource` file access scope。
2. Server 在 `/server/file/access` 中支持公共资料 fileAsset：
   - 只允许 `project_public_resources.visibility = app_shared`
   - 只允许已发布 `publishedAt is not null`
   - 只允许 contract 已冻结 MIME 类型
   - 返回 signed `accessUrl`
   - 不要求 `project_attachments` 绑定
3. BFF 仍只透传和整形：
   - 可继续调用 `/api/app/file/access?fileAssetId=...&mode=download`
   - 或显式传 `accessScope=public_resource`
4. Flutter 再进入 App 内下载实现。

不推荐路径：

- 不建议把公共资源补写进 `project_attachments`。
- 不建议让 BFF 直接签 OSS URL。
- 不建议 Flutter 直连 OSS key 或硬编码公共资料 URL。

## 8. 四类判断

| 判断 | 结论 |
|---|---|
| 哪个更稳 | 先补 Server 公共资料 file/access scope，再做 Flutter 下载 |
| 哪个更省成本 | 只改提示文案，但不满足下载闭环 |
| 哪个更适合当前阶段 | 解锁最小 Server scope + Flutter 下载闭环 |
| 哪个风险更大 | 直接放宽通用 file/access 或把公共资源伪装成项目附件 |

## 9. 是否允许进入下一天

- Day 2 `公共资料 App 内下载能力`：`No-Go`
- 原因：云端 `file/access` 对公共资料 fileAsset 返回 404，下载真相未闭合。
- 下一轮唯一动作：
  - 提交并冻结 `public_resource file/access scope` 的 Server/BFF 最小解锁方案。
