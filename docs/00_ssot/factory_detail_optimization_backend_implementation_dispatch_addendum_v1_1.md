---
owner: Codex 总控
status: active
purpose: Freeze the backend implementation dispatch prompt for the current factory-detail remediation round so Server execution stays inside the bounded location/name remediation, showcase projection support, and formal-info read closure.
layer: L0 SSOT
freeze_date_local: 2026-04-18
based_on:
  - docs/00_ssot/factory_detail_optimization_remediation_dispatch_bundle_addendum_v1_1.md
  - docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
---

# 《工厂详情优化修复 backend implementation dispatch V1.1》

## 当前唯一动作

- 发给 `后端 Agent` 的唯一执行口令如下。

```text
你是后端 Agent（仅云端），本轮不是重构整个 enterprise_hub，而是只实现《工厂详情优化修复》在 Server 侧已经冻结好的最小增量范围。

【一、唯一目标】
你这轮只完成 4 件事：
1. 定位并修复当前工厂地区 / 地址 / 名称口径冲突。
2. 让 `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info` 真实成立。
3. 为工厂 showcase 真值补齐展示型 carrier，支撑 app-facing Hero 图源。
4. 为案例展示提供稳定的后端状态语义边界，避免前端误把无数据当未接通。

【二、强制阅读】
- docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
- docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
- docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
- apps/server/src/modules/enterprise_hub/**

【三、只允许处理的范围】
- apps/server/src/modules/enterprise_hub/**
- 与 enterprise_hub detail / location / certification / media projection 直接相关的最小 supporting touch

【四、禁止事项】
- 不得重构整个企业真值系统
- 不得扩到公司详情 / 供应商详情整站大修
- 不得把当前查看者自己的 certification/current 当目标企业 formal-info
- 不得把 cases=[] 写成“未接通”业务语义
- 不得把 fileAssetId 直接当成展示 carrier 就算完成

【五、必须落实的真义】
1. 地区 / 地址 / 名称
- 必须定位“重庆工厂 + 成都省市 + 重庆地址”的错配来源
- 必须收口 location / listing / organization / certification / publicDisplayAddress 边界

2. formal-info
- server path 必须真实存在
- 只读目标企业正式认证 current truth
- 不得读当前查看者自己的认证 current

3. showcase
- 必须补齐展示型 carrier
- 单独返回 showcaseImageFileAssetIds 不算前台 Hero 图源闭环完成

4. cases 状态边界
- cases=[] 只表示当前无公开案例
- 不得把空数组本身定义成“能力未接通”

【六、完成标准】
- server build / targeted test / smoke 可证明：
  - 地区真值已收口
  - formal-info 路由已成立
  - showcase 展示型 carrier 已成立
  - cases 状态边界已稳定

【七、回执要求】
回执必须单独落盘为：
- docs/00_ssot/factory_detail_optimization_backend_execution_receipt_addendum_v1_1.md

回执至少包含：
1. 当前对象
2. 修改文件清单
3. 真值错配来源说明
4. formal-info 样本
5. showcase carrier 样本
6. 当前剩余阻断项
7. 是否可移交 BFF / 结果校验
```
