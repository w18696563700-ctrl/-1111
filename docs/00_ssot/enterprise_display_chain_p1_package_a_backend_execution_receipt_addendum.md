---
owner: Codex package A backend
status: partial
stage: enterprise_display_chain_p1
package: A_backend
updated_at_local: 2026-04-11
---

# enterprise display chain P1 package A backend execution receipt

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub-media-projection.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts`
- `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
- `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
- `docs/00_ssot/enterprise_display_chain_p1_package_a_backend_execution_receipt_addendum.md`

## 2. 每个修改点对应的冻结事实编号

| 修改点 | 文件 | 对应冻结事实编号 |
| --- | --- | --- |
| 公域列表 / 详情 / 推荐位统一走同一 visibility boundary | `enterprise-hub-query.service.ts` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `4.6` |
| 公域 `caseCount` 与详情案例区统一只认 `approved` | `enterprise-hub-query.service.ts` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `3.4`, `4.7` |
| `logoUrl` / `coverImageUrl` 由 Server 自持 display projection 输出 | `enterprise-hub-media-projection.service.ts`, `enterprise-hub.presenter.ts`, `enterprise-hub.module.ts` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `3.6`, `4.9` |
| workbench `hasContact` 继续只认持久化 contact truth | `enterprise-hub-workbench-closure.test.cjs` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `3.3`, `4.8` |

## 3. 联系人真实保存的实现说明

本轮没有把“普通保存后联系人真实持久化”写成已完成，因为当前阻断不是 `apps/server/src/modules/enterprise_hub/**` 单点缺陷，而是冻结 contract 与当前 runtime 调用面没有把编辑后的联系人值送到 Server。

- 当前 `Mobile` workbench 的普通保存只调用 `updateBasic`，发送 `name / logoFileAssetId / shortIntro / fullIntro / provinceCode / provinceName / cityCode / cityName / address / foundedAt / teamSizeRange / cooperationModes / contactVisible`，不发送联系人字段。
- 当前 `BFF` `normalizeBasicPayload()` 也只透传上述字段，不透传 `contactName / mobile / wechat / phone / email / position`。
- 在当前 package-A 允许范围内，Server 无法凭空 materialize “用户刚编辑但未上传”的联系人真值；如果强行补，会变成猜字段或伪闭环，这与冻结事实 `4.8` 冲突。

本轮实际完成的联系人相关收口只有一条：

- workbench readback 与 readiness 继续只认持久化 contact truth，不认前端暂存值。
- 已补测试证明：当持久化联系人存在时，`primaryContact` 能稳定读回，`readiness.hasContact` 与持久化 truth 一致。

结论：

- `联系人真实保存闭环` 当前只闭到了“读真值一致”。
- `联系人普通保存后真实持久化` 当前仍未闭合。

## 4. 案例口径统一的实现说明

本轮把所有公域案例数字与案例内容统一收到了同一冻结口径：

- `GET /server/exhibition/enterprise-hub/enterprises` 的 `caseCount` 现在只统计 `caseStatus = approved`。
- `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}` 的 `cases` 现在继续只返回 `caseStatus = approved`。
- 首页推荐位企业仍复用同一套 list item 投影，因此任何公域摘要中的案例数字也跟随统一成 `approved` 口径。

实现方式：

- `enterprise-hub-query.service.ts` 中 `toListItems()` 对案例查询改为 `enterpriseId IN (...) + caseStatus = approved`。
- `getEnterpriseDetail()` 的案例查询继续显式固定为 `caseStatus = approved`。
- `getRecommendations()` 返回的仍是 `toListItems()` 结果，因此不再出现“列表显示有案例，详情却没有公域可见案例”的漂移。

## 5. 图片展示投影闭环的实现说明

本轮没有改动存储真相，仍保持：

- `logoFileAssetId`
- `coverFileAssetId`
- `caseCoverFileAssetId`
- `caseMediaFileAssetIds`

本轮新增了一个只负责 display projection 的最小 Server 组件：

- `EnterpriseHubMediaProjectionService`

它只做两件事：

1. 通过 `file_asset` 真相读取 `objectKey`
2. 复用现有 `UploadPublicUrlService` 产出可消费的展示 URL

然后由 public presenter 输出当前 contract 已正式支持的展示字段：

- 列表与详情头部的 `logoUrl`
- 详情案例卡的 `coverImageUrl`

结果：

- public read model 不再长期把这些字段置空。
- Flutter/BFF 不需要自己猜 `fileAssetId -> URL` 规则。
- 图片 display projection 重新回到 Server-owned shaping。

## 6. published + visible 统一核落的实现说明

本轮把公域 listing 可见性边界显式收敛到了 `enterprise-hub-query.service.ts` 内的统一 helper：

- `createPublicListingQuery(boardType)`
- `loadPublicListing(enterpriseId, boardType)`
- `loadPublicListings(boardType, enterpriseIds)`

三条公域读取链现在共同依赖这套边界：

- 公域列表：`getEnterprises()`
- 公域详情：`getEnterpriseDetail()`
- 推荐位 / 首页企业读取：`getRecommendations()`

统一规则固定为：

- `enterpriseStatus = published`
- `displayStatus = visible`

推荐位在此基础上继续叠加有效 slot 时间窗，不再绕开 listing publish/display gating。

## 7. 新增或更新的测试清单

新增：

- `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
  - 公域列表 `caseCount` 只统计 `approved`
  - 公域详情只返回 `approved` 案例
  - `logoUrl` / `coverImageUrl` 从 `fileAsset` 真相稳定投影
  - 公域列表 / 详情 / 推荐位共同遵守 `published + visible`

更新：

- `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
  - 增补 `primaryContact` 读回断言
  - 增补 `readiness.hasContact === true` 断言

## 8. build / test 结果

已实际执行并通过：

- `cd apps/server && ./node_modules/.bin/tsc --noEmit -p tsconfig.json`
- `cd apps/server && npm run build`
- `cd apps/server && node --test test/enterprise-hub-workbench-scope-chain.test.cjs test/enterprise-hub-submit-chain-drift-repair.test.cjs test/enterprise-display-upstream-truth-repair.test.cjs test/enterprise-hub-workbench-closure.test.cjs test/enterprise-hub-public-read-closure.test.cjs`

结果：

- `tsc --noEmit`: PASS
- `npm run build`: PASS
- `node --test ...`: PASS, `17/17`

## 9. 当前剩余未闭合项

### 9.1 联系人普通保存后真实持久化

仍未闭合。

原因不是 Server truth 已经错误，而是当前 package-A 允许边界之外的调用面没有把联系人字段送入 write chain：

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart` 的 `_saveBasic()` 仍未发送联系人字段
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts` 的 `normalizeBasicPayload()` 仍未透传联系人字段

在不扩写 contract、不修改 BFF/Mobile 的前提下，Server 不能真实保存“编辑后的联系人”。

### 9.2 package A backend 结论

当前不能写成“package A backend 已完成”。

真实结论是：

- 已闭合：
  - 公域案例口径统一
  - 图片展示投影闭环
  - `published + visible` 公域读取边界统一
- 未闭合：
  - 联系人普通保存后真实持久化

## 10. 是否可移交 BFF package B

当前结论：**否**

原因：

- `package A / backend` 还不能整体宣告完成，联系人真实保存闭环仍缺最后一段 contract/BFF/Mobile write path。
- 已闭合的 public read 子链可以被后续 BFF 消费。
- 但在联系人 write path 没有正式补齐前，不应把 `package A backend` 整体标记为可完整移交。
