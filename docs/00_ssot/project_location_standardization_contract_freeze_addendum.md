---
owner: Codex 总控
status: frozen
purpose: Freeze the contract boundary for project-location standardization only, limited to project publish create/detail and the shared project read model.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目地点标准化 contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `项目地点标准化 contract freeze`。
- 本冻结单只服务于以下主线：
  - 项目发布
  - 项目展示
  - 地域分类
  - 搜索
- 本冻结单只冻结 project create/detail 所需的标准化地点 contract。
- 本冻结单不进入：
  - persistence freeze
  - migration freeze
  - backend / BFF / Flutter 实现
- 本冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 2. Contract Freeze Conclusion

- `province / city / district` 的 contract 正式采用 `code + name`。
- 当前冻结的 standardized location contract fields 是：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- 其中：
  - `provinceCode / cityCode / districtCode` 承担分类、筛选、聚合真相
  - `provinceName / cityName / districtName` 继续承担展示值
  - `detailAddress` 继续承担自由文本地址补充

## 3. Create / Detail Contract Boundary

### 3.1 `ProjectCreateRequest`

- `ProjectCreateRequest` 现正式冻结为：
  - `provinceCode` 必填
  - `provinceName` 必填
  - `cityCode` 必填
  - `cityName` 必填
  - `districtCode` 选填
  - `districtName` 选填
  - `detailAddress` 必填
- 当前 district 边界正式冻结为：
  - 若单独提供区县层，则必须按 `districtCode + districtName` 成对承载
  - 若当前未单独提供区县层，则 `districtCode / districtName` 可 omitted 或 `null`

### 3.2 `ProjectReadModel`

- `ProjectReadModel` 现正式冻结为可回读：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- `GET /api/app/project/detail` 与 `GET /server/projects/{projectId}` 必须在值已提交且已存储时回读同名字段。
- 当前共享 `ProjectReadModel` 仍继续服务 `project/list` 与 `project/detail`，但：
  - `project/detail` 是 standardized location round-trip owner
  - 当前 `project/list` 不要求承载这些 richer optional fields，可 omitted 或返回 `null`

## 4. Path And Schema Update Scope

- 本轮已更新的 schema：
  - `ProjectCreateRequest`
  - `ProjectReadModel`
- 本轮已更新 contract 语义的 path：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
- 当前不需要更新的 path / schema：
  - `GET /api/app/project/list`
  - workbench 相关 path
  - 任何 forum、消息、Profile、企业库、订单、合同、履约相关 contract

## 5. Mainline Dependency Boundary

- 项目发布：
  - 后续 create 提交必须承载 standardized location `code + name`
- 项目展示：
  - 展示面继续读 `provinceName / cityName / districtName / detailAddress`
- 地域分类：
  - 后续直接依赖 `provinceCode / cityCode / districtCode`
- 搜索：
  - 后续 filter / facet / 聚合依赖 `provinceCode / cityCode / districtCode`
  - `detailAddress` 只承担补充关键词文本，不承担地区主筛选真相

## 6. Compatibility Principle

- 现有 name-only contract 的兼容原则正式冻结为：
  - 不删除 `provinceName / cityName / districtName`
  - 在原有 name 字段上增补对应 code 字段
  - `name` 继续承担 display truth
  - `code` 新承担 canonical classification truth
- 当前正式禁止：
  - 继续把 name-only 解释成长期唯一标准化地点真源
  - 在本轮偷带地图、经纬度、行政区联动实现
  - 把地点标准化 contract 外溢到其他板块

## 7. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目地点标准化 persistence freeze` stage
  - `No-Go` for implementation by this file itself
- 本冻结单的真实含义是：
  - standardized location 的 app-facing / server-facing contract 已正式冻结
  - `code + name` 与 `detailAddress` 的边界已写死
  - 后续若继续推进，应进入 persistence freeze，而不是直接进入实现

## 8. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目地点标准化` contract。
  - 正式把 `province/city/district` 冻结为 `code + name`。
  - 正式确认 `detailAddress` 保持自由文本。
