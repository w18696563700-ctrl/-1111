---
owner: Codex 总控
status: frozen
phase_day: 第 1 天
layer: L0 SSOT
purpose: >
  Freeze the bounded Flutter-only scope, field truth, button capability,
  route truth, and acceptance gates for refining the My Project Detail
  prepublish material-completion and publish-confirmation page.
---

# 《预发布补资料并发布页 UI 精修边界冻结单》

## 1. 总裁决

本轮裁决：`Go`。

允许进入实现的前提：

1. 只修改 Flutter 前端展示层和既有 Flutter 入口调用。
2. 不修改 BFF、Server、contracts、OpenAPI、数据库、Nginx、云端服务和生产配置。
3. 不修改项目状态机、发布规则、诚意金规则、文件上传三步流。
4. 不新增接口字段、不新增假资料、不新增假支付、不新增假发布能力。
5. 不删除现有字段，只允许重排、弱化、折叠、分组。
6. `内测期间暂不需要真实支付` 只能作为说明文案和对既有 `not_required / frozen / paid` 等真实状态的展示承接，不得在 Flutter 伪造支付完成。

## 2. 本轮目标

将 `我的项目详情：预发布补资料并发布页` 优化为更短、更清晰的 Flutter 页面：

- 状态先行。
- 项目摘要默认只展示关键字段。
- 发布进度使用清晰 stepper。
- 诚意金大段规则默认折叠。
- 当前阶段动作主次分层。
- 五类报价依据资料形成 checklist。
- 五类资料均支持 `照片 / 文件` 二选一。
- 图片类附件卡片轻量展示，技术字段默认折叠。
- 公共资源下载区弱化技术字段，并修复移动端下载打开方式。
- 底部主操作不得被 bottom nav 遮挡。

## 3. 本轮范围

### 3.1 Flutter 页面和模块

| 对象 | 文件 / 模块 |
|---|---|
| 页面主体 | `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart` |
| 发布进度 / 诚意金卡片 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart` |
| 报价依据资料类型、选择器、上传规则展示 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart` |
| 报价依据资料区状态、上传、回读、预览入口 | `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart` |
| 报价依据资料卡片和类型选择面板 | `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart` |
| 图片预览组件 | `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_preview_widgets.dart` |
| 公共资源下载展示 | `apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart` |
| 公共资源下载打开方式 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart` |
| 竞标提交页模板下载复用区 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_template_download_support.dart` |

### 3.2 允许的 SSOT 文书

- 本冻结单。
- 本轮完成后的执行验收回执。
- `docs/00_ssot/source_of_truth_map.md` 索引登记。

## 4. 本轮非目标

1. 不做 BFF 改造。
2. 不做 Server 改造。
3. 不做 contracts / OpenAPI 改造。
4. 不做数据库、migration、云端部署、Nginx 或系统服务改造。
5. 不改项目状态机。
6. 不改发布门禁。
7. 不改诚意金订单、支付、预授权、退款、释放规则。
8. 不改文件上传三步流：`init -> direct upload -> confirm`。
9. 不新增真实支付绕过。
10. 不新增无真实路由的 `预览项目` 假入口。
11. 不新增公共资源假数据。
12. 不改 bottom nav 路由。

## 5. 只读核实清单

### A. 当前页面文件位置

- 页面主体：`apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- 路由注册：`apps/mobile/lib/shell/navigation/app_router.dart`
- 页面标题组件：`apps/mobile/lib/features/exhibition/presentation/widgets/project_edit_surface_widgets.dart`

### B. 当前项目摘要字段来源

页面读取：

- `ExhibitionConsumerLayer.instance.loadMyProjectDetail(projectId: widget.projectId)`
- canonical path：`GET /api/app/my/projects/{projectId}`

字段来自 payload：

- `publicProject.projectId`
- `publicProject.projectNo`
- `publicProject.title`
- `publicProject.buildingType`
- `publicProject.budgetAmount`
- `publicProject.areaSqm`
- `publicProject.state`
- `privateProgress.formalCompletionStatus`

### C. 当前发布进度字段来源

发布进度由 Flutter 根据 `publicProject.state` 和诚意金快照派生：

- `draft -> basic`
- `submitted -> quoteBasis / sincerity / confirmation`
- `published / awarded / converted_to_order / active -> published`

实现位置：

- `_projectPublishProgressStepForState`
- `_ProjectPublishProgressCard`

### D. 当前诚意金状态字段来源

页面在 `submitted / published / awarded / converted_to_order` 等状态读取：

- `ExhibitionConsumerLayer.instance.loadProjectPricingSummary(projectId: projectId)`
- canonical path：`GET /api/app/project/{projectId}/pricing-summary`

Flutter 只消费既有字段：

- `publisherPricing.authenticitySincerityStatus`
- `publisherPricing.publishGateStatus`
- `publisherPricing.authenticitySincerityAmount`
- `publisherPricing.authenticitySincerityOrderId`
- `projectAuthenticitySincerity.status / orderStatus / depositStatus`
- `projectAuthenticitySincerity.orderId / depositOrderId`
- `channelCandidates`

已存在的通过态承接：

- `paid`
- `frozen`
- `succeeded`
- `satisfied`
- `not_required`

本轮不得在 Flutter 伪造这些状态。

### E. 当前报价依据资料字段来源

页面读取：

- `ExhibitionConsumerLayer.instance.loadProjectAttachments(projectId: projectId)`
- canonical path：`GET /api/app/my/projects/{projectId}/attachments`

上传和绑定继续走：

- `POST /api/app/file/upload/init`
- signed direct upload
- `POST /api/app/file/upload/confirm`
- `POST /api/app/my/projects/{projectId}/attachments`

### F. 当前效果图 / 附件字段来源

回读模型字段：

- `attachmentId`
- `projectId`
- `fileAssetId`
- `fileName`
- `attachmentKind`
- `mimeType`
- `visibility`
- `sortOrder`
- `createdAt`
- `createdBy`

本轮可以弱化或折叠：

- 完整文件名
- 文件类型
- 可见范围
- 排序序号
- 创建时间长格式
- 其他技术字段

不得删除或篡改 payload 字段。

### G. 当前公共资源字段来源

公共资源目录读取：

- `ExhibitionConsumerLayer.instance.loadProjectPublicResources()`
- canonical path：`GET /api/app/project/public-resources`

公共资源访问：

- `ExhibitionConsumerLayer.instance.requestProjectPublicResourceDownload(fileAssetId: resource.fileAssetId)`
- canonical path：`GET /api/app/file/access?fileAssetId=...&mode=download`

当前分类真相：

- `contract_template`：合同模板
- `process_guide`：流程图与说明
- `other_resource`：公共资料

### H. 当前按钮真实能力

| 按钮 | 真实能力 |
|---|---|
| 继续支付诚意金 | 调用 `pay-init` 后拉起支付通道，并轮询订单状态 |
| 刷新状态 | 重新读取 `project pricing-summary` |
| 检查无误，确定发布 | 先检查必传效果图，再检查诚意金门禁，最后调用 `publishProject` |
| 返回草稿继续编辑 | 当前 submitted 阶段调用 `withdrawProject`，不是普通编辑跳转 |
| 作废删除 | 当前 submitted 阶段调用 `discardSubmittedProject` |
| 预览图片 / 预览资料 | 请求 `file/access`，图片优先 App 内加载预览，非图片打开访问链接 |
| 删除资料 | 调用 `deleteProjectAttachment` |
| 下载资料 | 请求公共资源 `file/access` 并打开 accessUrl |

按钮文案可以更清晰，但不得改变真实能力。

### I. 当前是否存在预览项目路由

存在真实公域项目详情路由：

- `ExhibitionRoutes.projectDetail`
- `ExhibitionRoutes.projectDetailWithProjectId(projectId)`

因此本轮可在 `projectId` 有效时显示 `预览项目`，并跳转到真实 `ProjectDetailPage`。若 `projectId` 缺失，不得显示该入口。

### J. 当前 bottom nav 是否遮挡内容

当前 shell 使用固定 bottom navigation：

- `AppShellScaffold.bottomNavigationBar`
- 78px NavigationBar + 外部 padding

页面主体在 shell body 内滚动，若本轮新增底部固定 CTA，必须在页面内容底部保留足够安全留白，避免被 bottom nav 视觉遮挡。

### K. 当前相关测试文件

优先回归：

- `apps/mobile/test/my_project_private_carry_test.dart`
- `apps/mobile/test/project_attachment_corridor_test.dart`
- `apps/mobile/test/shell_app_test.dart`

视改动范围补充：

- `apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart`
- 公共资源下载相关既有断言所在测试。

## 6. 阶段门禁核查表

| 门禁 | 结论 | 说明 |
|---|---|---|
| 只读核实 | Passed | 页面、字段、按钮、路由、bottom nav、测试文件已核对 |
| SSOT 冻结 | Passed | 本冻结单落地后可进入 Flutter 实现 |
| contracts | Passed | 本轮不改 contracts / OpenAPI |
| BFF | Passed | 本轮不改 BFF |
| Server | Passed | 本轮不改 Server |
| 云端 | Passed | 本轮只读 health / 真实链路验证，不部署不改配置 |
| 支付真相 | Passed with Guard | 只显示内测说明，不伪造支付完成 |
| 预览项目入口 | Passed with Guard | 仅复用真实 `projectDetailWithProjectId` |

## 7. 风险点

1. `内测期间暂不需要真实支付` 可能被误解为已完成支付。
   - 处理：文案必须绑定平台返回状态，不改变门禁。
2. 五类资料入口若统一照片入口，容易误改成只支持图片。
   - 处理：二选一后照片走相册，文件仍走全格式文件选择。
3. 公共资源下载依赖云端返回 `accessUrl`。
   - 处理：Flutter 只修移动端打开方式；无登录态、无 accessUrl 时保留失败提示。
4. 技术字段折叠后用户可能找不到排查信息。
   - 处理：提供 `高级信息` 展开，不删除字段。
5. 底部固定 CTA 可能与 bottom nav 视觉重叠。
   - 处理：CTA 内置 SafeArea 和滚动内容底部留白。

## 8. 验收标准

1. changed files 不包含 BFF、Server、contracts、OpenAPI、数据库、infra。
2. 没有新增生产 mock。
3. 没有新增接口字段。
4. 没有新增假资料、假支付、假发布能力。
5. 没有删除字段。
6. 项目摘要默认只显示项目名称、项目编号、当前阶段。
7. 发布进度为五步 stepper。
8. 诚意金规则默认折叠，按钮能力不变。
9. 当前阶段动作分为主操作、次操作、危险操作。
10. 五类报价依据资料都有已上传数量和待补充状态。
11. 五类资料入口都能选择照片或文件，且文件仍支持 PDF / 图纸 / 文档等全格式。
12. 图片类附件展示轻量化，技术字段默认折叠。
13. 公共资源保留三类分类，移动端下载能打开真实 accessUrl。
14. bottom nav 不遮挡底部 CTA。
15. `flutter analyze` 通过或只剩明确非本轮旧问题。
16. 相关 Flutter tests 通过或给出明确非本轮阻塞。
17. 隧道 health 只读验证通过。

## 9. 四类判断

| 判断 | 结论 |
|---|---|
| 哪个更稳 | Flutter-only 展示层精修 + 既有入口调用修正 |
| 哪个更省成本 | 只改五类资料二选一和公共资源移动端打开 |
| 哪个更适合当前阶段 | 本冻结单范围：页面精修、资料入口修正、移动端下载修复 |
| 哪个风险最大 | 为内测免支付直接改 BFF/Server 返回已支付或已冻结 |

## 10. 第 1 天门禁结论

第 1 天结论：`Go`。

允许进入第 2 天至第 6 天 Flutter-only 实现；第 7 天执行测试、截图、隧道只读联调和收口回执。
