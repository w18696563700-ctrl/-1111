---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day9-Day10 regression and audit gate for the create-page,
  prepublish-detail, attachment-entry, and factory bid-materials convergence
  round.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_create_day3_create_page_revision_brief_addendum.md
  - docs/00_ssot/project_prepublish_day4_confirmation_flow_brief_addendum.md
  - docs/00_ssot/project_create_prepublish_day5_day6_frontend_implementation_gate_checklist_addendum.md
  - docs/00_ssot/project_create_prepublish_day7_day8_attachment_frontend_gate_checklist_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
---

# Day9-Day10《回归检查与审核交付阶段门禁核查表》

## 1. Stage Objective

- Day9 只做回归检查：
  - 项目列表
  - 公域项目详情
  - 发布方我的项目/预发布详情
  - 工厂竞标提交页只读项目材料
- Day10 只做审核交付：
  - 汇总改动
  - 汇总风险
  - 汇总未开通项
  - 汇总后续扩展位
- 本阶段不进入：
  - BFF implementation
  - Server implementation
  - contract field/path expansion
  - lifecycle state-machine change
  - cloud release

## 2. Current Minimum Loop

当前最小闭环继续冻结为：

1. 发布方在创建页保存草稿或保存到预发布列表。
2. `submitted = 预发布列表`，不是新状态。
3. 发布方从我的项目进入预发布详情，补充项目详情文书。
4. owner 在 `submitted-or-later` 可管理 `效果图 / 施工图 / 其他资料`。
5. 发布方确认无误后走既有 `publish` 动作进入 `published`。
6. 工厂从公域项目详情进入竞标提交。
7. 工厂先核对项目，再只读查看 `effect_image / construction_doc`，再填写报价方案并上传 3 份竞标必选文档。

## 3. Passed Gates

- 真源门禁：通过。Day9-Day10 范围继续以 `docs/` 下既有 Day1-Day8 冻结文书和项目附件冻结文书为真源。
- 目录洁癖门禁：通过。本阶段新增内容只允许进入 `docs/00_ssot` 与 `apps/mobile/test`。
- 架构边界门禁：通过。Flutter App 仍只消费 BFF `/api/app/*`；不直接调用 Server。
- 契约门禁：通过。本阶段不新增字段、路径、错误码或请求体语义。
- 状态机门禁：通过。不新增 `prepublish` / `prepublished`，不改变 `draft -> submitted -> published`。
- 数据与上传门禁：通过。owner 附件继续遵循 `init -> direct upload -> confirm -> bind`；业务真相仍是 `FileAsset + project_attachments`。
- 前端体验门禁：通过。允许做 Flutter 回归断言与文案验收，不允许用假成功掩盖 BFF/Server 缺口。
- 审计门禁：通过。本阶段无高风险后端动作。
- 云上运行门禁：通过但不声明云端验收。本阶段仅做本地 Flutter 回归，不以云上 smoke 或 Computer Use 作为发布依据。
- 阶段控制门禁：通过。阶段目标单一，失败只允许回退或修复前端改动。
- 文件长度与职责门禁：通过。本阶段不扩展生产业务源文件职责。

## 4. Veto Gates

以下任一发生即 `No-Go`：

- 工厂竞标提交页渲染 `other_material`。
- 工厂竞标提交页出现 owner 项目附件的上传、删除、选择或绑定动作。
- 项目列表或公域项目详情被预发布/附件文案污染成 owner 私域界面。
- owner 公域项目详情不再回到我的项目，或 non-owner published 项目不再能进入竞标。
- 创建页明价/询价意向写入请求体或触发 P0-Pay。
- 新增 `prepublish` / `prepublished` 状态、路径或二套状态机。
- 本阶段修改 BFF、Server、contracts 或云上运行时。

## 5. More Stable / Cheaper / Current Fit / Higher Risk

- 更稳：只做 Flutter 回归与正式交付审查，不重开 BFF、Server、contracts。
- 更省成本：复用既有项目列表、项目详情、我的项目详情、竞标提交页测试，加一条 `other_material` drift 防护断言。
- 更适合当前阶段：把 Day5-Day8 的前端体验收敛验明，不进入后端阶段。
- 风险更大：把预发布附件和工厂竞标材料混成同一个可写区，或让 `other_material` 从 owner 私域泄露到工厂侧。

## 6. Stage Decision

- Day9 回归检查：Go。
- Day10 审核交付：Go。
- 后端阶段：No-Go，除非 Day10 审核稿通过并另行冻结后端阶段门禁。
