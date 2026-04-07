---
owner: Codex 总控
status: frozen
purpose: Freeze the Round 0 project asset register after independent signoff, so active assets, runtime/repo drift, and veto blockers are tracked in one formal truth file before any Round 1 admission review.
layer: L0 SSOT
generated_from:
  - docs/00_ssot/project_status_asset_inventory_round0.md
  - docs/00_ssot/round0_inventory_frontend_agent.md
  - docs/00_ssot/round0_inventory_bff_agent_cloud.md
  - docs/00_ssot/round0_inventory_server_agent_cloud.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/round0_inventory_validation_signoff.md
freeze_date_local: 2026-04-02
---

# 项目资产总台账 V1

## 1. 台账元数据

- 记录版本：`V1`
- 生成时间：`2026-04-02`
- 适用阶段：`新工作流 V2 / Round 0 退出裁决前`
- 本轮状态：`Go for asset register + gate checklist only`
- 当前总裁决：`No-Go for Round 1 implementation / migration / deployment / release`

## 2. 资产分类索引

1. 前端资产
2. BFF 资产
3. 后端资产
4. Admin 资产
5. 合同与接口资产
6. 部署与运行时资产
7. SSOT / 门禁 / 校验资产

## 3. 资产条目

### 3.1 前端资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| Flutter Shell 与五楼注册 | `apps/mobile` 已存在五楼壳；底栏当前只显式使用 `exhibition/messages/profile`；`renovation/custom_furniture` 仍为预埋隐藏楼 | 仅本地仓库 | 高 | 不得误删隐藏楼，不得重建壳 | 可直接沿用 |
| Flutter app-facing 基址 | 默认基址仍是 `http://127.0.0.1:8080/api/app`，未发现默认直连 Server 主链 | 仅本地仓库 | 高 | 存在 debug/直连云端入口残留，需后续专项收口 | 可直接沿用 |
| 展览、论坛、企业黄页、消息、个人中心页面资产 | `apps/mobile/lib` 当前 `177` 个文件，页面与消费层已大量存在；`apps/mobile/test` 当前 `112` 个文件 | 仅本地仓库 | 高 | 不能按“空壳 App”误判后重做；多文件超 450 行需后续治理 | 可直接沿用 |
| 前端测试资产 | 已存在 `enterprise_hub`、forum、profile、shell、phase23 等测试与截图失败样本 | 仅本地仓库 | 中 | 不得把失败快照当作生产证据 | 可直接沿用 |
| 前端文件长度门禁状态 | 已发现 handwritten source `>=450` 行：如 `enterprise_hub_consumer_layer.dart`、`forum_creator_page_sections.dart`、`app_router.dart` 等 | 仅本地仓库 | 中 | formal exemption 暂未在本轮定位到 | 本轮修正 |

### 3.2 BFF 资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| BFF workspace 主干 | `apps/bff/src` 当前 `29` 个文件，具备 Nest 主干、health、runtime、server client、error normalizer | 仅本地仓库 | 高 | 不得本地重建平行 BFF | 可直接沿用 |
| BFF 本地挂载面 | 本地 `RoutesModule` 当前仅挂 `EnterpriseHubModule` | 仅本地仓库 | 中 | 本地挂载面不能自动等于云端 running package | 可直接沿用 |
| BFF 云端运行态 | 云端 `3000` 进程、`systemd`、`/srv/apps/bff/current -> /srv/releases/**` 已被核验 | 云端进程与配置 | 高 | 主链运行态与仓库快照存在漂移 | 可直接沿用 |
| `/api/app/*` 真实闭环 | 当前云端真实闭环存在，但依赖线上 Nginx `rewrite ^/api/app/(.*)$ /bff/$1`，不是仓库样例中的单块直转 | 隧道实测 + 云端进程与配置 | 高 | 仓库 `infra/nginx/cloud.conf` 不能继续当 active runtime truth | 本轮修正 |
| forum / file app-facing 挂载 | 当前 runtime 对 `/api/app/forum/*`、`/api/app/file/*` 已返回 BFF 层响应；`file` 当前仍见 `skeleton_only` 语义 | 隧道实测 + 云端进程与配置 | 中 | runtime 已挂载，但本地 `RoutesModule` 未体现；属于 runtime/repo drift | 本轮修正 |

### 3.3 后端资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| Server workspace 主干 | `apps/server/src` 当前 `29` 个文件，`AppModule` 当前纳入 `EnterpriseHubModule` | 仅本地仓库 | 高 | 不得按“无后端”误判后重建 Server | 可直接沿用 |
| enterprise_hub truth / admin | 已存在 `/server/exhibition/enterprise-hub/*` 与 `/server/admin/exhibition/enterprise-hub/*` controller、service、entity、migration 定义 | 仅本地仓库 + 云端进程与配置 | 高 | Admin 外部路径与 canonical path 仍不闭环 | 可直接沿用 |
| Server 主联调链运行态 | 云端 `3001` 由 `systemd` + release 目录运行，health 可达 | 云端进程与配置 | 高 | 仍需和 repo truth 一起登记，不得只信运行态 | 可直接沿用 |
| forum / uploads 真相链 | 本地 Server 未见 forum/uploads controller 挂载；云端直探 `/server/forum/feed`、`/server/uploads/init` 仍为 `404` | 仅本地仓库 + 云端进程与配置 | 低 | 属真实缺口，不得在 Round 0 顺手补做 | 本轮补做 |
| enterprise_hub 迁移与 DB 定义 | 本地 `migrations.ts` 已存在 enterprise hub DDL；本轮未执行迁移 | 仅本地仓库 | 中 | 迁移执行链与表结构现状仍需后续专门核验 | 本轮补做 |

### 3.4 Admin 资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| Admin console skeleton | `apps/admin/src` 当前无源码文件，仅有 AGENTS 与 README 骨架 | 仅本地仓库 | 低 | 不能被误写成“已具备可用后台” | 本轮补做 |

### 3.5 合同与接口资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| L2 contracts / OpenAPI | `docs/01_contracts/openapi.yaml` 与 `packages/contracts` 生成物已存在；app-facing canonical path 已有冻结基线 | 仅本地仓库 | 高 | canonical `/server/admin/*` 与外部 `/api/admin/*` 当前不闭环 | 可直接沿用 |
| app-facing enterprise_hub contracts | `/api/app/exhibition/enterprise-hub/*` 已被 contracts、前端消费层、补证结果三方指向 | 仅本地仓库 + 隧道实测 | 高 | 闭环依赖线上 rewrite，必须写入台账 | 可直接沿用 |
| canonical admin contracts | `/server/admin/exhibition/enterprise-hub/*` 已在 contracts 与 Server controller 中一致 | 仅本地仓库 | 高 | 对外入口错位仍是 veto blocker | 本轮修正 |

### 3.6 部署与运行时资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| Docker 基座 | `infra/docker-compose.yml` 已定义 PostgreSQL / Redis / MinIO | 仅本地仓库 | 高 | 仅代表基座，不代表云端主链进程管理方式 | 可直接沿用 |
| Nginx 仓库样例 | `infra/nginx/cloud.conf` 仍存在 `80 -> 3000/3001` 样例 | 仅本地仓库 | 中 | 样例与当前云端生效规则不完全一致，不能继续当运行真相 | 本轮修正 |
| 云端 active tunnel / host | 当前 active tunnel 为 `8080 -> 47.108.180.198:80`，active dev host 为 `47.108.180.198` | 隧道实测 + 云端进程与配置 + 仅文档声称 | 高 | 必须以新文书为 active baseline，旧主机文书仅保留历史属性 | 可直接沿用 |
| 主联调链 release 运行 | `/srv/apps/*/current` 指向 `/srv/releases/**`，`systemd` 拉起 `node dist/main.js` | 云端进程与配置 | 高 | 可作为 active runtime truth | 可直接沿用 |
| pm2 smoke 并存链 | 仍存在 `/srv/workspaces/**` + `pm2` + `3100/3101/18080` 并存链 | 云端进程与配置 | 低 | 环境纯度风险，阻断 Round 1 准入 | 本轮修正 |

### 3.7 SSOT / 门禁 / 校验资产

| 资产名称 | 现状 | 证据层级 | 可复用性 | 风险 / 缺口 | Round 0 结论 |
|---|---|---|---|---|---|
| 新工作流 V2 接管文书 | Round 0 的 takeover、团队冻结、拓扑、增量原则、下一步唯一动作文书已存在 | 仅本地仓库 | 高 | 不得再回退到旧工作流口径 | 可直接沿用 |
| 角色盘点与独立签收文书 | 前端/BFF/后端/联调/结果校验五份 Round 0 文书已存在并形成证据分层 | 仅本地仓库 | 高 | 部分早期盘点口径与当前代码快照不一致，需以后置台账为准 | 可直接沿用 |
| 旧 active-like 文书漂移 | 仍存在保留过期主机/隧道/资产判断的历史文书 | 仅本地仓库 | 低 | 不得继续作为 active baseline 引用 | 本轮修正 |

## 4. 跨域依赖链

1. Flutter App 主链：
   - `/api/app/*` canonical path
   - 经 `http://127.0.0.1:8080`
   - 进入云端 `80`
   - 经生效 Nginx rewrite 到 `/bff/*`
   - 进入 BFF `3000`
2. enterprise_hub 主链：
   - Flutter `/api/app/exhibition/enterprise-hub/*`
   - BFF `/bff/exhibition/enterprise-hub/*`
   - Server `/server/exhibition/enterprise-hub/*`
   - PostgreSQL truth
3. admin 当前阻断链：
   - 外部 `/api/admin/*`
   - 生效 Nginx 当前转到 `/admin/*`
   - canonical Server controller 为 `/server/admin/*`
   - 当前不闭环
4. forum / file 当前链：
   - BFF app-facing 已挂载
   - Server forum/uploads truth 当前未在本地或补证中闭环

## 5. Round 0 结论字段

### 5.1 可直接沿用

- Flutter shell、五楼注册、隐藏楼策略
- Flutter app-facing canonical path 主链
- BFF / Server 的 Nest 主干与 enterprise_hub 资产
- contracts / generated contracts 基线
- Docker / bootstrap / smoke / Nginx 样例基座
- Round 0 新工作流文书、角色盘点文书、结果校验文书

### 5.2 本轮补做

- Server forum/uploads 真相链的真实位置与策略
- Admin console 真正的现状和后续边界
- enterprise_hub 迁移执行链与 DB 表结构现状核验
- 文件长度超线项的 formal exemption 或后续治理安排

### 5.3 本轮修正

- `/api/admin/*` 对外路径与 canonical `/server/admin/*` 错位
- 仓库 `infra/nginx/cloud.conf` 与当前云端生效 `/api/app/*` rewrite 规则不一致
- repo snapshot 与 runtime package 漂移未冻结成单一口径
- 旧 active-like 主机/隧道/资产文书仍保留误导性现时口吻
- pm2 smoke 并存链造成环境纯度风险

### 5.4 禁止重复

- 禁止本地重建 BFF
- 禁止本地重建 Server
- 禁止把前端现有页面体系整体推翻重做
- 禁止把 enterprise_hub 当作“未开始”重新搭架子
- 禁止在 Round 0 期间顺手修复、迁移、部署、发版

## 6. 阻断闭环字段

| 阻断项编号 | 阻断原因 | 证据路径 | 关闭条件 | 当前状态 |
|---|---|---|---|---|
| `BLK-R0-ADMIN-PATH` | `/api/admin/*` 外部入口与 canonical `/server/admin/*` 不闭环 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §7；`docs/00_ssot/round0_inventory_validation_signoff.md` §5.2 | 形成单一外部 canonical path 策略并以运行态证据闭环 | Open |
| `BLK-R0-APP-REWRITE-DRIFT` | `/api/app/*` 当前真实闭环依赖云端 rewrite，而仓库样例未同步 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §4.2、§8；`docs/00_ssot/round0_inventory_validation_signoff.md` §5.1 | active runtime truth 与 repo truth 对齐，或明确 active override 文书接管 | Open |
| `BLK-R0-RUNTIME-REPO-DRIFT` | BFF 本地 `RoutesModule` 与当前 runtime 已挂载面不一致 | `apps/bff/src/routes/routes.module.ts`；`docs/00_ssot/round0_inventory_validation_signoff.md` §5.3 | 冻结 active package 口径，并明确 repo 与 runtime 的关系 | Open |
| `BLK-R0-ENV-PURITY` | `pm2 + /srv/workspaces/** + 3100/3101/18080` 并存 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §4.3、§5.3；`docs/00_ssot/round0_inventory_validation_signoff.md` §5.6 | 形成明确环境边界或清理并存栈 | Open |
| `BLK-R0-SERVER-GAP` | Server forum/uploads 真相链当前未闭环 | `docs/00_ssot/round0_inventory_server_agent_cloud.md` §7.1；`docs/00_ssot/round0_inventory_validation_signoff.md` §5.4 | 明确该能力的真相承载位置和实施/下线策略 | Open |
| `BLK-R0-FILE-LENGTH` | handwritten source `>=450` 且未在本轮定位到 formal exemption | `docs/00_ssot/round0_inventory_validation_signoff.md` §4.2；本地源码统计 | 找到 formal exemption 或纳入后续治理包 | Open |

## 7. 审批与冻结记录

- 盘点冻结人：`Codex 总控`
- 独立复核结论：`有条件通过`
- 当前 No-Go 原因：
  - canonical admin path drift
  - runtime/repo drift 未冻结为单一真相
  - pm2 workspace smoke 并存
  - handwritten source 超线门禁未闭环
- 当前允许进入的下一步：
  - 新的《阶段门禁核查表》
- 当前不允许进入的下一步：
  - 《Round 1 增量派工单》
  - 任何执行角色开发轮
  - 联调实施、迁移、部署、发版
- 允许进入 Round 1 的前置条件：
  - 总控完成新的阶段门禁核查表
  - veto 阻断项闭环或被明确降级为非 veto
  - active topology、active tunnel、active runtime/repo truth 完成单一冻结
