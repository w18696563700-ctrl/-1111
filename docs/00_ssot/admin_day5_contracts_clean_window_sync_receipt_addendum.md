---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 5 Contracts / SSOT 最小同步窗口
created_at: 2026-05-11
---

# Admin Day 5 Contracts / SSOT 最小同步窗口执行回执

## 1. 总裁决

Day 5 目标是把 Day 3 / Day 4 已冻结的 Admin P0 API、状态和审计字段同步到正式 contracts / generated projection。

当前裁决：`PASS WITH GENERATED DIFF`。

本轮只处理 Admin P0 所需的最小 contract 投影：

- 内容安全 review task 只读列表 / 详情。
- profile safety 人工审核 approve / reject。
- forum report 最小 Admin 裁决命令。
- audit `content_safety` sourceFamily 只读聚合。

本轮未加入：

- 支付后台。
- 信用人工改分。
- 会员写操作后台。
- 通用消息后台。
- 工单重系统。
- settings / feature flags center。
- order / contract / fulfillment / settlement。
- Forum 帖子/评论隐藏恢复状态机。
- author restriction / ban / penalty 重系统。

云端 runtime 状态：`UNKNOWN`。本回执不声明云端已上线。

## 2. 修改范围

| 文件 | 修改内容 | 依据 |
| --- | --- | --- |
| `docs/01_contracts/openapi.yaml` | 增补 Admin content-safety review task、profile safety manual review、forum report decide、audit logs/list/detail schemas 与 paths | Day 3 / Day 4 冻结文书 |
| `packages/contracts/openapi/openapi.bundle.json` | 由 `pnpm contracts:generate` 生成的 OpenAPI bundle projection | generator |
| `packages/contracts/contracts-manifest.json` | 由 `pnpm contracts:generate` 更新的 manifest hash | generator |

## 3. 新增 / 对齐的 contract family

| Family | Path / Schema | 裁决 |
| --- | --- | --- |
| Review task list | `GET /server/admin/content-safety/review-tasks` | 纳入 P0 |
| Review task detail | `GET /server/admin/content-safety/review-tasks/{taskId}` | 纳入 P0 |
| Profile safety approve | `POST /server/admin/content-safety/profile-submissions/{submissionId}/approve` | 纳入 P0 |
| Profile safety reject | `POST /server/admin/content-safety/profile-submissions/{submissionId}/reject` | 纳入 P0 |
| Forum report decide | `POST /server/admin/content-safety/forum-reports/{ticketId}/decide` | 纳入 P0，只做案件裁决 |
| Audit list | `GET /server/admin/audit/logs` | 纳入 P0，只读 |
| Audit detail | `GET /server/admin/audit/logs/{auditLogId}` | 纳入 P0，只读 |
| Audit source family | `identity / project_publish / content_safety` | `content_safety` 新增为只读聚合来源 |

## 4. 验证命令

```bash
ruby -ryaml -e 'YAML.load_file("docs/01_contracts/openapi.yaml"); puts "openapi yaml ok"'
pnpm contracts:generate
pnpm contracts:check
```

结果：

- `openapi yaml ok`
- `pnpm contracts:generate`：通过
- `pnpm contracts:check`：通过

## 5. 风险与边界

| 风险 | 当前处理 |
| --- | --- |
| generated bundle diff 较大 | 属于生成投影；不得手改 generated bundle |
| 本地 contract 存在不等于云端 runtime 存在 | 保留 runtime `UNKNOWN` |
| forum report decide 被误扩成内容状态机 | Day 3 已收窄为案件裁决，不做 hide / restore / restrict |
| audit 聚合被误扩成 audit mutation | Day 4 已冻结只读聚合，不做 edit / delete / replay / export |

## 6. Day 5 准入 Day 6 裁决

准入条件：

- contract diff 限定在 Admin P0 family。
- generated projection 已通过 generator 与 check。
- No-Go 能力未写入 P0 contracts。
- Day 6 代码实现不得突破 Day 3 / Day 4 文书边界。

当前裁决：`PASS`。
