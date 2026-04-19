---
owner: Codex backend execution receipt
status: pass
stage: factory_detail_optimization_remediation
package: B_backend
updated_at_local: 2026-04-19
---

# 《工厂详情优化修复 backend execution receipt V1.1》

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-location.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts`
- `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
- `apps/server/test/enterprise-hub-formal-info-read.test.cjs`

## 2. 本地源码侧已完成的后端真值收口

- public detail 继续把 `showcaseImageFileAssetIds` 投影成展示型 `showcaseImageUrls`，前端不再需要直接消费 `fileAssetId`。
- 工厂详情继续区分：
  - `header.name = factoryName`
  - `basicInfo.legalName = legalName`
- 地区展示真值继续按 canonical location truth 收口，并进一步优先吃 `publicDisplayAddress` 推断出的 municipality truth。
- `cases=[]` 继续只表示：
  - `casesState = empty`
- `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info` 已在本地源码闭合，且读取目标企业 formal truth，而不是当前查看者自己的认证 truth。
- `EnterpriseHubWorkbenchQueryService` 增补了 fail-safe 依赖默认桩与 `caseMediaFileAssetIds` 空值保护，避免 workbench read / test new 场景出现伪红灯。

## 3. build / local test 结果

已执行：

```bash
cd apps/server
npm run build
node --test test/enterprise-hub-public-read-closure.test.cjs
node --test test/enterprise-hub-formal-info-read.test.cjs
node --test test/enterprise-hub-location-display-truth.test.cjs
```

结果：

- `build`: PASS
- `enterprise-hub-public-read-closure.test.cjs`: PASS `4/4`
- `enterprise-hub-formal-info-read.test.cjs`: PASS `3/3`
- `enterprise-hub-location-display-truth.test.cjs`: PASS `3/3`

## 4. 云端部署与 8080 chain smoke 结果

云端当前指针与服务态：

- `Server current`:
  - `/srv/releases/server/20260419000605-factory-detail-optimization-remediation-r2`
- `systemd`:
  - `exhibition-server = active`

实际通过本机已存在隧道与云端 loopback 访问 `127.0.0.1:8080`，结果如下：

- 工厂列表运行态已显示：
  - `provinceName = 重庆市`
  - `cityName = 重庆市`
- 工厂详情运行态已显示：
  - `header.name = 重庆海川展览工厂`
  - `basicInfo.legalName = 重庆坤特展览展示有限公司`
  - `visualGallery.source = showcase`
  - `boardProfile.showcaseImageUrls` 已存在
  - `serviceAreas[registered_location] = 重庆市 / 重庆市`
  - `casesState = empty`
- `formal-info` 运行态：
  - 未带 carrier 时 `401 AUTH_SESSION_INVALID`
  - 带合法 bearer 时 `200 OK`
  - 可真实读取目标企业正式认证 current truth

## 5. 当前剩余阻断项

- 当前对象范围内，`backend` 无剩余 blocker。

## 6. backend 结论

- `backend source + local truth verification`：
  - `PASS`
- `backend 8080 runtime verification`：
  - `PASS`
- 当前正式 verdict：
  - `PASS`
- 当前下一步唯一动作：
  - `移交总控做 Gate 3 / Gate 4 关单判断`
