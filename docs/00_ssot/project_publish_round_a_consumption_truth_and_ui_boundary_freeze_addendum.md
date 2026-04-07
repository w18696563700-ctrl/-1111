---
owner: Codex 总控
status: frozen
purpose: Freeze the Round A consumption-truth and UI boundary for project publish only, limited to the current create/detail field set and without widening to Round B or other boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_address_range_persistence_migration_unlock_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
freeze_date_local: 2026-04-04
---

# 项目发布 Round A 消费真源与 UI 边界冻结单

## 1. Scope

- 本冻结单只覆盖 `项目发布 Round A` 的消费真源与 UI 边界。
- 本冻结单只服务于：
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - 当前 `POST /api/app/project/create`
  - 当前 `GET /api/app/project/detail`
- 本冻结单不扩到：
  - Round B
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
- 本冻结单不 author 业务代码，不 author migration，不改写其他板块 contract。

## 2. Round A 真源总原则

- Round A 前端只能消费当前已冻结的 create/detail 真源字段，不得本地发明 second truth。
- create 与 detail 命名必须一致，不允许 create 一个名字、detail 另起一套展示字段名。
- 地址与范围字段只能来自已冻结的真实字段，不允许再塞进 `description` / `summary` 冒充。
- `project/list` 与 workbench 当前不要求承载地址与范围 7 字段；Round A 本冻结单只裁定 create/detail。

## 3. Round A 页面承接边界

- `project/create` 当前允许承接：
  - 基础信息
  - 地址与范围
  - 补充说明
  - 当前正式附件链的继续承接入口
- `project/detail` 当前允许承接：
  - 共享 `ProjectReadModel`
  - 地址与范围真实回读
  - 当前项目附件展示承接
- `project/create` 与 `project/detail` 当前都不得扩成：
  - Round B richer project master-data form
  - 支付 / 发布状态机
  - 履约主控台
  - 第二套项目类型真相

## 4. Round A 展示规则总则

- 能直接映射到真值字段的 UI 项，必须按真值字段命名和提交。
- 不能直接映射到真值字段的 UI 优化项，只能作为消费层收口，不得升格为业务真相。
- 凡是当前后端未冻结、detail 不能稳定回读、create 不能稳定提交的字段，Round A 默认 `不展示`。
- 只有总控单独特批，才允许以“未开放能力提示”形式出现；若无特批，前端不得自行加“仅提示”占位。

## 5. Round A 真实字段承接范围

- Round A 当前正式冻结的 create/detail 真值字段为：
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
- 其中：
  - `description`、`districtName`、`plannedStartAt`、`plannedEndAt` 当前可为空
  - `plannedStartAt` / `plannedEndAt` 真值格式固定为 `YYYY-MM-DD`
  - detail 回读时若值不存在，按 `null` / 未回传处理，不允许前端本地补默认值

## 6. 第 6 节真实字段映射最终版

| 产品显示项 | 真值字段 | Round A 映射口径 |
|---|---|---|
| 项目名称 | `title` | 1:1 直接映射。create 提交 `title`，detail 原样回读 `title`。 |
| 项目类型 | `buildingType` | 不是 8 个展示项到真值字段的一一持久化；Round A 只允许把标准化展示项收口到既有 `buildingType` 真值，详见第 7 节。detail 只以服务端回传的 `buildingType` 为准。 |
| 预算金额 | `budgetAmount` | 真值字段是数值型 `budgetAmount`。UI 可带货币文案或输入格式收口，但提交时必须归一到数值，不得提交展示文本。detail 仍按 `budgetAmount` 真值回读。 |
| 补充说明 | `description` | 1:1 直接映射，当前为选填。不得把地址、范围、时间塞进 `description` 冒充结构化字段。 |
| 省 | `provinceName` | 1:1 直接映射。create/detail 同名同义，不允许与 `detailAddress` 混写。 |
| 市 | `cityName` | 1:1 直接映射。create/detail 同名同义，不允许本地改成第二套城市字段名。 |
| 区/县 | `districtName` | 1:1 直接映射，当前可为空。未填写时 create 可 omitted / `null`，detail 回读为空时显示当前未提供。 |
| 详细地址 | `detailAddress` | 1:1 直接映射。必须单独承载，不得拼回 `description`。 |
| 范围说明 | `scopeSummary` | 1:1 直接映射。必须单独承载，不得拼回 `summary`。 |
| 计划开始日期 | `plannedStartAt` | 真值字段为 `plannedStartAt`，contract 格式固定 `YYYY-MM-DD`。UI 可显示为本地日期文案，但提交与回读口径都必须回到 `YYYY-MM-DD` 真值。 |
| 计划结束日期 | `plannedEndAt` | 真值字段为 `plannedEndAt`，contract 格式固定 `YYYY-MM-DD`。UI 可显示为本地日期文案，但提交与回读口径都必须回到 `YYYY-MM-DD` 真值。 |

## 7. 项目类型展示项 -> buildingType 真值映射冻结

### 7.1 Round A 标准化选择器定位

- Round A 的“项目类型”标准化选择器，只允许作为消费层收口。
- 当前 `buildingType` 真值仍是粗分类字段，本轮不扩真实字段，不新增 `projectSubtype`、`sceneType`、`activityType` 等 second truth。
- 因此 Round A 的标准化展示选择，不等于后端已拥有同粒度真值。

### 7.2 冻结映射表

| 展示值 | 提交到真值的 `buildingType` | Round A 说明 |
|---|---|---|
| 会展 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 展厅 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 商业活动 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 会议 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 路演 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 美陈 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 纯安装 | `exhibition` | 当前归并到展览项目粗分类真值。 |
| 其他 | `exhibition` | 当前归并到展览项目粗分类真值。 |

### 7.3 强边界

- Round A 不允许因为引入标准化选择器，就把上述 8 个展示值误写成新的后端真值枚举。
- create 时前端允许把用户所选展示值规范化后提交 `buildingType=exhibition`。
- detail 时前端只能展示服务端回传的 `buildingType` 所对应的粗分类标签，不得假装服务端持久化了用户当初选择的细分展示值。
- 若后续需要把“会展 / 展厅 / 商业活动 / 会议 / 路演 / 美陈 / 纯安装 / 其他”升级为真实业务真相，必须进入 Round B+ 另行冻结 contract / backend truth / persistence。

## 8. 省 / 市 / 区县联动 Round A 许可边界最终版

- Round A 允许：
  - 一排布局
  - 自动换行
  - 选择器外观收口
  - 输入框与选择器样式统一
  - 对 `provinceName` / `cityName` / `districtName` 的受控空值提示与必填提示
- Round A 不允许：
  - 真正的省 / 市 / 区县级联真值联动
  - 前端私带一整套行政区真相
  - 本地维护未冻结的地区 code / parent-child 树并把它解释成权威来源
  - 借地区联动扩出地理编码、经纬度、地图选点
- 当前正式冻结结论：
  - Round A 只允许布局与交互收口
  - 不允许前端私带一套地区真相来做真正联动
- 这意味着：
  - `provinceName` / `cityName` / `districtName` 当前可分别承接输入或选择
  - 但前端不得宣称自己具备 authoritative 行政区联动能力
  - 若未来要做真正联动，必须先冻结稳定行政区真源与 contract

## 9. Round B 字段在 Round A 的默认展示策略最终版

### 9.1 统一规则

- Round B 字段在 Round A 的默认策略统一冻结为：
  - `不展示`
- 理由：
  - 当前这些字段既未完成 create/detail 真值冻结，也未形成稳定回读与提交链
  - 若以“仅提示”形式提前露出，容易让用户误判能力已开放，形成假功能或伪承诺
- 只有总控单独特批，才允许以“未开放能力提示”出现；无特批时前端不得自行展示。

### 9.2 当前默认不展示项

- 项目面积
- 类型备注
- 预算区间
- 奖励金额
- 详细时间
- 创建前附件主表单化

## 10. Round A 前端施工边界结论

- Round A 前端 Agent 当前可以按本冻结单施工的内容，仅限：
  - 已冻结字段的 create/detail UI 承接
  - 字段命名与展示文案收口
  - 项目类型标准化选择器的消费层归一
  - 地址与范围区块的布局与交互收口
- Round A 前端 Agent 当前不得自行扩出的内容，包括：
  - Round B richer 字段
  - 真实地区联动
  - 第二套项目类型真相
  - 任何把未冻结字段塞进 `description` / `summary` 的伪实现

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版正式冻结。
  - 补齐第 6 节全部真实字段映射。
  - 冻结“项目类型展示项 -> buildingType 真值”映射。
  - 冻结“省 / 市 / 区县联动”在 Round A 的许可边界。
  - 冻结 Round B 字段在 Round A 的默认展示策略为 `不展示`。
