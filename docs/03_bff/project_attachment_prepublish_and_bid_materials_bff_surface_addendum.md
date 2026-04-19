---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF-side shaping boundary for prepublish owner attachment
  continuation and bid-submit project-material read projection, without
  creating a second attachment state machine.
layer: L4 BFF
freeze_date_local: 2026-04-16
inputs_canonical:
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
---

# 《项目附件预发布前移与竞标材料只读投影 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - owner 附件 family 的错误整形与透传
  - `GET /api/app/project/bid-materials`

## 2. BFF Boundary

- `BFF` 继续不得拥有：
  - 第二附件状态机
  - 第二上传真值
  - 第二 project detail truth
- `BFF` 只负责：
  - transport
  - shaping
  - 中文错误归一

## 3. Read Projection Rule

- `GET /api/app/project/bid-materials` 当前只对接：
  - `/server/projects/{projectId}/bid-materials`
- `BFF` 不得把 owner 写侧附件 family 直接伪装成 generic public attachments center。

## 4. Formal Conclusion

- 当前 BFF surface 正式冻结为：
  - owner 附件继续透传既有 family
  - bid-submit 新增 bounded read-only materials projection
