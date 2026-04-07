---
owner: Codex 总控
status: frozen
purpose: Formally freeze the canonical truth model, compatibility principle, and downstream dependency boundary for project-location standardization, limited to project publish, project display, regional classification, and search.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_location_standardization_pre_freeze_addendum.md
freeze_date_local: 2026-04-04
---

# 项目地点标准化真源冻结单

## 1. Scope

- 本冻结单只覆盖 `项目地点标准化 truth freeze`。
- 本冻结单只服务于以下主线：
  - 项目发布
  - 项目展示
  - 地域分类
  - 搜索
- 本冻结单不进入：
  - contract freeze
  - persistence freeze
  - migration freeze
  - backend / BFF / Flutter 实现
- 本冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 2. Truth Freeze Conclusion

- `province / city / district` 正式进入标准化真源。
- `detailAddress` 正式保持自由文本。
- 项目地点标准化的 canonical truth 正式采用 `code + name` 方案，而不是 `name-only`。
- 当前正式冻结的标准化真源形态是：
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `districtCode + districtName`

## 3. Canonical Truth Meaning

### 3.1 `code` 承担的真义

- `provinceCode / cityCode / districtCode` 是标准化地点真源中的 canonical classification truth。
- `code` 负责承载：
  - 稳定地域身份
  - 分类归桶
  - 搜索筛选
  - 聚合与排序
- 当前正式禁止把自由文本 name 当作长期唯一 canonical classification truth。

### 3.2 `name` 承担的真义

- `provinceName / cityName / districtName` 是 human-readable display truth。
- `name` 负责承载：
  - 项目展示直读
  - 面向用户的可见地点文本
  - 与标准化 code 配对的人类可读值
- `name` 不再单独承担长期唯一 canonical classification truth。

## 4. `detailAddress` Boundary Freeze

- `detailAddress` 继续保持自由文本。
- 正式冻结理由：
  - 它是具体落地地址补充，而不是行政区主真相
  - 它天然包含楼栋、园区、展馆、路名、门牌等开放文本
  - 它不适合进入枚举化地区层级真源
- `detailAddress` 允许服务：
  - 项目详情补充展示
  - 补充关键词搜索
- `detailAddress` 不承担：
  - 地域分类主真相
  - 省市区筛选主真相

## 5. Mainline Dependency Boundary

### 5.1 项目发布

- 项目发布后续必须提交可进入标准化链路的地点真相，而不是仅提交任意自由 name 文本。
- 这意味着后续 publish truth / contract / consumption 必须围绕：
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `districtCode + districtName`
  进行受控冻结。

### 5.2 项目展示

- 项目展示必须稳定展示：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
- 其中：
  - 行政区展示依赖标准化 `code + name`
  - `detailAddress` 继续只是补充文本

### 5.3 地域分类

- 地域分类必须直接依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 原因是：
  - code 才能稳定承载归桶和层级关系
  - 单靠自由 name 文本无法可靠分类

### 5.4 搜索

- 搜索必须依赖标准化地点真源做：
  - filter
  - facet
  - 命中归类
- 当前冻结为：
  - `code` 是地区主筛选真相
  - `name` 是展示与可读搜索辅助值
  - `detailAddress` 只承担补充关键词搜索，不承担地区主筛选真相

## 6. Compatibility Principle

- 当前已存在的：
  - `provinceName`
  - `cityName`
  - `districtName`
  必须与未来 `code + name` 方案兼容，不得被偷偷废弃，也不得被偷偷改义。
- 正式冻结的兼容原则是：
  - `provinceName / cityName / districtName` 保留为 display truth
  - 新增的 `provinceCode / cityCode / districtCode` 才承载标准化 canonical classification truth
  - 旧 name 字段不得继续单独充当长期唯一真源
- 当前正式禁止：
  - 在未进入后续 contract freeze 前，直接补写 schema
  - 在未进入后续 persistence freeze 前，直接补写列或迁移
  - 在未进入实现轮前，让前端私带一套地区真相

## 7. Explicit Non-goals

- 本冻结单不直接 author：
  - contract 字段清单
  - persistence column
  - migration 文件
  - 前端联动选择器实现
  - 搜索实现
- 本冻结单不把地点标准化外溢到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目地点标准化 contract freeze` stage
  - `No-Go` for skipping directly into persistence freeze
  - `No-Go` for implementation by this file itself
- 本冻结单的真实含义是：
  - 地点标准化真源方案已经正式冻结
  - 标准化字段与自由文本字段边界已经写死
  - 发布 / 展示 / 地域分类 / 搜索的依赖边界已经写清
  - 后续若继续推进，应先进入 contract freeze，而不是直接进入 persistence 或实现

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目地点标准化` 真源方案。
  - 正式确认 `province / city / district` 进入标准化真源。
  - 正式确认 `code + name` 为 canonical truth 方案。
  - 正式确认 `detailAddress` 保持自由文本。
