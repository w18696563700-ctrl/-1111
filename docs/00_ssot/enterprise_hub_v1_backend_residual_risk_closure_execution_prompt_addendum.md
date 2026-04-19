---
owner: Codex 总控
status: active
purpose: Freeze the backend execution prompt for enterprise_hub V1 residual-risk closure so Server truth closes only the real entity and authenticated application-status prerequisites on the formal chain.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
  - docs/00_ssot/enterprise_hub_v1_frontend_real_entity_chain_receipt_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
freeze_date_local: 2026-04-10
---

# 《enterprise_hub V1 backend residual-risk closure execution prompt》

## 当前阶段

- 主线：
  - `enterprise_hub V1`
- 子阶段：
  - `residual-risk closure / backend`
- 当前只允许处理：
  - real entity truth
  - real authenticated application-status 前置条件

## 当前唯一动作

- 发给 `后端 Agent` 的唯一执行口令如下。

```text
你是后端 Agent（仅云端），本轮不是重开 enterprise_hub 全量实现，而是只关闭 residual-risk closure 剩余的后端真值阻断。

【一、唯一目标】
你这轮只关闭两条后端阻断：
1. 提供真实 public entity chain，使当前首页已暴露的 `company / factory / supplier` 三类 boardType 都能在 app-facing 列表里出现真实实体，并能继续进入真实 detail。
2. 提供真实 authenticated application-status chain，使结果校验 Agent 能在真实 `session + organization context` 下复核：
   - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`

【二、强制阅读】
- docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
- docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
- docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
- docs/00_ssot/enterprise_hub_v1_frontend_real_entity_chain_receipt_addendum.md
- docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
- docs/01_contracts/openapi.yaml

【三、只允许处理的范围】
- apps/server/**
- enterprise_hub 现有 truth / read-model / admin publish-review 范围
- 为真实样本所必需的最小 seed data、现有数据修正、受控 runtime config

【四、禁止事项】
- 不得新增新的 `/api/app/*` path family
- 不得新增新的 `/server/admin/*` 产品对象
- 不得新增第二套 enterprise truth
- 不得新增第二套 identity truth
- 不得新增第二状态机
- 不得关闭或绕过 auth / organization / certification / publish gating
- 不得把业务 `403/404` 伪装成 `200`
- 不得扩到交易、IM、地图、forum 主线

【五、当前已冻结的失败事实】
- `GET /api/app/exhibition/home` 已显示三张 live-card，但前轮独立复核里：
  - `company` 列表为空
  - `factory` 列表为空
  - `supplier` 列表为空
- 已提供的真实 `enterpriseId` 仍在 app-facing detail 返回业务 `404`
- `application-status` 仍缺真实 `session / organization context` 下的 app-facing 可复核样本
- 这些问题已经被正式判定为：
  - 不是 route absence
  - 是真实实体与真实上下文前置未闭合

【六、你必须交付的最小可复核对象】
1. `company` 至少一条真实公开实体：
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=10`
   - 必须出现真实 `items`
2. `factory` 至少一条真实公开实体：
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=10`
   - 必须出现真实 `items`
3. `supplier` 至少一条真实公开实体：
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=supplier&page=1&pageSize=10`
   - 必须出现真实 `items`
4. 对应每个 boardType 的样本实体都必须满足：
   - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=...` 返回 `200`
5. 至少一条真实 authenticated application-status 样本：
   - 必须有真实 `account + organization context`
   - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}` 返回 `200`
   - 如果当前 truth 需要 review / publish / submit 之后才允许 status read，则只能走现有冻结 truth/admin path family，不能发明捷径

【七、允许使用的既有路径】
- `GET /api/app/exhibition/enterprise-hub/enterprises`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
- `POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review`
- `POST /server/admin/exhibition/enterprise-hub/enterprises/{enterpriseId}/publish`
- 其他 enterprise_hub 现有 truth/admin 路径，但只限当前包已冻结对象

【八、完成标准】
- 当前 formal chain 能独立证明：
  - 首页已暴露的三个 boardType 不再全部落到空列表
  - `company / factory / supplier` 各至少有一条真实公开实体
  - 每条样本实体都可被 app-facing detail 读取为 `200`
  - `application-status` 能在真实认证组织上下文下读取为 `200`
- 如果你只能闭合一部分：
  - 必须逐条写出未闭合的 boardType 或 application-status 阻断
  - 不得把整体 backend risk 写成已关闭

【九、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. 数据修正 / seed / runtime 调整清单
4. 样本 `enterpriseId / boardType / applicationId / organizationId`
5. build / start / minimal smoke 结果
6. 当前剩余阻断项
7. 是否可移交 `BFF Agent`

【十、输出禁令】
- 不要写“应该可以”
- 不要只给代码阅读结论
- 不要把 admin truth 绕过成脚本假成功
- 不要给前端甩锅
- 只给真实样本和真实验证证据
```
