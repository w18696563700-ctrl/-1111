---
owner: BFF Agent
status: active
purpose: Record the bounded BFF execution result for enterprise display chain P1 package E public-list filter transport cleanup.
layer: execution receipt
receipt_date_local: 2026-04-11
---

# enterprise display chain P1 package E BFF execution receipt

## 1. 修改文件清单

- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/enterprise-hub-list-query-transport.test.cjs`

## 2. 删除的 query transport 清单

本轮已从 controller surface 与 service forwarding 一并删除：

- `certifiedOnly`
- `sortBy`
- `exhibitionType`
- `serviceCity`
- `caseCountRange`
- `reputationLevel`
- `processType`
- `urgentCapability`
- `warehouseCapability`
- `supplyCategory`
- `supplyMode`
- `responseLevel`

这些字段不再：

- 出现在 `AppEnterpriseHubController.listEnterprises()`
- 出现在 `EnterpriseHubController.listEnterprises()`
- 出现在 `EnterpriseHubListQuery`
- 出现在 `buildListParams()` 对 `Server` 的 query forwarding

## 3. 保留的 query transport 清单

当前 enterprise public list 在 BFF 仅保留正式 contract 最小集合：

- `boardType`
- `keyword`
- `provinceCode`
- `cityCode`
- `plantAreaRange`
- `page`
- `pageSize`

说明：

- `plantAreaRange` 继续允许透传
- 本轮未在 BFF 新增任何 `cityContextSource / nationalMode / sortBy` 等附加 schema
- canonical path 继续保持：
  - `GET /api/app/exhibition/enterprise-hub/enterprises`

## 4. 新增或更新的测试清单

- 新增：
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/test/enterprise-hub-list-query-transport.test.cjs`

覆盖项：

1. enterprise public list 只透传：
   - `boardType`
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange`
   - `page`
   - `pageSize`
2. 已删除的历史 query 参数不会再进入 `Server` 请求
3. `plantAreaRange` 仍可正常透传
4. canonical path 与现有错误归一化不被破坏

## 5. build / test 结果

- build：
  - `cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/bff && npm run build`
  - `PASS`
- targeted test：
  - `cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/bff && node --test test/enterprise-hub-list-query-transport.test.cjs`
  - `PASS (3/3)`

## 6. 当前剩余未闭合项

- BFF package E 范围内：
  - `none`
- 当前 fake-filter cleanup 仍未闭合到最终消费完成的剩余项：
  - `Flutter package E` 仍需移除历史残留筛选 UI 与 query builder

## 7. 是否允许进入 Flutter package E

- `yes`
- 当前结论含义：
  - BFF 已不再自持历史残留 enterprise public list filter transport
  - BFF 对 enterprise public list 的 query 解释已与正式 contract 最小集合一致
  - 当前 fake-filter cleanup 剩余责任层已收敛到 `Flutter package E`
