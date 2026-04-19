---
owner: Codex 总控
status: draft
purpose: Record the controller's first-pass filled checklist for 项目发布工作台 / 项目发布 / 项目展示 using current docs and code evidence, without overstating unverified cloud runtime hits.
layer: L0 SSOT
based_on:
  - docs/00_ssot/three_board_real_chain_verification_checklist_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_signoff.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
freeze_date_local: 2026-04-10
---

# 《三板块真实链路核查表 V1》初稿 Round 0

## 1. 填表前提

- 本稿为 `总控初判版`。
- 本稿主要依据：
  - 已冻结 SSOT
  - 现有 Flutter / BFF / Server 代码
  - 现有 development-stage 签收文书
- 本稿明确不冒充：
  - 本轮实时云端复测结果
  - 结果校验 Agent 独立复核结论
  - 联调发布 Agent 放行结论

因此本稿中的以下判定口径固定为：

- 有签收文书 + 有对应代码 + 边界一致：
  - 可记为 `真实命中（development-stage 已有证据）`
- 只有代码与页面承接，但存在 demo fallback：
  - 记为 `demo 承接` 或 `不稳定`
- 只有文档冻结，没有真实运行证据：
  - 记为 `未承接` 或在备注中写明 `仅代码/文档判断`

## 2. 主链核查表

| 链路段 | 所属板块 | 预期行为 | 当前证据来源 | 当前判定 | 是否阻断联调发布 | 备注 |
|---|---|---|---|---|---|---|
| 首页发布入口 -> 工作台 | 项目发布工作台 | 从首页进入工作台或发布相关私域入口，不误导成公域展示页 | Flutter 代码 | 不稳定 | 否 | 首页可跳工作台或发布页，但本稿未见独立 runtime 证据，只能记代码层成立。 |
| 工作台 -> 发布页 | 项目发布工作台 / 项目发布 | 工作台只做摘要与导流，可进入发布页 | Flutter + BFF + Server 代码 | demo 承接 | 是 | 工作台真实接口存在，但移动端允许 demo 承接，当前不能直接记为真实打通。 |
| 发布页加载 | 项目发布 | 发布页按既有冻结字段加载，不新增第二状态机 | Flutter 代码 + SSOT | 真实命中（development-stage 已有证据） | 否 | 发布页字段边界与已冻结最小走廊一致。 |
| 上传三步链 | 项目发布 | `init -> direct upload -> confirm` 正常承接 | 独立签收文书 + Flutter/BFF/Server 代码 | 真实命中（development-stage 已有证据） | 否 | 已有 upload revalidation 与 blocker closure 文书。 |
| create 提交 | 项目发布 | `POST /api/app/project/create -> 202 + projectId` | 独立签收文书 + BFF/Server 代码 | 真实命中（development-stage 已有证据） | 否 | 当前是最小走廊 create accepted，不等于完整审核发布体系。 |
| create 成功 -> 公域详情 | 项目发布 / 项目展示 | 使用返回 `projectId` 进入公域详情 | 独立签收文书 + Flutter/BFF/Server 代码 | 真实命中（development-stage 已有证据） | 否 | `GET /api/app/project/detail` 已有 development-stage 证据。 |
| 公域项目列表 | 项目展示 | 列表读取已发布项目，不混入私域态 | Flutter/BFF/Server 代码 + truth freeze | demo 承接 | 是 | 页面与接口都存在，但列表页存在 demo fallback。 |
| 公域项目详情 | 项目展示 | 详情只读公开字段，owner 只做 handoff，不做私域真值 | Flutter/BFF/Server 代码 + truth freeze | 不稳定 | 是 | 详情字段边界正确，但页面有 demo fallback，且缺本轮独立 runtime 复核。 |
| 公域详情 -> 我的项目 | 项目展示 / 项目发布工作台 | owner 可回流到私域承接面 | Flutter 代码 + `viewerProjectRelation` 代码 | 不稳定 | 否 | 代码已承接 owner handoff，但未见本轮独立 runtime 证据。 |
| 我的项目列表 | 项目发布工作台 | 展示当前组织项目分组，不替代工作台或展示页 | Flutter/BFF/Server 代码 | demo 承接 | 是 | 私域列表链存在，但页面有 demo fallback。 |
| 我的项目详情 | 项目发布工作台 | 承接 owner 私域详情与 privateProgress | Flutter/BFF/Server 代码 | demo 承接 | 是 | 私域详情链存在，但页面有 demo fallback。 |

## 3. demo fallback 剥离表

| 页面/接口 | 是否存在 demo fallback | 触发条件 | 当前真实链路状态 | 是否会误导为已打通 | 是否必须先清除 |
|---|---|---|---|---|---|
| `/exhibition/workbench` | 是 | workbench 请求落到 `current fake transport did not provide this canonical path` 时切 demo | 真实接口存在，移动端允许演示兜底 | 是 | 是 |
| `/exhibition/projects` | 是 | project list 请求落到 `current fake transport did not provide this canonical path` 时切 demo | 真实接口存在，缺本轮独立 runtime 复核 | 是 | 是 |
| `/exhibition/projects/detail` | 是 | detail 请求落到 `current fake transport did not provide this canonical path` 时切 demo | 真实接口存在，detail 字段链正确 | 是 | 是 |
| `/exhibition/my/projects` | 是 | my project list 请求落到 `current fake transport did not provide this canonical path` 时切 demo | 真实接口存在，私域分组逻辑存在 | 是 | 是 |
| `/exhibition/my/projects/detail` | 是 | my project detail 请求落到 `current fake transport did not provide this canonical path` 时切 demo | 真实接口存在，privateProgress 链存在 | 是 | 是 |

## 4. 真值边界核查表

| 对象 | 当前 owner | 允许语义 | 禁止语义 | 当前是否漂移 | 处理结论 |
|---|---|---|---|---|---|
| `project.state` | `Server project` | 公域生命周期 | visibility / review / 私域推进 | 否 | 当前仍按冻结口径执行。 |
| `publishedAt` | `Server project` | 公域准入 | 生命周期全语义 | 否 | 当前 list/detail 查询均以已物化公域项目为边界。 |
| `viewerProjectRelation` | `project/detail` 读投影 | owner/non-owner handoff | 权限真值 | 否 | 当前只用于 owner 回流，不承担权限矩阵。 |
| `privateProgress` | `my/projects/{id}` 读投影 | 私域推进与完结投影 | 公域展示判断 | 否 | 当前仍用于私域分组与 owner 详情。 |
| `workbench summary` | `exhibition/workbench` 摘要投影 | 私域摘要与 route handoff | 第二状态机 / 第二后台 | 否 | 当前后端/BFF职责未漂移，但前端语言仍需继续收口。 |

## 5. 板块结论表

### 5.1 项目发布工作台

- 当前状态：
  - 真实接口存在，四容器摘要边界明确，但移动端演示兜底会污染联调判断。
- 结论类型：
  - `伪闭环`
- 当前是否允许进入联调发布判断：
  - `否`
- 当前阻断项：
  - demo fallback 未从联调结论中剥离
  - 页面语言仍容易被理解为“完整项目工作台”

### 5.2 项目发布

- 当前状态：
  - 最小发布走廊已具备 development-stage 真实证据，create / detail / upload 子链已闭合。
- 结论类型：
  - `真实闭环`
- 当前是否允许进入联调发布判断：
  - `有条件允许`
- 当前阻断项：
  - 只能按“最小走廊”解释，不得升格为完整审核发布体系
  - 仍缺本轮与工作台、展示面合并后的统一独立复核

### 5.3 项目展示

- 当前状态：
  - 展示字段与发布字段边界已冻结且代码已消费，但列表/详情仍受 demo fallback 污染，且正式附件不在当前主线内。
- 结论类型：
  - `伪闭环`
- 当前是否允许进入联调发布判断：
  - `否`
- 当前阻断项：
  - 公域列表与详情未从 demo 承接中完全剥离
  - 正式附件列表不在当前展示主线内，不能误报为完整展示体系

## 6. 总控裁决区

### 6.1 passed gates

- `项目发布` 最小走廊已有 development-stage 真实证据。
- `Flutter App -> BFF -> Server` 主架构未被破坏。
- `project.state / publishedAt / viewerProjectRelation / privateProgress / workbench summary` 当前职责边界未发现明显漂移。

### 6.2 failed gates

- `项目发布工作台` 当前仍无法从联调判断中剥离 demo fallback。
- `项目展示` 当前仍无法从联调判断中剥离 demo fallback。
- 三板块尚未形成一份由结果校验 Agent 出具的统一真实链路复核结论。

### 6.3 veto gates

- release-stage veto：
  - 当前全部结论仍仅限 `development-stage`
- runtime-evidence veto：
  - 任何带 demo fallback 且会误导为已打通的页面，不得直接计入联调发布放行

### 6.4 stage decision

- `Go for 真实链路联调前置清理`
- `Go for 结果校验 Agent 独立复核`
- `No-Go for 联调发布`
- `No-Go for production release`

## 7. 强制结论

1. 真实命中的链路目前只明确包括：
   - `项目发布` 最小走廊：
     - `upload init -> direct upload -> confirm`
     - `project create -> 202 + projectId`
     - `project detail -> 200`
2. 只是 demo 承接或受 demo 污染的链路包括：
   - `项目发布工作台`
   - `公域项目列表`
   - `公域项目详情`
   - `我的项目列表`
   - `我的项目详情`
3. 当前结论仍然只是：
   - `development-stage 初判`
4. 当前不允许进入：
   - `联调发布`

## 8. 总控下一步建议

- 先由前端 Agent 输出：
  - 三板块 demo fallback 清单与联调模式隔离方案
- 再由结果校验 Agent 按本表做一次独立复核
- 最后由总控决定是否允许联调发布 Agent 介入
