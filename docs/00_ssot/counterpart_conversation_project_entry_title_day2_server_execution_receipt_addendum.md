---
owner: Codex 总控
status: frozen
purpose: >
  Record Day-2 Server execution for counterpart conversation project entry title
  correction after separating exhibitionName from the concrete project title.
layer: L0 SSOT
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_project_entry_title_day1_stage_gate_checklist_addendum.md
---

# 《消息楼项目入口标题 Day-2 Server 执行回执》

## 1. 结论

Day-2 Server 低风险修正已完成。

本轮只修正 `counterpart conversation` 专用 project entry title
projection：

- `exhibitionName` 继续只表示展会名。
- `project.title` 是消息楼项目入口可见态的优先具体项目名。
- 未授权遮罩仍使用名称查看受控遮罩标题。
- BFF 不改业务逻辑。
- Flutter 不本地拼标题。
- 全局 `buildProjectDisplayTitle()` 未修改。

## 2. 代码变更边界

变更文件：

- `apps/server/src/modules/message_interaction/counterpart-conversation.projection.service.ts`

修正规则：

1. `titleVisibility = masked`：
   - 优先使用 Server name-access projection 下发的遮罩标题。
   - 兜底 `项目名称需申请查看`。
2. `titleVisibility = visible`：
   - 优先 `project.title`。
   - 再回退 `exhibitionName + brandName`。
   - 再回退既有 projection `displayTitle`。
   - 最终兜底 `未命名项目`。

明确未改：

- 未修改 `apps/server/src/modules/project_name_access/project-name-access.support.ts`
- 未修改 BFF read-model。
- 未修改 Flutter 显示逻辑。
- 未新增字段。
- 未新增迁移。

## 3. 回归测试

新增测试文件覆盖：

- `apps/server/test/message-interaction-bid-carry.test.cjs`

新增用例：

- `counterpart conversation project title uses concrete project title when visible`

测试输入：

- `exhibitionName = 西洽会`
- `brandName = 泸州`
- `project.title = 西洽会 - 泸州`
- name-access projection 旧显示值模拟为 `displayTitle = 西洽会`
- `titleVisibility = visible`

断言：

- `projectGroups[0].titleVisibility = visible`
- `projectGroups[0].projectDisplayTitle = 西洽会 - 泸州`

## 4. 本地验证记录

已通过：

- `corepack pnpm --dir apps/server build`
- `node --test apps/server/test/message-interaction-bid-carry.test.cjs`
- `git diff --check`

测试结果：

- Server targeted suite：10 passed，0 failed。

## 5. 当前最小闭环

当前最小闭环已闭合：

1. Server 在消息楼项目入口专用投影中输出具体项目名。
2. BFF 继续只校验透传。
3. Flutter 继续只消费 `projectDisplayTitle`。
4. 同一对方主体下的 `西洽会 - 泸州` 与后续 `西洽会 - 成都` 可通过项目入口标题区分。

## 6. 需要保留但暂不开通

本轮保留但不开通：

- `projectEntryTitle` 新字段。
- 结构化城市/展台字段。
- BFF 二次标题生成。
- Flutter 本地标题拼接。
- 公域项目列表标题策略重构。
- 云上发布和双账号 UAT 结论。

## 7. 后续扩展位

后续如要继续提高表达精度，可以单独开链：

- 创建页结构化补 `cityName / boothName / projectSpecificName`。
- Server 增加专用 app-facing `projectEntryTitle`。
- Flutter 对多项目列表增加副标题，但仍只消费 Server/BFF 投影。

## 8. 阶段判断

- 更稳：
  - Server 专用 projection 修正 + Server 回归测试。
- 更省成本：
  - 不改 BFF、Flutter、全局 helper、不加迁移。
- 更适合当前阶段：
  - 只解决消息楼总框项目入口无法区分具体项目的问题。
- 风险更大：
  - 改全局 `buildProjectDisplayTitle()`，或让 BFF/Flutter 临时拼标题。

## 9. Retained Gates

仍然不允许宣称：

- 云上已发版。
- 8080 隧道 smoke 已通过。
- 双账号多项目 UAT 已通过。
- 生产可切换。

下一阶段若继续，应先走：

1. Server/BFF 云上 runtime alignment。
2. 8080 route smoke。
3. Flutter Computer Use 多项目视觉验收。
4. 双账号多项目真实 UAT。
