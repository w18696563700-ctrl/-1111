---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-02
purpose: Freeze the Day 4 cloud runtime recovery receipt and Day 5 frontend visual verification for project showcase public-pool restoration.
inputs_canonical:
  - docs/00_ssot/project_showcase_public_pool_recovery_exit_boundary_freeze_addendum.md
  - docs/01_contracts/project_showcase_public_pool_contract_boundary_confirmation_addendum.md
  - docs/00_ssot/project_showcase_public_pool_controlled_sample_recovery_plan_addendum.md
  - docs/00_ssot/evidence/20260502-project-showcase-public-pool-macos-detail.png
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/test/project-showcase-public-filtering.test.cjs
---

# 项目展示公开池恢复 Day4 / Day5 运行回执

## 0. 总裁决

- 本回执总裁决：`Conditional Pass`。
- `GET /api/app/project/list` 公开池恢复：`Pass`。
- Flutter 首页项目面板真实展示：`Pass`。
- Flutter 项目展示列表真实展示：`Pass`。
- Flutter 项目详情真实进入：`Pass`。
- BFF 是否改动：`No`。
- Flutter 是否改动：`No`。
- Server 是否改动并部署：`Yes`，仅部署公开池资格保护最小 patch。
- 云端数据是否写入：`Yes`，仅写入 1 条 rollbackable canary 项目。
- `/api/app/exhibition/home.recommendationSections.project_recommendations` 是否恢复：`No`，该字段当前由 Server presenter 固定输出空数组，不作为本轮公开池修复完成证据。

本轮结论：项目展示为空的主链路已恢复，真实页面已经能看到云端公开项目；首页聚合接口里的 `project_recommendations` 空数组属于独立首页反射/聚合缺口，不得被本轮误报为已完成。

## 1. 执行边界

本轮只允许并实际执行：

1. Server 最小公开资格保护部署。
2. 新增 1 条受控公开 canary 项目。
3. 只读验证 BFF / Server 健康、`project/list`、城市/省份筛选。
4. Flutter 本地 macOS 指向云端隧道做真实页面验收。

本轮未执行：

1. 未部署 BFF。
2. 未修改 Flutter。
3. 未新增业务接口。
4. 未新增 payment / order / bid / project communication 写入。
5. 未把私域项目混入公开池。
6. 未把 `converted_to_order / submitted` 项目重新塞回普通项目展示。

## 2. 云端 Server 部署回执

| 项 | 值 |
|---|---|
| 执行前 Server release | `/srv/releases/server/20260502225353-project-communication-workbench-source-files-server` |
| 执行后 Server release | `/srv/releases/server/20260502232455-project-showcase-public-pool-protection` |
| BFF release | `/srv/releases/bff/20260502225353-project-communication-workbench-source-files-bff` |
| Server systemd service | `exhibition-server` |
| 回滚记录 | `/srv/patches/project-showcase-public-pool-protection/20260502232455-project-showcase-public-pool-protection.rollback` |
| canary 回执 | `/srv/patches/project-showcase-public-pool-protection/20260502232455-project-showcase-public-pool-protection.canary.json` |

部署内容只覆盖 Server 项目查询服务的源文件和构建产物：

1. `src/modules/project/project-query.service.ts`
2. `dist/modules/project/project-query.service.js`
3. `dist/modules/project/project-query.service.d.ts`
4. `dist/modules/project/project-query.service.js.map`

部署后只读健康结果：

| Endpoint | 结果 |
|---|---|
| `GET http://127.0.0.1:8080/health/bff/live` | `200` |
| `GET http://127.0.0.1:8080/health/server/live` | `200` |

说明：Server restart 后第一次本机端口探测出现过启动瞬间连接拒绝，随后健康检查恢复为 `200`；最终运行态以通过隧道的 BFF / Server 健康结果为准。

## 3. 受控公开样本回执

本轮仅新增 1 条 canary 项目：

| 字段 | 值 |
|---|---|
| `id` | `96c3aed9-66dd-4851-a8ec-280777383e8c` |
| `project_no` | `SHOWCASE-CANARY-20260502-A` |
| `state` | `published` |
| `published_at` | `2026-05-02T15:28:40.781Z` |
| `planned_start_at` | `2026-05-10` |
| `planned_end_at` | `2026-06-10` |
| `province_name` | `重庆市` |
| `city_name` | `南岸区` |
| `building_type` | `exhibition` |
| `budget_amount` | `80000.00` |
| `area_sqm` | `36.00` |

只读库验收：

```json
{
  "canary_count": 1,
  "eligible_now": 1
}
```

Rollback 只允许删除本 canary 行：

```sql
delete from public.project
where project_no = 'SHOWCASE-CANARY-20260502-A';
```

## 4. 接口验收回执

| 只读接口 | 结果 |
|---|---|
| `GET /api/app/project/list?page=1&pageSize=5` | `200`，返回 1 条 canary 项目 |
| `GET /api/app/project/list?page=1&pageSize=5&cityCode=500108` | `200`，返回 1 条 canary 项目 |
| `GET /api/app/project/list?page=1&pageSize=5&provinceCode=500000` | `200`，返回 1 条 canary 项目 |
| `GET /api/app/exhibition/home` | `200`，但 `recommendationSections.project_recommendations.items=[]` |

`project/list` 返回的关键字段：

```json
{
  "projectId": "96c3aed9-66dd-4851-a8ec-280777383e8c",
  "projectNo": "SHOWCASE-CANARY-20260502-A",
  "title": "项目名称需申请查看",
  "displayTitle": "项目名称需申请查看",
  "state": "published",
  "buildingType": "exhibition",
  "budgetAmount": 80000,
  "areaSqm": 36,
  "provinceName": "重庆市",
  "cityName": "南岸区",
  "plannedStartAt": "2026-05-10",
  "plannedEndAt": "2026-06-10"
}
```

## 5. 首页聚合口径修正

Day 4 预案中曾把 `GET /api/app/exhibition/home` 的 `project_recommendations` 非空列为验收项。当前运行核对后修正为：

1. 普通项目展示公开池的正式验收接口是 `GET /api/app/project/list`。
2. Flutter 首页项目面板当前通过 `ExhibitionConsumerLayer.loadProjectList()` 消费 `project/list`，不是依赖 `recommendationSections.project_recommendations`。
3. Server 当前 `exhibition-home.presenter.ts` 对 `recommendationSections` 输出固定空集合。
4. 因此，本轮不得声称 `/api/app/exhibition/home.recommendationSections.project_recommendations` 已恢复。
5. 如需恢复首页聚合接口项目推荐，必须另开 `exhibition_home` / 首页反射聚合的 SSOT 与 contracts 门禁。

## 6. Flutter 页面验收回执

本地 Flutter 运行参数：

```bash
flutter run -d macos --dart-define=APP_BFF_BASE_URL=http://127.0.0.1:8080/api/app
```

Computer Use 真实页面验收：

| 页面 | 结果 |
|---|---|
| 展览首页项目面板 | 出现真实项目卡片，空态消失 |
| 项目展示列表 | 出现 `SHOWCASE-CANARY-20260502-A` 项目卡片 |
| 项目详情 | 可进入详情页，展示项目编号、类型、面积、预算、说明 |

截图证据：

- [20260502-project-showcase-public-pool-macos-detail.png](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/evidence/20260502-project-showcase-public-pool-macos-detail.png)

浏览器验收说明：

- Codex Browser Use 后端不可用，无法通过内置浏览器完成。
- Flutter Web 启动后页面显示该应用未配置 Web 构建，不作为移动端验收口径。
- 本轮最终采用 macOS Flutter App + Computer Use 完成真实 UI 验收。

## 7. 本地验证回执

| 命令 | 结果 |
|---|---|
| `pnpm contracts:generate` | `Pass` |
| `pnpm contracts:check` | `Pass` |
| `cd apps/server && npm run build` | `Pass` |
| `node --test test/project-showcase-public-filtering.test.cjs test/project-lifecycle-correction.test.cjs` | `Pass`，`19` tests |
| `flutter test test/project_showcase_filter_create_refactor_test.dart --plain-name 'project list renders real content-state with compact main info'` | `Pass` |
| `flutter test test/exhibition_home_test.dart --plain-name 'exhibition home reads province project recommendations from cloud list and refreshes in place'` | `Pass` |

## 8. 仍保留的风险

1. 当前公开池依赖 1 条 canary 样本，后续真实公开项目上架后，应决定是否保留、替换或删除该 canary。
2. `project/list` 已恢复，但首页聚合接口 `project_recommendations` 仍为空，不能用它证明首页项目推荐链路完整。
3. 本地工作区存在大量项目通信工作台相关未归属脏文件，本轮未清理、未回滚、未归并。
4. 本轮没有做正式生产发布流水线，只做了获得确认后的云端最小 release 切换和 runtime smoke。

## 9. 下一步门禁

若继续治理，建议按以下顺序：

1. 单独冻结 `exhibition_home` 首页聚合接口是否应承载项目推荐。
2. 决定 canary 样本保留周期和 owner。
3. 把退出治理验证样本和公开展示样本永久隔离，避免再次把公开池当作验证耗材。
4. 在云端真实公开项目数量稳定后，再评估是否删除 `SHOWCASE-CANARY-20260502-A`。
