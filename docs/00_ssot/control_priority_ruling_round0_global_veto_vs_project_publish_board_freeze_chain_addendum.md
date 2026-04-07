---
owner: Codex 总控
status: frozen
purpose: Decide which control chain currently governs the project publish board under New Workflow V2, map Round 0 global veto blockers to the publish board minimum-success corridor, and freeze the next unique action without reopening unlimited implementation.
layer: L0 SSOT
inputs:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/admin_path_blocker_closure_assessment_addendum.md
  - docs/00_ssot/app_api_rewrite_drift_closure_assessment_addendum.md
  - docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md
  - docs/00_ssot/environment_purity_blocker_closure_assessment_addendum.md
  - docs/00_ssot/file_length_governance_blocker_closure_assessment_addendum.md
  - docs/00_ssot/server_truth_gap_blocker_closure_assessment_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/file/file.controller.ts
  - apps/bff/src/routes/file/file.service.ts
  - apps/server/src/app.module.ts
freeze_date_local: 2026-04-02
---

# 控制优先级裁决单：Round 0 全局 veto vs 项目发布板块冻结链

## 1. 裁决对象

- 当前裁决对象只限于 `项目发布板块`。
- 当前争议不在于板块范围是否已冻结，而在于：
  - 哪条控制链当前有权决定 `是否允许进入项目发布实施派工`
  - 哪条控制链只负责约束 `项目发布实施一旦获准时，最多能做到哪里`

## 2. 正式裁决

### 2.1 当前生效的最高优先级控制链

- 对 `项目发布板块` 的 **阶段准入**，当前最高优先级控制链是：
  - `Round 0 全局 veto / 阶段门禁链`
- 对 `项目发布板块` 的 **板块范围上限**，当前仍生效但次级的控制链是：
  - `project_publish_board` 冻结体系

### 2.2 具体含义

- `docs/00_ssot/project_publish_board_boundary_freeze_addendum.md`
  - 仍然有效
  - 它冻结的是：
    - 允许的最小成功走廊
    - 明确非目标
    - 前端 / BFF / Server 的职责边界
  - 它 **不具备** 覆盖 `Round 0` 阶段准入 veto 的权限
- `docs/00_ssot/project_publish_board_closure_conclusion_addendum.md`
  - 保留为历史项目资产
  - 但在 `新工作流 V2` 接管后的当前 active baseline 中，不再作为新的实施准入放行文书
- 当前真正控制“能不能发《项目发布板块正式派工单》”的，是以下文书组：
  - `docs/00_ssot/gate_register_v1.md`
  - `docs/00_ssot/project_asset_register_v1.md`
  - `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
  - 各 blocker closure assessment addendum

### 2.3 本次裁决结论

- 当前不是 `project_publish_board` 冻结链优先统管实施准入。
- 当前是：
  - `Round 0 全局 veto` 继续统管项目发布板块的实施准入
  - `project_publish_board` 冻结链只保留为已冻结最小成功走廊的范围上限

## 3. 为什么不是项目发布板块冻结链优先

- `project_publish_board_boundary_freeze_addendum.md` 自身已经写明：
  - 它 `does not by itself unlock the project publish implementation round`
- `new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md` 已冻结：
  - `No-Go for any execution-role development round`
- `gate_register_v1.md` 已冻结：
  - `Any failed veto gate blocks the stage directly`
- 因此，项目发布板块冻结链现在只能回答：
  - “如果未来允许实施，最多能做到哪里”
- 它现在不能回答：
  - “在当前存在 failed veto gates 的情况下，是否仍可直接进入实施”

## 4. Round 0 全局 veto 对项目发布最小成功走廊的逐项映射

### 4.1 当前被映射的最小成功走廊

- 当前唯一允许讨论的项目发布最小成功走廊仍限于：
  - `/exhibition/projects/create`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - 文件三段上传链：
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`

### 4.2 映射表

| 阻断项 | 与项目发布最小成功走廊的直接关系 | 当前如何阻断 | 关闭条件 |
|---|---|---|---|
| `BLK-R0-ADMIN-PATH` | **共享入口级阻断，不是 create/detail/upload 直接数据链阻断**。项目发布走廊不调用 `/api/admin/*`，但它与项目发布共用同一台主机、同一层 Nginx、同一套 active canonical ingress。 | 当前如果继续在同一 active ingress 上给项目发布发实施单，会把“已知 canonical path drift 的运行基线”当成可继续增量施工的单一真相，违反 Gate 4 与 Gate 9。它不直接让 `project/create` 404，但会让项目发布板块继续建立在非单一 ingress truth 上。 | 按 `方案 A｜Ingress Alias 对齐，保持 /server/admin/* 为 canonical truth` 关闭；补齐 live Nginx 与 repo baseline；给出 `/api/admin/*` 与 canonical `/server/admin/*` 的运行态闭环证据。 |
| `BLK-R0-APP-REWRITE-DRIFT` | **项目发布走廊直接命中此项**。`POST /api/app/project/create`、`GET /api/app/project/detail`、文件三段上传链全部属于 `/api/app/*` 家族。 | 当前 live runtime 依赖 `Nginx: /api/app/* -> /bff/*` rewrite 才能闭环，但 repo `infra/nginx/cloud.conf` 不体现这一点。若现在直接派工，项目发布实现会落在一个“contracts 是 `/api/app/*`、runtime 实际靠 `/bff/*` rewrite”的漂移基线上。 | 先冻结 `/api/app/*` 为唯一 canonical app-facing family；把 live rewrite 与 repo baseline 统一成单一真相，或以 active override 文书正式接管；至少补齐 `project/create`、`project/detail`、`upload/init`、`upload/confirm` 的 ingress-to-BFF 映射证据。 |
| `BLK-R0-RUNTIME-REPO-DRIFT` | **项目发布走廊直接命中此项**。项目发布若进入实施，必须改 BFF app-facing 聚合层；但当前本地 `apps/bff/src/routes/routes.module.ts` 不能代表 active BFF runtime。 | 现在如果给项目发布派工，执行侧无法确认自己是在扩展“repo 权威挂载面”还是在追着“云端混装 dist”补洞。这样会直接污染项目发布板块的 BFF 实施真相。 | 先恢复 `repo -> build -> release` 的单一权威链；冻结 active BFF route graph；禁止继续以 cloud-only dist 挂载面作为实施真相；完成 clean rebuild/redeploy 的准入条件设计。 |
| `BLK-R0-ENV-PURITY` | **项目发布走廊直接命中此项的验证侧**。项目发布板块边界冻结要求最小成功走廊必须在 approved host/tunnel runtime 上取证。 | 当前同时存在 `systemd + /srv/releases/** + 80/3000/3001` 主链和 `pm2 + /srv/workspaces/** + 3100/3101 + 127.0.0.1:18080` 旁路链。若现在派工，后续 `project/create` 或 upload 成功证据可能来自错误链，封板和回归都不可信。 | 退役或硬隔离 pm2 workspace smoke 链；把 active runtime 明确固定为 release 主链；证明 `8080 -> 80 -> 3000/3001` 才是唯一项目发布验收链。 |
| `BLK-R0-FILE-LENGTH` | **项目发布走廊直接命中此项的实现触点**。当前前端 `project_create_page.dart` 已 `583` 行、`app_router.dart` 已 `494` 行；这些都在项目发布走廊的真实 touch-set 内。 | 如果现在直接派工，项目发布新增实现会继续堆在未豁免的超线 handwritten source 上，直接触发 Gate 11。它不是抽象治理项，而是当前板块已知触点的实施门禁。 | 对项目发布 touch-set 做精准豁免或拆分治理：`route registry` 类文件要先落 formal exemption，非豁免的 `project_create_page.dart` 等要先进入分阶段治理包或在派工前冻结可接受拆分方案。 |
| `BLK-R0-SERVER-GAP` | **项目发布走廊最直接的真相阻断项**。项目发布最小走廊需要 `project/create`、`project/detail`、upload truth；当前本地 `apps/server/src/app.module.ts` 只挂 `EnterpriseHubModule`，且 live `Server` 对 `/server/uploads/*`、`/server/file/access` raw `404`。 | 当前即使前端已有 `/exhibition/projects/create` 页面，BFF/Server 本地代码也没有可对应的项目真相主链；上传三段链在 live `Server` 上也未闭环。继续派工会导致“板块范围已冻结，但 truth owner 尚未冻结”。 | 先冻结项目发布专属 truth map：`project/create`、`project/detail`、publish businessType upload truth 由谁承载、内部 canonical path 是什么、哪些要补 contracts / SSOT；随后才允许进入项目发布最小走廊的正式派工。 |

### 4.3 结论

- 对项目发布最小成功走廊而言：
  - **最直接的阻断项**是：
    - `BLK-R0-APP-REWRITE-DRIFT`
    - `BLK-R0-RUNTIME-REPO-DRIFT`
    - `BLK-R0-FILE-LENGTH`
    - `BLK-R0-SERVER-GAP`
  - **共享平台级阻断项**是：
    - `BLK-R0-ADMIN-PATH`
    - `BLK-R0-ENV-PURITY`
- 但按照当前门禁总表，以上 veto 只要未关闭，项目发布板块仍不得直接进入实施派工。

## 5. 对“项目发布板块正式派工单”的裁决

- 当前裁决：
  - `不输出《项目发布板块正式派工单》`
- 原因不是项目发布板块范围未冻结。
- 原因是：
  - 当前项目发布板块的范围冻结已存在
  - 但阶段准入仍被 `Round 0 全局 veto` 统管
  - 且至少四个与最小走廊直接相关的 blocker 仍未关闭

## 6. 当前团队名册

| 角色 | 当前定位 | 当前状态 |
|---|---|---|
| 前端 Agent（本地） | 负责 `/exhibition/projects/create`、detail continuation、upload reuse 的前端消费侧 | 待命，不进入代码实施 |
| BFF Agent（云端） | 负责 `/api/app/project/create`、`/api/app/project/detail`、upload init/confirm 的 app-facing 聚合层 | 待命，不进入代码实施 |
| 后端 Agent（云端） | 负责 project truth、upload truth、validation、audit、detail read truth | **本轮唯一动作执行者** |
| 文书冻结 | 负责 docs/SSOT 冻结、裁决落盘、板块闭环清单维护 | 已完成本轮裁决落盘 |
| 结果校验 Agent | 负责对 blocker 关闭证据做独立复核 | 待命，等待下一份关闭前置文书 |
| 联调发布 Agent | 负责 `8080 -> 80 -> 3000/3001` 主链验证与上线前门禁 | 待命，等待准入后再接入 |

## 7. 当前任务分派对象

- 当前不向前端、BFF、联调发布发开发口令。
- 当前也不向结果校验发签收口令。
- 当前唯一分派对象是：
  - `后端 Agent（云端）`

## 8. 本轮唯一动作

- 本轮唯一动作是：
  - 由 `后端 Agent（云端）` 先输出
    - `《项目发布最小成功走廊真相映射与关闭前置单》`
- 该文书必须只解决项目发布板块最直接的 truth 问题：
  - `POST /api/app/project/create` 内部 canonical truth path
  - `GET /api/app/project/detail` 内部 canonical truth path
  - `publish` 场景下文件三段上传链的 `Server` truth owner
  - 当前本地 repo / contracts / live runtime 三者之间哪里已存在，哪里不存在
  - 哪些是要补实现，哪些是要补 contracts，哪些要补 SSOT
- 在这份文书出来前：
  - 不发《项目发布板块正式派工单》
  - 不允许任何执行角色进入项目发布开发轮

## 9. 总控自限

- 我不会把 `project_publish_board` 冻结文书误用为“自动准入实施”的放行文书。
- 我不会把全局 blocker 无差别扩大成无限期悬空阻断。
- 我不会亲自替代前端、BFF、后端长期施工。
- 我不会在未形成项目发布 truth map 前，向任何执行角色发开发口令。
- 我不会把 bid / order / contract / milestone / inspection / rating / dispute 带入当前板块。

## 10. 最终裁决句

- 当前对 `项目发布板块` 生效的最高优先级控制链是：
  - `Round 0 全局 veto / 阶段门禁链`
- `project_publish_board` 冻结体系当前仍生效，但只作为：
  - `项目发布最小成功走廊的范围上限`
- 当前阶段结论：
  - `No-Go for 项目发布板块正式派工`
- 当前下一步唯一动作：
  - 向 `后端 Agent（云端）` 发出《项目发布最小成功走廊真相映射与关闭前置单》
