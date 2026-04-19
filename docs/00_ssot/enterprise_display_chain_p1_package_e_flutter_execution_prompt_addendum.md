---
owner: Codex 总控
status: active
purpose: Freeze the Flutter execution prompt for enterprise display chain P1 package E so the app removes historical fake-filter UI and query fields while keeping only the real public-list filter set.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_bff_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_flutter_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_controls.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_state_support.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
---

# 《enterprise display chain P1 package E Flutter execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package E / Flutter`

## 2. 唯一目标

- 你这轮只关闭 enterprise public list 在 `Flutter` 这一层的 fake-filter UI 与 query drift。
- 当前唯一目标固定为：
  - 让 `Flutter` 的 enterprise public list 只保留正式最小筛选集对应的 query builder 和可见筛选 UI

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_bff_result_verification_conclusion_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_flutter_stage_gate_checklist_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 4. 只允许修改的范围

- `apps/mobile/lib/features/exhibition/**`
- 与本轮最小 UI / query cleanup 直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不新增新的路由
- 不恢复任何已从 contract 删除的筛选 query
- 不误删卡片摘要、详情摘要等 board 展示高亮
- 不把 package-E 扩成详情深化、推荐位改造或排序能力建设

## 6. 当前已冻结事实

1. enterprise public list 正式最小筛选集只包括：
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange` for `factory`
2. `BFF` 已只承接上述最小集合
3. 当前 `Flutter` 仍保留：
   - `EnterpriseHubListQuery` 历史残留字段
   - primary filter UI
   - sort UI
   - 对应 list-state helper 逻辑
4. board-specific card summary / detail summary 高亮不是本包目标，不得误删

## 7. 你必须完成

1. 在 `EnterpriseHubListQuery` 中删除已不属于正式最小集合的字段
2. 在 `toQueryParameters()` 与相关 `copyWith()` / builder 逻辑中只保留：
   - `boardType`
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange`
   - `page`
   - `pageSize`
3. 在 list toolbar UI 中移除：
   - primary filter button
   - sort button
4. 保留：
   - 搜索
   - 城市
   - `factory` 专属 `plantAreaRange`
5. 如 board surface spec 仅为历史 primary filter UI 服务，必须同步收口，但不得误伤 board 展示高亮逻辑

## 8. 你必须补的测试

至少补齐以下覆盖：

1. enterprise public list query 参数只包含正式最小集合
2. primary filter / sort 不再出现在用户可见筛选 UI
3. `factory` 仍保留 `plantAreaRange`
4. `company / supplier` 不再展示假筛选按钮
5. 卡片摘要与详情摘要高亮未被误删

## 9. 完成标准

- 结果必须能证明：
  1. `Flutter` 不再保留历史残留 fake filter UI
  2. `Flutter` 对 enterprise public list 的 query 构造与正式 contract 完全一致
  3. 当前 `P1 fake-filter cleanup` 已真正闭合
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package E / Flutter` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_e_flutter_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 删除的 fake-filter UI / query 字段清单
  3. 保留的最小筛选集说明
  4. 新增或更新的测试清单
  5. analyze / test 结果
  6. 当前剩余未闭合项
  7. 是否已达到 P1 fake-filter cleanup closure

## 11. 输出禁令

- 不要写“应该可以”
- 不要把已删 query 字段继续留在 query builder
- 不要把 primary filter / sort 继续伪装成 P1 正式能力
- 不要误删卡片展示高亮
- 只给真实 UI cleanup、真实测试、真实剩余风险
