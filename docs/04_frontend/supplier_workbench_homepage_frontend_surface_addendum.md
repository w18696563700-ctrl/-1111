---
owner: Codex 总控
status: active
purpose: Freeze the bounded Flutter-only surface for turning the supplier display workbench into a compact homepage, without changing enterprise display truth, app-facing contracts, BFF, Server, or cloud runtime.
layer: L4 Frontend
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_stage_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
freeze_date_local: 2026-05-01
---

# 《供应商展示工作台首页化 frontend surface freeze》

## 1. Scope

- 当前冻结只覆盖：
  - `/exhibition/supplier-display/workbench`
  - `/exhibition/supplier-display/cases/editor`
  - `/exhibition/supplier-display/status`
  - Flutter 本地工作台页面结构、模块入口、预览摘要和底部动作栏
- 当前冻结不覆盖：
  - BFF / Server / OpenAPI / database / cloud deployment
  - enterprise display truth model changes
  - public supplier detail business rule changes
  - analytics truth
  - review management truth
  - activity feed truth
  - new global private route family

## 2. Current Minimum Closure

- 本轮唯一目标：
  - 把供应商展示工作台从长页面压缩为 `首页 + 模块入口 + 关键预览 + 真实动作`
- 首页只允许消费现有 Flutter 已读取的 workbench / published-change / case / status 数据。
- 详细编辑内容只能通过现有 section 或本地模块页承接，不新增接口，不新增真值，不新增云端依赖。
- 已发布变更模式必须继续保持：
  - live public display
  - current change draft preview
  - submit current change
  - view change status
  的分离语义。

## 3. Homepage Field Mapping

| 首页块 | 字段 / 行为 | 当前来源 | 编辑性 | 本轮处理 | 禁止事项 |
|---|---|---|---|---|---|
| 供应商身份卡 | 供应商名称 | `EnterpriseHubWorkbenchBasic.name`；缺失时回退认证 legalName 摘要 | 只读展示 | 首页展示 | 不新增手填公司名 |
| 供应商身份卡 | Logo | `basic.logoUrl / logoFileAssetId` 与现有 `_logoImage` | 可通过现有 Logo 上传维护 | 首页展示，编辑入口回现有展示标识模块 | 不伪造图片 |
| 供应商身份卡 | 供应商标签 | `boardProfile.supplyCategories` | 可编辑 | 首页展示最多 3 个，编辑入口进入服务能力模块 | 不增加新标签源 |
| 供应商身份卡 | 一句话简介 | `basic.shortIntro` | 当前已回读但不在主编辑流 | 首页只读展示；编辑不作为本轮主入口 | 不恢复为基础资料主输入 |
| 供应商身份卡 | 当前状态 badge | `latestApplication.applicationStatus`、`readiness.submitReady`、`published change status` | 只读 | 首页展示状态摘要 | 不派生第二套状态机 |
| 供应商身份卡 | 编辑资料 | 本地模块入口 | 本地导航 | 进入核心信息模块 | 不新增全局路由 |
| 供应商身份卡 | 预览展示页 | published mode 使用 live / draft preview；application mode 只给草稿预览或当前资料预览 | 只读 | 明确区分草稿预览与线上展示 | 不把工作台当公域详情页 |
| 数据概览 | 曝光 / 访客 / 询盘 / 收藏 | 当前 workbench contract 未提供 | 不可编辑 | 本轮延期，首页不展示实数 | 不显示假 0 或假数字 |
| 模块入口 | 核心信息 | `basic.fullIntro / teamSizeRange / cooperationModes` | 可编辑 | 入口化，进入现有基础资料 section | 不删除字段 |
| 模块入口 | 联系方式 | `primaryContact.*`、`basic.contactVisible` | 可编辑 | 入口化，进入现有联系人 section | 不新增公开联系 CTA |
| 模块入口 | 服务能力 | `boardProfile.supplyCategories / coreProductsOrServices / responseSlaDesc / deliveryRange` | 可编辑 | 入口化，进入现有展示标识 / supplier profile section | 不恢复 retired `supplyMode` |
| 模块入口 | 项目案例 | `cases` 与现有 case editor | 可编辑 | 首页显示 1-3 条，新增 / 编辑继续跳现有 case editor | 不重写案例链 |
| 模块入口 | 认证与资料真值 | `certification`、conditional upstream truth | 只读 / 条件提示 | 入口化或条件展示 | 不新建资质管理真值 |
| 模块入口 | 提交与状态 | `readiness`、`latestApplication`、published change status | 只读 + 真实动作 | 首页摘要和底部动作栏承接 | 不新增假按钮 |
| 公开展示预览 | 企业位置 | `basic.location / address / provinceName / cityName` | 可通过现有位置区维护 | 首页只展示摘要 | 不伪装完整地图已接通 |
| 公开展示预览 | 服务与优势 | supplier board profile fields | 可编辑 | 首页最多展示 1-3 条 | 不新增运营文案 |
| 公开展示预览 | 精选案例 | `cases` | 可编辑 | 首页最多展示 1-3 条 | 不虚构案例 |
| 公开展示预览 | 客户评价 | 当前 public detail 可有 review summary，但 workbench homepage 无管理真值 | 只读且不稳定 | 本轮延期 | 不做客户评价管理页 |
| 公开展示预览 | 最新动态 | 当前 workbench contract 未提供 | 不可编辑 | 本轮延期 | 不接论坛或动态流 |
| 底部操作栏 | 查看状态 | existing status route | 真实动作 | 条件显示 | 不新增路由 |
| 底部操作栏 | 提交申请 / 提交变更 / 重新创建草稿 | existing workbench actions | 真实动作 | 按当前 disposition 条件显示 | 不新增保存草稿按钮 |
| 底部操作栏 | 删除当前板块展示 | existing delete action | 真实动作 | 保留但弱化为危险动作 | 不改删除语义 |

## 4. Module Rule

- 本轮只允许最小模块：
  - 核心信息
  - 联系方式
  - 服务能力
  - 项目案例
  - 认证与资料真值
  - 提交与状态
- 模块页实现方式：
  - 优先本地页面栈 / 本地 full-screen drill-in
  - 不新增 app router 全局 path
  - 不改 bottom nav
- 每个模块必须继续复用现有保存、上传、提交、案例和状态动作。

## 5. Preview Rule

- application mode：
  - 只能展示当前工作台资料摘要
  - 文案必须标明不是线上公开展示
- published-change mode：
  - 必须继续使用现有 live public display 与 current change draft preview 分离
  - 保存修改不得被解释为直接更新线上展示
- 本轮不得把 public detail CTA 迁移成私域工作台主操作。

## 6. Deferred Items

- 本轮明确延期：
  - 展示曝光
  - 访客人数
  - 询盘数量
  - 收藏数量
  - 客户评价管理页
  - 最新动态
  - 联系供应商
  - 分享名片
  - 团队实力
  - new analytics BFF surface
  - new review read/write surface
  - new activity feed surface

## 7. File Boundary

- 允许修改：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_*`
  - `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
  - `apps/mobile/test/enterprise_hub_routes_test.dart`
- 允许新增：
  - supplier homepage / module section 的 Flutter part 文件
  - supplier homepage 对应 widget tests
- 禁止修改：
  - `apps/bff/**`
  - `apps/server/**`
  - `docs/01_contracts/**`
  - database migrations / seeds
  - cloud deployment artifacts

## 8. Acceptance Criteria

- 首页每个展示块均有现有真值来源。
- 延期项明确不可展示假数据。
- 供应商工作台页面长度明显短于旧长页。
- 模块入口清晰，详细字段不在首页全部摊开。
- bottom nav / bottom safe area 不遮挡底部动作。
- company / factory workbench 不因 supplier 分支回归。
- published change corridor 不被削弱。
- `flutter analyze` 和目标 `flutter test` 通过或给出明确非本轮原因。

## 9. Formal Conclusion

- `供应商展示工作台首页化` 当前允许进入：
  - local Flutter implementation
  - local widget tests
  - readonly tunnel smoke
- 当前不允许进入：
  - BFF / Server / contracts implementation
  - cloud deployment
  - analytics / review / activity feed implementation
  - release-prep

## 10. Implementation File Blueprint

| File / module | Action | Responsibility boundary |
|---|---|---|
| `enterprise_hub_workbench_pages.dart` | register supplier homepage parts and local module refresh bridge | page state wiring only |
| `enterprise_hub_workbench_page_shell.dart` | branch supplier full workbench into compact homepage | supplier-only shell selection |
| `enterprise_hub_workbench_page_supplier_homepage.dart` | add supplier homepage container, identity card, status summary, module section | homepage layout only |
| `enterprise_hub_workbench_page_supplier_homepage_entries.dart` | add module entry row and public preview summary | homepage entry / preview only |
| `enterprise_hub_workbench_page_supplier_modules.dart` | add local module drill-in pages and bottom action bar | local page stack only; no global route |
| `enterprise_hub_workbench_page_supplier_support.dart` | add supplier display labels and preview helpers | read-only formatting helpers |
| `enterprise_hub_workbench_page_supplier_widgets.dart` | add private visual atoms | supplier homepage private widgets |
| `enterprise_hub_workbench_stage1_relayout_test.dart` | add supplier homepage and module drill-in coverage | route-local widget regression |
| `enterprise_hub_routes_test.dart` | update supplier profile save route test for module drill-in | existing save-chain regression |
| screenshot artifacts | generate standard and narrow captures | acceptance evidence only |

## 11. Test Matrix

| Test / check | Scope | Expected result |
|---|---|---|
| `flutter analyze lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart test/enterprise_hub_workbench_stage1_relayout_test.dart test/enterprise_hub_routes_test.dart` | targeted Flutter static check | no issues |
| `flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart` | company, supplier, published-change relayout regressions | all pass |
| `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise supplier workbench keeps single category save and hides retired supply mode UI"` | supplier service module and save body | pass; no retired `supplyMode` |
| standard screenshot | 430px width supplier homepage | generated |
| narrow screenshot | 360px width supplier homepage | generated |
| readonly tunnel smoke | `GET /api/app/exhibition/enterprise-hub/supplier/workbench` through `127.0.0.1:8080` | tunnel reaches BFF; unauthenticated request may return 401 |
