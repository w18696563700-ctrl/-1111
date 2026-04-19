# enterprise_hub mobile structural compliance cleanup execution receipt addendum

## 1. 修改文件清单

### data / published-change consumer
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_models.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_paths.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_parser.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_transport.dart`

### presentation / workbench
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_form_state.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_hydration.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_profile_actions.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_submit_actions.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_interactions.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_submit_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_truth_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_application_status_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_request_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_application_status_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_published_change_disposition_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_truth_copy_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_error_copy_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_ui_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_format_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_equipment_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_guard_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_media_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_location_options.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_page_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/forum/forum_asset_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_page_frames.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_surface_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart`

### tests
- 本轮未新增或改写测试文件。
- 直接复用 `apps/mobile/test/enterprise_hub_routes_test.dart` 做 published-change / workbench 主链回归验证。

## 2. 拆分后的职责分布

### published-change consumer
- `enterprise_hub_published_change_consumer_layer.dart`
  - 对外 facade，只保留 app-facing published-change consumer API。
- `enterprise_hub_published_change_models.dart`
  - published-change status / readiness / snapshot 数据模型。
- `enterprise_hub_published_change_paths.dart`
  - canonical path 组装。
- `enterprise_hub_published_change_parser.dart`
  - payload parse / mapping。
- `enterprise_hub_published_change_transport.dart`
  - transport request、ack helpers、失败态收口。

### workbench
- `enterprise_hub_workbench_pages.dart`
  - page shell entry、state 字段、route hydration、debug test hooks。
- `enterprise_hub_workbench_page_form_state.dart`
  - 表单 reset、case composer state、图片 id 收口。
- `enterprise_hub_workbench_page_load.dart`
  - workbench / published-change workbench 读取与 supporting truth load。
- `enterprise_hub_workbench_page_hydration.dart`
  - workbench payload hydration、organization truth / certification truth 同步。
- `enterprise_hub_workbench_page_basic_profile_actions.dart`
  - basic save、profile save、统一 action running 状态。
- `enterprise_hub_workbench_page_case_actions.dart`
  - create case、continue edit、save modification。
- `enterprise_hub_workbench_page_submit_actions.dart`
  - submit application、submit current change、delete case、delete enterprise。
- `enterprise_hub_workbench_page_media_actions.dart`
  - logo / showcase / case 图片挑选上传、enterprise ensure、location fill。
- `enterprise_hub_workbench_page_interactions.dart`
  - snackbar message、case city/date picker 交互。
- `enterprise_hub_workbench_page_shell.dart`
  - workbench ListView shell、header section。
- `enterprise_hub_workbench_page_basic_sections.dart`
  - basic / board profile / brand / contact sections。
- `enterprise_hub_workbench_page_case_sections.dart`
  - case editor、equipment field、image field widgets。
- `enterprise_hub_workbench_page_snapshot_sections.dart`
  - published-change current snapshot / live snapshot panel。
- `enterprise_hub_workbench_page_submit_sections.dart`
  - submit panel、required hint、factory optional capability section。
- `enterprise_hub_workbench_page_truth_sections.dart`
  - address assist、upstream truth、certification summary、header status、guard。
- `enterprise_hub_application_status_page.dart`
  - application status / published-change status page。
- `enterprise_hub_workbench_request_support.dart`
  - request body builder、field normalization、list/image serialization。
- `enterprise_hub_workbench_application_status_support.dart`
  - application submit disposition helpers。
- `enterprise_hub_workbench_published_change_disposition_support.dart`
  - published-change disposition、status label、snapshot tone。
- `enterprise_hub_workbench_truth_copy_support.dart`
  - upstream truth / certification summary 的显示条件和 helper copy。
- `enterprise_hub_workbench_error_copy_support.dart`
  - published-change / application / case continuation 错误 copy 与 direct-edit exit 规则。
- `enterprise_hub_workbench_ui_support.dart`
  - readonly truth field、section notice UI。
- `enterprise_hub_workbench_format_support.dart`
  - date / address / image merge / board label formatting helpers。
- `enterprise_hub_workbench_equipment_support.dart`
  - factory equipment entry model。
- `enterprise_hub_workbench_guard_support.dart`
  - guard action widget。
- `enterprise_hub_workbench_media_support.dart`
  - workbench image constants、image item model、upload tile widgets。

## 3. 哪些超长文件已被拆解
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
  - 结构整改前：`674` 行单文件。
  - 结构整改后：facade `210` 行，剩余职责拆到 `83 / 37 / 194 / 188` 行的四个专责文件。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - 结构整改前：`4917` 行单文件。
  - 结构整改后：主文件 `390` 行。
  - 最大新分片：`enterprise_hub_workbench_page_media_actions.dart`，`433` 行。
  - 本轮新增的 workbench / status / support 手写文件均未超过 `450` 行门禁。

## 4. remediation 消除项
- `_EnterpriseApplicationPageState` 相关分片不再通过 `extension ... on _EnterpriseApplicationPageState` 直接调用 `setState`。
  - 已统一改为主 state 内部的 `_updateWorkbenchState(...)` 包装。
- 重复 debug hook 已从分片文件移除，只保留 `enterprise_hub_workbench_pages.dart` 的单一测试入口。
  - 已清理 `enterprise_hub_workbench_page_case_actions.dart`
  - 已清理 `enterprise_hub_workbench_page_media_actions.dart`
- mixed-responsibility support 已拆开，不再把 published-change status、认证摘要、上游真值、错误 copy 混在一个主责任文件里。
  - 已删除 `enterprise_hub_workbench_published_change_status_support.dart`
  - 已拆成 `enterprise_hub_workbench_published_change_disposition_support.dart`
  - 已拆成 `enterprise_hub_workbench_truth_copy_support.dart`
  - 已拆成 `enterprise_hub_workbench_error_copy_support.dart`
- 首轮整改遗留的 analyzer 残留已清零：
  - 删除未再消费的 location / payload / forum helper
  - 收口未被调用的 page-frame / surface-widget / attachment-section 历史参数

## 5. 明确保持不变的行为
- published-change workbench / status / submit flow 语义保持不变。
- `liveSnapshot` 与 `current change snapshot` 分离保持不变。
- `approved != applied` 用户侧语义保持不变。
- direct case continuation 与 workbench 主链行为保持不变。
- canonical app-facing route / transport 未改向，不新增业务能力，不改业务真值。

## 6. analyze / test 结果
- `cd apps/mobile && flutter analyze lib/features/exhibition/data lib/features/exhibition/presentation test/enterprise_hub_routes_test.dart`
  - 结果：`No issues found!`
- `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart`
  - 结果：`46 tests passed`
- remediation 结论：
  - analyzer 问题已归零。
  - routes test 全量通过。

## 7. 当前是否允许重新进入结果校验
- 允许重新进入结果校验。
- 边界说明：
  - 本轮结论仅代表 Flutter structural remediation 已完成并满足重新校验前提。
  - 本回执不宣告 corridor 已通过总体验收。
  - 是否通过结果校验，仍需以后续独立 verification 结论为准。

## 8. 当前剩余未闭合项
- 本轮 `enterprise_hub mobile structural compliance cleanup` 目标范围内，无剩余结构未闭合项。
- 未触碰：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - `docs/**` 既有 truth / contract 内容
  - 任何业务语义、contract、published-change / workbench 既有功能边界
