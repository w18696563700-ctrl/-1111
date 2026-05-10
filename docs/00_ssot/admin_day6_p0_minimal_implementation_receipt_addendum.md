---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 6 P0 最小实现窗口执行回执
created_at: 2026-05-11
---

# Admin Day 6 P0 最小实现窗口执行回执

## 1. 总裁决

Day 6 目标是实施 P0 必需代码改动，不做 P1 重构。

当前裁决：`PASS WITH RUNTIME FOLLOW-UP`。

本地代码与测试已闭合：

- Forum report 已从 view-only 变成最小 Admin 裁决。
- Forum report 裁决只写 `ForumReportTicketEntity.status` 和 `content_safety_audit_logs`。
- Forum report P0 不隐藏/恢复帖子或评论，不限制作者，不创建处罚系统。
- Audit Admin 只读聚合新增 `content_safety` sourceFamily。
- Admin `/review` 可提交 forum report decision。
- Admin `/audit` 可筛选和展示 `content_safety` audit。

云端 runtime 状态：`PARTIAL`。只完成匿名 fail-close 只读核验；本地新实现未声明已部署到 cloud active release。

## 2. 修改范围

| 层 | 文件 | 内容 |
| --- | --- | --- |
| Server | `apps/server/src/modules/content_safety/content-safety-review-task.write.service.ts` | 新增 `decideForumReport()` 最小裁决命令 |
| Server | `apps/server/src/modules/content_safety/content-safety-admin.controller.ts` | 新增 `/server/admin/content-safety/forum-reports/{ticketId}/decide` |
| Server | `apps/server/src/modules/content_safety/content-safety-review-task.presenter.ts` | forum report `submitted/pending_review` 暴露 `allowedActions=['decide']` |
| Server | `apps/server/src/modules/audit/**` | audit list/detail 聚合 `content_safety` |
| Server | `apps/server/src/modules/review/review.errors.ts` | 新增 content safety task invalid-state error |
| Admin | `apps/admin/src/core/server/admin-review-api-client.ts` | 新增 `decideForumReport()` client |
| Admin | `apps/admin/src/core/server/admin-audit-api-client.ts` | `AuditSourceFamily` 增加 `content_safety` |
| Admin | `apps/admin/src/modules/review/**` | `/review` 增加 forum report 裁决表单 |
| Admin | `apps/admin/src/modules/audit/**` | `/audit` 增加 `content_safety` 筛选 |
| Tests | `apps/server/test/**`, `apps/admin/test/**` | 补充 Server role/audit/review 与 Admin side 测试 |

## 3. 验收命令

```bash
cd apps/server && npm run build
cd apps/server && node --test test/admin-role-gate-header-hint.test.cjs test/admin-review-p0-profile-safety-manual-review-role.test.cjs test/audit-admin-read.test.cjs
cd apps/admin && npm run test:admin-side
cd apps/admin && npm run build
pnpm contracts:check
```

结果：

- Server build：通过。
- Server targeted tests：12 pass / 0 fail。
- Admin `test:admin-side`：48 pass / 0 fail。
- Admin build：通过。
- Contracts check：通过。

## 4. 边界确认

| 禁止项 | 当前状态 |
| --- | --- |
| 支付后台 | 未触碰 |
| 信用人工改分 | 未触碰 |
| 会员写操作后台 | 未触碰 |
| 通用消息后台 | 未触碰 |
| 工单重系统 | 未触碰 |
| settings / flags center | 未触碰 |
| order / contract / fulfillment / settlement | 未触碰 |
| Admin 第二业务真值 | 未引入 |
| Forum 内容隐藏/恢复/处罚状态机 | 未引入 |

## 5. 残余风险

| 风险 | 状态 |
| --- | --- |
| 云端 active release 未证明已包含本地新代码 | `待发布 / 待 runtime 复核` |
| 有效 reviewer carrier 操作链未执行 | `待受控人工核验` |
| Admin full lint 受既有脚本 / test-dist CommonJS 规则影响失败 | `不归因于本轮业务代码；已补定向 lint 与 build/test` |

## 6. Day 6 裁决

Day 6：`PASS`。

进入 Day 7 条件：只允许做证据只读追踪与 P1 边界说明，不允许把证据追踪扩成文件管理后台。
