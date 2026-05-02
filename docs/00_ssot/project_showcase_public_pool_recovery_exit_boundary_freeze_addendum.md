---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-02
purpose: Freeze the public project-showcase pool recovery truth and the exit-governance boundary before contracts, Server, BFF, Flutter, or cloud data repair.
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/01_contracts/project_list_published_at_contract_refinement_addendum.md
  - docs/00_ssot/project_exit_and_breach_governance_phase1_rule_freeze_addendum.md
  - docs/02_backend/project_exit_and_breach_governance_phase1_server_truth_and_persistence_addendum.md
  - docs/00_ssot/project_exit_and_breach_governance_phase1_day10b_cancellation_closeout_addendum.md
  - docs/00_ssot/platform_pricing_cloud_parity_deployment_and_day11_rerun_receipt.md
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project-exit-governance.service.ts
---

# 项目展示公开池恢复与退出治理边界修正冻结单

## 0. 总裁决

- 当前是否允许直接云端写入恢复公开项目：`No-Go`，必须另行二次确认。
- 当前是否允许进入 contracts / OpenAPI 最小校正：`Go`。
- 当前是否允许进入 Server 最小保护实现：`Go`。
- 当前是否允许改 Flutter 空态或造假数据兜底：`No-Go`。
- 当前根因裁决：项目展示为空不是 Flutter 首要问题，而是云上当前 `public.project` 中没有满足公域展示资格的项目；`18696563700` 账号有项目，但这些项目当前不在公域展示池。

## 1. 运行时证据冻结

### 1.1 云端只读证据

本轮通过默认隧道和云端只读库核对确认：

- `GET /api/app/project/list?page=1&pageSize=5` 返回 `200`，但 `items=[]`。
- `GET /api/app/exhibition/home` 返回 `200`，但 `recommendationSections.project_recommendations.items=[]`。
- 云端 `public.project` 当前：
  - 总项目数：`18`
  - `published_at IS NOT NULL`：`0`
  - 当前可进入公域展示池：`0`
  - `18696563700` 所属主组织项目数：`11`
- `18696563700` 用户、组织成员、组织状态均为有效。

### 1.2 当前展示为空的正式解释

`18696563700` 有项目，不等于这些项目具备公域展示资格。

当前项目展示列表的正式空态由以下事实共同造成：

1. `project/list` 当前以 `publishedAt` 作为公域发布时间真源。
2. 云端当前所有 `public.project.published_at` 均为 `NULL`。
3. 退出治理、关闭、撤回、作废、取消接受等写操作在真实云库里清理了公开资格。
4. 前端只是渲染 BFF 返回的空列表，不应被优先改成私域项目兜底。

## 2. 公开展示资格冻结

### 2.1 最小公开展示资格

`GET /api/app/project/list` 的公开池资格正式冻结为同时满足：

1. `project.state = published`
2. `project.publishedAt IS NOT NULL`
3. `project` 未归档
4. `plannedEndAt IS NULL OR plannedEndAt >= CURRENT_DATE`
5. 命中当前查询筛选：
   - `provinceCode`
   - `cityCode`
   - `areaBucket`
   - `budgetBucket`

其中：

- `publishedAt` 只表示项目进入公域公开列表的发布时间。
- `plannedEndAt` 只承担 public read eligibility trimming 输入，不是持久化 visibility state。
- 历史项目缺 `exhibitionName / brandName` 不得因此失去展示资格。
- `submitted` 永远不是公域展示资格。
- `draft` 永远不是公域展示资格。
- `archived` 永远不是公域展示资格。
- `awarded / converted_to_order` 默认不是普通公域展示资格。

### 2.2 不得混入项目展示的项目

以下项目不得进入普通 `project/list`：

1. 我的项目私域列表项目。
2. 预发布 `submitted` 项目。
3. 草稿 `draft` 项目。
4. 已归档 `archived` 项目。
5. 已进入交易承接的 `awarded / converted_to_order` 项目。
6. 取消接受后回到 `submitted` 的项目。
7. 缺少 `publishedAt` 的项目。

若后续需要展示交易中或历史项目，只能开独立只读面，不得污染普通项目展示池。

## 3. 退出治理边界冻结

### 3.1 允许退出 public showcase corridor 的动作

以下动作允许让项目退出公域展示池：

| 动作 | 允许结果 | 公开资格处理 |
|---|---|---|
| `published -> submitted` 竞标中撤回 | 回预发布承接 | 必须清理 `publishedAt` 或等价确保公域不可见 |
| `published -> archived` 下架关闭 | 归档 | 必须清理 `publishedAt` |
| `submitted -> archived` 预发布作废 | 归档 | 保持 `publishedAt = NULL` |
| accepted mutual cancellation closeout | 取消后承接 | 若当前继续使用 Day10B `submitted` 口径，必须清理 `publishedAt` |
| public expiry trimming | 只读裁剪 | 不写库，不改业务状态 |

### 3.2 不得误伤或恢复 public showcase corridor 的动作

以下动作不得新增或恢复公域展示资格：

1. 发起取消申请。
2. 拒绝取消申请。
3. 记录发布方违约。
4. 记录工厂违约。
5. 项目通信消息、材料确认、合同确认入口。
6. P0 / platform pricing 只读状态查询。

这些动作不得把项目重新写回 `published`，不得补写 `publishedAt`，不得让 BFF 或 Flutter 本地推导公开资格。

## 4. 文书冲突冻结

### 4.1 已确认冲突

`project_exit_and_breach_governance_phase1_rule_freeze_addendum.md` 早期规则写明：

- 进行中项目双方同意取消后，不回到 `submitted`。

Day10B closeout 后续文书和代码则采用：

- accepted mutual cancellation 后 `converted_to_order -> submitted`
- `published_at -> NULL`
- 订单 `active -> cancelled`

本冻结单不在本轮重写完整退出治理状态机；当前只冻结兼容裁决：

1. 若保留 Day10B `submitted` 结果，它只能表示取消后的重新编辑/重新发布 carrier。
2. 该 `submitted` 不等于旧项目恢复公开展示。
3. 旧 bid / order / contract / payment / message / audit 不得继承为新一轮竞标资格。
4. 若后续要把取消后项目改为独立 `mutually_cancelled` 状态，必须另开状态机冻结和迁移评估。

### 4.2 关键开发时间点

- `0e6284e` `2026-04-19 19:04:13 +0800` 引入项目展示和交易交付走廊，`project/list` 以 `publishedAt != NULL` 和非归档/未过期裁剪为主，未严格限定 `state = published`。
- `77fa2b9` `2026-04-29 12:29:36 +0800` 引入项目退出治理第一期，多个退出动作清理 `publishedAt`，同时 Day10B 形成 `converted_to_order -> submitted` 的取消 closeout 口径。
- `2026-05-02` 云端真实写操作批量命中撤回、作废、关闭、取消接受等路径，当前公开池被消耗为 `0`。

## 5. 验证样本边界

### 5.1 公开池不得作为验证耗材

正式公开项目池不得被以下验证动作批量消耗：

1. 批量撤回公开项目。
2. 批量关闭公开项目。
3. 批量作废预发布项目。
4. 批量取消进行中项目。
5. 批量记录违约。

任何交易、退出、P0 / platform pricing、project communication 验证，必须使用专用样本，并在回执中标明不会消耗普通项目展示公开池。

### 5.2 受控公开样本要求

第 4 天若恢复受控公开样本，必须满足：

1. 样本数量小，默认 `1-3` 条。
2. `state = published`。
3. `publishedAt IS NOT NULL`。
4. `plannedEndAt IS NULL OR plannedEndAt >= CURRENT_DATE`。
5. 不绑定真实支付写入。
6. 不绑定真实成交后状态。
7. 不作为后续退出治理、P0、project communication 写操作验证耗材。
8. 写入前必须有 rollback 方案并获得二次确认。

## 6. Layer 边界

| 层 | 本轮边界 |
|---|---|
| SSOT | 本文件冻结公开池资格、退出治理影响、验证样本隔离 |
| Contracts | 不新增路线；只允许补齐已冻结的 `project/list` app-facing 字段投影 |
| Server | 唯一公开资格和状态机 owner；第 3 天只做最小 `state = published` 保护 |
| BFF | 只转发 `/server/projects` 并做 app-facing shaping；不得混入 `/server/my/projects` |
| Flutter | 只消费 BFF 返回；不得用私域项目或 demo fallback 填补公开池 |
| Cloud | 第 4 天前只读；公开样本恢复需二次确认 |

## 7. No-Go 清单

1. 未二次确认前，不得写云库恢复样本。
2. 不得把 `my/projects` 数据拼入 `project/list`。
3. 不得让 BFF 拥有公开资格真值。
4. 不得让 Flutter 本地判断 `submitted / converted_to_order` 是否可展示。
5. 不得把 `converted_to_order` 重新塞回普通项目展示列表。
6. 不得为了页面有内容而展示 fake/demo/mock 项目。
7. 不得借本轮加入 payment、wallet、deposit、settlement、invoice、governance scoring 等语义。

## 8. 阶段结论

- `Go` for 第 2 天 contracts / BFF / Server 最小边界确认。
- `Go` for 第 3 天 Server 最小保护与针对性测试。
- `No-Go` for 云端写入，直到第 4 天受控恢复方案获得二次确认。
- `No-Go` for Flutter 修复，直到云端公开池恢复后仍证明前端消费异常。
