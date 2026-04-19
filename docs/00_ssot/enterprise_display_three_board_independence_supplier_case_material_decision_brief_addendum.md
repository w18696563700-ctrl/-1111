---
owner: Codex 总控
status: frozen
purpose: Freeze the stage-1 business decision brief for the supplier invalid case media under enterprise-display three-board independence, so the next action becomes clearing the invalid supplier case rather than supplementing guessed media.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_receipt_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
---

# 《enterprise display three-board independence supplier case material decision brief》

## 1. 背景与对象定义

- 当前对象固定为：
  - `supplier` listing：
    - `enterprise_id = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
  - 目标 case：
    - `case_id = 5ffda6ac-e379-4ff9-85fc-720beb2a7161`
    - `title = supplier 样本案例`
- 当前 live truth 已确认：
  - 该 case 的 cover / media 都绑在：
    - `file_asset_id = 9399d036-aca4-4331-b15f-0c6ede2e8df9`
    - `business_type = profile`
    - `file_kind = business_license`
  - 当前 public read 仍会直接吐出 `profile/business_license` URL。

## 2. 非法 / 不合规判定依据

- 当前 case 图片不合规，依据固定为：
  - 不属于 `enterprise_display`
  - 不属于当前 `supplier` listing
  - 不属于合法 case media `file_kind`
- 当前只读盘点已确认：
  - 数据库中不存在任何一张：
    - `business_type = enterprise_display`
    - `business_id = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
    - `mime_type LIKE image/%`
    的合法 supplier 图片资产
- 因此当前不能通过：
  - 猜测目标图片
  - 沿用 company / factory 现有图片
  - 把 `business_license` 强改成 case media
  来完成修复。

## 3. 业务处理选项

### 3.1 Option A｜保留 supplier case，并人工补素材

- 业务含义：
  - 该 supplier case 是有效公开案例
  - 需要补齐至少一张合法 supplier case 图片
- 要求：
  - 至少提供 `1` 张合法图片作为 cover
  - 可选再提供 `0..n` 张 gallery 图片
  - 必须明确该图片可用于 supplier 对外展示

### 3.2 Option B｜保留 case 文本，但先撤下公开图片能力

- 业务含义：
  - 该 case 仍存在，但当前无合法图片
- 要求：
  - 先把该 case 从公开面移除，或调整其公开状态
  - 后续有合法图片后再单开修复

### 3.3 Option C｜判定当前 supplier case 为残留样本，直接下线

- 业务含义：
  - 当前 case 不是需要保留的真实 supplier 案例
- 要求：
  - 走单独的 case 下线 / 删除决策
  - 不再为其补素材

## 4. 当前业务决策

- 当前正式决策固定为：
  - 采用 `Option C`
  - 直接清掉当前 supplier 非法案例
  - 不再为该 case 补素材
- 当前决策含义固定为：
  - 当前目标不是保留案例内容
  - 当前目标是先恢复同库内的严格独立规则
  - 该 `supplier` case 不再保留为 live business truth

## 5. 明确禁止事项

- 不允许把 company / factory 的现有案例图直接挪给 supplier case。
- 不允许把 `profile/business_license` 继续冒充 supplier case 图片。
- 不允许继续保留这条非法 `approved` live case 作为“以后再补”的占位真值。
- 不允许把 `business_license` 资产本体一起误删。
- 不允许因为要删 case，就顺手删掉不属于该 case 专属 truth 的共享对象。

## 6. 下一阶段是否允许开启

- 当前结论：
  - `Go for delete-type bounded repair`
  - `No-Go for manual material supplementation`
- 下一阶段的唯一目标固定为：
  - 删除当前非法 supplier case live truth
  - 清理该 case 专属的 case-level 关联
  - 不保留该 case 的业务真值占位
