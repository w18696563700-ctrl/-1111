---
owner: Frontend Agent
status: draft
purpose: Record the frontend-side real-entity chain rerun result for enterprise_hub V1 on the formal app-facing runtime chain.
layer: L0 SSOT
---

# Enterprise Hub V1 Frontend Real Entity Chain Receipt Addendum

## 1. 当前对象
- 当前对象：
  - `enterprise_hub V1`
- 当前轮次：
  - `real-entity chain rerun`
- 当前验证时间：
  - `2026-04-02`
- 当前验证范围：
  - 首页三卡
  - `company / factory / supplier` 列表
  - 真实 `enterpriseId` 详情
  - `application / application-status`
- 当前明确非结论：
  - 不接受 `empty-state` 作为主链证明
  - 不接受 `missing-entity 404` 作为主链证明
  - 不进入 `release-prep / release`

## 2. 前置依据
- 本轮使用的前置依据：
  - [enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md)
- 该前置文书已记录：
  - cloud 侧 BFF / backend / admin 风险收口回执存在
  - 一条真实 `enterpriseId`
    - `245933eb-5f71-4019-a1b8-66300c123001`
  - 一条真实 `applicationId`
    - `cc61fa2b-7db5-47e7-9c83-e29fb81fec9c`
- 当前 formal chain 健康检查：
  - `GET http://127.0.0.1:8080/health/bff/live` -> `200`
  - 返回要点：
    - `status=ok`
    - `service=exhibition-bff`

## 3. 首页三卡是否已是 live-card
- 验证入口：
  - `GET http://127.0.0.1:8080/api/app/exhibition/home`
- 当前结果：
  - `excellent_company`
    - `enabled=true`
    - `placeholder=false`
    - `actionLabel=查看公司`
  - `excellent_factory`
    - `enabled=true`
    - `placeholder=false`
    - `actionLabel=查看工厂`
  - `excellent_supplier`
    - `enabled=true`
    - `placeholder=false`
    - `actionLabel=查看供应商`
- 当前结论：
  - 首页三卡已从 `placeholder-disabled` 变为可用 `live-card`

## 4. 列表是否已出现真实实体卡片
- 验证入口：
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=10`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=10`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=supplier&page=1&pageSize=10`
- 当前结果：
  - `company`：
    - `recommended=[]`
    - `items=[]`
    - `pagination.total=0`
  - `factory`：
    - `recommended=[]`
    - `items=[]`
    - `pagination.total=0`
  - `supplier`：
    - `recommended=[]`
    - `items=[]`
    - `pagination.total=0`
- FAIL 点：
  - 三类列表当前都没有真实实体卡片
  - 因此“首页三卡 -> 可见真实列表实体”本轮未跑通

## 5. 详情是否已命中真实 enterpriseId
- 验证入口：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/245933eb-5f71-4019-a1b8-66300c123001?boardType=company`
- 当前结果：
  - 返回 `404`
  - `code=ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
  - `message=Enterprise hub listing is unavailable.`
  - `source=server`
- FAIL 点：
  - 当前仍未命中真实 `enterprise detail`
  - 当前返回的是业务层 `404`
  - 因此“真实 enterpriseId -> 真实 detail”本轮未跑通

## 6. application / application-status 是否已在真实 session / organization context 下返回预期业务态
- 申请创建验证：
  - `POST /api/app/exhibition/enterprise-hub/applications`
  - body：
    - `applyBoardType=company`
    - `applicantName=Test User`
    - `applicantMobile=13800138000`
  - 返回：
    - `401 AUTH_SESSION_INVALID`
    - `message=Request must include a valid session carrier (authorization or x-actor-id/x-user-id header).`
- 申请状态验证：
  - `GET /api/app/exhibition/enterprise-hub/applications/cc61fa2b-7db5-47e7-9c83-e29fb81fec9c`
  - 返回：
    - `401 AUTH_SESSION_INVALID`
- 当前 shell 上下文检查：
  - 未发现可用的：
    - `authorization`
    - `x-actor-id`
    - `x-organization-id`
    - 相关 `AUTH / TOKEN / SESSION / ACTOR / ORG` 环境变量
- FAIL 点：
  - 本轮仍未拿到真实 `session / organization context`
  - 因此 `application / application-status` 无法证明已在真实上下文下返回预期业务态

## 7. 当前剩余风险
- 首页三卡已 live，但三类列表仍为空，主链在列表层断开。
- 已提供的真实 `enterpriseId` 当前仍返回 app-facing 业务 `404`，详情链未闭合。
- 已提供的真实 `applicationId` 在无真实 session carrier 条件下仍返回 `401`，状态链未闭合。
- 当前 formal chain 已连通，但 real-entity chain 仍未闭合。
- 当前不得把：
  - live-card
  - 空列表
  - `missing-entity 404`
  - 无 session 的 `401`
  误写成“主链已通”。

## 8. 本轮正式结论
- 当前结论：
  - `FAIL`
- 当前已确认项：
  - 首页三卡已是 `live-card`
  - formal app-facing chain 可达
- 当前未通过项：
  - 列表未出现真实实体卡片
  - 详情未命中真实 `enterpriseId`
  - `application / application-status` 未在真实 `session / organization context` 下完成验证
- 当前 release 结论：
  - `release-prep / release` 仍然 `No-Go`

## 9. 下一唯一动作
- 下一唯一动作：
  - 由 backend / BFF 提供一条可在 app-facing 列表中真实出现的公开实体
  - 同时提供可用于 app-facing `application-status` 的真实 session / organization context
  - 然后再重跑前端 real-entity chain 复验
