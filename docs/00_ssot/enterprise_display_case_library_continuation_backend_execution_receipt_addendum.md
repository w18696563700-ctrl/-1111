# enterprise display case library continuation backend execution receipt

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation-support.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-case-continuation.write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts`
- `apps/server/test/enterprise-hub-case-continuation.test.cjs`

## 2. 每个修改点对应的冻结事实编号

- `enterprise-hub-case-continuation-support.service.ts`
  - 对应 `Truth 3.1`：case 继续属于 `listing-owned`
  - 对应 `Contract 2.2`：只允许读取当前 organization scope 下可维护的 `listing-owned case`
  - 对应 `Contract 4`：direct continuation 只适用于 `未发布 / draft-editable`
  - 对应 `Contract 5`：published-governed direct update 必须返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- `enterprise-hub-case-continuation.query.service.ts`
  - 对应 `Truth 4.2`：单案例继续编辑必须有正式 edit carrier
  - 对应 `Contract 2.1`：`GET /cases/{caseId}` 必须返回完整 `EnterpriseHubCaseDetailResponse`
  - 对应 `Contract 6`：workbench `cases[]` 继续只承接摘要，完整 edit carrier 走单案例路径
- `enterprise-hub-case-continuation.write.service.ts`
  - 对应 `Contract 3.1`：`PUT /cases/{caseId}` 只接 `title / exhibitionType / city / eventTime / summary / caseCoverFileAssetId / caseMediaFileAssetIds / isFeatured`
  - 对应 `Contract 3.1`：明确不承接 `boardType`
  - 对应 `Contract 3.2`：`caseCoverFileAssetId = null` 且存在 media 时，继续使用首图兜底
  - 对应 `Contract 4`：published-governed 不得走 direct update
- `enterprise-hub-truth.controller.ts`
  - 对应 `Stage Gate 当前阶段目标 1 / 2 / 3`
  - 对应 `Contract 2` 和 `Contract 3`：materialize 单案例 detail / update 的 Server truth 入口
- `enterprise-hub.errors.ts`
  - 对应 `Contract 5`：补齐 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- `enterprise-hub.module.ts`
  - 对应 `Stage Gate 3`：当前包只落实 Server truth owner，不越级改 BFF / Flutter
- `enterprise-hub-case-continuation.test.cjs`
  - 对应执行 prompt 的最低测试要求 `1 / 2 / 3 / 4 / 5`

## 3. `GET /cases/{caseId}` 实现说明

- Server 新增 `EnterpriseHubCaseContinuationQueryService.getCaseDetail()`，承接单案例继续编辑 carrier。
- 查询入口先通过 `EnterpriseHubCaseContinuationSupportService.loadOwnedCase()`：
  - 先按 `caseId` 读取当前 case truth
  - 再通过已有 `EnterpriseHubListingWriteSupportService.loadOwnedListing()` 校验当前 organization scope
  - 不新开 `user-owned` case truth，也不绕过既有 organization scope 校验
- 成功读取后输出固定 carrier：
  - `caseId`
  - `enterpriseId`
  - `boardType`
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
  - `caseStatus`
- `GET` 不再依赖 workbench `cases[]` 摘要列表拼 edit body。

## 4. `PUT /cases/{caseId}` 实现说明

- Server 新增 `EnterpriseHubCaseContinuationWriteService.updateCase()`，直接更新当前 `listing-owned case` 真值。
- 当前 direct update 只接住以下字段：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- `boardType` 只要出现在 payload 中就直接拒绝，返回 `ENTERPRISE_HUB_INVALID_BOARD_TYPE`。
- `caseMediaFileAssetIds` 继续限制最多 `6` 个。
- 当 `caseCoverFileAssetId = null` 且新 media 非空时，Server 继续用首图兜底，不把 cover 推给前端自行猜测。
- 更新结果继续只返回：
  - `caseId`
  - `caseStatus`

## 5. published 边界拒绝说明

- direct continuation 的 Server gating 现在统一落在 `EnterpriseHubCaseContinuationSupportService`。
- 当前 direct path 只在以下语义成立时放行：
  - `listing.enterpriseStatus = unpublished`
  - `latestApplication.applicationStatus = draft`
- 当 listing 已进入 `published`：
  - direct update 立即拒绝
  - 返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
  - 不把 `PUT /cases/{caseId}` 偷做成 published 直改线上后门
- 当前 `GET` 也不再对非 `未发布 / draft-editable` scope 放行，继续保持 direct continuation path 边界一致。

## 6. 新增或更新的测试清单

- 新增 `apps/server/test/enterprise-hub-case-continuation.test.cjs`
  - `GET /cases/{caseId}` 返回完整 edit carrier
  - `PUT /cases/{caseId}` 更新 case 真值并可读回
  - `PUT /cases/{caseId}` 不接受 `boardType`
  - organization scope 外访问被拒绝
  - published-governed case direct update 返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- 同时回归既有 enterprise-hub 最小闭环测试：
  - `apps/server/test/enterprise-hub-workbench-scope-chain.test.cjs`
  - `apps/server/test/enterprise-hub-submit-chain-drift-repair.test.cjs`
  - `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
  - `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
  - `apps/server/test/enterprise-display-upstream-truth-repair.test.cjs`

## 7. build / test 结果

- `cd apps/server && ./node_modules/.bin/tsc --noEmit -p tsconfig.json`
  - PASS
- `cd apps/server && npm run build`
  - PASS
- `cd apps/server && node --test test/enterprise-hub-case-continuation.test.cjs`
  - PASS
  - `5 / 5`
- `cd apps/server && node --test test/enterprise-hub-case-continuation.test.cjs test/enterprise-hub-workbench-scope-chain.test.cjs test/enterprise-hub-submit-chain-drift-repair.test.cjs test/enterprise-hub-workbench-closure.test.cjs test/enterprise-hub-public-read-closure.test.cjs test/enterprise-display-upstream-truth-repair.test.cjs`
  - PASS
  - `23 / 23`

## 8. 当前剩余未闭合项

- `published change corridor runtime`
  - 本轮禁止实现
- `BFF` 对 `GET /cases/{caseId}` 与 `PUT /cases/{caseId}` 的 app-facing 消费
  - 下一包处理
- `Flutter` 的案例库继续编辑接线
  - 下一包处理

以上剩余项都不属于当前 backend package 的执行目标；当前 backend package 目标范围内没有未闭合阻断。

## 9. 是否允许进入 BFF package

- 允许进入 `BFF package`

原因：

- 当前 `Server` 已具备 direct case continuation truth
- case 仍然保持 `listing-owned`
- direct path 与 published corridor 的边界已经在 `Server` 真相层落地
- 当前包没有把 `PUT /cases/{caseId}` 放宽成 published 直改 path
