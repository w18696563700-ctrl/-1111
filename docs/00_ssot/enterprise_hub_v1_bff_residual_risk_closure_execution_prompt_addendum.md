---
owner: Codex 总控
status: active
purpose: Freeze the BFF execution prompt for enterprise_hub V1 residual-risk closure so the current cloud verifier environment independently passes the full BFF build and preserves the canonical app-facing enterprise_hub chain.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
freeze_date_local: 2026-04-10
---

# 《enterprise_hub V1 BFF residual-risk closure execution prompt》

## 当前阶段

- 主线：
  - `enterprise_hub V1`
- 子阶段：
  - `residual-risk closure / BFF`
- 当前只允许处理：
  - full build drift closure
  - canonical app-facing shaping stability

## 当前唯一动作

- 发给 `BFF Agent` 的唯一执行口令如下。

```text
你是 BFF Agent（仅云端），本轮只关闭 enterprise_hub V1 residual-risk closure 中属于 BFF 的两类问题：
1. 当前 cloud verifier 环境里 `apps/bff` full build 必须独立通过
2. enterprise_hub canonical app-facing route family 必须在 formal `80/8080` chain 上稳定承接 backend 已提供的真实实体与真实 application-status 样本

【一、强制阅读】
- docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
- docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
- docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
- docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
- docs/01_contracts/openapi.yaml
- 后端 Agent 本轮 residual-risk closure 回执

【二、只允许处理的范围】
- apps/bff/**
- enterprise_hub 当前冻结 route family 的聚合、转发、错误归一、transport closure
- 如 full build 受其他现有模块编译漂移阻断，只允许做“让当前 `apps/bff` build 通过”的 bounded supporting fix

【三、禁止事项】
- 不得新增新的 `/api/app/*` path
- 不得让 `/bff/*` 成为产品合同
- 不得在 BFF 里补第二套 enterprise truth
- 不得在 BFF 里补第二状态机
- 不得用 fallback 假数据把空列表、缺实体、缺会话伪装成成功
- 不得借 full build supporting fix 重开 forum 产品主线

【四、你必须独立关闭的风险】
1. full build drift
- 在当前 cloud verifier 环境里：
  - `cd apps/bff && npm run build`
  - 必须独立通过
- 不接受只引用历史回执

2. canonical route family stability
- 你必须基于 backend 本轮提供的真实样本，保证以下路径在 formal `80/8080` chain 上语义稳定：
  - `GET /api/app/exhibition/home`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=supplier`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=...`
  - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
- 当前要求是：
  - 正确透传真实非空列表
  - 正确透传真实 detail
  - 正确透传真实 authenticated application-status
  - 保留受控 `401/403/404` 的原始业务语义

【五、你必须证明的结果】
1. 当前 `apps/bff` full build 已在 verifier 环境里独立通过
2. 当前 `80 -> 3000 -> 3001` chain 上 enterprise_hub canonical routes 无路由漂移
3. 当前 app-facing 响应不再把 backend 已闭合的真实实体链裁成空结果
4. 当前 app-facing 响应不再把 backend 已闭合的真实 application-status 裁成错误态

【六、完成标准】
- `npm run build` 通过
- `GET /health/bff/live` 正常
- 使用 backend 回执里的样本：
  - 三个 boardType 列表都返回非空真实 `items`
  - 对应 detail 返回 `200`
  - authenticated application-status 返回 `200`
- 如果 build 已通过，但某条 canonical route 仍错误：
  - 必须逐条写出
  - 不得把整体 BFF risk 写成已关闭

【七、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. full build 命令与结果
4. health / start / route smoke 结果
5. backend 样本映射关系
6. 当前剩余阻断项
7. 是否可移交 `前端 Agent`

【八、输出禁令】
- 不要写“build 理论上能过”
- 不要引用旧回执替代本轮 verifier 结果
- 不要把 forum supporting fix 写成 forum 主线重开
- 不要把 BFF fallback 当 closure 证据
- 只给 build 证据和 route 证据
```
