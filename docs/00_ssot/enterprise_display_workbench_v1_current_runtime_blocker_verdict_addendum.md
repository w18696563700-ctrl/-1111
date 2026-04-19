---
owner: Codex 总控
status: frozen
purpose: Record the current-runtime blocker verdict for enterprise display workbench V1, so release decisions, root causes, and next routing do not drift into screenshot-based judgment or false blame on BFF/Server transport.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - cloud runtime probes on 47.108.180.198 at 2026-04-10
---

# 企业展示工作台 V1 当前运行态阻断裁决单

## 1. Verdict

- 当前正式结论固定为：
  - `不通过`
  - `本轮不执行发布`
- 当前 review 对象固定为：
  - `enterprise display workbench V1`
  - 不扩大到全部 `enterprise_hub` 历史资产

## 2. Current Active Runtime Under Review

- 当前现网 active 保持为：
  - `BFF = /srv/releases/bff/20260410170440/apps/bff`
  - `Server = /srv/releases/server/20260410133438`
- 当前不执行发布的原因不是：
  - 只看截图
  - 只看本地代码
  - 误把灰态当 transport 故障
- 当前不执行发布的直接原因是：
  - 组织真值无效
  - mobile 本地前置条件拦截
  - mobile 显示层对无效地区码回退为空文案

## 3. Root Cause Classification

- 当前根因只归为三类：
  - `organization truth invalid`
  - `mobile local precondition block`
  - `mobile display masking over invalid city truth`
- 当前明确不是根因：
  - `BFF forwarding loss`
  - `Server save-chain persistence loss`
  - `runtime not updated`
- 补充说明：
  - `Server active vs local repo drift` 当前确实存在
  - 但这次用户看到的 `注册城市没同步 + 提交灰态` 不能靠“直接切本地 Server 版”单独消掉

## 4. Key Evidence

### 4.1 Organization Mine Truth

- 当前 `organization mine` 返回关键字段为：
  - `provinceCode = 000000`
  - `cityCode = 000000`
  - `contactName = 王巍威`
  - `contactMobile = 18696563700`
- 当前判断固定为：
  - `cityCode` 不是空值，而是无效占位值 `000000`
  - mobile 本地 region catalog 中不存在 `000000`
  - `_cityDisplayLabel()` 解析失败时回空字符串
  - 页面因此显示“当前还没有同步到注册城市真值”类占位文案

### 4.2 Certification / OCR Truth

- 当前 `GET /api/app/profile/certification/current` 返回：
  - `legalName = 重庆坤特展览展示有限公司`
  - `licenseFileId` 非空
  - `certificationStatus = approved`
- 当前 `POST /api/app/profile/certification/license/ocr` 返回：
  - `legalName = 重庆坤特展览展示有限公司`
  - `establishedAt = null`
  - `address = null`
- 当前判断固定为：
  - 认证通过不等于工作台必填真值齐备
  - `foundedAt` 与 `address` 当前没有从 OCR 真值补齐到工作台

### 4.3 Workbench Read Truth

- 当前 `GET /api/app/exhibition/enterprise-hub/workbench?boardType=factory` 返回：
  - `basic.name = null`
  - `basic.shortIntro = null`
  - `basic.provinceCode = null`
  - `basic.provinceName = null`
  - `basic.cityCode = null`
  - `basic.cityName = null`
  - `boardProfile.factoryName = null`
  - `boardProfile.processTypes = null`
  - `boardProfile.coreProducts = null`
  - `readiness.basicCompleted = false`
  - `readiness.profileCompleted = false`
  - `readiness.submitReady = false`
- 当前 `Server` readiness blocker 口径与返回值一致：
  - `基础资料未完成，请补齐企业名称、一句话简介和注册城市。`
  - `板块画像未完成，请补齐当前主板块的必填资料。`
- 当前判断固定为：
  - 提交按钮灰态不是错判
  - 是 workbench 当前真值确实为空的正确投影

### 4.4 Mobile Basic Save Was Never Sent

- 当前 mobile 基础资料保存并没有真正发出：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
- 当前本地拦截发生在：
  - `city = _regionCatalog?.cityByCode(_selectedCityCode)` 为空时直接 return
  - `foundedAt` 为空时不具备完整资料真值
  - `address` 为空时不具备完整资料真值
- 当前提示文案固定为：
  - `当前还没有同步到可用的注册城市真值，请先在我的公司补全有效城市后再试。`
- 当前判断固定为：
  - 这次基础资料未落库，不是 BFF/Server 丢请求
  - 是 mobile 在请求发出前就按真值前置条件拦住

### 4.5 Factory Profile Save Chain Is Working

- 当前受控复测直接调用了现网：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory`
- 关键请求字段包括：
  - `factoryName`
  - `processTypes`
  - `coreProducts`
- 当前结果固定为：
  - `BFF upstream_status = 200`
  - 现网 `Server` 能落库并回读
- 当前判断固定为：
  - `factoryName / processTypes / coreProducts` 当前不属于 transport 丢字段问题

## 5. Field-Level Blocker Ledger

- 当前真实阻断字段固定为：
  - `organization.provinceCode = 000000`
  - `organization.cityCode = 000000`
  - `certification.establishedAt = null`
  - `certification.address = null`
  - `workbench.basic.name = null`
  - `workbench.basic.shortIntro = null`
  - `workbench.basic.provinceCode = null`
  - `workbench.basic.provinceName = null`
  - `workbench.basic.cityCode = null`
  - `workbench.basic.cityName = null`
  - `workbench.boardProfile.factoryName = null`
  - `workbench.boardProfile.processTypes = null`
  - `workbench.boardProfile.coreProducts = null`

## 6. Non-root Cause Ruling

- 当前正式排除项固定为：
  - `BFF 转发问题：不是`
  - `Server 落库问题：不是`
  - `runtime 未更新：存在 repo 漂移，但不是本轮灰态主因`
- 当前形式化判断固定为：
  - `organization.cityCode = 000000` 是页面显示“当前还没有同步到注册城市真值”的直接原因
  - 该显示当前属于正确揭示，不属于误报
  - workbench profile save 链在现网是通的

## 7. Formal Conclusion

- 当前正式结论固定为：
  - `enterprise display workbench V1` 当前不具备发布放行条件
  - 当前主阻断不在 `BFF -> Server` 保存链
  - 当前主阻断在 `organization/certification truth -> mobile guard -> workbench readiness`
  - 不得把这次灰态问题归因成“只要切本地 Server 版就能解决”

## 8. Next Route

- 当前阶段完成度：
  - `closure 完成`
- 当前下一步唯一动作：
  - 输出 `enterprise display workbench truth repair dispatch`，先收 `organization valid province/city truth` 与 `certification foundedAt/address truth`，然后重跑 mobile basic-save smoke
- 下一步执行角色：
  - `总控`
- 下一步进入条件：
  - 本阻断裁决单已正式落盘，并已同步进全功能总表
