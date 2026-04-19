---
owner: Codex 总控
status: frozen
purpose: Freeze the Day-1 L0 truth for enterprise-display three-board independence so `company / factory / supplier` domain boundaries, case/media ownership, and published-change board scope stop drifting before lower-layer docs authoring.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
---

# 《enterprise display three-board independence truth freeze addendum》

## 1. Scope

- 当前 Day-1 冻结只覆盖：
  - `enterprise display / three-board independence` 的 L0 高层真相
- 当前只允许：
  - formal truth freeze
  - 下游 docs-only 冻结链 authoring
- 当前不允许：
  - implementation
  - data repair
  - cloud write
  - release judgment

## 2. Three Independent Display Domains

- `company / factory / supplier` 正式冻结为三个独立 display domain。
- 同一 `organization` 可以承接三个 board-scoped display object，但 domain 身份必须始终按 `boardType` 分区。
- shared organization identity、shared listing 底座、shared page skeleton，不构成跨板块真相合并依据。
- public list / detail / recommendation / workbench 的任何读取与展示语义，都必须先落到当前 board，再决定当前 carrier。

## 3. Case Library Independence

- 每个 board 只拥有自己的独立 case library。
- `company` case 只属于 `company`；
  `factory` case 只属于 `factory`；
  `supplier` case 只属于 `supplier`。
- case read、case count、case detail、continue edit、snapshot、apply、public projection 都必须保持 board-scoped。
- sibling board case 不得作为：
  - fallback
  - preload seed
  - count 补位
  - detail substitute

## 4. Case Upload Independence

- case upload 的 `init -> direct upload -> confirm -> bind` 仍是统一基础设施流程，但业务绑定必须是 board-local。
- 上传成功本身只形成 `FileAsset` 基础设施真值；
  只有当素材被挂到当前 board 的 case 或 current-change carrier 上时，才形成业务归属。
- 一个 board 发起的 case upload，不得自动挂到 sibling board。
- 当前不承认：
  - organization-level shared case upload pool
  - cross-board implicit reuse as business truth

## 5. Media Ownership Independence

- media ownership 真相冻结为：
  - board-local carrier ownership
  - 不是 organization-wide implicit sharing
- `objectKey` 与 URL projection 不是 ownership truth；
  board-local `FileAsset` binding、case carrier、board profile carrier、change snapshot binding 才是。
- hero、gallery、case cover、case media 不得因为 uploader 或 organization 相同，就被静默借给别的 board。
- presentation fallback 只允许消费当前 board 已合法拥有的 media，不得伪造 cross-board ownership。

## 6. Published-change Same-board Rule

- 已发布 listing 的 `current change` 走廊必须严格锁定在同一个 `enterpriseId + boardType` 组合内。
- change snapshot、case add/edit/delete、review、approve、apply、live projection 都必须遵守 same-board rule。
- 一个 board 的 published change，不得：
  - mutate sibling board
  - apply 到 sibling board
  - preview 为 sibling board
  - 以 sibling board 的 case 或 media 补洞
- same-board rule 同时适用于：
  - `basic`
  - `boardProfile`
  - `cases`
  - media bindings

## 7. Explicit Non-goals

- 不在 Day-1 直接放 implementation dispatch。
- 不在 Day-1 直接裁决 data repair / backfill。
- 不在 Day-1 直接放云端写操作、deploy、restart、rollback、release。
- 不新开 board type。
- 不建立 organization-wide shared case pool。
- 不建立 cross-board unified media gallery truth。
- 不再发明第二条 published-change corridor。

## 8. Priority And Supersede Relation

- 在当前 `enterprise display / three-board independence` bounded object 内：
  - 本轮 Day-1 freeze bundle 的优先级高于旧的“单一企业展示入驻入口 / bottom sheet 选板块”解释
- 当前私有入口 controlling truth 正式固定为：
  - `我的公司展示`
  - `我的工厂展示`
  - `我的供应商展示`
  - `我的个人/团队展示`
- 其中前三个入口进入三板块独立化主线；
  `个人/团队展示` 继续只保留受控占位。
- 既有 `factory` published-change routing 明确裁决继续有效，
  但其在本轮内只作为三板块对称治理的先行样本，
  不再被解释成长期仅 `factory` 独享的特例。

## 9. Next Document Chain

- 当前下游文书链固定为：
  - `docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md`
  - `docs/02_backend/enterprise_display_three_board_independence_backend_truth_scope_addendum.md`
  - `docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md`
  - `docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md`
- 若未来需要 data repair、cloud action 或 bounded rollout judgment，
  必须在上述 docs chain 完成后，重新提交新的 L0 《阶段门禁核查表》。
