---
owner: BFF Agent（云端）
status: assessment_only
purpose: 对 veto 阻断项 BLK-R0-RUNTIME-REPO-DRIFT 进行只读关闭评估，定位本地 repo、云端 active release source、云端 active runtime dist 之间的漂移层，并给出候选关闭路径与唯一推荐方案。
layer: L0 SSOT 配套文书
evidence_date_local: 2026-04-02
scope: read-only verification only
---

# BFF runtime/repo 漂移阻断关闭评估补充文书

## 1. 问题定义

当前 veto 阻断项为：`BLK-R0-RUNTIME-REPO-DRIFT`。

本次只读核验要解释的不是单一现象，而是四个层面的矛盾同时存在：

1. 本地仓库 `apps/bff/src/routes/routes.module.ts` 当前只挂 `EnterpriseHubModule`。
2. 当前云端 active runtime 已能对 `/api/app/forum/*`、`/api/app/file/*` 返回 BFF 层响应。
3. 当前云端 active release 目录中的手写源码，不等于当前 active runtime 实际执行的 `dist`。
4. Nginx `rewrite /api/app/* -> /bff/*` 只能解释“外部入口如何改写”，不能解释“3000 上哪些 controller 实际被 Nest 挂载”。

本次评估目标不是修复，不是切换，不是回库，而是回答：

- 漂移发生在哪一层。
- 这些层之间现在是什么关系。
- 候选关闭路径分别意味着什么。
- 哪一条是唯一推荐方案。
- 当前阻断项是否已经关闭。

本次文书结论口径固定为：

- 当前 `BLK-R0-RUNTIME-REPO-DRIFT`：`未关闭`
- 本次状态：`仅完成关闭评估`

## 2. 当前证据链

### 2.1 本地 repo 证据

本地只读核验对象：

- `docs/00_ssot/project_asset_register_v1.md`
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
- `docs/00_ssot/round0_inventory_release_integration_agent.md`
- `docs/00_ssot/round0_inventory_validation_signoff.md`
- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/src/routes/forum/forum.controller.ts`
- `apps/bff/src/routes/file/file.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
- `apps/bff/src/app.module.ts`
- `infra/nginx/cloud.conf`

本地 repo 已确认事实：

- `apps/bff/src/routes/routes.module.ts` 当前只 `imports: [EnterpriseHubModule]`，且文件内注释明确写明：
  - `This workspace slice is assembled for enterprise_hub release-prep verification.`
- 本地 repo 中同时存在：
  - `forum.controller.ts`
  - `file.controller.ts`
- 但这些 controller 当前并没有被本地 `RoutesModule` 挂入。
- 本地 `file.controller.ts` 当前含 `@Get('access')`。
- 本地 `forum.controller.ts` 当前同时含：
  - `author/profile`
  - `author/posts`
  - `draft/delete`
- 本地 `infra/nginx/cloud.conf` 仍是仓库样例：
  - `/api/app/` 直接 `proxy_pass http://bff_upstream/;`
  - 不足以代表云端当前生效规则。

### 2.2 云端 active entry / active release 证据

云端只读核验确认：

- `exhibition-bff.service`
  - `WorkingDirectory=/srv/apps/bff/current`
  - `ExecStart=/usr/bin/node dist/main.js`
- `/srv/apps/bff/current -> /srv/releases/bff/20260331195903/apps/bff`
- 当前 active release 不是 `bff` 目录下最新时间戳目录。
  - 已发现更晚目录：`20260401014802`、`20260401021030`
  - 但 `current` 仍指向 `20260331195903`

### 2.3 active runtime dist 装载链证据

active runtime 的真正装载链已经核验为：

1. `systemd` 执行 `node dist/main.js`
2. 根层 `dist/main.js` 不是独立文件，而是符号链接：
   - `dist/main.js -> apps/bff/src/main.js`
3. `dist/apps/bff/src/main.js` 引入：
   - `./app.module`
4. `dist/apps/bff/src/app.module.js` 引入：
   - `./routes/routes.module`
5. `dist/apps/bff/src/routes/routes.module.js` 决定最终 controller/module 挂载面

结论：

- active runtime 以 `dist/apps/bff/src/**` 为准。
- active release 目录内的手写 `.ts` 文件，不自动等于当前运行态。

### 2.4 active runtime HTTP 证据

云端本机只读探测已确认：

- `GET http://127.0.0.1:3000/bff/forum/feed`
  - 返回 BFF 层错误体
  - `code=FORUM_FEED_FAILED`
  - `details.original/upstreamMessage` 指向 `/server/forum/feed` 的 `404`
  - 这证明：`/bff/forum/feed` 已被 3000 上的 BFF controller 实际挂载
- `GET http://127.0.0.1:3000/bff/file/index`
  - `200`
  - 返回 `skeleton_only`
  - 这证明：`/bff/file/index` 已被 3000 上的 BFF controller 实际挂载
- `GET http://127.0.0.1:3000/bff/file/access?fileAssetId=f1&mode=view`
  - 返回 BFF 层错误体
  - `code=FILE_ACCESS_FAILED`
  - 上游指向 `/server/file/access` 的 `404`
  - 这证明：`/bff/file/access` 也已被 3000 上的 BFF controller 实际挂载
- `GET http://127.0.0.1:80/api/app/file/access?...`
  - 返回与 `3000/bff/file/access` 一致的 BFF 层错误体
  - 这证明外部 `/api/app/*` 经 rewrite 后命中真实 controller
- `GET http://127.0.0.1:80/api/app/forum/author/profile?authorId=a1`
  - 返回原始 Nest `404`
  - `Cannot GET /bff/forum/author/profile?authorId=a1`
  - 这证明：
    - Nginx rewrite 已发生
    - 但 active runtime 并未挂载这个 controller path

### 2.5 active release source 与 active dist 的直接矛盾

当前 active release：`/srv/releases/bff/20260331195903/apps/bff`

已核验到以下矛盾：

1. `routes.module`
   - active release source `routes/routes.module.ts`
     - 挂 `forum/file/...`
     - 不挂 `EnterpriseHubModule`
   - active dist `dist/apps/bff/src/routes/routes.module.js`
     - 挂 `forum/file/...`
     - 同时挂 `EnterpriseHubModule`

2. `file.controller`
   - active release source `routes/file/file.controller.ts`
     - 只有 `index/upload/init/upload/confirm`
     - 没有 `access`
   - active dist `dist/apps/bff/src/routes/file/file.controller.js`
     - 明确存在 `getAccess`
   - 实际 runtime：
     - `/bff/file/access` 可命中

3. `forum.controller`
   - active release source `routes/forum/forum.controller.ts`
     - 有 `author/profile`
     - 有 `author/posts`
     - 无 `draft/delete`
   - active dist `dist/apps/bff/src/routes/forum/forum.controller.js`
     - 无 `author/profile`
     - 无 `author/posts`
     - 有 `draft/delete`
   - 实际 runtime：
     - `/api/app/forum/author/profile` 原始 404
     - `POST /bff/forum/draft/delete` 可命中 BFF 层错误体

这说明：

- 当前 active release 目录内部就不是“单一快照”。
- `source.ts` 和 `dist.js` 各自来自不同的快照分支。
- active runtime 实际以 `dist` 胜出。

### 2.6 非 active release 样本证据

抽样核验非 active release `20260401021030`：

- 它的 `routes.module.ts` 与 active source 不同：
  - 已加入 `EnterpriseHubModule`
- 它的 `dist/file/file.controller.js` 与 active dist 不同：
  - 不再包含 `getAccess`
- 它的 `dist/forum/forum.controller.js` 与 active dist 不同：
  - 包含 `author/profile`
  - 包含 `author/posts`
  - 不再是当前 active dist 的 `draft/delete` 形态

结论：

- release 序列本身也不是单一稳定演进链。
- 当前 active runtime 并不代表最新 release。
- “直接切换到更晚 release” 也不能自动关闭 drift。

### 2.7 本地 contracts / SSOT 交叉证据

当前 SSOT 和签收文书已明确登记：

- `BLK-R0-RUNTIME-REPO-DRIFT` 当前 `Open`
- Round 0 不允许开发、迁移、部署、发版
- 当前只允许 blocker closure assessment

本地 quick grep 结果：

- `docs/01_contracts/openapi.yaml` 已能定位：
  - `/api/app/forum/feed`
  - `/api/app/exhibition/enterprise-hub/recommendations`
- 当前未在 quick grep 中定位到：
  - `/api/app/file/index`
  - `/api/app/file/access`

因此：

- 若要把 `file/index`、`file/access` 冻结为正式 active truth，contracts 很可能还需要补登记或复核。

## 3. repo 层与 runtime 层分离说明

当前必须严格区分四层：

### 3.1 Layer A: 本地 repo source

路径：

- `apps/bff/src/**`

职责：

- 本地仓库冻结面
- Round 0 / SSOT / contracts 对照面

当前结论：

- 它不是 active runtime 的可靠代表。
- 当前更像一个 `enterprise_hub release-prep verification slice`。

### 3.2 Layer B: 云端 active release source

路径：

- `/srv/apps/bff/current/routes/**`
- `/srv/apps/bff/current/app.module.ts`

职责：

- 当前 active release 包里随 artifact 一起落盘的源码视图

当前结论：

- 它不是 active runtime 的可靠代表。
- 因为它与 active `dist` 已发生实证矛盾。

### 3.3 Layer C: 云端 active runtime dist

路径：

- `/srv/apps/bff/current/dist/apps/bff/src/**`

职责：

- `systemd + node dist/main.js` 真正执行的编译产物

当前结论：

- 它才是 active runtime 真正的挂载面来源。
- `/bff/forum/*`、`/bff/file/*` 是否存在，应以这一层为准。

### 3.4 Layer D: Nginx 外部入口改写层

路径：

- `/etc/nginx/conf.d/exhibition.conf`

职责：

- 解释外部 `/api/app/*` 如何改写到 `/bff/*`

当前结论：

- 这一层只能解释：
  - 为什么外部请求会进入 `/bff/*`
- 不能解释：
  - `/bff/*` 对应 controller 是否存在
  - controller 是从哪份 module graph 编出来的

### 3.5 关键区分结论

- `rewrite` 不会创造 controller。
- `3000/bff/*` 的实际可命中性，只能由 active `dist` 决定。
- 当前 repo drift 不是单一“本地 repo vs 云端 runtime”。
- 当前至少存在以下分离：
  - 本地 repo source vs active runtime dist
  - active release source vs active runtime dist
  - active release vs newer release

## 4. 漂移层级定位

## 4.1 结论

当前漂移同时发生在以下层级：

1. `本地源码未合并`
   - 成立，但只说这一句不够
   - 本地 repo 当前没有代表 active runtime 的挂载面

2. `云端 release 领先于本地仓库`
   - 部分成立
   - active dist 已包含本地 repo `RoutesModule` 未挂入的 forum/file 路由面

3. `云端运行的是另一套 build 产物`
   - 成立，且这是当前最关键的层级判断
   - active runtime 实际跑的是 `/srv/apps/bff/current/dist/apps/bff/src/**`
   - 其 module graph 不等于本地 repo，也不等于同目录 source.ts

4. `Nginx rewrite 只解释外部入口，不足以解释模块实际挂载`
   - 成立
   - `/api/app/forum/author/profile` 的原始 404 已直接证明此点

5. `云端 release 落后于本地仓库`
   - 不能整体成立
   - 因为 local repo 不是 active release 的严格超集，也不是 active dist 的严格超集
   - 当前更像多份快照交叉存在，而不是单向“谁领先谁落后”

## 4.2 精确定位

最准确的漂移定位应写成：

- 漂移主层：`active runtime dist != local repo source`
- 漂移次层：`active runtime dist != active release source`
- 漂移补层：`active release current != sampled newer release`

换句话说，当前不是一个“单点同步问题”，而是一个“三层包快照失配问题”。

## 4.3 对问题本身的最终判断

当前云端为什么会对 `/api/app/forum/*`、`/api/app/file/*` 返回 BFF 层响应：

- 不是因为本地 repo 的 `RoutesModule` 已挂这些模块
- 不是因为 Nginx rewrite 自动创造了这些 controller
- 而是因为 active runtime 真正执行的 `dist/apps/bff/src/routes/routes.module.js` 中已经挂入了这些模块

当前云端为什么会对 `/bff/file/access` 命中：

- 不是因为 active release source `routes/file/file.controller.ts` 有这个路由
- 而是因为 active dist `file.controller.js` 有 `getAccess`

当前云端为什么 `/api/app/forum/author/profile` 反而 raw 404：

- 因为虽然 active release source `forum.controller.ts` 有这个方法
- 但 active dist `forum.controller.js` 没有把它编进去
- 而 runtime 以 dist 为准

## 5. 候选关闭方案对比

| 方案 | 核心动作 | 是否需要回写 repo | 是否需要替换 release artifact | 是否需要重新 build / deploy | 是否需要改 docs / contracts | 是否影响 `/api/app/*` | 是否影响当前主联调链 | 风险等级 | 推荐结论 |
|---|---|---|---|---|---|---|---|---|---|
| 方案 A | 以 active runtime 挂载面为准，先回写 repo，随后从单一 repo clean build 新 release，再替换 current | 是 | 是 | 是 | 是 | 会保持现有 forum/file 主链能力，但会要求把真实挂载面正式冻结 | 影响发布流程，但目标是保链纠偏 | 高 | 推荐 |
| 方案 B | 以本地 repo enterprise_hub slice 为准，收缩云端 runtime 到 repo 当前挂载面 | 否或极少 | 是 | 是 | 是 | 会直接收缩 `/api/app/forum/*`、`/api/app/file/*` 等当前已命中的入口 | 高概率中断当前主联调链 | 极高 | 不推荐 |
| 方案 C | 不回库，只切换到另一份现成 release artifact（例如更晚目录） | 否 | 是 | 否或极少 | 仍需要 | 不确定，因 sampled newer release 也不是当前真相 | 会改变当前主链，且不能消除 repo drift | 高 | 不推荐 |

### 5.1 方案 A 说明

方案 A 的准确含义不是“直接把当前 dirty release 抄回 repo”。

它应拆成两段：

1. 先把 active runtime 实际挂载面冻结成 formal truth
   - 以 active dist 为准
   - 把 repo / docs / contracts 补齐到可复核状态
2. 再从这个单一 truth 重新 clean build
   - 产出不再含 source/dist 混装矛盾的新 release
   - 然后再走替换 release artifact / current 的动作

优点：

- 唯一能在保住当前 `/api/app/forum/*`、`/api/app/file/*` 主链能力的前提下关闭 drift。
- 能同时解决：
  - local repo vs runtime drift
  - active release source vs dist drift
  - docs/contracts 未冻结问题

缺点：

- 成本最高。
- 必须经过 docs/contracts/repo/release 全链对齐。

### 5.2 方案 B 说明

方案 B 的准确含义是：

- 把“本地 repo 当前只挂 EnterpriseHubModule”视为唯一真相
- 然后把云端 runtime 收缩到这个面

优点：

- 理论上最容易解释 repo。

缺点：

- 会直接破坏当前已存在的 `/api/app/forum/*`、`/api/app/file/*` 联调入口。
- 与当前云端 active runtime 现实严重冲突。
- 本地 repo 本身带有 `enterprise_hub release-prep verification` 注释，说明它不是当前 active BFF 全面真相。

### 5.3 方案 C 说明

方案 C 的准确含义是：

- 不回写 repo
- 只尝试把 current 切到别的 release 目录

优点：

- 可能不需要重新 build。

缺点：

- sampled newer release 也不是单一真相。
- 只换 artifact 不能解释 repo。
- 即使切换成功，也只是把 drift 从一份 artifact 挪到另一份 artifact。

## 6. 唯一推荐方案

### 6.1 推荐方案名称

`方案 A：以 active runtime 挂载面为准回写 repo，再从单一 truth clean rebuild/redeploy`

### 6.2 推荐原因

这是唯一能同时满足以下目标的关闭路径：

1. 不把当前 active `/api/app/forum/*`、`/api/app/file/*` 入口直接打掉。
2. 不把 dirty release 目录里的 source/dist 混装状态直接合法化。
3. 让 repo 再次成为可复核的 active truth，而不是继续做 `enterprise_hub` 局部 slice。
4. 让后续任何 release 都从单一 repo 快照产出，而不是继续依赖云端独有 artifact。

### 6.3 推荐方案的实施前提

本轮不实施，只定义前提：

1. 先冻结 active runtime route surface 清单。
2. 先明确哪些路径是要保留、哪些是要下线。
3. 对保留路径补齐 docs / contracts / repo。
4. 再 clean build 新 artifact。
5. 再做替换 release / current / reload / 验收。

## 7. 不允许采用的方案

以下动作不允许被视为 blocker closure：

1. 只改 Nginx rewrite，不改 repo、不改 artifact。
   - 原因：rewrite 不能解释 controller 挂载。

2. 只回写 docs，不回写 repo。
   - 原因：这只能把 drift 文书化，不能关闭 drift。

3. 直接把当前 active release 目录 source.ts 当真相。
   - 原因：它已被证据证明不等于实际执行的 dist。

4. 直接把当前 active dist 当永久真相，不做 clean rebuild。
   - 原因：会把 source/dist 混装 artifact 合法化。

5. 直接把 current 切到 `20260401021030` 或任何其它现成 release。
   - 原因：sampled newer release 同样存在独立快照，不构成已审核的 repo-aligned truth。

6. 直接按本地 repo enterprise_hub slice 收缩云端 runtime。
   - 原因：会切断当前主联调链已命中的 forum/file 面。

## 8. 关闭验收条件

`BLK-R0-RUNTIME-REPO-DRIFT` 要关闭，必须同时满足以下条件。

### 8.1 repo 对齐条件

以下本地文件必须与 active runtime 的最终冻结挂载面一致：

- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/src/routes/forum/forum.controller.ts`
- `apps/bff/src/routes/file/file.controller.ts`
- `apps/bff/src/app.module.ts`

如果最终冻结面保留 forum/file 入口，还必须补齐：

- 相应 module / service / error code / contract 引用
- `docs/01_contracts/openapi.yaml`
- `docs/00_ssot/project_asset_register_v1.md`
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
- 必要时 `infra/nginx/cloud.conf`

### 8.2 runtime 证据对齐条件

云端必须能复核：

1. `/srv/apps/bff/current` 指向唯一 active release 目录。
2. `systemd` 仍以 `node dist/main.js` 启动。
3. `dist/main.js` 指向的真正编译树必须可追到单一 repo 快照。
4. active release source 与 active dist 不得再出现当前这种“同目录不同挂载面”的矛盾。

最低要求：

- `routes.module`
  - repo source
  - active release source
  - active dist
  三者的挂载面必须一致
- `file.controller`
  - repo source
  - active release source
  - active dist
  三者对 `access` 是否存在必须一致
- `forum.controller`
  - repo source
  - active release source
  - active dist
  三者对 `author/profile`、`author/posts`、`draft/delete` 是否存在必须一致

### 8.3 URL 验收条件

关闭时，不要求所有上游业务已经变成 `200`，但要求“挂载面一致、状态语义一致”。

必测 URL：

1. `http://127.0.0.1:80/api/app/forum/feed`
2. `http://127.0.0.1:3000/bff/forum/feed`
3. `http://127.0.0.1:80/api/app/file/index`
4. `http://127.0.0.1:3000/bff/file/index`
5. `http://127.0.0.1:80/api/app/file/access?fileAssetId=test&mode=view`
6. `http://127.0.0.1:3000/bff/file/access?fileAssetId=test&mode=view`
7. `http://127.0.0.1:80/api/app/forum/author/profile?authorId=test`
8. `http://127.0.0.1:3000/bff/forum/author/profile?authorId=test`
9. `http://127.0.0.1:3000/bff/forum/draft/delete` 或其对应 app-facing path

验收标准：

- 对于被正式冻结为“已挂载”的路径：
  - 必须返回 BFF 层响应
  - 不能再返回原始 `Cannot GET /bff/...`
- 对于被正式冻结为“未挂载”的路径：
  - repo source、active release source、active dist、HTTP 结果必须一致
  - 不能出现 source 声称已挂，但 dist 实际未挂

### 8.4 角色复核条件

关闭前至少需要以下角色复核：

- BFF Agent
  - 负责 repo 与 runtime 挂载面对表
- 联调发布 Agent
  - 负责 current / release / systemd / Nginx / URL 证据复核
- Backend Agent
  - 负责确认保留的 BFF route surface 是否有对应 Server 真相承接
- 结果校验 Agent
  - 负责独立签收 blocker close 证据
- Codex 总控
  - 负责是否允许从 veto 降级或关闭

## 9. 对 Round 1 准入的影响

当前影响结论如下：

1. 当前 `BLK-R0-RUNTIME-REPO-DRIFT`：`未关闭`
2. 当前 local repo：`不能代表 active BFF runtime`
3. 当前 active runtime：`包含 repo 未冻结的挂载面`
4. 当前 veto：`不允许降级`
5. 当前 Round 1：`仍然 No-Go`

原因不是单一“代码没回库”，而是：

- repo、active release source、active dist 三层都没有统一
- active release 自身含 source/dist 混装矛盾
- sampled newer release 也不能直接当替代真相
- 当前 forum/file 入口已经进入主联调链，不能靠“缩回 repo slice”粗暴解决

因此本阻断项在本轮最多只能达到：

- `关闭评估完成`

不能达到：

- `阻断关闭`
- `veto 降级`
- `Round 1 准入放行`

## 10. 修订记录

| 日期 | 角色 | 动作 | 说明 |
|---|---|---|---|
| 2026-04-02 | BFF Agent（云端） | 新增文书 | 完成 `BLK-R0-RUNTIME-REPO-DRIFT` 只读关闭评估；未做代码、配置、deploy、restart、reload 变更 |

## 最终裁决

- `BLK-R0-RUNTIME-REPO-DRIFT` 当前是否已关闭：`未关闭`
- 当前 repo 是否能代表 active BFF runtime：`不能`
- 当前 runtime 是否包含 repo 未冻结的挂载面：`是`
- 当前是否允许总控把该阻断项从 veto 降级：`不允许`
- 当前文书状态：`仅完成关闭评估`
