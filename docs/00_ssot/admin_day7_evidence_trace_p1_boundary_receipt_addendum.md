---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 7 证据只读追踪与 P1 边界
created_at: 2026-05-11
---

# Admin Day 7 证据只读追踪与 P1 边界回执

## 1. 总裁决

Day 7 目标是补 P0-7 和部分 P1：项目 / FileAsset / Evidence 只读追踪、Enterprise Hub 管理面补强。

当前裁决：`PARTIAL PASS`。

完成项：

- Admin 增加共享 `EvidenceFileAssetRefs` 只读组件。
- `/project_review` 展示 exhibition report-case 的 `evidenceFileAssetIds`。
- `/governance/penalties` 展示 penalty 的 `evidenceFileAssetIds`。
- `/governance/appeals` 展示 appeal 的 `evidenceFileAssetIds`。

明确延后项：

- Enterprise Hub `publish/offline/freeze/recommendation-slots` 受控 UI 不在本地 P0 代码窗口继续扩张。
- 不新增 FileAsset 管理后台。
- 不新增 Evidence 详情解析后台。
- 不新增文件下载、删除、替换、重绑、审核状态机。

## 2. 修改范围

| 文件 | 修改内容 |
| --- | --- |
| `apps/admin/src/modules/evidence-file-asset-refs.tsx` | 新增 FileAsset / Evidence 只读引用组件 |
| `apps/admin/src/modules/project_review/project-review-shell.tsx` | 案件详情显示证据 FileAsset ID |
| `apps/admin/src/modules/governance/penalty-shell.tsx` | 处罚详情显示证据 FileAsset ID |
| `apps/admin/src/modules/governance/appeal-shell.tsx` | 申诉详情显示证据 FileAsset ID |

## 3. 验收命令

```bash
cd apps/admin && npm run test:admin-side
cd apps/admin && npm run build
cd apps/admin && ./node_modules/.bin/eslint src/core/server/admin-audit-api-client.ts src/core/server/admin-review-api-client.ts src/modules/audit/audit-shell.tsx src/modules/audit/audit-state.ts src/modules/review/review-actions.ts src/modules/review/review-shell.tsx src/modules/evidence-file-asset-refs.tsx src/modules/project_review/project-review-shell.tsx src/modules/governance/penalty-shell.tsx src/modules/governance/appeal-shell.tsx test/admin-api-client.test.cjs test/admin-audit.test.cjs test/admin-review.test.cjs test/admin-governance-penalty.test.cjs test/admin-governance-appeal.test.cjs
```

结果：

- Admin `test:admin-side`：48 pass / 0 fail。
- Admin build：通过。
- Admin changed-files targeted lint：通过。

## 4. 边界确认

| 能力 | 当前裁决 |
| --- | --- |
| FileAsset ID 展示 | 允许，只读 |
| 文件下载 / 预览 | 本轮不做 |
| 文件替换 / 删除 / 重新绑定 | 本轮不做 |
| Evidence 独立详情页 | 本轮不做 |
| Enterprise Hub 管理操作 UI | P1，需独立施工窗口 |

## 5. Day 7 裁决

Day 7：`PARTIAL PASS`。

原因：P0 证据 ID 只读追踪已补，P1 Enterprise Hub 操作 UI 明确延后，不阻塞本轮 Admin P0 最小闭环。
