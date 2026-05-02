---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-02
purpose: Freeze the Day 4 pre-write plan for controlled public showcase sample recovery on Aliyun while keeping actual cloud writes blocked until explicit second confirmation.
inputs_canonical:
  - docs/00_ssot/project_showcase_public_pool_recovery_exit_boundary_freeze_addendum.md
  - docs/01_contracts/project_showcase_public_pool_contract_boundary_confirmation_addendum.md
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project-query.service.ts
  - Aliyun read-only schema inspection via current Server process environment
---

# 项目展示公开池受控样本恢复计划

## 0. 总裁决

- 当前是否已经执行云端写入：`No`。
- 当前是否允许直接执行云端写入：`No-Go`，必须获得二次确认。
- 当前推荐恢复路径：新增专用 canary 项目行，不修改现有用户项目。
- 当前 rollback：按 `project_no` 前缀和本次 `project_id` 精确删除 canary 项目行。
- 当前最小目标：恢复 `1` 条普通公域展示项目，验证 `project/list` 和首页聚合不再为空。

## 1. 只读前置证据

本轮已只读确认云端 `public.project`：

- 当前总行数：`18`
- 当前 `state = published AND published_at IS NOT NULL AND planned_end_at 未过期`：`0`
- 当前 `SHOWCASE-CANARY-%` 样本：`0`
- `project_no` 有唯一索引。
- `id` 有主键。

## 2. 恢复方案对比

| 方案 | 做法 | 稳定性 | 成本 | 风险 | 结论 |
|---|---|---|---|---|---|
| A. 新增 canary 项目 | 插入 1 条专用 `SHOWCASE-CANARY-*` 项目 | 高 | 低 | 可精确 rollback；会产生一条公开样本 | 推荐 |
| B. 修改现有 draft/submitted 项目 | 把已有项目改回 published | 中 | 低 | 可能污染用户真实项目状态 | 不推荐 |
| C. 通过业务 API 新建并发布 | 走 create/submit/publish | 中 | 高 | 可能触发发布门槛、支付或资料链 | 暂不做 |
| D. Flutter/BFF 假数据 | 不写云库，前端兜底 | 低 | 低 | 污染公私域边界 | 禁止 |

推荐采用方案 A。

## 3. 方案 A 的写入边界

只允许新增 1 条项目：

| 字段 | 值 |
|---|---|
| `project_no` | `SHOWCASE-CANARY-20260502-A` |
| `state` | `published` |
| `published_at` | 执行时 `now()` |
| `planned_start_at` | `2026-05-10` |
| `planned_end_at` | `2026-06-10` |
| `province_code / city_code` | `500000 / 500100` |
| `province_name / city_name` | `重庆市 / 重庆市` |
| `building_type` | `exhibition` |
| `budget_amount` | `80000.00` |
| `area_sqm` | `36.00` |
| `organization_id` | `e6bf4567-016e-45f9-9420-9c950237690e` |

本次不允许写入：

- bid
- order
- contract
- milestone
- payment
- platform fee authorization
- project communication
- file asset / attachment
- audit backfill

## 4. 拟执行脚本

以下脚本仅在获得二次确认后执行。它通过当前 Server 进程环境读取数据库连接配置，不打印敏感值。

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 root@47.108.180.198 'bash -s' <<'REMOTE'
set -euo pipefail
pid=$(ss -ltnp | awk '/:3001 / { if (match($0, /pid=[0-9]+/)) { print substr($0, RSTART+4, RLENGTH-4); exit } }')
cwd=$(readlink -f "/proc/$pid/cwd")
cd "$cwd"
SERVER_PID="$pid" NODE_PATH="/srv/workspaces/exhibition-infra-monorepo/node_modules:/srv/workspaces/exhibition-infra-monorepo/node_modules/.pnpm/pg@8.20.0/node_modules" node <<'NODE'
const fs = require('fs');
const { randomUUID } = require('crypto');
const { Client } = require('pg');
const pid = process.env.SERVER_PID;
for (const entry of fs.readFileSync(`/proc/${pid}/environ`, 'utf8').split('\0')) {
  const idx = entry.indexOf('=');
  if (idx <= 0) continue;
  const key = entry.slice(0, idx);
  const value = entry.slice(idx + 1);
  if (key.startsWith('POSTGRES_') || key === 'DATABASE_URL') process.env[key] = value;
}
const client = new Client({
  host: process.env.POSTGRES_HOST || '127.0.0.1',
  port: Number(process.env.POSTGRES_PORT || 5432),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});
(async () => {
  await client.connect();
  const projectNo = 'SHOWCASE-CANARY-20260502-A';
  const existing = await client.query(
    'select id from public.project where project_no = $1 limit 1',
    [projectNo]
  );
  if (existing.rowCount > 0) {
    console.log(JSON.stringify({ ok: false, reason: 'canary_already_exists', projectNo }));
    return;
  }
  const projectId = randomUUID();
  await client.query(
    `
      insert into public.project (
        id, project_no, organization_id, creator_user_id, creator_actor_id,
        title, exhibition_name, brand_name, building_type, budget_amount,
        area_sqm, province_code, province_name, city_code, city_name,
        district_code, district_name, detail_address, scope_summary,
        planned_start_at, planned_end_at, schedule_detail, description,
        state, summary, published_at, created_at, updated_at
      )
      values (
        $1, $2, $3, $4, $4,
        $5, $6, $7, 'exhibition', 80000.00,
        36.00, '500000', '重庆市', '500100', '重庆市',
        null, null, '受控公开展示验收样本地址', '受控公开展示验收样本，仅用于项目展示列表恢复验证。',
        '2026-05-10', '2026-06-10', null, '受控公开展示验收样本。',
        'published',
        $8::jsonb,
        now(), now(), now()
      )
    `,
    [
      projectId,
      projectNo,
      'e6bf4567-016e-45f9-9420-9c950237690e',
      '99c99709-3786-4d8a-a0c3-5e1a0e945821',
      '重庆展览公开展示验收样本',
      '重庆智造展',
      '受控样本品牌',
      JSON.stringify({
        heading: '受控公开展示验收样本',
        stateLabel: '已发布',
      }),
    ]
  );
  const verify = await client.query(
    `
      select id, project_no, state, published_at::text as "publishedAt"
      from public.project
      where id = $1
    `,
    [projectId]
  );
  console.log(JSON.stringify({ ok: true, inserted: verify.rows[0] }, null, 2));
})().catch((error) => {
  console.log(JSON.stringify({ ok: false, error: String(error.message || error) }));
}).finally(async () => {
  try { await client.end(); } catch (_) {}
});
NODE
REMOTE
```

## 5. Rollback 脚本

如恢复后需要回滚，只允许删除本次 canary 行：

```sql
delete from public.project
where project_no = 'SHOWCASE-CANARY-20260502-A'
  and state = 'published'
  and project_no like 'SHOWCASE-CANARY-%';
```

Rollback 后必须只读验证：

```bash
curl -i 'http://127.0.0.1:8080/api/app/project/list?page=1&pageSize=5'
```

## 6. 写入后验收标准

写入后必须只读验证：

1. `GET /api/app/project/list?page=1&pageSize=5` 返回 `200`。
2. `items.length >= 1`。
3. 至少一条 `projectNo = SHOWCASE-CANARY-20260502-A`。
4. `publishedAt` 非空。
5. `state = published`。
6. `GET /api/app/exhibition/home` 的项目推荐不再为空。
7. 无 bid/order/payment/project communication 新行因本次恢复产生。

## 7. 第 5 天前置

只有第 4 天写入和只读接口验收通过后，才允许进入第 5 天 Flutter / Computer Use 页面验收。

若你不批准云端写入，本轮停在“本地修复完成、云端未恢复公开样本”的状态，不得声称页面已恢复。
