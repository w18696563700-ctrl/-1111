---
owner: Codex 总控
status: frozen
purpose: Freeze the truth ruling for the current bounded repair covering factory workbench/detail case-alignment semantics and company/factory album de-dup semantics.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
  - docs/04_frontend/enterprise_detail_company_sample_and_home_module_sync_frontend_addendum.md
---

# 《enterprise display factory case alignment and album dedup truth ruling》

## 1. Post-submit Case Continuation Truth

- `published + visible` 企业展示下：
  - 公域详情继续只承接 `live approved listing / case`。
  - 工作台中的 `继续编辑` 不得再先按 live case editor 语义起步。
- 正式裁决：
  - 只要当前 workbench 已进入 `post-submit` 语义，案例继续编辑入口必须直接收口到：
    - `changes/current` current carrier
  - 不允许继续出现：
    - 同一次进入先看到 live case seed
    - 再在运行中掉到 current-change draft

## 2. Hero / Album De-dup Truth

- `company detail`
  - 首屏主视觉本身承接企业画册主职责。
  - 不再额外渲染独立正文 `企业画册` 区。
- `factory detail`
  - Hero 继续优先消费 `showcaseImageUrls`。
  - 正文独立 `企业画册` 区继续隐藏。
- 正式裁决：
  - 不得把 `showcase` 首屏图、`case cover`、或其它 fallback 图源伪装成独立正文 `企业画册`。

## 3. Non-goals

- 不把 public detail 改成 current-change preview。
- 不新增 `draft detail` 公域读取 path。
- 不重开 detail 全量重排对象。
