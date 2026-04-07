---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter App consumption boundary for project-location standardization only, limited to project create/detail and without widening any other board or implementation scope.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/02_backend/project_location_standardization_persistence_truth_addendum.md
  - docs/00_ssot/project_location_standardization_persistence_migration_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_backend_bff_implementation_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目地点标准化前端消费冻结单

## 1. Scope

- 本冻结单只覆盖 `项目地点标准化 frontend consumption freeze`。
- 本冻结单只服务于以下主线：
  - 项目发布
  - 项目展示
  - 地域分类
  - 搜索
- 本冻结单只冻结 Flutter App 的：
  - create 页字段承接边界
  - detail 页字段展示边界
  - standardized location 输入边界
  - list / workbench 非承载边界
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
  - 行政区联动具体实现
  - 搜索界面实现
  - 地域分类实现
  - 地图 / 经纬度
- 本冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 2. Frontend Consumption Conclusion

- Flutter 后续消费必须以 standardized location `code + name` 为标准化 carrier：
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `districtCode + districtName`
- `detailAddress` 继续作为自由文本消费。
- 当前 standardized location 只服务：
  - `project/create`
  - `project/detail`
- 当前不扩：
  - `project/list`
  - workbench

## 3. Create Page Consumption Boundary

### 3.1 必须承接的字段

- `project create` 页必须承接：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`

### 3.2 标准化输入原则

- Flutter 不得再把 `provinceName / cityName / districtName` 当成唯一长期真源。
- Flutter 不得继续以自由手填省 / 市 / 区县文本作为最终提交 carrier。
- create 页后续必须通过“受控 standardized location 输入机制”产出 `code + name` 成对值。
- 当前正式冻结结论：
  - Flutter 需要地区选择器或等价的受控 standardized location 输入机制
  - 但本轮只冻结消费边界，不冻结该选择器的具体实现、数据源、交互形态、级联样式或搜索样式

### 3.3 district 输入边界

- 若单独提供区县层：
  - `districtCode + districtName` 必须成对承接
- 若当前未单独提供区县层：
  - `districtCode / districtName` 可同时为空
- Flutter 不得提交：
  - 只有 `districtCode` 没有 `districtName`
  - 只有 `districtName` 没有 `districtCode`

## 4. Detail Page Consumption Boundary

### 4.1 必须消费的字段

- `project detail` 页必须消费：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`

### 4.2 展示原则

- detail 页的用户可见地点展示以 human-readable values 为主：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
- `provinceCode / cityCode / districtCode` 必须被 Flutter 正确消费，但当前不要求作为终端用户可见文案直接展示。
- 这些 code 在当前前端边界中的职责是：
  - 保持 standardized location carrier 完整
  - 为后续地域分类 / 搜索消费预留标准化输入

### 4.3 旧数据兼容

- 对历史项目：
  - `provinceCode / cityCode / districtCode` 可为 `null`
  - `provinceName / cityName / districtName / detailAddress` 继续按既有值展示
- Flutter 不得因为 code 缺失而本地伪造 code。

## 5. `detailAddress` Consumption Boundary

- `detailAddress` 在 create 页继续作为自由文本输入。
- `detailAddress` 在 detail 页继续作为自由文本展示。
- Flutter 必须明确：
  - `detailAddress` 不是标准化分类 carrier
  - `detailAddress` 不是省市区筛选主真相
  - `detailAddress` 只承担补充地址文本

## 6. Existing Name-only Compatibility Principle

- 现有 name-only 页面向 `code + name` 兼容的消费原则正式冻结为：
  - 不删除 `provinceName / cityName / districtName` 的显示职责
  - 在页面输入与状态承载上新增对应 `code` carrier
  - `name` 继续面向用户可读
  - `code` 继续面向 standardized classification truth
- Flutter 当前不允许：
  - 继续把 name-only form 当作最终稳定方案
  - 继续把纯手填 name 文本提交为标准化地点真源

## 7. Region Selector Boundary

- 当前正式冻结结论：
  - Flutter 后续需要地区选择器或等价的受控 standardized location 输入机制
- 但本轮明确不 author：
  - 三级联动具体交互
  - picker / searchable sheet / cascader 具体形态
  - 行政区数据源接入实现
  - 地图 / 经纬度 / 行政区联动实现
- 本轮只冻结：
  - 标准化输入必须产出 `code + name`
  - 自由手填省 / 市 / 区县不能继续作为最终 carrier

## 8. Mainline Frontend Dependency Boundary

### 8.1 项目发布

- create 页必须消费 standardized location `code + name + detailAddress`。

### 8.2 项目展示

- detail 页必须以 `provinceName / cityName / districtName / detailAddress` 为当前展示主值。

### 8.3 地域分类

- 后续前端地域分类若进入实现，必须依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 本轮只冻结这种依赖关系，不 author 地域分类页面。

### 8.4 搜索

- 后续前端搜索若进入实现，地区筛选必须依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- `detailAddress` 只承担补充关键词文本，不承担地区主筛选真相。
- 本轮只冻结这种依赖关系，不 author 搜索界面。

## 9. List / Workbench Non-owner Boundary

- `project/list` 当前继续不是 standardized location richer-field owner。
- workbench 当前继续不是 standardized location richer-field owner。
- 当前正式冻结结论：
  - list / workbench 不要求消费：
    - `provinceCode`
    - `provinceName`
    - `cityCode`
    - `cityName`
    - `districtCode`
    - `districtName`
    - `detailAddress`
- create/detail rollout 不得被 list/workbench 扩面绑定。

## 10. Explicit Non-goals

- 不 author Flutter 实现代码
- 不 author 行政区联动具体实现
- 不 author 地图 / 经纬度
- 不 author 搜索界面
- 不 author 地域分类界面
- 不把地点标准化外溢到其他板块

## 11. Stage Conclusion

- 当前结论：
  - Flutter standardized location consumption boundary 已正式冻结
  - 后续可以进入地点标准化的 backend / BFF / Flutter 受控实现阶段
- 本冻结单的真实含义是：
  - create 页必须承接 `code + name + detailAddress`
  - detail 页必须消费并展示 standardized location 的 human-readable values
  - list / workbench 继续非承载
  - 但本文件本身不 author Flutter 实现，不 author地区选择器实现，不 author搜索或地域分类实现

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目地点标准化` Flutter 消费边界。
  - 正式确认 create 页必须承接 `code + name + detailAddress`。
  - 正式确认 detail 页消费 standardized location 且以 human-readable values 展示。
  - 正式确认 list / workbench 继续非承载。
