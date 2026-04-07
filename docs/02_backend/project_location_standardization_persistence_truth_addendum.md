---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth and persistence binding for standardized project location only, limited to project publish, project display, regional classification, and search dependencies.
layer: L3 Backend
decision_date_local: 2026-04-04
inputs_canonical:
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 项目地点标准化后端真值与持久化冻结单

## 1. Scope

- 本冻结单只覆盖 `项目地点标准化 persistence freeze`。
- 本冻结单只服务于以下主线：
  - 项目发布
  - 项目展示
  - 地域分类
  - 搜索
- 本冻结单只冻结 `project` 聚合中的 standardized location persistence truth。
- 本冻结单不冻结：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - backend / BFF / Flutter 实现
  - 搜索索引实现
  - 地图、经纬度、行政区联动实现

## 2. Canonical Persistence Ownership

- `Server.project` 仍是 standardized location 的唯一 business truth owner。
- `public.project` 是 standardized location 当前唯一允许承载的 relational persistence carrier。
- `province / city / district` 继续按 `code + name` 承载：
  - `code` = canonical classification truth
  - `name` = display truth
- `detailAddress` 继续是自由文本补充，不承担标准化分类真相。

## 3. Canonical Persistence Binding

| app-facing field | persistence column | DB type | nullable | persistence meaning |
|---|---|---|---|---|
| `provinceCode` | `province_code` | `text` | `NULL` | canonical province classification truth |
| `provinceName` | `province_name` | `text` | `NOT NULL` | province display truth |
| `cityCode` | `city_code` | `text` | `NULL` | canonical city classification truth |
| `cityName` | `city_name` | `text` | `NOT NULL` | city display truth |
| `districtCode` | `district_code` | `text` | `NULL` | canonical district / county classification truth |
| `districtName` | `district_name` | `text` | `NULL` | district / county display truth |
| `detailAddress` | `detail_address` | `text` | `NOT NULL` | free-text detailed address supplement |

## 4. Field-level Freeze Result

### 4.1 `provinceCode`

- 进入 `public.project`。
- 列名冻结为 `province_code`。
- DB 类型冻结为 `text`。
- 当前 DB 层允许 `NULL`，仅用于历史兼容。
- 对新标准化 create truth 的要求仍然是：
  - app-facing contract 必填
  - 新写入不得省略
- 该字段是后续地域分类 / 搜索 / 聚合的 canonical province input。

### 4.2 `provinceName`

- 进入 `public.project`。
- 列名冻结为 `province_name`。
- DB 类型冻结为 `text`。
- `NOT NULL`。
- 继续承担 province display truth，不改写为 classification truth。

### 4.3 `cityCode`

- 进入 `public.project`。
- 列名冻结为 `city_code`。
- DB 类型冻结为 `text`。
- 当前 DB 层允许 `NULL`，仅用于历史兼容。
- 对新标准化 create truth 的要求仍然是：
  - app-facing contract 必填
  - 新写入不得省略
- 该字段是后续地域分类 / 搜索 / 聚合的 canonical city input。

### 4.4 `cityName`

- 进入 `public.project`。
- 列名冻结为 `city_name`。
- DB 类型冻结为 `text`。
- `NOT NULL`。
- 继续承担 city display truth，不改写为 classification truth。

### 4.5 `districtCode`

- 进入 `public.project`。
- 列名冻结为 `district_code`。
- DB 类型冻结为 `text`。
- `NULL`。
- 当 district 层未单独提供时，写 `NULL`。
- 当 district 层单独提供时，必须与 `district_name` 同时存在。

### 4.6 `districtName`

- 进入 `public.project`。
- 列名冻结为 `district_name`。
- DB 类型冻结为 `text`。
- `NULL`。
- 当 district 层未单独提供时，写 `NULL`。
- 当 district 层单独提供时，必须与 `district_code` 同时存在。

### 4.7 `detailAddress`

- 进入 `public.project`。
- 列名冻结为 `detail_address`。
- DB 类型冻结为 `text`。
- `NOT NULL`。
- 继续承担自由文本地址补充。
- 不承担：
  - 地域分类主真相
  - 省市区筛选主真相

## 5. District Pair Rule

- `district_code` 与 `district_name` 的 DB 层语义正式冻结为 paired nullable carrier：
  - 要么同时为 `NULL`
  - 要么同时为非 `NULL`
- 本冻结单只冻结 paired-nullability 语义，不 author 实际 DB constraint 写法。

## 6. Create / Detail Persistence Rule

- `project/create` 必须为新标准化数据真实写入：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- `project/detail` 必须按同名语义真实回读这些字段。
- `code` 回读后继续承担：
  - 分类
  - 筛选
  - 聚合输入
- `name` 回读后继续承担：
  - 展示值
- `detailAddress` 回读后继续承担：
  - 补充文本展示

## 7. Old-data Compatibility Freeze

- 历史 `project` rows 可能存在以下情况：
  - 只有 `province_name / city_name / district_name / detail_address`
  - 还没有 `province_code / city_code / district_code`
- 旧数据兼容策略正式冻结为：
  - additive migration 后，历史行允许 `province_code / city_code / district_code` 保持 `NULL`
  - 旧项目 detail 回读时，code 字段允许返回 `null`
  - 旧项目的 `provinceName / cityName / districtName / detailAddress` 继续按既有值回读
- 本轮不要求：
  - 一次性回填历史 code
  - 本轮 author 历史标准化修复任务

## 8. Projection Boundary Freeze

- `project/list` 当前不要求承载：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- workbench 当前不要求承载上述 standardized location fields。
- 但后续地域分类 / 搜索若需要 projection 或 index，唯一允许依赖的上游真源正式冻结为：
  - `province_code`
  - `city_code`
  - `district_code`
- 本冻结单不进入这些 projection / index 的实现。

## 9. Explicit Non-goals

- 不把地点标准化外溢到其他板块
- 不 author 搜索索引
- 不 author 地图、经纬度、行政区联动
- 不 author backend / BFF / Flutter 代码
- 不改变 `project/list` / workbench 当前的非承载边界

## 10. Stage Conclusion

- 当前结论：
  - standardized location persistence truth 已足够清楚
  - `public.project` 是唯一允许的 carrier
  - 后续只需在受控实现阶段补齐对应 entity / create-detail binding

