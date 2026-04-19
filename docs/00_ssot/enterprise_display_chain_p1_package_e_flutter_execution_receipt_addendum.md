# enterprise_display_chain_p1_package_e_flutter_execution_receipt_addendum

## 1. 修改文件清单

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
  - 对应冻结事实：1、2、3
  - 修改点：`EnterpriseHubListQuery`、`toQueryParameters()`、`copyWith()` 只保留正式最小集合；`plantAreaRange` 仅在 `factory` query 中发出。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
  - 对应冻结事实：1、3、4
  - 修改点：list page 只保留搜索、城市、`factory` 专属 `plantAreaRange`；移除 primary filter / sort 入口与对应状态流转。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_controls.dart`
  - 对应冻结事实：1、3、4
  - 修改点：toolbar button builder 只渲染城市按钮与 `factory` 专属 `plantAreaRange` 按钮，不再渲染 primary filter / sort。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_state_support.dart`
  - 对应冻结事实：1、3、4
  - 修改点：query builder 与 active-filter helper 收口到最小筛选集，不再承接历史 primary filter / sort 语义。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart`
  - 对应冻结事实：3、4
  - 修改点：surface spec 删除仅服务历史 primary filter UI 的字段；保留卡片摘要/详情展示高亮相关 helper，不改 board-specific summary 逻辑。
- `apps/mobile/test/enterprise_hub_routes_test.dart`
  - 对应冻结事实：1、3、4
  - 修改点：补齐最小 query / UI cleanup / 高亮保留测试。

## 2. 删除的 fake-filter UI / query 字段清单

### 2.1 Query 字段删除

从 `EnterpriseHubListQuery`、`toQueryParameters()`、相关 builder 逻辑中删除：

- `certifiedOnly`
- `sortBy`
- `exhibitionType`
- `serviceCity`
- `processType`
- `urgentCapability`
- `warehouseCapability`
- `supplyCategory`
- `supplyMode`

### 2.2 用户可见 fake-filter UI 删除

从 enterprise public list toolbar 中删除：

- primary filter button
  - company：`业务方向`
  - factory：`工艺类型`
  - supplier：`供应品类`
- sort button
  - `默认排序`

## 3. 保留的最小筛选集说明

当前 Flutter public list query builder 与正式 contract 对齐后，只保留：

- `boardType`
- `keyword`
- `provinceCode`
- `cityCode`
- `plantAreaRange`
  - 仅 `factory` 发出
- `page`
- `pageSize`

当前用户可见筛选 UI 只保留：

- 搜索
- 城市
- `factory` 专属 `plantAreaRange`

边界说明：

- 本轮没有恢复任何已从 contract 删除的 query。
- 本轮没有把 primary filter / sort 伪装成正式 P1 能力。
- 本轮没有误删卡片摘要、详情摘要高亮逻辑；`enterpriseBoardCardSummaryChips`、`enterpriseBoardCardSummaryText`、detail 页 `reviewSummary.keywordTags` 仍保留。

## 4. 新增或更新的测试清单

更新/新增的最小覆盖：

- `enterprise public list query only sends frozen minimal contract`
  - 验证 public list 实际请求 query 只包含正式最小集合。
- `enterprise company list route renders formal list skeleton`
  - 验证 company list 不再显示 `业务方向` / `默认排序`。
- `enterprise supplier list renders differentiated landing copy`
  - 验证 supplier list 不再显示 `供应品类` / `默认排序`，且卡片摘要高亮仍保留。
- `enterprise factory list keeps plant area filter and removes fake primary filter and sort`
  - 验证 factory 仍保留 `厂房面积`，同时不再显示 `工艺类型` / `默认排序`。
- `enterprise detail route renders unified detail sections`
  - 验证 detail 页关键词高亮 `交付稳定` 仍可见，未被本轮 surface cleanup 误伤。

## 5. analyze / test 结果

### 5.1 Analyze

执行：

```bash
cd apps/mobile
flutter analyze \
  lib/features/exhibition/data/enterprise_hub_consumer_layer.dart \
  lib/features/exhibition/presentation/enterprise_hub_list_state_support.dart \
  lib/features/exhibition/presentation/enterprise_hub_board_surface.dart \
  lib/features/exhibition/presentation/enterprise_hub_list_controls.dart \
  lib/features/exhibition/presentation/enterprise_hub_list_pages.dart \
  test/enterprise_hub_routes_test.dart
```

结果：

- `No issues found!`

### 5.2 Targeted tests

执行：

```bash
cd apps/mobile
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise public list query only sends frozen minimal contract"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise company list route renders formal list skeleton"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise supplier list renders differentiated landing copy"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise factory list keeps plant area filter and removes fake primary filter and sort"
flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise detail route renders unified detail sections"
```

结果：

- 5/5 passed

## 6. 当前剩余未闭合项

Flutter package E 本轮目标范围内，无剩余未闭合项。

未纳入本轮范围，且未改动：

- server / bff / admin
- enterprise detail 深化
- recommendation 位改造
- 排序能力建设
- board-specific card summary / detail summary 展示逻辑

## 7. 是否已达到 P1 fake-filter cleanup closure

已达到。

闭合结论：

1. Flutter 不再保留历史残留 fake-filter UI。
2. Flutter 对 enterprise public list 的 query 构造已与正式 contract 对齐。
3. `factory` 的 `plantAreaRange` 保留，`company / supplier` 不再展示假筛选按钮。
4. 卡片摘要与详情摘要高亮未被误删。
