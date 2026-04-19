---
owner: Codex package D backend
status: completed
stage: enterprise_display_chain_p1
package: D_backend
updated_at_local: 2026-04-11
---

# enterprise display chain P1 package D backend execution receipt

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-contact-write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-listing-write-support.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts`
- `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
- `apps/server/test/enterprise-hub-submit-chain-drift-repair.test.cjs`
- `docs/00_ssot/enterprise_display_chain_p1_package_d_backend_execution_receipt_addendum.md`

## 2. 每个修改点对应的冻结事实编号

| 修改点 | 文件 | 对应冻结事实编号 |
| --- | --- | --- |
| `updateBasic()` 接住 `contactName / contactMobile` 并写入现有 contact truth | `enterprise-hub-write.service.ts` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `4.8`; `enterprise_display_chain_p1_package_c_result_verification_conclusion_addendum.md` `3.1`, `4`; `enterprise_display_chain_p1_package_d_backend_execution_prompt_addendum.md` `6`, `7` |
| 联系人 persistence 收口到单一 contact owner，不新增第二条 update family | `enterprise-hub-contact-write.service.ts` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `4.8`; `enterprise_display_chain_p1_package_d_backend_execution_prompt_addendum.md` `5`, `7` |
| write scope / registered-area 辅助逻辑抽离，保持主写链职责收口 | `enterprise-hub-listing-write-support.service.ts`, `enterprise-hub-write.service.ts`, `enterprise-hub.module.ts` | `AGENTS.md` file-length and responsibility gate |
| readback / readiness 继续只认持久化 contact truth，并验证不接受其他联系人字段 | `enterprise-hub-workbench-closure.test.cjs`, `enterprise-hub-submit-chain-drift-repair.test.cjs` | `enterprise_display_chain_single_source_of_truth_freeze_addendum.md` `4.8`; `enterprise_display_chain_p1_package_d_backend_execution_prompt_addendum.md` `8` |

## 3. contactName / contactMobile persistence 说明

本轮把联系人普通保存链在 Server 这一层的剩余阻断真正收掉了。

### 3.1 `updateBasic()` 已接住联系人字段

- `EnterpriseHubWriteService.updateBasic()` 现在在保存 listing basic 字段之后，会把：
  - `contactName`
  - `contactMobile`
  送入 `EnterpriseHubContactWriteService.upsertPrimaryContactFromBasic(...)`
- 位置：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts:143-185`

### 3.2 联系人仍写入当前 contact persistence truth owner

- 没有新增新的 path family
- 没有新增新的 contact truth
- 没有新增第二条 contact update family
- 仍然只写当前 `EnterpriseContactEntity`

具体实现：

- `EnterpriseHubContactWriteService` 先找当前 enterprise 的可写联系人 truth：
  - 优先 `isPrimary = true`
  - 否则回退到 `visibleToPublic = true`
- 然后只更新：
  - `contactName`
  - `mobile`
- 并保持：
  - `isPrimary = true`
  - `visibleToPublic` 保持既有值；若是首次创建则按当前 `listing.contactVisible` 兜底

位置：

- `apps/server/src/modules/enterprise_hub/enterprise-hub-contact-write.service.ts:15-56`

### 3.3 没有顺手扩写其他联系人字段

本轮没有开始接受或持久化：

- `wechat`
- `phone`
- `email`
- `position`

`updateBasic()` 仍然只把 `contactName / contactMobile` 送入 contact persistence helper。

## 4. readback / readiness 一致性说明

本轮没有改动 workbench read 规则。

- `EnterpriseHubWorkbenchQueryService.loadPrimaryContact()` 仍然只从持久化联系人 truth 读取
- `readiness.hasContact` 仍然只由 `primaryContact != null` 决定

因此当前链路行为固定为：

1. Flutter 普通保存发出 `contactName / contactMobile`
2. BFF 透传这两个字段
3. Server `updateBasic()` 持久化到 `EnterpriseContactEntity`
4. workbench refresh 从持久化 truth 读回 `primaryContact`
5. `readiness.hasContact` 与持久化结果保持一致

这条链现在已经不再依赖 Flutter controller 暂存值。

## 5. 新增或更新的测试清单

更新：

- `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
  - 新增 `enterprise workbench basic save persists contactName and contactMobile into the current contact truth only`
  - 覆盖：
    - `updateBasic()` 收到 `contactName / contactMobile` 后真实持久化
    - workbench readback 可读回
    - `readiness.hasContact` 与持久化结果一致
    - `wechat / phone / email / position` 未被顺手接受
  - 同时对新构造的 contact / listing support helper 完成回归

更新：

- `apps/server/test/enterprise-hub-submit-chain-drift-repair.test.cjs`
  - 对 `EnterpriseHubWriteService` 的新依赖注入做最小对齐
  - 保持 `createApplication` 既有行为回归通过

回归一起覆盖：

- `enterprise-hub-workbench-scope-chain.test.cjs`
- `enterprise-hub-public-read-closure.test.cjs`
- `enterprise-display-upstream-truth-repair.test.cjs`

## 6. build / test 结果

已实际执行并通过：

- `cd apps/server && ./node_modules/.bin/tsc --noEmit -p tsconfig.json`
- `cd apps/server && npm run build`
- `cd apps/server && node --test test/enterprise-hub-submit-chain-drift-repair.test.cjs test/enterprise-hub-workbench-scope-chain.test.cjs test/enterprise-hub-workbench-closure.test.cjs test/enterprise-hub-public-read-closure.test.cjs test/enterprise-display-upstream-truth-repair.test.cjs`

结果：

- `tsc --noEmit`: PASS
- `npm run build`: PASS
- `node --test ...`: PASS, `18/18`

补充：

- `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts` 当前为 `437` 行，回到仓内 file-length gate 以内。

## 7. 当前剩余未闭合项

当前 package D / backend 目标范围内，没有剩余未闭合项。

本轮没有做、且仍不在 package D 范围内的事项：

- `wechat / phone / email / position` 持久化
- 新的 contact update family
- list / detail / recommendation / submit gating 额外改写
- 任何 BFF / Flutter / Admin 修改

## 8. 是否已达到联系人普通保存链 closure

结论：**是**

原因：

- `Flutter` 当前已发出 `contactName / contactMobile`
- `BFF` 当前已透传 `contactName / contactMobile`
- `Server updateBasic()` 现在已把这两个字段写入当前 contact persistence truth
- workbench refresh 可从持久化 truth 读回
- `readiness.hasContact` 与持久化 truth 一致

因此当前正式状态是：

- 联系人普通保存链已经从 `Flutter -> BFF -> Server` 打通
- `package D / backend` 这轮目标已完成
