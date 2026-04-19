---
owner: Codex 总控
status: active
purpose: Freeze the contract boundary and compatibility ruling for the project-showcase filter and project-create-form refactor object, so backend truth and persistence authoring can proceed on one stable meaning for filters, dual-field create input, expiry trimming, and historical compatibility.
layer: L0 SSOT
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_dispatch_bundle_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-11
---

# 《项目展示筛选与创建表单重构 contract freeze / compatibility ruling》

## 1. Scope

- 本冻结单只覆盖：
  - `项目展示筛选与创建表单重构`
- 本冻结单只服务于：
  - `project/list` 查询参数
  - `ProjectShowcaseListItemReadModel`
  - `ProjectReadModel`
  - `ProjectCreateRequest`
  - 过期项目的公域 read eligibility contract 语义
  - 历史 `title` 项目与旧 create client 的兼容
- 本冻结单不进入：
  - persistence / migration
  - backend / BFF / Flutter 实现
  - 独立 `visibility/displayStatus` carrier
  - 项目审核状态机

## 2. Contract Freeze Conclusion

- 本轮 contract freeze 的正式结论不是 `no-op`。
- 本轮正式允许且必须发生的 contract 变化只限于：
  1. `GET /api/app/project/list` 增加筛选参数
  2. `ProjectShowcaseListItemReadModel` 增加双字段展示身份与时间承接
  3. `ProjectReadModel` 增加双字段展示身份承接
  4. `ProjectCreateRequest` 从单一 `title` 输入升级为双字段优先、`title` 兼容
  5. `project/list` 与公域 `project/detail` 的过期 read eligibility 语义收口
- 本轮正式不允许：
  - 新增 path family
  - 新增 preview-only schema
  - 新增 visibility-only schema
  - 新增 review state machine carrier
  - 扩到附件公开、交易后链、私域 richer 状态

## 3. `project/list` Query Contract Freeze

### 3.1 新增可选查询参数

- `GET /api/app/project/list` 当前正式新增以下可选 query：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`

### 3.2 默认城市上下文 contract 语义

- 当前正式冻结为：
  - 当 `provinceCode / cityCode` 未显式提供时，
    `project/list` 允许按既有“当前城市上下文” carrier 解析 effective city。
- 当前默认优先级正式冻结为：
  1. 手动选择的当前城市
  2. 当前定位/当前城市上下文
  3. 全国兜底
- 当前正式不新增：
  - `cityContextSource`
  - `nationalMode`
  - 独立 location source schema

### 3.3 当前城市筛选边界

- 当前城市筛选 contract 只允许依赖：
  - `provinceCode`
  - `cityCode`
- 当前正式禁止：
  - `districtCode` 进入本轮筛选 contract
  - `detailAddress` 进入主筛选 contract

### 3.4 面积档位 contract

- `areaBucket` 当前正式冻结为字符串枚举：
  - `9_sqm`
  - `18_sqm`
  - `27_sqm`
  - `36_sqm`
  - `54_sqm`
  - `72_sqm`
  - `81_sqm`
  - `90_sqm`
  - `108_sqm`
  - `gt_108_sqm`
  - `custom_sqm`

### 3.5 金额档位 contract

- `budgetBucket` 当前正式冻结为字符串枚举：
  - `0_2w`
  - `2_4w`
  - `4_6w`
  - `6_8w`
  - `8_10w`
  - `10_15w`
  - `15_20w`
  - `20w_plus`

### 3.6 过期项目列表语义

- `project/list` 当前正式冻结为：
  - 默认不返回已过期公域项目
- 这里的“已过期”正式依赖：
  - `plannedEndAt < 当前日期`
- 当前正式不新增：
  - `includeExpired`
  - `expiredOnly`
  - `visibility`
  - `displayStatus`

## 4. `ProjectShowcaseListItemReadModel` Contract Freeze

### 4.1 当前必须新增的字段

- `ProjectShowcaseListItemReadModel` 当前正式新增：
  - `exhibitionName`
  - `brandName`
  - `plannedStartAt`
  - `plannedEndAt`

### 4.2 当前保留的兼容字段

- `title` 当前继续保留为 required compatibility field。
- 当前正式冻结为：
  - 当 `exhibitionName` 与 `brandName` 都存在时，
    `title` 只承担兼容展示 carrier
  - 新消费层不得再把 `title` 视为唯一主展示身份

### 4.3 当前列表卡片主展示语义

- 当前列表卡片应优先消费：
  - `exhibitionName`
  - `brandName`
  - `budgetAmount`
  - `areaSqm`
  - `provinceName/cityName`
  - `plannedStartAt/plannedEndAt`
- `title` 只作为兼容 fallback：
  - 当双字段缺失时可继续展示

## 5. `ProjectReadModel` Contract Freeze

### 5.1 当前必须新增的字段

- `ProjectReadModel` 当前正式新增：
  - `exhibitionName`
  - `brandName`

### 5.2 时间字段边界

- `plannedStartAt`
- `plannedEndAt`
  当前已在既有 detail contract 中存在，
  本轮不新增第二套时间字段。

### 5.3 详情兼容语义

- 当前 detail 正式冻结为：
  - 当双字段存在时，详情页应优先按：
    - 展会
    - 品牌
    承接主信息
  - `title` 继续只承担兼容 fallback

## 6. `ProjectCreateRequest` Contract Freeze

### 6.1 双字段优先输入

- `ProjectCreateRequest` 当前正式新增：
  - `exhibitionName`
  - `brandName`

### 6.2 `title` 的兼容角色

- `title` 当前不立即删除。
- 当前正式兼容裁决如下：
  1. 新 client：
     - 应提交 `exhibitionName + brandName`
  2. 兼容模式：
     - 旧 client 仍可只提交 `title`
  3. 过渡期内：
     - `title` 继续保留在 request schema 中，作为 legacy compatibility carrier

### 6.3 新旧模式的正式约束

- 当前 create request 正式允许两种模式：
  - `dual-field mode`
    - `exhibitionName` 非空
    - `brandName` 非空
    - `title` 可由服务端或 BFF 兼容生成
  - `legacy-title mode`
    - 只提交 `title`
- 当前正式禁止：
  - 三者都空
  - 只提交 `exhibitionName`
  - 只提交 `brandName`

### 6.4 当前其他字段维持不变

- 本轮不改变：
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - standardized location `code + name`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`

## 7. 过期项目公域 detail Compatibility Ruling

- 当前 `GET /api/app/project/detail` 仍是共享 read path。
- 但本轮正式冻结为：
  - 当该 path 被用作公域 showcase detail continuation 时，
    过期项目允许返回受控 unavailable 语义
- 当前正式不影响：
  - `my/projects`
  - owner 私域承接
- 当前正式禁止：
  - 把这条 detail trimming 语义误写成 persisted visibility 变更

## 8. Historical Compatibility Ruling

### 8.1 历史项目读取兼容

- 历史项目若只具备：
  - `title`
  而没有：
  - `exhibitionName`
  - `brandName`
  仍必须继续支持：
  - `project/list`
  - `project/detail`
  - 与 `my/projects` 的共享 publicProject 读取

### 8.2 历史项目筛选兼容

- 城市、面积、金额筛选当前不依赖：
  - `title`
  - `exhibitionName`
  - `brandName`
- 因此历史项目只要现有：
  - `provinceCode / cityCode`
  - `areaSqm`
  - `budgetAmount`
  真值存在，就必须继续可被筛选。

### 8.3 旧 client 兼容

- 旧 create client 在过渡期内继续允许走：
  - `legacy-title mode`
- 当前正式不允许：
  - 因为双字段升级而直接打断旧 create 请求

## 9. `openapi.yaml` 更新范围裁决

### 9.1 需要更新的 path

- `GET /api/app/project/list`
- `POST /api/app/project/create`
- `GET /api/app/project/detail`
- `GET /server/projects`
- `POST /server/projects`
- `GET /server/projects/{projectId}`

### 9.2 需要更新的 schema

- `ProjectCreateRequest`
- `ProjectShowcaseListItemReadModel`
- `ProjectReadModel`
- 新增枚举型 query 语义：
  - `areaBucket`
  - `budgetBucket`

### 9.3 当前明确 no-op 的对象

- `GET /api/app/my/projects`
- `GET /api/app/my/projects/{projectId}`
- `GET /api/app/exhibition/workbench`
- 正式附件列表
- 独立 `visibility/displayStatus`
- review state machine 家族

## 10. Explicit Contract Guardrails

- 不得把这轮 contract 变化偷写成“纯消费层优化”
- 不得在 contract 中引入企业所在地筛选
- 不得引入新的 persisted visibility state
- 不得引入新的 review-before-display 状态机
- 不得借双字段升级扩到奖励金额、单位平米金额、附件公开

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目展示筛选与创建表单重构 backend truth / persistence freeze` stage
  - `No-Go` for direct implementation
  - `No-Go` for release-prep
  - `No-Go` for production release

## 12. Next Unique Action

- 下一步唯一动作：
  - 输出《项目展示筛选与创建表单重构 backend truth / persistence freeze》
