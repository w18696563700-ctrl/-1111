---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server-side truth adjustment for prepublish owner attachment
  continuation and bid-submit read-only material projection, while preserving
  `project_attachments` as the single attachment business carrier.
layer: L3 Backend
freeze_date_local: 2026-04-16
inputs_canonical:
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - apps/server/src/modules/project/project-attachment.service.ts
  - apps/server/src/modules/project/project-query.service.ts
---

# 《项目附件预发布前移与竞标材料只读投影 backend truth freeze》

## 1. Owner Attachment Corridor

- `Server` 继续拥有 `project_attachments` 唯一业务真值。
- 当前进入 owner 附件走廊的状态正式放宽为：
  - `submitted`
  - `published`
  - `bidding_closed`
  - `awarded`
  - `converted_to_order`
- 当前仍禁止：
  - `draft`
  - `archived`

## 2. Bid Materials Projection

- `Server` 当前正式新增一个只读查询投影：
  - 从 `project_attachments` 过滤出 `effect_image / construction_doc`
  - 只服务 bid-submit
- 当前投影不产生第二张业务表，不新增持久化 carrier。

## 3. Persistence Boundary

- 当前不新增：
  - 新表
  - 新列
  - 新 migration family
- `project_attachments.visibility` 当前不扩成新的可写矩阵；bid-side 只读投影只改变读侧暴露方式。

## 4. Non-goals

- 不开放 generic public attachment center
- 不开放 bid-side 写入
- 不新增 `published -> submitted` lifecycle truth

## 5. Formal Conclusion

- 当前 backend truth 正式冻结为：
  - owner 附件 corridor 前移到 `submitted-or-later`
  - bid-submit 可读 effect/construction materials projection
  - `No Migration`
