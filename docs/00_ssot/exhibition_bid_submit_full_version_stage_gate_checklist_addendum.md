---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the stage gate checklist for the exhibition bid-submit full-version
  truth freeze round so later implementation prompts only proceed after the
  docs-only truth is aligned and the current submit page is no longer treated
  as a seat/completeness display surface.
layer: L0 SSOT
freeze_date_local: 2026-04-15
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《竞标提交页满分版改造阶段门禁核查表》

## 1. Stage Objective

- 冻结 `竞标提交页` 的满分版展示与提交规则。
- 统一当前 submit page 的单一语义为：
  - `第一步 核对项目`
  - `第二步 填写报价与方案说明`
  - `第三步 上传必选文档`
  - `提交竞标`
- 让后续实现只围绕以下真相展开：
  - 项目完整信息前置
  - 3 份必传文档
  - 模板下载区
  - 已隐藏的说明卡 / seat / completeness / 结果解释卡

## 2. Non-goals

- 不进入实现。
- 不进入 implementation unlock。
- 不新增第二套竞标工作台。
- 不把 `objectKey` 提升为业务真值。
- 不重新引入席位数量限制、占位收费或报名费。
- 不把当前 submit page 继续解释成 seat / completeness 运营页。

## 3. Allowed Directories

- 本轮只允许编辑：
  - `docs/00_ssot/**`
  - `docs/01_contracts/**`
  - `docs/02_backend/**`
  - `docs/03_bff/**`
  - `docs/04_frontend/**`
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
- 本轮禁止编辑：
  - `apps/**`
  - `packages/**`
  - `scripts/**`

## 4. Frozen Inputs

- `docs/00_ssot/gate_register_v1.md`
- `docs/00_ssot/latest_user_confirmed_change_ledger.md`
- `docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md`
- `docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md`
- `docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 5. Passed Gates

- 真源门禁：
  - 通过
  - 这轮只写 formal docs，不把实现写成已放行。
- 目录洁癖门禁：
  - 通过
  - 本轮只允许 `docs/**`。
- 架构边界门禁：
  - 通过
  - Flutter 仍然只能经由 BFF。
- 数据与上传门禁：
  - 通过
  - 文档明确要求 `init -> direct upload -> confirm`。
- 阶段控制门禁：
  - 通过
  - 本轮先冻结文书，再谈后续实现。

## 6. Failed Gates

- implementation gate：
  - 未通过
  - 当前没有允许前端直接开始实现的 truth freeze 完整闭环。
- runtime gate：
  - 未通过
  - 当前没有云上执行验证结论。
- seat/completeness display gate：
  - 未通过
  - 当前 submit page 不能继续把 seat / completeness 当作主展示内容。

## 7. Veto Gates

- 若把 `objectKey` 写成 bid submit 的业务真值，直接 veto。
- 若把模板下载区放到结果页按钮下方，直接 veto。
- 若把 seat / completeness / 冗长解释卡继续留在当前 submit page 的主视觉区，直接 veto。
- 若把这轮文书冻结误写成 implementation unlock，直接 veto。

## 8. Go / No-Go

- 本轮结论：
  - `Go` for docs freeze
  - `No-Go` for frontend implementation stage
- 理由：
  - 还需要先完成合同、后端、BFF、前端五层冻结文书的一致化。
  - 当前页的实现边界必须先在文书里收口，再进入代码层。
