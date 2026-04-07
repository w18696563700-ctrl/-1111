---
owner: 结果校验 Agent
status: conditional_signoff
purpose: Round 0 盘点独立复核与正式签收；仅限文书裁决、证据分层与门禁建议，不授予开发、迁移、部署或发布许可。
layer: L0 SSOT
inputs_canonical:
  - docs/00_ssot/new_workflow_v2_takeover_declaration_round0.md
  - docs/00_ssot/project_status_asset_inventory_round0.md
  - docs/00_ssot/team_organization_freeze_round0.md
  - docs/00_ssot/project_topology_and_tunnel_rules_round0.md
  - docs/00_ssot/zh_incremental_construction_principles_round0.md
  - docs/00_ssot/port_path_mapping_rules_round0_draft.md
  - docs/00_ssot/round0_inventory_review_rubric_and_checklist_draft.md
  - docs/00_ssot/round0_inventory_frontend_agent.md
  - docs/00_ssot/round0_inventory_bff_agent_cloud.md
  - docs/00_ssot/round0_inventory_server_agent_cloud.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md
  - docs/01_contracts/openapi.yaml
review_method:
  - local docs read-only review
  - local repo read-only code/config review
  - local tunnel read-only probe on 127.0.0.1:8080
review_date_local: 2026-04-02
---

# Round 0 盘点独立签收文书

## 1. 签收结论

- 本席正式签收结论：`有条件通过`。
- 本结论的准确含义是：
  - 允许总控输出《项目资产总台账 V1》。
  - 允许总控输出新的《阶段门禁核查表》。
  - 不允许总控输出《Round 1 增量派工单》。
  - 不允许任何执行角色进入开发轮、联调实施、迁移、部署或发版。
- 本结论不是：
  - Round 1 放行
  - release-prep 放行
  - release 放行
  - 对现网拓扑、Admin 路径或环境纯度问题的闭环确认

作出 `有条件通过` 而不是 `通过` 的原因如下：

- Round 0 核心事实已经形成可复核的证据分层，且主要缺口已能精确登记。
- `/api/app/*` 闭环、`current -> /srv/releases/**` 主联调链、`pm2 + /srv/workspaces/** + 3100/3101/18080` 并存风险，都已不再只是文字声称。
- 但 `/api/admin/*` 与 canonical `/server/admin/*` 仍然不闭环，当前阶段仍存在 veto 级阻断。
- 本地仓库快照与云端 running package 存在已证实漂移，仍需总控先把台账和阶段门禁冻结成单一口径，不能直接进入 Round 1。

## 2. 结论依据表

| 主题 | 独立判断 | 证据层级 | 核心锚点 |
|------|----------|----------|----------|
| 旧工作流废弃但旧资产保留 | 成立 | 仅本地仓库 | `docs/00_ssot/new_workflow_v2_takeover_declaration_round0.md`；`docs/00_ssot/project_status_asset_inventory_round0.md` |
| 前端不是空壳 | 成立 | 仅本地仓库 | `apps/mobile/lib/**`、`apps/mobile/test/**`；`app_building.dart`、`config_manifest.dart`、`app_router.dart` |
| Flutter 默认只通过 BFF | 成立 | 仅本地仓库 | `apps/mobile/lib/core/api/app_api_client.dart` |
| BFF 源码存在与实际挂载需要区分 | 成立，且当前已出现漂移 | 仅本地仓库 + 隧道实测 + 云端进程与配置 | `apps/bff/src/routes/routes.module.ts`；`docs/00_ssot/round0_inventory_release_integration_agent.md` §4、§6；`docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md` §1.3 |
| Server 当前本地已落地 enterprise_hub | 成立 | 仅本地仓库 | `apps/server/src/app.module.ts`；`enterprise-hub-truth.controller.ts`；`enterprise-hub-admin.controller.ts` |
| Server 当前本地未见 forum/uploads 真相挂载 | 成立，且已登记为缺口 | 仅本地仓库 | `apps/server/src`；`docs/00_ssot/round0_inventory_server_agent_cloud.md` §7.1 E-SRV-03 |
| `/api/app/*` 当前云端真实闭环存在 | 成立，但依赖云端 rewrite，不等于仓库样例逐字同构 | 隧道实测 + 云端进程与配置 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §4.4、§6.1；`docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md` §1.3、§2 |
| `/api/admin/*` 当前不闭环 | 成立 | 隧道实测 + 云端进程与配置 + 仅本地仓库 | `infra/nginx/cloud.conf`；`apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`；`docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md` §3 |
| 主联调链为 release 目录而非 workspace 源码目录 | 成立 | 云端进程与配置 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §5.1、§5.2 |
| pm2 workspace smoke 栈并存属于环境纯度风险 | 成立 | 云端进程与配置 | `docs/00_ssot/round0_inventory_release_integration_agent.md` §4.3、§5.3、§5.4 |
| Round 1 仍不可进入 | 成立 | 文书交叉复核 + 门禁建议 | 本文 §8 与 §9 结论 |

## 3. 与 Round 0 核心要求的对照勾选结果

> 勾选语义：`[x]` = 已核验成立；`[~]` = 已核验但需带缺口说明；`[ ]` = 当前不能勾选。

### 3.1 工作流与资产口径

- [x] 旧工作流已废弃，但旧资产保留且不得重复建设。
- [x] Round 0 仍是盘点与独立复核轮，不授予实现许可。
- [x] 四类盘点文书均未使用 Round 0 禁用措辞。
- [~] 当前 docs 内仍有历史/旧基线文书保留了过期主机与隧道口径，已构成 truth drift 风险，不能继续当作 active baseline 使用。

### 3.2 本地 / 云端边界

- [x] 前端仅本地、BFF 与 Server 仅云端的角色边界，在 current Round 0 文书中是清楚的。
- [x] Flutter 默认基址仍是 `http://127.0.0.1:8080/api/app`，不是直连 Server。
- [~] 前端存在 debug 直连云端 BFF 的入口：`apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart` 中 `_devCloudDirectBaseUrl`，该入口不等于主链，但必须保留为边界风险。
- [x] 未发现把 SSH 隧道当作“远程编码通道”的正式表述。

### 3.3 资产盘点完整性

- [x] 前端既有页面、路由、消费者和测试资产已被识别为可复用资产，不允许被误判为空壳。
- [~] BFF 的“本地源码存在”和“云端实际挂载”已能区分，但 Round 0 盘点文书尚未把当前 running package 漂移写实到位。
- [x] Server 的 enterprise_hub 已落地、本地 forum/uploads 真相缺口已被诚实登记。
- [ ] `apps/admin` skeleton 未进入当前 Round 0 主盘点链，资产盘点不算完全闭合。

### 3.4 路径与联调链

- [x] `/api/app/*` 已经由补证文书和本席只读探测证明当前云端真实闭环存在。
- [x] `/api/admin/*` 已经由补证文书和本席只读探测证明当前不闭环。
- [x] `/api/app/*` 当前真实闭环依赖云端 rewrite 到 `/bff/*`，不能把仓库 `infra/nginx/cloud.conf` 样例直接当成线上真相。
- [x] `current -> /srv/releases/**` 已有云端证据，不再只是仓库推断。
- [x] `pm2 + /srv/workspaces/** + 3100/3101/18080` 并存已被正式登记，属于环境纯度风险。

### 3.5 Formal truth 约束

- [x] 本文继续保留 `owner / status / purpose / layer` 头字段。
- [x] 本文明确区分 `仅本地仓库 / 隧道实测 / 云端进程与配置` 三类证据。
- [x] 本文未写入密码、密钥、token、完整敏感头。
- [x] 本文未使用 Round 0 禁用措辞描述本轮行为。

## 4. 关键证据与关键缺口

### 4.1 关键证据

1. 五楼壳与首发可见楼保持冻结拓扑，没有被推倒重来。
   - `apps/mobile/lib/shell/navigation/app_building.dart`
   - `apps/mobile/lib/core/config/config_manifest.dart`

2. Flutter 默认仍走 BFF app-facing canonical path。
   - `apps/mobile/lib/core/api/app_api_client.dart`
   - 默认 `baseUrl = http://127.0.0.1:8080/api/app`

3. 本地 BFF 源码并非空壳，且本地 `RoutesModule` 当前只挂 `EnterpriseHubModule`。
   - `apps/bff/src/routes/routes.module.ts`
   - `apps/bff/src/routes/forum/forum.controller.ts`
   - `apps/bff/src/routes/file/file.controller.ts`

4. 本地 Server 当前只把 `EnterpriseHubModule` 纳入 `AppModule`。
   - `apps/server/src/app.module.ts`
   - `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
   - `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`

5. 本席本轮只读补证表明当前本机 `8080` 隧道已活跃，且最小路径已可复核。
   - `lsof -nP -iTCP:8080 -sTCP:LISTEN` 可见 `ssh` 监听
   - `GET /health/bff/live -> 200`
   - `GET /health/server/live -> 200`
   - `GET /api/app/exhibition/home -> 200`
   - `GET /api/app/forum/feed -> 401, source=bff`
   - `GET /api/app/file/access -> 401, source=bff`
   - `GET /api/app/project/list -> 404, source=bff`
   - `GET /api/admin/ -> 404`

6. 联调补证文书已证明线上 Nginx 与仓库样例并非完全同构。
   - `docs/00_ssot/round1_r1_01_r1_03_evidence_release_integration.md` §1.3
   - 线上 `/api/app/*` 为多 `location` + `rewrite ^/api/app/(.*)$ /bff/$1`

7. 联调补证文书已证明主联调链为 release 目录运行，而不是 workspace 源码目录。
   - `docs/00_ssot/round0_inventory_release_integration_agent.md` §5.1、§5.2
   - `readlink -f /srv/apps/*/current` 指向 `/srv/releases/**`
   - `WorkingDirectory=/srv/apps/*/current`

8. 联调补证文书已证明 smoke pm2 栈并存。
   - `docs/00_ssot/round0_inventory_release_integration_agent.md` §4.3、§5.3、§5.4
   - `pm2` 进程指向 `/srv/workspaces/exhibition-infra-monorepo/...`
   - 监听端口为 `3100/3101/18080`

9. canonical admin 路径在 contracts 与 Server controller 中是一致的 `/server/admin/*`。
   - `docs/01_contracts/openapi.yaml` `/server/admin/exhibition/enterprise-hub/applications`
   - `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`

### 4.2 关键缺口

1. `/api/admin/*` 外部入口与 canonical `/server/admin/*` 未闭环。

2. 本地 BFF `RoutesModule` 与当前云端 running package 不一致。
   - 本地只挂 `EnterpriseHubModule`
   - 当前 runtime 已可对 forum/file 路径返回 BFF 层响应

3. 本地 Server 未见 forum/uploads 真相挂载。
   - 当前只能说“本地未见”，不能把 BFF 侧 `401` 当成 Server 真相存在证明。

4. 历史/旧基线文书仍保留过期拓扑口径。
   - 典型例：`docs/00_ssot/new_workflow_takeover_asset_inventory_baseline_addendum.md`
   - 其中仍保留 `28790 -> 47.108.140.84:8443` 与“本地无 BFF/Server 有效手写实现”等旧判断，不能继续作为 active baseline

5. 文件长度门禁未闭环。
   - `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`：576 行
   - `apps/mobile/lib/shell/navigation/app_router.dart`：494 行
   - 在当前复核范围内未找到 formal exemption

## 5. 逐项裁决

### 5.1 `/api/app` 闭环裁决

- 裁决：`已核验闭环存在，但不是按仓库样例直通形成。`
- 结论细化：
  - `/api/app/*` 当前可通过 `80 -> rewrite -> /bff/* -> 3000` 的真实云端链路闭环。
  - 这一点已有云端进程与配置证据，也有当前本机 `8080` 只读探测复核。
  - 因此不能再把 `/api/app/*` 记为“未测”。
  - 同时也不能把仓库 `infra/nginx/cloud.conf` 的单块 `/api/app/` 样例直接写成当前线上真相。

### 5.2 `/api/admin` 错位裁决

- 裁决：`已核验证实当前不闭环。`
- 结论细化：
  - `infra/nginx/cloud.conf` 与线上生效 Nginx 都把 `/api/admin/` 反代到上游 `/admin/...`。
  - Server canonical controller 与 openapi canonical path 均为 `/server/admin/...`。
  - 因此外部 `/api/admin/*` 与内部 `/server/admin/*` 之间出现前缀错位。
  - 本问题已经不是“待猜测风险”，而是“已被证据证明的阻断项”。

### 5.3 BFF forum/file 挂载裁决

- 裁决：`本地源码存在；云端 runtime 当前也存在对应 app-facing 闭环；二者不可直接视为同一真相。`
- 结论细化：
  - 本地有 `bff/forum` 与 `bff/file` controller。
  - 但本地 `RoutesModule` 没有把 `ForumModule` / `FileModule` 纳入当前挂载。
  - 当前云端 runtime 对 `/api/app/forum/*` 与 `/api/app/file/*` 已可返回 BFF 层响应，说明 running package 并不等于本地当前 `RoutesModule` 快照。
  - 此项必须在台账中单列为“源码快照 / 运行快照漂移”，不能继续笼统写成“待核验”。

### 5.4 Server forum/uploads 缺口裁决

- 裁决：`本地真相侧缺口已登记，当前仍应保持缺口状态。`
- 结论细化：
  - 本地 `AppModule` 仅引入 `EnterpriseHubModule`。
  - 本地未见 forum/uploads controller 或 module 挂载。
  - BFF 侧对 forum/file 的可达，只能证明 BFF app-facing 路由存在，不能自动证明 Server forum/uploads 真相已落地。
  - 因此 Round 0 必须继续维持“本地 Server 真相缺口已登记”的判断。

### 5.5 主联调链 release 化裁决

- 裁决：`已核验成立。`
- 结论细化：
  - `current` 已解析到 `/srv/releases/**`，不是 `/srv/workspaces/**`。
  - `systemd WorkingDirectory` 指向 `/srv/apps/*/current`。
  - 因而当前 `80 -> 3000/3001` 主联调链满足“非 workspace 源码目录运行”门禁。
  - 这能支持台账输出，但不能据此推出 Round 1 已可放行。

### 5.6 pm2 smoke 并存风险裁决

- 裁决：`已核验存在，属于环境纯度风险。`
- 结论细化：
  - 当前云端并存一套 `pm2` 管理的 workspace-based smoke 栈，监听 `3100/3101`，并有 `127.0.0.1:18080` 入口。
  - 该栈不是本轮 `8080 -> 80` 主联调链。
  - 但它会阻断“环境单一、路径单一、运行态纯净”的判断。
  - 本风险不阻断《项目资产总台账 V1》，但阻断《Round 1 增量派工单》与任何开发轮放行。

## 6. 是否允许进入《项目资产总台账 V1》

- 结论：`允许。`
- 但只允许在以下口径下输出：
  - 明确写出 `/api/app/*` 当前真实闭环已经被补证，不再写成“未测”。
  - 明确写出 `/api/admin/*` 当前不闭环，且属于阻断项。
  - 明确写出当前主联调链为 `/srv/releases/**`，同时并存 `pm2 /srv/workspaces/** /3100/3101/18080` 风险。
  - 明确写出本地 BFF/Server 源码快照与云端 running package 不等价。
  - 明确写出旧/过期拓扑文书只能保留为历史资产，不得继续充当 active baseline。

## 7. 是否允许进入《Round 1 增量派工单》

- 结论：`不允许。`
- 原因：
  - canonical admin path drift 仍为 veto 级阻断。
  - runtime / repo drift 仍未被总控冻结成单一真相。
  - pm2 smoke 栈并存风险未闭环。
  - 文件长度门禁仍有未登记 exemption 的 handwritten source 超线项。

## 8. 当前阶段门禁建议

### 8.1 passed gates

- `Gate 2 目录洁癖门禁`
  - 本轮复核范围内未发现密码、密钥、token 被写入 docs 回执。
- `Gate 3 架构边界门禁`
  - 五楼壳仍在，隐藏楼仍隐藏，Flutter 默认仍走 BFF。
- `Gate 6 数据与上传门禁`
  - 契约与 BFF 文件流仍维持 `init -> direct upload -> confirm` 口径。

### 8.2 failed gates

- `Gate 1 真源门禁`
  - 旧/过期拓扑基线文书仍保留 active-like 口吻，形成 truth drift 风险。
- `Gate 4 契约门禁`
  - canonical `/server/admin/*` 与对外 `/api/admin/*` 当前不闭环。
- `Gate 9 云上运行门禁`
  - 虽然主联调链满足 release 目录运行，但 runtime rewrite 未纳入本地样例，且 pm2 workspace smoke 栈并存。
- `Gate 11 文件长度与职责门禁`
  - 已发现 handwritten source `>= 450` 行，且当前复核范围内未找到 formal exemption。

### 8.3 veto gates

- `Gate 4`：canonical path drift
- `Gate 9`：cloud-only truth drift / environment purity unresolved
- `Gate 11`：handwritten source `>= 450` without located formal exemption

### 8.4 stage go / no-go suggestion

- 对《项目资产总台账 V1》：`Go`
- 对新的《阶段门禁核查表》：`Go`
- 对《Round 1 增量派工单》：`No-Go`
- 对任何执行角色进入开发轮：`No-Go`

## 9. 修订记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-04-01 | 结果校验 Agent 首次签收稿，主要依据四份 Round 0 盘点文书与本地仓库抽检。 |
| v0.2 | 2026-04-02 | 按总控口令升版：补入 Round 0 核心文书、openapi、云端联调补证、`current -> /srv/releases/**`、pm2 workspace smoke 风险，以及本席当前 `127.0.0.1:8080` 只读探测结果；重写门禁建议与总控可执行结论。 |

**总控可执行结论**

1. 当前允许总控输出《项目资产总台账 V1》，但必须把 `/api/app` 闭环、`/api/admin` 错位、release 主链与 pm2 smoke 并存风险写成单一口径。  
2. 当前不允许总控输出《Round 1 增量派工单》。  
3. 当前不允许任何执行角色进入开发轮。  
4. 当前下一步唯一动作应当是：由总控先输出《项目资产总台账 V1》与新的《阶段门禁核查表》，把 active topology、active tunnel、runtime/repo 漂移和 veto 阻断项冻结成单一真相，然后再决定是否重新发起 Round 1 准入审查。  
