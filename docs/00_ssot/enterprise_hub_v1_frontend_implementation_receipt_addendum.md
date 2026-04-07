---
owner: Frontend Agent
status: draft
purpose: Record the local frontend implementation receipt for enterprise_hub V1 so result verification can use concrete mobile-side evidence.
layer: L0 SSOT
---

# Enterprise Hub V1 Frontend Implementation Receipt Addendum

## 1. 当前对象
- 当前对象：
  - `enterprise_hub V1`
- 当前执行角色：
  - Frontend Agent
- 当前执行范围：
  - `apps/mobile`
- 当前执行日期：
  - `2026-04-02`
- 当前实现边界：
  - 展览首页既有三卡到 `enterprise_hub` 的消费与跳转
  - `companies / factories / suppliers` 列表页
  - `enterprise detail`
  - `enterprise apply / application status`
  - 受控 `403 / 404 / empty-state` 展示
- 当前未实现项：
  - 新 building
  - 新底部 tab
  - 直连 `Server`
  - 绕过 `BFF`
  - release-prep / release

## 2. 修改文件清单
- `apps/mobile/lib/core/api/app_api_client.dart`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart`
- `apps/mobile/test/widget_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

## 3. 接入页面与路由清单
- 首页三卡承接：
  - `优秀公司 -> /exhibition/companies`
  - `优秀工厂 -> /exhibition/factories`
  - `优秀供应商 -> /exhibition/suppliers`
- 列表页：
  - `/exhibition/companies`
  - `/exhibition/factories`
  - `/exhibition/suppliers`
- 详情页：
  - `/exhibition/companies/detail?enterpriseId=...`
  - `/exhibition/factories/detail?enterpriseId=...`
  - `/exhibition/suppliers/detail?enterpriseId=...`
- 申请页：
  - `/exhibition/enterprise/apply?boardType=company|factory|supplier`
- 申请状态页：
  - `/exhibition/enterprise/application-status?applicationId=...&boardType=...`

## 4. 与 BFF 路径对应关系
- 首页三卡摘要：
  - `GET /api/app/exhibition/home`
  - 读取 `modules` 中的 `excellent_company / excellent_factory / excellent_supplier`
- 列表页：
  - `GET /api/app/exhibition/enterprise-hub/enterprises`
  - `GET /api/app/exhibition/enterprise-hub/recommendations`
- 详情页：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- 申请页：
  - `POST /api/app/exhibition/enterprise-hub/applications`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/company`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/supplier`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases`
  - `POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit`
- 申请状态页：
  - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`

## 5. 路径 / 页面 / 数据落地情况
- 首页未新增第七容器，继续复用既有三卡作为 `enterprise_hub` 入口。
- `companies / factories / suppliers` 三类列表共用一套消费页骨架，按 `boardType` 切换筛选项、推荐位和卡片跳转。
- `enterprise detail` 统一承接：
  - `header`
  - `basicInfo`
  - `boardProfile`
  - `serviceAreas`
  - `cases`
  - `certifications`
  - `reviewSummary`
  - `contacts`
- `enterprise apply` 继续绑定现有登录、组织、认证上下文，不引入第二套账号或组织真相。
- `enterprise application status` 按 applicationId 读取受控业务态。
- `apps/mobile` 仅消费 `/api/app/*` 冻结路径族，未接入 `/server/*`，未使用直连 `Server`。

## 6. 本地运行与 tunnel 联调结果
- `flutter analyze`：
  - 执行目录：`apps/mobile`
  - 校验对象：13 个 enterprise_hub 相关实现与测试文件
  - 结果：`No issues found!`
- `flutter test test/widget_test.dart test/enterprise_hub_routes_test.dart`
  - 执行目录：`apps/mobile`
  - 结果：`9 tests passed`
- `flutter run -d macos --dart-define=APP_BFF_BASE_URL=http://127.0.0.1:8080/api/app`
  - 执行目录：`apps/mobile`
  - 结果：成功构建并启动 `mobile.app`
  - 附加结果：应用进入可交互调试态后正常退出
- tunnel 联调检查：
  - `curl -i --max-time 5 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/recommendations?boardType=company'`
  - `curl -i --max-time 5 'http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=10'`
  - 当前结果：两次均返回 `curl: (7) Failed to connect to 127.0.0.1 port 8080`
  - 当前判断：本轮执行时本机未存在活动 tunnel，未拿到 live BFF 返回体

## 7. 403 / 404 / empty-state 展示情况
- 列表页：
  - `403`：显示受控无权限态，不伪造成功列表
  - `404`：显示受控未找到态
  - `empty-state`：当冻结 list payload 的 `items` 为空时显示空态，不误判为内容态
  - 推荐位：区分 `empty / forbidden / notFound / failed`
- 详情页：
  - `404`：显示后端返回 message，不伪造详情内容
  - `403`：显示受控失败卡片，不伪造详情内容
- 申请状态页：
  - `404`：显示后端返回 message
  - `403`：显示受控失败卡片
- 申请页：
  - 登录、组织、认证前置不足时，回退到现有上下文入口，不伪造可申请态
  - create / update / submit 的 `4xx/5xx` 通过 `SnackBar` 展示 BFF 返回 message

## 8. 当前剩余阻断项
- 仓库中未找到你点名的前置文档：
  - `docs/00_ssot/enterprise_hub_v1_bff_implementation_receipt_addendum.md`
- 当前本机无活动 tunnel：
  - `127.0.0.1:8080` 无法连接
- 当前缺少可验证的 live BFF 返回体：
  - 无法完成真实数据联调截图或返回样本归档
- `enterprise apply` 案例封面当前仍要求已有 `caseCoverFileAssetId`
  - 本轮未扩上传流，符合当前冻结范围
- 真实账号 / 组织上下文与可验证业务数据前置仍未在本轮补齐
  - 当前 `403 / 404` 仍需按冻结说明视为受控业务态

## 9. 是否可移交下一角色
- 可以移交结果校验：
  - 前提一：补齐 BFF 回执文档
  - 前提二：启动可访问 `127.0.0.1:8080` 的 tunnel 或等价本地联调入口
- 当前不应移交 release-prep / release：
  - live 联调证据仍不完整
  - 真实账号组织上下文前置仍未补齐
