---
owner: Codex 总控
status: frozen
purpose: >
  Record Day4 regression, copy acceptance, Day5 local Flutter over 8080 cloud
  UAT, and stage-gate decision for publisher project detail information-density
  optimization.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/publisher_project_detail_information_density_optimization_ruling_addendum.md
  - docs/04_frontend/publisher_project_detail_information_density_optimization_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart
  - apps/mobile/test/my_project_private_carry_test.dart
  - apps/mobile/test/project_attachment_corridor_test.dart
  - apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart
---

# 《发布方项目详情页信息密度优化 Day4-Day5 UAT 与阶段门禁核查表》

## 1. 本轮范围

本回执只覆盖发布方 `我的项目详情` 页的信息密度优化闭环：

- 基础信息默认折叠。
- 当前页隐藏大块 `项目沟通` 主入口。
- `报价依据资料` 成为主任务区。
- 正式资料卡片展示资料名称、文件名、文件类型、可见范围、排序、创建时间和操作。
- `公共资源下载区` 裁剪长说明文案，只保留分类、下载卡和必要空态。

本回执不声明 BFF / Server / DB / OSS 变更，也不声明五条真实上传资料在当前登录账号项目中全部存在。

## 2. Day4 测试回归

### 2.1 静态分析

命令：

```bash
flutter analyze \
  lib/features/exhibition/presentation/pages/my_project_detail_page.dart \
  lib/features/exhibition/presentation/widgets/project_attachment_panels.dart \
  lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart \
  lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart \
  lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart \
  test/my_project_private_carry_test.dart \
  test/project_attachment_corridor_test.dart \
  test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `No issues found`

### 2.2 Widget / Flow 测试

命令：

```bash
flutter test \
  test/my_project_private_carry_test.dart \
  test/project_attachment_corridor_test.dart \
  test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `33` 个测试通过。
- 覆盖基础信息默认折叠和展开。
- 覆盖当前页不展示 `项目沟通 / 项目澄清` 主入口。
- 覆盖资料卡字段 `资料名称 / 文件名 / 可见范围`。
- 覆盖 `接单方在竞标第二步查看` 权限文案。
- 覆盖公共资源短文案 `可下载平台共享模板与公共资料。`
- 覆盖 owner 上传、预览、删除链路仍可用。
- 覆盖接单方竞标页不展示 owner 预览 / 管理按钮。

## 3. Day4 文案验收

文案核查结论：

| 文案点 | 结论 |
| --- | --- |
| `资料名称` | 清楚。资料名称来自 `attachmentKind` 映射，不要求发布方另填标题。 |
| `文件名` | 清楚。原始文件名仍展示，方便发布方核对上传文件。 |
| `可见范围` | 清楚。`owner_private` 展示为 `仅 owner 私域可见；接单方在竞标第二步查看`。 |
| `接单方在竞标第二步查看` | 清楚。表达该资料已进入报价依据链路，但不暗示公开下载或无资格访问。 |
| 空态 `当前还没有补充报价依据资料。` | 清楚。发布方知道当前项目还没有正式 bind 成功的资料。 |
| 公共资源 `可下载平台共享模板与公共资料。` | 清楚。公共资源被弱化，不再抢报价依据资料主任务。 |

文案保留边界：

- 不新增 `资料标题` 字段。
- 不允许用户本轮自定义每个附件标题。
- 不把 `owner_private` 误写成全公开。
- 不把 `公共资源下载区` 解释成报价依据资料。

## 4. Day5 8080 隧道与本地 Flutter 联调

### 4.1 8080 隧道状态

本机 8080 端口由 SSH tunnel 监听：

- `ssh` 进程监听 `127.0.0.1:8080`

云上 app-facing 路由探测：

- `GET /api/app/project/public-resources` 返回受控 `401 AUTH_SESSION_INVALID`
- `GET /api/app/project/bid-materials?projectId=cc25fd27-75a6-4d50-88b3-a223af65be3a` 返回受控 `401 AUTH_SESSION_INVALID`

结论：

- 8080 到云上 Nginx / BFF / Server 入口可达。
- 未登录 curl 返回 401 是预期认证边界，不是路由 404。

### 4.2 本地 Flutter 重启

本地 Flutter macOS app 已重建并重启：

```bash
flutter build macos --debug
open build/macos/Build/Products/Debug/mobile.app
```

运行入口：

- Flutter 默认 `sshTunnel` base URL：`http://127.0.0.1:8080/api/app`

### 4.3 Computer Use 视觉核对

登录后进入：

`我的 -> 我的项目 -> 我的发布 -> 进行中 -> 西洽会 - 泸州 -> 查看详情`

视觉核对通过项：

- 页面标题为 `我的项目详情`。
- 顶部 `已保存的项目基础信息摘要` 默认只展示项目名称、项目编号、当前阶段。
- 展开按钮为 `展开项目基础信息`。
- 当前页未出现大块 `项目沟通` 卡片。
- `报价依据资料` 区位于公共资源之前。
- 报价依据资料区展示 5 类入口：
  - 效果图
  - 尺寸图 / 施工图
  - 材质图 / 材料样板
  - 设备物料清单
  - 服务清单
- 当前项目无已 bind 的正式报价依据资料时，空态显示：
  - `当前还没有报价依据资料`
  - `当前还没有补充报价依据资料。只有 bind 成功后，报价依据资料才会出现在这里。`
- 公共资源区文案为：
  - `可下载平台共享模板与公共资料。`
- 公共资源区保留分类 chips、共享资料列表和 `下载资料` 按钮。

视觉核对保留项：

- 当前登录账号下核对到的项目是 `EXH-2026-DD93A8 / 西洽会 - 泸州`，该项目当前没有 5 条已上传正式报价依据资料；因此本回执只声明“五类入口和展示结构清楚”，不声明“5 条正式资料记录全部显示”。
- owner 真实上传、预览、删除链路由 Day4 widget / flow 测试覆盖；本次 UAT 未执行真实上传、删除或下载写动作。

## 5. 阶段门禁核查表

| Gate | 状态 | 说明 |
| --- | --- | --- |
| L0 ruling 已冻结 | Pass | 已冻结基础信息折叠、项目沟通当前页隐藏、报价依据资料主任务、公共资源弱化。 |
| L5 frontend surface 已冻结 | Pass | 已冻结页面顺序、折叠状态、卡片字段、按钮保留、公共资源文案裁剪。 |
| Flutter 实现 | Pass | 发布方项目详情页已按冻结口径实现。 |
| 基础信息默认折叠 | Pass | 测试与本地视觉核对均通过。 |
| 项目沟通当前页隐藏 | Pass | 当前页不展示 `项目沟通 / 项目澄清` 主卡；消息楼能力未删除。 |
| 报价依据资料全宽字段 | Pass | 资料卡展示 `资料名称 / 文件名 / 文件类型 / 可见范围 / 排序 / 创建时间 / 操作`。 |
| 公共资源文案精简 | Pass | 长说明已移除，保留短文案、分类、下载卡和必要空态。 |
| 上传 / 预览 / 删除链路 | Pass | 目标测试通过；未改 BFF / Server / DB / OSS。 |
| 8080 云上入口 | Pass | Tunnel 可达，app-facing route 返回受控 401。 |
| 本地 Flutter 云端展示 | Pass | 本地 macOS app 已通过 8080 打开云上数据并完成视觉核对。 |
| 真实五条资料记录展示 | Not claimed | 当前登录账号项目无 5 条正式资料记录，本回执不做虚假完成声明。 |

## 6. Veto 项

当前无 veto。

未触发的 veto：

- 未改 BFF / Server。
- 未改 DB / OSS。
- 未新增资料标题字段。
- 未删除项目沟通底层能力。
- 未把公共资源合并进报价依据资料。
- 未执行真实上传、删除、支付或提交等高风险动作。

## 7. 后续扩展位

允许进入下一阶段之一：

- 真实账号验收：使用存在 5 条正式报价依据资料的发布方项目，核对每条正式记录的资料名称、文件名、可见范围、预览和删除按钮。
- 自定义资料标题阶段：另开 L0 / L2 / L3 / L4 / L5，评估是否新增 `materialTitle` 或 display-only title，当前阶段不得直接加字段。
- 项目详情轻量沟通跳转：仅在必要状态下恢复小型跳转入口，不恢复大块沟通卡。
- 公共资源个性化推荐：另开阶段，不与报价依据资料混合。

## 8. 结论

本阶段结论为：

- `Go for current Flutter delivery`
- `Go for next real-account visual acceptance`
- `Go for a separately frozen custom-material-title stage`

当前发布方项目详情页信息密度优化闭环可交付。
