---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded stage-2 object after the local workbench relayout so the enterprise display chain can close the remaining cloud truth, BFF shaping, and frontend consumption gaps for company public cards and workbench album echo.
layer: L0 SSOT
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_stage_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - docs/03_bff/enterprise_display_album_and_target_enterprise_info_bff_surface_addendum.md
---

# 企业展示 Stage 2 公域卡片与画册云端补链边界裁决

## 1. Stage Objective

- 当前 stage-2 只补齐 stage-1 之后仍然存在的正式链路缺口：
  - `优秀公司` 公域列表卡片缺少 `serviceItems`
  - 工作台 `basic.albumImageFileAssetIds` 未形成 Server -> BFF -> Flutter 正式回读闭环
  - 公域列表 company 卡片仍以 `serviceCities / avgScore` 驱动，而不是以 `serviceItems / 信用评分占位` 驱动

## 2. Bounded Scope

- 当前允许进入的对象只包括：
  - `docs/**`
  - `apps/server/src/modules/enterprise_hub/**`
  - `apps/server/src/modules/upload/**`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/mobile/lib/features/exhibition/data/**`
  - `apps/mobile/lib/features/exhibition/presentation/**`
  - 对应最小测试
- 当前不覆盖：
  - 企业详情整页重排
  - Admin 面
  - 新信用系统真值建设
  - release-prep
  - production release

## 3. Formal Stage-2 Gaps

### 3.1 Public Company Card Gap

- 当前 `Server` 公域列表 `boardHighlights.company` 仍只稳定承接：
  - `exhibitionTypes`
  - `serviceCities`
- 当前 stage-2 必须把 `serviceItems` 补入公域列表正式输出。

### 3.2 Workbench Album Echo Gap

- 当前 `workbench.basic.albumImageFileAssetIds` contract 与 frontend consumer 已存在，
  但 `Server` / `BFF` source implementation 尚未形成正式回读闭环。
- 当前 stage-2 必须补齐：
  - basic write 接收
  - persistence truth
  - workbench read 回传
  - BFF 透传与 shaping

### 3.3 Company Credit Slot Gap

- 当前 company 公域列表卡片仍把：
  - `avgScore`
  - 或 `caseCount`
  直接占据底部摘要位置。
- 当前 stage-2 必须把 company 卡片底部固定为：
  - `信用评分：建设中`
  - 或等价且不伪装真实信用分的占位表达

## 4. Shared Layout Rule Continuity

- stage-1 已冻结的三类工作台主骨架继续生效：
  1. 展示标识
  2. 企业画册
  3. 地图
  4. 基础资料
  5. 联系人
  6. 案例编辑器
- stage-2 不得借补链之名回退 stage-1 的信息架构裁决。

## 5. Company Public Card Rule

- company 公域列表卡片当前正式目标信息固定为：
  - Logo
  - 企业名称
  - 企业位置，仅省市
  - 展会类型
  - 服务项目
  - 信用评分占位
- 当前 company 公域列表卡片不得再把：
  - `服务城市`
  - 真实评论均分
  作为主摘要结果替代上述目标字段。

## 6. Anti-revert

- 不得把 company 公域列表主摘要重新改回 `serviceCities`
- 不得继续用 `avgScore` 冒充 `信用评分`
- 不得把 `albumImageFileAssetIds` 继续停留在 contract-only / frontend-only 状态
- 不得把 stage-2 补链误报为 production release 完成

## 7. Formal Conclusion

- 当前 stage-2 的正式对象已经固定为：
  - company 公域列表卡片字段补链
  - workbench 统一企业画册回读闭环
  - company 卡片信用评分占位消费裁决
- 超出该对象的扩面，一律不属于本轮。
