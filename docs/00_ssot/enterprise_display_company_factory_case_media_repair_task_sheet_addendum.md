---
owner: Codex 总控
status: frozen
purpose: Freeze the detailed repair task sheet for the enterprise-display company/factory board-separation and case-media repair round, constraining the current work to bounded truth repair, route alignment, consumption fallback, data correction, and regression closure only.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_display_company_factory_case_media_repair_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_backend_truth_scope_addendum.md
  - docs/03_bff/enterprise_display_company_factory_case_media_repair_bff_surface_scope_addendum.md
  - docs/04_frontend/enterprise_display_company_factory_case_media_repair_frontend_surface_addendum.md
---

# 《企业展示 company/factory 串板块与案例媒体回显维修任务单》

## 1. Scope

- 当前任务单只服务于：
  - `enterprise display / company-factory board separation and case-media repair`
- 当前任务单只回答：
  - 修哪些问题
  - 先后顺序是什么
  - 哪些文件族允许动
  - 何时可以做线上数据修复
  - 用什么口径验收
- 当前任务单不是：
  - implementation unlock for other objects
  - release-prep
  - production release approval

## 2. 唯一目标

- 当前 round 唯一目标只有五条：
  - 让 company / factory 公开与私有展示语义一致
  - 让 case 读取、提升、快照、apply 不再串板块
  - 让工厂案例继续编辑图片稳定回显
  - 让 `public-cases` app-facing route 与 live runtime 对齐
  - 让测试与 smoke 能真正拦住上述回归

## 3. 当前根因分解

### 3.1 真值根因

- `Server` 多条 case 链只按 `enterpriseId` 收口。
- 这会导致：
  - 公开详情串 case
  - workbench 串 case
  - published-change snapshot / apply 串 case
  - approved 提升与 caseCount 一并串板块

### 3.2 命名根因

- public list / detail / workbench / published-change 存在多套 display-name 决策。
- 这会导致：
  - factory 列表像 company
  - factory 详情又像 factory
  - workbench 再显示第三套主体名

### 3.3 媒体根因

- case continuation edit carrier 与 workbench summary carrier 对 `caseImageUrlMap` 的依赖很强。
- 一旦 upstream 缺少 URL map：
  - Flutter 就会从 remote image 退成空占位

### 3.4 部署根因

- 仓库已有 `public-cases` route，
  但 live tunnel 返回 `404`。
- 这说明：
  - 当前问题包含部署对齐或网关对齐缺口

## 4. Repair Packages

### 4.1 Package A｜Server truth isolation

- 责任：
  - 修复所有 case 读取、approved 提升、快照、apply 的 board isolation
- 必修项：
  - public detail 只读当前 `listing.primaryBoardType` 的 case
  - public list caseCount 只计当前板块
  - workbench 只读当前板块 case
  - published-change snapshot / apply 只处理当前板块 case
  - approved promotion / drift repair 不得把异板块 case 一起推进
- 允许文件：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts`
  - 必要的同目录 support / presenter / tests

### 4.2 Package B｜Server canonical naming

- 责任：
  - 统一 company / factory 对外与私有展示名策略
- 必修项：
  - factory 对外标题统一优先 `factoryName`
  - 公司主体名只作为所属公司 / formal info carrier
  - public list / detail / workbench / published-change 不再各自决策
- 允许文件：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change.presenter.ts`

### 4.3 Package C｜Server media carrier hardening

- 责任：
  - 稳定 `caseImageUrlMap` / `showcaseImageUrlMap` 的生成与语义
- 必修项：
  - private case detail 必须持续返回 `caseImageUrlMap`
  - public case detail 必须持续返回 `caseImageUrlMap`
  - workbench case item 必须持续返回 `caseImageUrlMap`
  - factory showcase carrier 必须持续返回 `showcaseImageUrlMap`
  - 对“有 fileAssetId 但无 URL”的情形给出受控语义，不得静默装成功
- 允许文件：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`

### 4.4 Package D｜BFF route and shaping alignment

- 责任：
  - 修复 app-facing route drift 与 read-model 透传
- 必修项：
  - `public-cases` app-facing route 在 live runtime 可达
  - controller / module / gateway / current release 一致
  - `caseImageUrlMap` 不得被静默洗成空对象
  - factory list / detail naming 在 app-facing read model 内一致
- 允许文件：
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/bff/test/enterprise-hub-*.test.cjs`

### 4.5 Package E｜Flutter continuation fallback and display semantics

- 责任：
  - 让继续编辑图片在 URL map 缺失时仍尽量稳定回显
  - 让 company / factory 标题与公司行语义稳定
  - 让 detail gallery fallback 真正生效
- 必修项：
  - continue-edit 先用当前 workbench case item 预灌图片，再等 detail 增量覆盖
  - detail 缺 URL map 时不得把已有 remote image 清空
  - factory 标题与所属公司行明确分离
  - company / factory detail 在需要时可消费 fallback gallery images
- 允许文件：
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_*`
  - `apps/mobile/test/enterprise_hub*.dart`

### 4.6 Package F｜Data correction and runtime validation

- 责任：
  - 线上修复历史脏数据并完成 smoke
- 必修项：
  - 排查 `enterprise_case.boardType != enterprise_listing.primaryBoardType`
  - 排查 `enterprise_case.enterpriseId` 错挂
  - 排查 `caseCoverFileAssetId / caseMediaFileAssetIds` 指向无效或不可展示资源
  - 排查 approved application 与 published / visible listing 不一致
  - 修完后走 tunnel smoke
- 当前 package 只允许在 A-E 完成并冻结后执行

## 5. 执行顺序

1. 先冻结 docs 与 contract。
2. 先做 `Server` truth isolation。
3. 再做 `Server` naming 与 media carrier。
4. 再做 `BFF` route / shaping alignment。
5. 再做 `Flutter` fallback 与语义修复。
6. 再做线上数据修复。
7. 最后做 tunnel smoke 与 bounded rollout judgment。

## 6. 明确不做

- 不做新 board 扩面。
- 不做新详情页大改版。
- 不做新地图 contract。
- 不做 Admin review 流程重写。
- 不做第二套 case 状态机。
- 不把 release-prep 混进本轮 repair。

## 7. 验收口径

- 只允许按以下口径验收：
  1. factory 列表 / 推荐 / 详情 / workbench 标题一致
  2. company detail 只显示 company 自己的 approved case
  3. factory detail 只显示 factory 自己的 approved case
  4. 工厂案例继续编辑图片稳定回显
  5. live `public-cases` route 不再 `404`
  6. mixed-board regression tests 与 route smoke tests 通过
- 不允许按以下口径验收：
  - “前端看起来差不多了”
  - “线上旧数据先不管”
  - “空 URL map 也算成功”

## 8. 当前交付物

- 本任务单冻结后，唯一允许的下一步是：
  - 按 `Package A-F` 顺序进入 bounded implementation
  - 并在 code 完成后单独发起数据修复与 smoke judgment
