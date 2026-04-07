---
owner: Codex 总控
status: frozen
purpose: Freeze the backend and BFF implementation boundary for project-location standardization only, limited to project create/detail and without widening any other board, path family, or implementation scope.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/02_backend/project_location_standardization_persistence_truth_addendum.md
  - docs/00_ssot/project_location_standardization_persistence_migration_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project.module.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/project/project.controller.ts
  - apps/bff/src/routes/project/project.module.ts
freeze_date_local: 2026-04-04
---

# 项目地点标准化 backend-BFF 实现边界冻结单

## 1. Scope

- 本冻结单只覆盖 `项目地点标准化 backend-BFF implementation freeze`。
- 本冻结单只允许围绕以下字段冻结实现边界：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- 本冻结单只服务于：
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
- 本冻结单不冻结：
  - 业务代码本体
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - `project/list`
  - workbench
  - Flutter / Admin
  - 地图、经纬度、行政区联动 UI
  - 搜索 index
  - 地域分类 projection

## 2. Upstream Freeze Intake

- 当前 standardized location 已冻结完成：
  - truth 边界
  - app-facing / server-facing contract
  - persistence truth
  - additive migration 合法边界
- 当前唯一准入的 standardized location implementation scope 是：
  - `province/city/district` 采用 `code + name`
  - `detailAddress` 保持自由文本
  - 只服务 `project create/detail`
  - 不扩 `project/list` / `workbench`
- 因此本轮 implementation freeze 的真实含义是：
  - 只给后续 Backend / BFF 提供最小施工边界
  - 不重新裁定 truth
  - 不重新裁定 contract
  - 不重新裁定 persistence
  - 不 author migration file

## 3. Canonical Truth Responsibility Split

- `code` 承担 canonical classification truth：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- `name` 承担 display truth：
  - `provinceName`
  - `cityName`
  - `districtName`
- `detailAddress` 承担自由文本补充：
  - 只服务展示与补充文本消费
  - 不承担分类真相

## 4. Backend Implementation Freeze

### 4.1 Backend 允许职责

- 后续 Backend 实现只允许完成以下职责：
  - 在 `public.project` 执行一轮已冻结范围内的 additive migration，增加：
    - `province_code`
    - `city_code`
    - `district_code`
  - 在 `ProjectEntity` 承接：
    - `provinceCode`
    - `cityCode`
    - `districtCode`
    并保持既有：
    - `provinceName`
    - `cityName`
    - `districtName`
    - `detailAddress`
  - 在 `POST /server/projects` 的 create 写入链路承接 `code + name + detailAddress`
  - 在 `GET /server/projects/{projectId}` 的 detail read 链路回读 `code + name + detailAddress`

### 4.2 Backend create 写入规则

- `provinceCode / provinceName`
  - 对新标准化 create truth 必须真实写入
- `cityCode / cityName`
  - 对新标准化 create truth 必须真实写入
- `districtCode / districtName`
  - 若单独提供区县层，则必须成对写入
  - 若未单独提供区县层，则两者同为 `NULL`
- `detailAddress`
  - 继续作为自由文本真实写入
- 后续 Backend 不得：
  - 把 `detailAddress` 解释成分类真相
  - 把 name-only 重新解释成唯一标准化真相

### 4.3 Backend detail 回读规则

- `GET /server/projects/{projectId}` 只允许按同名同义回读：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
- 历史数据兼容规则必须保持：
  - `provinceCode / cityCode / districtCode` 允许回读为 `null`
  - `provinceName / cityName / districtName / detailAddress` 保持既有值
- Backend 不允许：
  - 改名输出
  - 发明 second detail-only location model
  - 把 standardized location 扩到 `project/list` / workbench

### 4.4 Backend 明确禁止

- 不得借本轮改动：
  - forum / 消息 / Profile / 企业库 / 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - `project/list`
  - workbench
  - upload flow
  - 搜索 index
  - 地域分类 projection
  - 地图、经纬度、行政区联动实现
  - `project` 聚合全量 refactor

## 5. BFF Implementation Freeze

### 5.1 BFF 允许职责

- 后续 BFF 实现只允许完成以下职责：
  - 在 `POST /api/app/project/create` 透传：
    - `provinceCode`
    - `provinceName`
    - `cityCode`
    - `cityName`
    - `districtCode`
    - `districtName`
    - `detailAddress`
  - 在 `GET /api/app/project/detail` 整形并回读同名字段
  - 继续只承担：
    - auth envelope
    - controlled failure normalization
    - shaping

### 5.2 BFF 明确禁止

- `BFF` 不得为 standardized location 新增本地真相。
- `BFF` 不得：
  - 解释行政区标准源
  - synthesize classification truth
  - 新增本地状态机
  - 改写 upload truth
  - 扩到 `project/list`
  - 扩到 workbench
  - 扩到搜索 index 或地域分类 projection

## 6. Create / Detail Only Boundary

- standardized location 当前只进入：
  - `project/create`
  - `project/detail`
- 当前明确不进入：
  - `project/list`
  - workbench
- 原因正式冻结为：
  - 上游 truth / contract / persistence freeze 只要求 create 真写与 detail 真读
  - 当前没有任何已冻结义务要求 list/workbench 承担 standardized location projection
  - 若提前扩到 list/workbench，会无端扩大 `BFF` 与 `Server` 的投影面

## 7. Search / Classification Non-implementation Boundary

- 后续地域分类 / 搜索的上游真源已冻结为：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 但本轮实现边界明确不 author：
  - 搜索 index
  - 分类 projection
  - 搜索查询实现
  - 地区 facet 聚合实现

## 8. Allowed Change Surface

- 后续实现阶段允许改动面正式冻结为：
  - `apps/server/src/core/migrations/**`
  - `apps/server/src/modules/project/entities/project.entity.ts`
  - `apps/server/src/modules/project/project-write.service.ts`
  - `apps/server/src/modules/project/project-query.service.ts`
  - `apps/server/src/modules/project/project.presenter.ts`
  - `apps/server/src/modules/project/project.controller.ts`
  - `apps/server/src/modules/project/project.module.ts`
  - `apps/bff/src/routes/project/app-project.controller.ts`
  - `apps/bff/src/routes/project/project.service.ts`
  - `apps/bff/src/routes/project/project.controller.ts`
  - `apps/bff/src/routes/project/project.module.ts`
- 上述允许面只服务于：
  - standardized location create/detail binding
  - additive migration wiring
  - compile-required mechanical touch

## 9. Forbidden Change Surface

- 后续实现阶段明确不应触碰：
  - `apps/mobile/**`
  - `apps/admin/**`
  - `docs/**`
  - `apps/server/src/modules/upload/**`
  - forum 相关实现
  - `project/list` projection 扩面
  - workbench projection 扩面
  - 搜索 index
  - 地域分类 projection
  - 地图、经纬度、行政区联动 UI/实现

## 10. Stage Conclusion

- 当前结论：
  - `Go` for bounded Backend / BFF implementation for project location standardization only
  - `No-Go` for any wider project aggregate refactor
  - `No-Go` for `project/list` / workbench standardized location projection expansion
  - `No-Go` for search index or regional classification implementation
  - `No-Go` for any board outside the current project location standardization scope
- 本冻结单的真实含义是：
  - standardized location 的 backend / BFF 实现边界已正式冻结
  - 后续实现只允许围绕 `project create/detail` 的 `code + name + detailAddress` 闭环
  - 其他板块与其他投影面继续完全不得进入

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目地点标准化` backend-BFF implementation 边界。
  - 只放行 `project create/detail` 的 standardized location 实现面。
  - 明确 `project/list` / workbench / 搜索 index / 地域分类 projection 不在本轮。
