---
owner: Codex 总控
status: active
purpose: Freeze the BFF implementation dispatch prompt for the current factory-detail remediation round so cloud app-facing work closes only the showcase URL shaping, formal-info route, and controlled field semantics.
layer: L0 SSOT
freeze_date_local: 2026-04-18
based_on:
  - docs/00_ssot/factory_detail_optimization_remediation_dispatch_bundle_addendum_v1_1.md
  - docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
  - docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
---

# 《工厂详情优化修复 BFF implementation dispatch V1.1》

## 当前唯一动作

- 发给 `BFF Agent` 的唯一执行口令如下。

```text
你是 BFF Agent（仅云端），本轮不是重开 enterprise_hub 全量改造，而是只闭合《工厂详情优化修复》在 BFF 侧已经冻结好的最小 transport / shaping 范围。

【一、唯一目标】
你这轮只完成 4 件事：
1. 让 app-facing 工厂详情能稳定输出 Hero 所需的 showcase 展示型 URL surface。
2. 让 `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info` 真正成立。
3. 让地区 / 名称 / 地址类字段在 app-facing 输出上收口。
4. 让案例展示所需的“无数据 / 未接通”语义不再由前端靠空数组猜测。

【二、强制阅读】
- docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
- docs/03_bff/factory_detail_optimization_remediation_bff_surface_addendum_v1_1.md
- docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
- docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
- apps/bff/src/routes/enterprise_hub/**

【三、只允许处理的范围】
- apps/bff/src/routes/enterprise_hub/**
- apps/bff/src/core/** 中与 enterprise_hub route shaping / auth context / error normalization 直接相关的最小 supporting touch

【四、禁止事项】
- 不得新增新 app-facing path family
- 不得把 profile/certification/current 冒充目标企业 formal-info
- 不得把 fileAssetId 直接下发给 Flutter 当展示 URL
- 不得让前端继续面对三套漂移字段口径
- 不得改前端视觉结构

【五、必须落实的 app-facing 真义】
1. showcase surface
- 工厂详情必须给 Flutter 可直接消费的 showcase 图片 URL
- 不得只给 fileAssetId

2. formal-info path
- `/formal-info` 必须真实可用
- 404 Cannot GET 不算完成
- 双重认证不满足时必须返回受控失败，而不是 success empty

3. 地区 / 名称 / 地址
- 必须收口为稳定 app-facing 输出
- 不得继续让 header/basic/location 三套口径漂移

4. 案例状态
- cases=[] 只代表当前无公开案例
- 若需要表达“未接通”，必须返回明确可判定语义

【六、完成标准】
- apps/bff build 通过
- formal 8080 chain 上工厂详情可输出 showcase 展示 URL
- formal 8080 chain 上 `/formal-info` 可读
- 地区 / 名称 / 地址输出语义稳定

【七、回执要求】
回执至少包含：
1. 当前对象
2. 修改文件清单
3. build 结果
4. 8080 chain smoke 结果
5. showcase surface 样本
6. formal-info 样本
7. 地区 / 名称 / 地址收口说明
8. 当前剩余阻断项
9. 是否可移交前端 / 结果校验
```
