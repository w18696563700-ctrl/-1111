---
owner: Codex 总控
status: frozen
purpose: Freeze the Round B truth ownership, field admission, and upload-boundary decisions for project publish only, without entering implementation, migration authoring, or any other board.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_address_range_persistence_migration_unlock_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/data/commands/project_create_command.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/server/src/modules/upload/upload-write.service.ts
  - apps/server/src/modules/upload/entities/upload-session.entity.ts
  - apps/server/src/modules/upload/entities/file-asset.entity.ts
freeze_date_local: 2026-04-04
---

# 项目发布 Round B 真源冻结单

## 1. Scope

- 本冻结单只覆盖 `项目发布 Round B` 的新增字段与附件承接边界。
- 本冻结单只裁定：
  - 哪些新增项进入正式真源
  - 哪些新增项暂不进入正式真源
  - 哪些项需要后续 contract freeze
  - 哪些项需要后续 persistence / migration freeze
  - 哪些项会触发 upload 绑定语义变化
- 本冻结单不进入：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - 业务代码实现
  - migration authoring
  - BFF / Server / Flutter 实施轮

## 2. Current Round A Baseline

- 当前 Round A 已冻结的 project create/detail 真值字段限于：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `description`
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
- 当前 upload canonical truth 仍冻结为：
  - `businessType=project`
  - `fileKind=evidence`
  - `businessId=projectId`
  - `init -> direct upload -> confirm`
  - confirm 后才产生 `FileAsset`
- 当前本地代码证据也表明：
  - create command 当前不承接预创建附件主表单字段，见
    [project_create_command.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/commands/project_create_command.dart)
  - 项目附件当前必须先拿到 `projectId` 才继续上传，见
    [project_attachment_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart)
  - `Server` upload init / confirm 当前仍围绕 `businessType=project` 与
    `businessId=projectId` 运行，见
    [upload-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload-write.service.ts)

## 3. Round B 逐项真源归属裁定总表

| 新增项 | 是否进入正式真源 | 真源归属 | 是否需要 persistence 字段 | 是否需要 app-facing contract | 是否需要新增 BFF / Server 行为 | 是否可分阶段落地 | 本轮裁定 |
|---|---|---|---|---|---|---|---|
| 项目面积 | 是 | create truth + detail read truth | 是 | 是 | 是 | 是 | 进入 Round B 正式字段 |
| 类型备注 | 是 | create truth + detail read truth | 是 | 是 | 是 | 是 | 进入 Round B 正式字段 |
| 预算区间 | 否 | guidance-only | 否 | 否 | 否 | 不适用 | 暂不进入正式真源 |
| 奖励金额 | 否 | 暂不冻结为 publish-only 真源 | 否 | 否 | 否 | 不适用 | 暂不进入正式真源 |
| 详细时间 | 是 | create truth + detail read truth | 是 | 是 | 是 | 是 | 进入 Round B 正式字段 |
| 创建前附件主表单化 | 否 | upload binding truth change candidate | 很可能需要，但本轮不冻结 | 很可能需要，但本轮不冻结 | 是，且影响 upload 机制 | 必须拆阶段 | 暂不进入 Round B 字段真源 |

## 4. 进入正式真源的 Round B 字段

### 4.1 项目面积

- 本轮正式裁定：
  - `项目面积` 进入 Round B 正式真源。
- 冻结归属：
  - `create truth`
  - `detail read truth`
- 当前不进入：
  - `project/list` projection
  - workbench projection
- 冻结命名：
  - app-facing canonical field: `areaSqm`
  - persistence canonical column: `area_sqm`
- 冻结单位与精度：
  - canonical unit 固定为 `平方米`
  - app-facing / backend / persistence 全链只认 `sqm`
  - 数值精度冻结为最多两位小数
- 冻结类型建议：
  - app-facing: `number`
  - persistence: `numeric(10,2)` 或同等精度 decimal
- 当前冻结口径：
  - Round B 不新增独立单位字段
  - Round B 不允许前端提交“平方米”“㎡”之类展示文本作为真值
  - create/detail 以数值真值为准，展示单位由消费层补文案

### 4.2 类型备注

- 本轮正式裁定：
  - `类型备注` 进入 Round B 正式真源。
- 冻结归属：
  - `create truth`
  - `detail read truth`
- 不允许仅做 detail-only 虚字段。
- 冻结命名：
  - app-facing canonical field: `buildingTypeRemark`
  - persistence canonical column: `building_type_remark`
- 冻结语义：
  - 它是对既有粗分类 `buildingType` 的补充说明
  - 它不替代 `buildingType`
  - 它不创造新的项目类型枚举真相
- 当前冻结口径：
  - `buildingType` 继续保留为当前 canonical coarse type truth
  - `buildingTypeRemark` 只承接更细的文本补充

### 4.3 详细时间

- 本轮正式裁定：
  - `详细时间` 进入 Round B 正式真源。
- 冻结归属：
  - `create truth`
  - `detail read truth`
- 当前不进入：
  - `project/list` projection
  - workbench projection
- 冻结命名：
  - app-facing canonical field: `scheduleDetail`
  - persistence canonical column: `schedule_detail`
- 冻结语义：
  - `scheduleDetail` 是对 `plannedStartAt` / `plannedEndAt` 的排期补充说明
  - 它是文本型补充字段，不是新的多时间点状态机，也不是完整排期对象
- 当前冻结口径：
  - `plannedStartAt` / `plannedEndAt` 继续保留为主日期字段
  - `scheduleDetail` 不替代现有日期字段
  - Round B 不冻结 start-time / end-time / multi-slot / calendar-object 新家族

## 5. 暂不进入正式真源的 Round B 项

### 5.1 预算区间

- 本轮正式裁定：
  - `预算区间` 暂不进入项目正式真源。
- 主要原因：
  - 当前 canonical financial field 已是 `budgetAmount`
  - 若直接新增 `预算区间` 真值，会立刻产生“替代还是并存”的语义冲突
  - 在未先冻结 range taxonomy 或 min/max 方案之前，不能让 `budgetAmount` 与 `预算区间` 并行成为两个 budget truths
- 当前正式口径：
  - `budgetAmount` 继续保留为当前唯一预算真值
  - 若 UI 未来要提供预算档位 chips，只能作为 guidance-only，帮助用户填写 `budgetAmount`
  - Round B 不冻结 `budgetRangeMin` / `budgetRangeMax` / `budgetRangeKey`

### 5.2 奖励金额

- 本轮正式裁定：
  - `奖励金额` 暂不进入项目正式真源。
- 主要原因：
  - `奖励金额` 一旦进入真值，就会牵连后续竞标、成交、支付、结算、激励归属等下游语义
  - 这些语义已超出当前 `项目发布` 板块的 Round B 文书边界
- 当前正式口径：
  - Round B 不冻结 `rewardAmount`
  - 不允许仅把它当作“无下游约束的展示数字”塞进 create/detail
  - 只有在后续单独冻结奖励与结算边界后，才可重开

### 5.3 创建前附件主表单化

- 本轮正式裁定：
  - `创建前附件主表单化` 暂不进入 Round B 正式字段真源。
- 主要原因：
  - 它不是“多一个表单字段”这么简单，而是会改变当前 upload binding truth
  - 当前 canonical upload 语义仍是：
    - `businessType=project`
    - `businessId=projectId`
    - 项目实例创建后再绑定附件
  - 若要在创建前把附件主表单化，至少要新增以下其中之一：
    - pre-create draft carrier
    - create command 内的 confirmed `FileAsset` handoff 规则
    - 新的 draft-to-project binding truth
  - 这些都属于 upload/business binding truth change，不应被伪装成普通字段扩面
- 当前正式口径：
  - Round B 继续保持“先 create 拿 `projectId`，再走正式附件链”
  - pre-create attachment 只能作为后续单独子议题进入真源冻结，不得在本轮顺手放开

## 6. Round B 正式字段的 contract / persistence / behavior 影响

### 6.1 需要后续 contract freeze 的项

- `areaSqm`
- `buildingTypeRemark`
- `scheduleDetail`

后续 contract freeze 必须至少覆盖：

- `POST /api/app/project/create`
- `GET /api/app/project/detail`
- `POST /server/projects`
- `GET /server/projects/{projectId}`
- 共享 `ProjectCreateRequest`
- 共享 `ProjectReadModel`

当前明确不需要进入 Round B contract freeze 的项：

- `预算区间`
- `奖励金额`
- `创建前附件主表单化`

### 6.2 需要后续 persistence / migration freeze 的项

- `areaSqm` -> `area_sqm`
- `buildingTypeRemark` -> `building_type_remark`
- `scheduleDetail` -> `schedule_detail`

当前冻结结论：

- 这 3 项若进入 runtime truth，必须新增 `public.project` persistence carrier
- 因此后续一定需要：
  - backend truth / persistence addendum
  - additive migration freeze
- 当前不要求 list/workbench 因这 3 项同步扩 projection

### 6.3 需要后续 BFF / Server 行为跟进的项

- `areaSqm`
  - create request validation
  - detail read projection
  - numeric mapping / formatting boundary
- `buildingTypeRemark`
  - create request passthrough
  - detail read projection
  - 与 `buildingType` 的共存校验
- `scheduleDetail`
  - create request passthrough
  - detail read projection
  - 与 `plannedStartAt` / `plannedEndAt` 的补充关系校验

## 7. Upload 绑定语义变化评估

- 本轮逐项裁定后，只有一项会直接触发 upload 语义变化：
  - `创建前附件主表单化`
- 其影响不是 UI 小改，而是：
  - upload init 是否仍要求现成 `projectId`
  - create command 是否要接收 confirmed `FileAsset` handoff
  - draft attachment 如何在 create success 后转正绑定到 `project`
  - `businessType` / `businessId` 是否需要新增 pre-create binding truth
- 当前正式结论：
  - 该项已被明确识别为 upload-binding-change candidate
  - 但不在本轮进入正式真源
  - Round B contract freeze 也不得顺手把它混进去

## 8. Stage Conclusion

- 当前正式结论：
  - Round B 可进入正式真源的字段仅限：
    - `areaSqm`
    - `buildingTypeRemark`
    - `scheduleDetail`
  - Round B 暂不进入正式真源的项为：
    - `预算区间`
    - `奖励金额`
    - `创建前附件主表单化`
- 当前阶段允许的下一步只应是：
  - 围绕上述 3 个 admitted fields 进入 contract freeze
- 当前阶段仍不允许：
  - 直接 author migration
  - 直接 author code
  - 顺手重开 pre-create attachment upload family
  - 越界冻结其他板块 richer 字段

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目发布 Round B` 真源归属。
  - 正式裁定 `areaSqm`、`buildingTypeRemark`、`scheduleDetail` 进入 Round B 正式字段。
  - 正式裁定 `预算区间`、`奖励金额`、`创建前附件主表单化` 暂不进入 Round B 正式真源。
  - 明确只有“创建前附件主表单化”会触发 upload binding truth 变化。
