---
owner: Codex BFF execution receipt
status: pass
stage: factory_detail_optimization_remediation
package: B_bff
updated_at_local: 2026-04-19
---

# 《工厂详情优化修复 BFF execution receipt V1.1》

## 1. 修改文件清单

- `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
- `apps/bff/test/enterprise-hub-factory-detail-remediation.test.cjs`

## 2. 本地源码侧已完成的 BFF 收口

- 工厂详情 `header.provinceName / header.cityName` 优先回填 `location` 公开真值。
- 工厂详情 `basicInfo.address` 优先收口到 `location.publicDisplayAddress`。
- `boardProfile` 增补可直接消费的 `showcaseImageUrls`，同时保留 `showcaseImageFileAssetIds`。
- `visualGallery.source` 在存在 showcase 展示 URL 时收口为 `showcase`。
- 详情响应透传/兜底 `casesState`，不再逼前端把 `cases=[]` 猜成“未接通”。
- `/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info` 的本地 app-facing route 已存在，且 forward 到 canonical Server path。

## 3. build / local test 结果

已执行：

```bash
corepack pnpm --dir apps/bff build
node --test apps/bff/test/enterprise-hub-factory-detail-remediation.test.cjs
node --test apps/bff/test/enterprise-hub-list-query-transport.test.cjs
```

结果：

- `build`: PASS
- `enterprise-hub-factory-detail-remediation.test.cjs`: PASS `2/2`
- `enterprise-hub-list-query-transport.test.cjs`: PASS `5/5`

## 4. 云端部署与 8080 chain smoke 结果

云端当前指针与服务态：

- `BFF current`:
  - `/srv/releases/bff/20260418235914-factory-detail-optimization-remediation/apps/bff`
- `systemd`:
  - `exhibition-bff = active`

实际通过本机已存在隧道与云端 loopback 访问：

```bash
curl 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=1'
curl 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises/a9b46040-956e-44fd-8e35-e3c533687e27?boardType=factory'
curl 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises/a9b46040-956e-44fd-8e35-e3c533687e27/formal-info'
```

结果：

- 工厂列表返回已收口：
  - `provinceName = 重庆市`
  - `cityName = 重庆市`
- 工厂详情返回已收口：
  - `header.name = 重庆海川展览工厂`
  - `header.provinceName = 重庆市`
  - `header.cityName = 重庆市`
  - `visualGallery.source = showcase`
  - `boardProfile.showcaseImageUrls` 已存在
  - `serviceAreas[registered_location] = 重庆市 / 重庆市`
  - `casesState = empty`
- `formal-info` 未带 auth carrier 时返回：
  - `401 AUTH_SESSION_INVALID`
  - 该结果符合受控鉴权门预期
- `formal-info` 带合法 bearer 时返回：
  - `200 OK`
  - 可真实读取目标企业正式资料

## 5. 当前剩余阻断项

- 当前对象范围内，`BFF` 无剩余 blocker。
- 后续若继续推进，只属于：
  - 发布后回归观察
  - 更大范围详情系统对象，不属于本轮 bounded remediation

## 6. BFF 结论

- `BFF source + local transport verification`：
  - `PASS`
- `BFF 8080 runtime verification`：
  - `PASS`
- 当前正式 verdict：
  - `PASS`
- 当前下一步唯一动作：
  - `移交总控做 Gate 3 / Gate 4 关单判断`
