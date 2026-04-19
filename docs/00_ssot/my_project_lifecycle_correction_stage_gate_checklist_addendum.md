---
owner: Codex 总控
status: active
purpose: >
  Submit the formal stage gate checklist for the second-round my-project
  lifecycle correction, covering only withdraw, archive, close, and the
  draft-only delete boundary under the current publish-workbench object
  cluster.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
---

# 《我的项目生命周期修正规则第二轮阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 纠正 `我的项目` 生命周期动作边界
  - 明确 `draft / submitted / published / awarded | converted_to_order`
    在 `删除 / 撤回 / 作废归档 / 下架关闭 / 业务关闭链`
    上的正式真值语义
  - 完成 docs-only freeze 后，落最小 `Server / BFF` 实施
- 当前明确非目标：
  - `apps/mobile`
  - `Admin`
  - `bid / payment / forum / enterprise_hub`
  - release-prep
  - production release

## 2. Passed Gates

- `真源门禁` 通过：
  - 当前 authority 已锁定在 `AGENTS.md`、`authority_refresh_addendum`、
    `my_project_four_stage_smooth_flow_rule_freeze_addendum`、`openapi.yaml`
    与当前 repo 代码资产。
- `目录洁癖门禁` 通过：
  - 本轮新增文书与代码均可收口在允许目录内。
- `架构边界门禁` 通过：
  - 只改 `Server` 真值与 `BFF` app-facing transport；
    不触碰 mobile、Admin、也不引入 BFF 第二状态机。
- `契约门禁` 通过：
  - 当前已明确先做 docs-only freeze，再做 `Server / BFF`。
- `状态机门禁` 通过：
  - 当前 project 上位状态机可锚定
    `draft -> ... -> converted_to_order -> archived`；
    本轮不发明第二 project 状态机。
- `数据与上传门禁` 通过：
  - 本轮不改上传语义，不把 `objectKey` 当真值，不先拍脑袋改库。
- `审计门禁` 通过：
  - 本轮如果新增动作，必须同时补 append-only audit event。
- `阶段控制门禁` 通过：
  - 当前阶段目标、非目标、允许目录、上位输入已明确。

## 3. Failed Gates

- `文件长度与职责门禁` 当前 repo 存量不洁净：
  - [project-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-write.service.ts)
    已超过默认 handwritten business source limit。
  - [project.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.service.ts)
    已超过默认 handwritten business source limit。
- 上述失败项当前按 `legacy debt already present in repo` 记录，
  本轮只允许通过新增 dedicated lifecycle files 收口，
  不允许继续把新职责堆进上述文件。

## 4. Veto Gates

- 当前未发现会直接阻断 docs-only freeze authoring 的 veto gate。
- 当前未发现必须先改数据库 schema 才能判断 project lifecycle 真值的 veto gate。
- 当前 retained veto discipline：
  - 不得在 docs / contracts 冻结前直接实施
  - 不得把 `delete` 继续混充为 `withdraw / archive / close`
  - 不得为 `awarded / converted_to_order` 伪造关闭链
  - 不得继续扩写已有超长文件

## 5. Stage Decision

- `Go`：
  - docs-only freeze authoring
  - docs-only freeze 完成后的 bounded `Server / BFF` implementation
    only if new lifecycle actions land in new dedicated files and do not widen
    the current oversized source files
- `No-Go`：
  - direct implementation before freeze
  - migration before freeze
  - any fake `awarded / converted_to_order` close implementation
  - mobile / Admin / integration / release-prep / production release

