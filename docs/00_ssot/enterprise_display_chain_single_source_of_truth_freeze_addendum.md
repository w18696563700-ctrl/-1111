---
owner: Codex 总控
status: draft
purpose: Freeze the single-source-of-truth boundary for the enterprise display chain from private workbench through admin review and publish to public list, detail, and home recommendation surfaces, and stop cross-layer drift before parallel code repair.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/enterprise_hub/**
  - apps/bff/src/routes/enterprise_hub/**
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
---

# 《enterprise display chain single source of truth freeze addendum》

## 1. 冻结结论

- 当前链路正式裁决为：
  - `No-Go for code-repair fan-out`
  - `Go for truth freeze`
- 本单只冻结以下单一业务链：
  - `企业展示工作台 -> 申请提交 -> Admin 审核 -> Admin 发布 -> 公域列表/详情 -> 首页三板块推荐`
- 在本单完成对齐前：
  - Flutter 不得各自重定义产品语义
  - `BFF` 不得各自重定义 contract truth
  - `Server` 不得各自重定义对象真相与状态真相
- 当前唯一允许推进的工作只限：
  - 证据补抓
  - `SSOT` 冻结文书
  - contract 收口
  - 冲突旧文书退役标记

## 2. 当前代码真相

### 2.1 对象真相

- `organization` 仍是上游主体身份真相。
- `enterprise_listing` 是当前展示链的 listing truth carrier。
- 当前代码真相已经不是：
  - `一个 organization 仅允许一条 listing`
- 当前代码真相已经变成：
  - `一个 organization 在每个 boardType 下最多一条 listing`
  - 唯一边界为 `(organization_id, primary_board_type)`
- 证据：
  - `apps/server/src/core/migrations/migrations.ts:188-192`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:71-79`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts:52-55`

### 2.2 板块画像真相

- `company / factory / supplier` 当前不是一套字段硬共用。
- 当前代码真相是三套 board-profile truth 并存：
  - `enterprise_profile_company`
  - `enterprise_profile_factory`
  - `enterprise_profile_supplier`
- 它们共享 listing 底座，但不共享字段真相。
- 证据：
  - `apps/server/src/core/migrations/migrations.ts:33-77`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:182-253`

### 2.3 私域与公域分层真相

- workbench 当前是组织侧私域 create / continue / submit carrier。
- 公域列表、详情、推荐位当前是独立 public projection。
- workbench 当前不得被解释成：
  - 公域榜单
  - Admin 发布席位
  - 第二个公司资料总后台
- 证据：
  - `docs/01_contracts/openapi.yaml:958-982`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:58-62`

### 2.4 当前状态家族真相

- 当前代码并不是一条已经收口好的单生命周期。
- 当前代码同时维护：
  - `applicationStatus`
  - `enterpriseStatus`
  - `displayStatus`
  - `caseStatus`
- 证据：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts:2-25`

### 2.5 前台承接真相

- 公域列表与详情当前是同一套前台骨架按 `boardType` 承接，不是三套完全独立页面。
- 当前前台真相是：
  - 列表共用一套 `EnterpriseBoardListPage`
  - 详情共用一套 `EnterpriseDetailPage`
  - 具体筛选文案、卡片摘要、字段展示按 `boardType` 分支
- 证据：
  - `apps/mobile/lib/shell/navigation/app_router.dart:239-275`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart:12-79`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart:7-62`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart:26-177`

## 3. 已证实冲突集

### 3.1 listing 模型冲突

- 旧文书仍主张：
  - 一个 organization 仅允许一条 listing
  - `primaryBoardType` 一旦建立即单主板块锁死
- 当前数据库、写链、workbench 读链已经不是该真相。
- 证据：
  - 旧文书：`docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:197-203`
  - 旧文书：`docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md:66-69`
  - 当前迁移：`apps/server/src/core/migrations/migrations.ts:188-192`
  - 当前写链：`apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:71-79`

### 3.2 workbench contract 漂移

- workbench 运行时强依赖 `boardType`。
- 当前 OpenAPI 中 `GET /api/app/exhibition/enterprise-hub/workbench` 没有声明 `boardType` query 参数。
- 证据：
  - 运行时：`apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts:259-264`
  - contract：`docs/01_contracts/openapi.yaml:958-982`

### 3.3 联系人假可编辑冲突

- workbench 页面暴露了可编辑的联系人姓名和手机号。
- 基础资料保存并不会把这两个字段发到 write chain。
- 当前联系人 upsert 只发生在 `createApplication`。
- readiness 又只认持久化后的联系人 truth。
- 这导致：
  - 页面看起来可改
  - 真实持久化并不跟随普通保存动作
  - 页面输入与 readiness 真相可脱钩
- 证据：
  - 页面输入：`apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:1648-1677`
  - basic save：`apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:503-519`
  - create path：`apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:65-102`
  - contact upsert：`apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:436-448`
  - readiness：`apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts:174-217`

### 3.4 案例公域投影口径冲突

- 公域详情只读取 `approved` 案例。
- 公域列表 `caseCount` 当前统计的是全部案例。
- submit-time minimum 当前只检查“至少有案例”，并不要求公域可见案例。
- 这允许出现：
  - 列表显示“有案例”
  - 详情却没有任何公域可见案例
- 证据：
  - 公域详情：`apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:120-142`
  - 公域列表统计：`apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:180-201`
  - submit minimum：`apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:376-382`

### 3.5 筛选/排序假动作冲突

- `BFF` 当前向下透传了大量 list query 参数。
- `Server` 当前实际落地的筛选只有少数几项。
- 当前 public filter UI 面已经超过真实 query truth。
- 证据：
  - `BFF`：`apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts:563-587`
  - `Server`：`apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:58-89`

### 3.6 图片真相与展示投影冲突

- write truth 当前明确是 `fileAssetId` 体系。
- `BFF` 在写链上显式拒绝 URL truth。
- `Server` public presenter 仍返回 `logoUrl / coverImageUrl = null`。
- 这意味着：
  - 存储侧真相存在
  - 公域展示侧 display projection 未闭环
- 证据：
  - write basic normalize：`apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts:605-623`
  - workbench save：`apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:503-519`
  - public presenter：`apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts:29-67`
  - public detail presenter：`apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts:84-140`

### 3.7 旧 non-goal 与运行时 API 冲突

- 旧 workbench freeze 仍把 `case edit / 删除` 列为当前阶段不计入完整。
- 运行时代码已经暴露并实现 `deleteCase`。
- 该旧条款不能继续被当成当前 runtime truth 引用。
- 证据：
  - 旧文书：`docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:60-65`
  - `BFF` route：`apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts:167-174`
  - `Server` impl：`apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:291-299`

## 4. 正式冻结裁决

### 4.1 架构 Go / No-Go 裁决

- 自本单起：
  - `Go`：真相冻结、contract 收口、旧文书退役、补证据
  - `No-Go`：Flutter / `BFF` / `Server` 并行各修各的
- 任何单层实现便利都不得在本单前升级成新的链路真相。

### 4.2 listing 真相裁决

- 当前正式链路真相冻结为：
  - `enterprise_listing` 是 board 级展示实体
  - 唯一边界是 `(organization_id, primary_board_type)`
  - 一个 organization 在当前阶段最多各拥有一条：
    - `company`
    - `factory`
    - `supplier`
- `enterprise_listing` 不是组织级唯一总档案。
- `organization` 继续是上游主体身份真相。
- 所有仍声称“organization 仅允许一条 listing”的旧条款，自本单起正式失效。

### 4.3 板块画像裁决

- `enterprise_profile_company`
- `enterprise_profile_factory`
- `enterprise_profile_supplier`
- 以上三者继续冻结为独立 board-profile truth carrier。
- 它们共享 listing 底座，但不共享字段真相。
- 未来如要抽公共展示字段，只能做 presentation shaping，不得反向改写三套 profile truth。

### 4.4 workbench 定位裁决

- workbench 正式冻结为：
  - 私域企业展示建档台
  - 继续编辑台
  - 申请提交台
- workbench 不是：
  - 公域发布台
  - 榜单展示台
  - 推荐位运营台
- 页面文案、contract 文案、流程说明均不得再暗示：
  - `submit = 已公域可见`

### 4.5 状态链裁决

- 当前链路正式冻结为四段式关系：
  - `submit`
  - `review`
  - `publish`
  - `recommendation`
- 当前运行时含义冻结为：
  - `submit`：application 进入审核队列
  - `review`：Admin 对 application 做审核结论
  - `publish`：listing 进入 `published + visible`
  - `recommendation`：已发布可见 listing 可进入推荐位
- 本单不宣称当前多状态实现已经是最终完态架构。
- 本单只冻结一条关键真相：
  - 当前公域可见性由 listing publish/display truth 决定，不由 application status 单独决定

### 4.6 公域读取裁决

- 公域列表、详情、推荐位、首页三板块企业推荐的读取边界统一冻结为：
  - `enterpriseStatus = published`
  - `displayStatus = visible`
- workbench 数据、latest application 数据、draft completeness 数据，不得直接作为公域展示 truth。
- 首页推荐位在上述基础上，还必须满足有效 slot 边界。

### 4.7 公域案例裁决

- 公域案例真相必须统一口径。
- 在当前 case 模型尚未拆出独立可见性维度之前，当前正式公域案例边界冻结为：
  - `caseStatus = approved`
- 因此以下面向公域用户的案例清单与案例数字，必须统一使用 `approved` 口径：
  - 公域详情案例区
  - 公域列表 `caseCount`
  - 任何公域摘要中的案例数字
- submit-time minimum 属于私域提交门槛，不得冒充公域统计 truth。

### 4.8 联系人真相裁决

- workbench 上所有“可编辑”联系人字段必须满足二选一：
  - 真可持久化
  - 明确只读
- `看起来可改但不会保存` 正式列为禁止状态。
- readiness 只能判断持久化 truth，不能判断 Flutter controller 暂存值。
- 当前联系人 truth owner 继续固定为 server persistence。

### 4.9 图片真相裁决

- 存储真相冻结为 file-asset 模式：
  - `logoFileAssetId`
  - `coverFileAssetId`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
- 展示真相必须由 server-side 或 server-owned shaping 输出 display projection。
- Flutter 不得自己猜测 `fileAssetId -> 可展示 URL` 规则。
- 如果某个展示位仍被正式支持，对应 read model 必须返回可消费的展示投影字段。
- 如果某字段例如 `cover` 被正式废止，则必须同步从：
  - `SSOT`
  - contract
  - 实现
  中一起删除，不允许长时间维持“双轨真相”。

### 4.10 筛选真相裁决

- 公域筛选面只允许暴露已真实实现的筛选。
- 当前最小真实筛选集冻结为：
  - `keyword`
  - `provinceCode`
  - `cityCode`
  - `plantAreaRange` for `factory`
- 其他当前已出现在 query 面但未被 `Server` 实施的筛选，不得继续被描述为可靠 public truth。

### 4.11 contract 对齐裁决

- `GET /api/app/exhibition/enterprise-hub/workbench` 必须显式声明 `boardType` query truth。
- contract 必须收口到当前 board-bound workbench 模型。
- 不允许再用当前 OpenAPI 漏项，反推“workbench 可以 board-agnostic”这种错误语义。

### 4.12 generated contract owner 裁决

- 当前 generated contract projection 的唯一 formal owner 冻结为：
  - `packages/contracts`
- `apps/bff` 允许直接消费 generated contract projection。
- 但 `apps/bff` 不得再维护第二套长期并存的本地 generated truth。
- `apps/bff/src/shared/generated/*` 自本单起只允许作为迁移中的 legacy transitional output：
  - 不再是 formal truth owner
  - 不再是 contract drift 的裁决依据
  - 在 `apps/bff` 完成 direct binding 到 `packages/contracts` 后必须退役删除
- 本单不允许把 `apps/bff/src/shared/generated/*` 裁决成永久豁免资产。

## 5. 退役或失效条款

- 以下旧条款自本单起正式退役：
  - `当前 organization 仅允许拥有一条 enterprise listing。`
  - source: `docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:199`
- 以下旧条款自本单起正式退役：
  - `enterprise_listing.organization_id is mandatory and unique.`
  - source: `docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md:68`
- 以下旧条款不得继续被当成 runtime-truth 证据引用：
  - `case 编辑 / 删除` 不在当前完整边界内
  - source: `docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:60-65`
- 以下 legacy generated projection 自本单起进入退役对象：
  - `apps/bff/src/shared/generated/app-api.types.ts`
  - `apps/bff/src/shared/generated/error-codes.ts`
- 上述 legacy projection 的退役含义是：
  - `BFF` 必须改为直接消费 `packages/contracts/src/generated/*`
  - legacy projection 不再允许作为正式 generated-output 存续
  - 如仍存在，会继续构成 `contracts:check` 阻塞
- 本单中的“退役”含义是：
  - 旧条款不再描述当前 runtime truth
  - 旧条款不得继续否决 contract 收口
  - 某能力是否被正式产品化，仍可在后续独立闭环文书里再裁决

## 6. 冻结期强制同步项

- 在放开代码修复扩散前，以下事项必须先完成文书或 contract 对齐：
  - 把 board-level listing 规则写回 `SSOT`
  - 把 `workbench.boardType` 写回 OpenAPI
  - 把公域案例统计口径写成 `approved` 统一规则
  - 把联系人可编辑即需可持久化的规则写死
  - 把图片的存储真相与展示投影责任层写死
  - 把最小真实 public filter 集写死
  - 把上述失效旧条款标明退役
- 上述任一项仍有模糊空间时，业务实现 dispatch 继续阻断。

## 7. 证据边界与待补证项

- 本单已将以下内容视为“已证实代码真相”：
  - board-level listing uniqueness
  - `submit / review / publish / recommendation` 四段式关系
  - workbench `boardType` 运行时必填
  - 联系人假可编辑问题
  - 案例公域统计口径不一致
  - 筛选假动作问题
  - 图片 display projection 未闭环
- 本单当前未把以下内容冻结成已证实真相：
  - recommendation slot create 是否强校验 `payload.boardType === listing.primaryBoardType`
  - 认证展示到底是实时组织真相还是 snapshot 真相，以及 snapshot 刷新时机
  - 所有企业展示入口 owner 是否已经完全收口为单主入口
- 上述项目暂留待补证附录，不得在正文里被过度宣称为已定论。

## 8. 下一轮唯一动作

- 本单通过后，下一轮唯一允许动作是：
  - 针对本链路做一次 focused contract sync 与 legacy-doc retirement pass
- 下一轮仍不授权：
  - 功能面扩大
  - UI 继续叠加
  - 推测式重构
  - Flutter / `BFF` / `Server` 并行各修各的

## 附录 A. 主证据索引

- listing 唯一边界迁移：
  - `apps/server/src/core/migrations/migrations.ts:188-192`
- application create path：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:65-139`
- workbench board-bound read：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts:43-55`
- submit path：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:320-340`
- review path：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts:140-157`
- publish path：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts:160-176`
- recommendation placement gate：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts:220-264`
- public list/detail gate：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:58-62`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:108-117`
- 联系人假可编辑证据：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:503-519`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart:1648-1677`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:436-448`
- 案例口径冲突证据：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:120-142`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:180-201`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:376-382`
- 筛选假动作证据：
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts:563-587`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts:58-89`
- 图片投影缺口证据：
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts:605-623`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts:29-67`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts:84-140`
- 前台共骨架承接证据：
  - `apps/mobile/lib/shell/navigation/app_router.dart:239-275`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart:12-79`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart:7-62`
- 旧条款退役证据：
  - `docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:60-65`
  - `docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md:197-203`
  - `docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md:66-69`
