---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the project-entry title truth for counterpart conversation project
  lists, separating exhibitionName from the concrete project title.
layer: L0 SSOT
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_sliced_ia_correction_addendum.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_bff_surface_freeze_addendum.md
---

# 《消息楼项目入口标题真相冻结》

## 1. 结论

正式冻结：

- `exhibitionName` 是展会名，例如 `西洽会`。
- `brandName` / 项目业务语义可以承载具体对象、城市、品牌或展台识别，例如 `泸州`。
- `project.title` 是具体项目名，例如 `西洽会 - 泸州`。
- 消息楼对方主体总框里的项目入口必须显示能区分具体项目的标题。
- 已授权可见时，`projectDisplayTitle` 必须优先显示 `project.title`。
- 未授权遮罩时，继续显示受控遮罩标题，不泄露真实项目名。

当前错误来源：

- 旧 `buildProjectDisplayTitle()` 在有 `exhibitionName` 时优先返回 `exhibitionName`。
- 因此 `project.title = 西洽会 - 泸州` 会在消息楼项目入口被投影成 `西洽会`。
- 这会导致同一展会下多个项目无法区分。

## 2. 冻结显示规则

`counterpart conversation projectGroups[].projectDisplayTitle` 规则：

1. 若 `titleVisibility = masked`：
   - 显示受控遮罩标题。
   - 默认值为 `项目名称需申请查看`。
2. 若 `titleVisibility = visible`：
   - 优先显示 `project.title`。
   - 若 `project.title` 为空，回退 `exhibitionName + brandName`。
   - 若仍为空，回退既有 `displayTitle`。
   - 最终兜底 `未命名项目`。

禁止规则：

- Flutter 不得本地拼接 `exhibitionName + brandName`。
- BFF 不得创造第二项目标题真值。
- 不得把 `exhibitionName` 当作具体项目标题。
- 不得为了消息楼修正直接修改公域项目列表的名称查看遮罩规则。

## 3. 当前最小闭环

当前最小闭环：

1. Server 输出消息楼项目入口标题真值。
2. BFF 校验并透传 `projectDisplayTitle`。
3. Flutter 只消费 `projectDisplayTitle`。
4. 消息楼总框可区分 `西洽会 - 泸州` / `西洽会 - 成都`。
5. 聊天仍绑定 `projectId + threadId`。

## 4. 需要保留但暂不开通

保留但本轮不开通：

- 新增 `projectShortName`
- 新增 `projectSpecificName`
- 新增 `projectEntryTitle`
- 新增城市/展台结构化展示字段
- Flutter 本地拼标题
- BFF 二次拼标题
- 公域项目列表标题策略重构

## 5. 后续扩展位

后续扩展位：

- 若产品需要更细颗粒度，可新增 `projectEntryTitle` 作为专门 app-facing 字段。
- 若创建页正式拆分更多字段，可补 `exhibitionName / cityName / boothName / brandName` 的结构化投影。
- 若多语言上线，可给项目入口标题增加 i18n display projection。

## 6. 策略判断

- 更稳：
  - 只在 counterpart conversation projection 做专用标题规则。
- 更省成本：
  - 不改 Flutter，不改 BFF 业务逻辑，不改全局 `buildProjectDisplayTitle()`。
- 更适合当前阶段：
  - 修正消息楼多项目识别，不扩大到公域项目展示。
- 风险更大：
  - Flutter 本地拼标题，或直接修改全局名称查看标题函数。
