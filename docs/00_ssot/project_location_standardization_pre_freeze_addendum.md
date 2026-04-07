---
owner: Codex 总控
status: frozen
purpose: Pre-freeze the canonical-truth direction, scope boundary, and downstream impact of project-location standardization before entering truth, contract, persistence, or implementation stages.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_address_range_persistence_migration_unlock_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目地点标准化预冻结单

## 1. Scope

- 本预冻结单只覆盖 `项目地点标准化` 议题。
- 本预冻结单只服务于以下主线：
  - 项目发布
  - 项目展示
  - 地域分类
  - 搜索
- 本预冻结单不进入：
  - contract freeze
  - persistence freeze
  - migration freeze
  - backend / BFF / Flutter 实现
- 本预冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 2. Business Necessity

- 当前项目发布已存在以下地址字段：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
- 当前填报模式仍带有自由输入属性，因此会产生：
  - `四川` / `四川省`
  - `成都` / `成都市`
  - `高新` / `高新区`
  这类写法漂移。
- 一旦后续进入：
  - 项目展示
  - 地域分类
  - 搜索
  name-only 且不受约束的填报会直接污染：
  - 地区聚合
  - facet 分类
  - 搜索过滤
  - 同城或同区域展示一致性
- 因此本议题的必要性已经正式认定为：
  - `province / city / district` 必须进入标准化真源治理
  - `detailAddress` 不应被错误枚举化

## 3. Standardized vs Free-text Boundary

### 3.1 必须标准化的字段

- `province`
- `city`
- `district`

正式预冻结理由：

- 这三个字段承担的是地域归属真义，而不是自由描述。
- 它们会直接服务：
  - 项目展示中的地点标签一致性
  - 地域分类聚合
  - 搜索筛选与归并
- 若这三层不标准化，后续所有地区主线都会被脏数据污染。

### 3.2 保持自由文本的字段

- `detailAddress`

正式预冻结理由：

- `detailAddress` 是具体落地地址补充，不是行政区划主真相。
- 它天然需要人工输入，存在楼栋、园区、展馆、路名、门牌等开放文本特征。
- 将其枚举化既不现实，也会损害真实填写能力。

## 4. Canonical Truth Shape Comparison

### 4.1 方案一：`name-only`

- 形态：
  - `provinceName`
  - `cityName`
  - `districtName`
- 优点：
  - 对当前 UI 侵入最小
  - 视觉显示直接可用
  - 早期 create/detail 接口表面上更轻
- 缺点：
  - 无法稳定消除简称 / 全称 / 别名 / 多写法
  - 无法稳定处理同名区域冲突
  - 不利于地域分类与搜索做可靠聚合
  - 后续一旦引入标准化 code，仍要再做一次兼容迁移

### 4.2 方案二：`code + name`

- 形态：
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `districtCode + districtName`
- 优点：
  - `code` 能承载稳定、可聚合、可筛选的 canonical truth
  - `name` 能继续服务展示层直读
  - 能降低简称 / 全称 / 同名冲突带来的真值歧义
  - 更适合后续地域分类、搜索、聚合与排序
- 缺点：
  - 后续 truth / contract / persistence / consumption 都要增加字段与兼容设计
  - 需要一条稳定的行政区标准源作为上游依赖

## 5. Recommended Direction

- 当前正式预冻结结论：
  - `province / city / district` 的标准化 canonical truth 方案优先采用 `code + name`
  - `detailAddress` 继续保持自由文本
- 当前不把该结论偷换为：
  - schema 已新增
  - contract 已冻结
  - persistence 已冻结
  - implementation 已开始

### 5.1 推荐理由

- `code + name` 比 `name-only` 更能服务：
  - 项目展示的稳定地域标签
  - 地域分类的正确归桶
  - 搜索的精确过滤与聚合
- 仅使用 `name-only` 会把标准化工作延后到更靠后阶段，届时改动成本更高。
- 因此本轮只预冻结：
  - 方案优先级
  - 主线依赖边界
  - 后续阶段顺序

## 6. Existing Name-field Compatibility Principle

- 如果后续 truth freeze 正式采用 `code + name`，当前已存在的：
  - `provinceName`
  - `cityName`
  - `districtName`
  不应被废弃，也不应被偷偷改义。
- 兼容原则预冻结为：
  - `provinceName / cityName / districtName` 继续承担 human-readable display value
  - 新增的 `provinceCode / cityCode / districtCode` 才承担标准化 canonical classification truth
  - 旧 name 字段不得单独再被视为长期唯一 canonical truth
- 当前不允许直接做的事：
  - 在未冻结 code 字段前，把现有 `provinceName / cityName / districtName` 强行解释成“已标准化”
  - 在未冻结标准源前，让前端私带一套地区真相

## 7. Mainline Impact Boundary

### 7.1 项目发布

- 项目发布需要的不是任意文本地点，而是可持续进入后续展示与检索主线的标准化地点归属。
- 这意味着后续 publish truth / contract / UI 都必须为 `province / city / district` 标准化留出空间。

### 7.2 项目展示

- 项目展示需要稳定展示：
  - 省
  - 市
  - 区县
  - 详细地址
- 其中：
  - 行政区展示应依赖标准化 `code + name`
  - `detailAddress` 继续只是补充文本

### 7.3 地域分类

- 地域分类必须依赖标准化 `province / city / district` truth。
- 仅靠自由 name 文本无法稳定做：
  - 地区聚合
  - 层级分类
  - 同区域项目归桶

### 7.4 搜索

- 搜索必须依赖标准化地点 truth 做：
  - filter
  - facet
  - 命中归类
- `detailAddress` 只适合补充关键词搜索，不适合作为地区主筛选真相。

## 8. Explicit Non-goals

- 本预冻结单不直接 author：
  - `provinceCode / cityCode / districtCode` schema
  - contract patch
  - persistence column
  - migration file
  - 前端地区选择器联动实现
  - 搜索实现
- 本预冻结单不把地点标准化外溢到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 9. Next Required Stages

- 后续若继续推进，本议题必须按以下顺序进入受控阶段：
  1. location standardization truth freeze
  2. contract freeze
  3. persistence freeze
  4. frontend consumption freeze
- 各阶段职责预冻结为：
  - truth freeze：正式决定 `code + name` 字段面与标准源边界
  - contract freeze：决定 create/detail 的 app-facing / server-facing schema
  - persistence freeze：决定 `public.project` 承载与兼容策略
  - frontend consumption freeze：决定选择器、展示、分类和搜索消费边界

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目地点标准化 truth freeze` stage
  - `No-Go` for skipping directly into contract freeze
  - `No-Go` for skipping directly into persistence freeze
  - `No-Go` for implementation by this file itself
- 本预冻结单的真实含义是：
  - 项目地点标准化的真源方向已经足够清楚
  - 标准化字段与非标准化字段已经被明确分开
  - `code + name` 已被正式确定为优先方案
  - 但后续仍必须再经过独立的 truth / contract / persistence / consumption 冻结轮

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目地点标准化` 预冻结边界。
  - 明确 `province / city / district` 必须标准化，`detailAddress` 保持自由文本。
  - 明确 `code + name` 为优先 canonical truth 方案。
