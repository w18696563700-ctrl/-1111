# 首页项目卡面积示例图展示层冻结 Addendum

状态：冻结
冻结日期：2026-05-02
Owner：总控 Agent
适用范围：Flutter App 首页「展览 / 推荐频道 / 项目」前三条项目卡

## 1. 本轮最小闭环

本轮只处理首页项目卡的展示层问题：

1. 根据真实 `areaSqm` 选择本地面积示例图。
2. 手机窄屏下项目卡仍保持「左侧示例图 + 右侧信息」布局。
3. 示例图下方展示真实 `buildingType` 对应的项目类型标签。

本轮不改变项目列表接口、项目状态、筛选规则、详情路由、竞标入口、底部导航和任何业务真相。

## 2. 当前入口和组件

| 对象 | 文件 | 本轮处理方式 |
| --- | --- | --- |
| 首页项目模块 | `apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart` | 只透传真实 `areaSqm` 和 `buildingType` 派生标签 |
| 首页项目卡 | `apps/mobile/lib/features/exhibition/presentation/exhibition_home_widgets.dart` | 只改卡片展示、图片渲染和窄屏布局 |
| 首页项目展示辅助 | `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart` | 只新增展示层 resolver，不新增业务字段 |
| 示例图资源 | `apps/mobile/assets/exhibition/project_examples/` | 使用 Flutter 本地 assets |

## 3. 面积示例图分档

用户提供的本地源目录：`/Users/wangweiwei/Desktop/示例图`

已确认 12 张源图：

| 分档 | 源文件 | Flutter asset 建议名 |
| --- | --- | --- |
| 9 平方 | `9.png` | `area_009.png` |
| 18 平方 | `18.png` | `area_018.png` |
| 27 平方 | `27.png` | `area_027.png` |
| 36 平方 | `36.png` | `area_036.png` |
| 45 平方 | `45.png` | `area_045.png` |
| 54 平方 | `54.png` | `area_054.png` |
| 63 平方 | `63.png` | `area_063.png` |
| 72 平方 | `72.png` | `area_072.png` |
| 81 平方 | `81.png` | `area_081.png` |
| 90 平方 | `90.png` | `area_090.png` |
| 108 平方 | `108.png` | `area_108.png` |
| 108 以上平方 | `108+.png` | `area_108_plus.png` |

面积匹配规则冻结为「向上归档」：

| 真实 `areaSqm` | 使用示例图 |
| --- | --- |
| `0 < areaSqm <= 9` | `area_009.png` |
| `9 < areaSqm <= 18` | `area_018.png` |
| `18 < areaSqm <= 27` | `area_027.png` |
| `27 < areaSqm <= 36` | `area_036.png` |
| `36 < areaSqm <= 45` | `area_045.png` |
| `45 < areaSqm <= 54` | `area_054.png` |
| `54 < areaSqm <= 63` | `area_063.png` |
| `63 < areaSqm <= 72` | `area_072.png` |
| `72 < areaSqm <= 81` | `area_081.png` |
| `81 < areaSqm <= 90` | `area_090.png` |
| `90 < areaSqm <= 108` | `area_108.png` |
| `areaSqm > 108` | `area_108_plus.png` |

若 `areaSqm` 缺失、非数字或小于等于 0，只能使用展示层默认示意兜底，不允许伪造面积。

## 4. 字段真源

| 展示内容 | 真源字段 | Owner | 本轮规则 |
| --- | --- | --- | --- |
| 面积示例图 | `areaSqm` | Server，经 BFF 透传/整形 | Flutter 只根据真实值选择本地 asset |
| 项目类型标签 | `buildingType` | Server，经 BFF 透传/整形 | Flutter 只使用现有 label 映射 |
| 项目状态 | `state` | Server | 不改 |
| 预算 | `budgetAmount` | Server | 不改 |
| 搭建地 | `cityName` / `provinceName` | Server | 不改 |
| 进场时间 | `plannedStartAt` | Server | 不改 |
| 发布时间 | `publishedAt` | Server | 不改 |

项目类型展示规则：

1. 只读取真实 `buildingType`。
2. 优先复用现有 Flutter 展示 label，例如 `exhibition` 显示为「会展」。
3. 无真实 `buildingType` 时显示「类型待确认」或弱化占位。
4. 不允许为了示例效果硬写「展厅」「商业活动」等假类型。

## 5. 布局冻结

首页项目卡在手机窄屏下不再切换为「上图下文」。

冻结布局：

1. 左侧固定示例图区域。
2. 示例图下方显示项目类型标签。
3. 右侧展示项目标题、状态、进场、搭建地、面积、预算。
4. 底部继续展示发布时间和真实详情入口。
5. 文字必须截断或换行约束，避免挤压、溢出或遮挡 bottom nav。

## 6. 本轮不做

1. 不改 BFF。
2. 不改 Server。
3. 不改 contracts / OpenAPI。
4. 不改数据库。
5. 不新增接口字段。
6. 不新增 mock 数据。
7. 不修改项目状态机、竞标规则、发布规则。
8. 不改 bottom nav 路由。
9. 不把本地 3000/3001 当作真实 BFF/Server。
10. 不把云端服务作为写入目标。

## 7. 验收口径

1. 首页项目卡窄屏截图中示例图仍在左侧。
2. 不同真实面积命中不同本地示例图，`150 ㎡` 命中 `108+` 分档。
3. 示例图下方展示真实项目类型标签。
4. 缺少 `areaSqm` 时显示默认示意兜底，不伪造。
5. 缺少 `buildingType` 时显示弱化占位，不伪造。
6. `flutter analyze` 目标文件无本轮新增问题。
7. 相关 Flutter test 通过，或仅存在明确非本轮旧问题。
8. 云端只读联调确认真实数据不崩溃。

## 8. 风险和处置

| 风险 | 处置 |
| --- | --- |
| 真实云端项目缺少 `areaSqm` | 使用默认示例图兜底，不造字段 |
| 真实云端项目只有 `buildingType=exhibition` | 只显示「会展」 |
| 固定左图后窄屏拥挤 | 缩小图宽、限制标题和信息块行数 |
| 图片尺寸不一致 | 使用统一容器和 `BoxFit.cover` |
| 当前仓库已有大量 dirty 文件 | 验收回执中区分本轮与非本轮，不误提交 |

## 9. 进入下一天结论

冻结单已明确：

1. 本轮只做 Flutter 首页项目卡展示层。
2. 图片由 Flutter assets 本地资源承载。
3. 面积图选择只依赖真实 `areaSqm`。
4. 项目类型只依赖真实 `buildingType`。
5. 不改 BFF、Server、contracts、OpenAPI、数据库、云端。

若代码复核未发现与上述真源冲突，允许进入第 2 天 Flutter 最小 UI 改造。
