---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded remediation scope, truth rules, dispatch boundary, and acceptance baseline for the current factory-detail optimization round.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/04_frontend/enterprise_display_album_and_target_enterprise_info_frontend_surface_addendum.md
  - docs/03_bff/enterprise_display_album_and_target_enterprise_info_bff_surface_addendum.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
---

# 《工厂详情优化修复冻结单 V1.1》

## 1. 文书定位

- 本冻结单不是普通优化建议，不是零散问题清单，也不是一次性改版备忘。
- 本冻结单当前只服务于：
  - 工厂详情页结构去重
  - 云端公开真值收口
  - `formal-info` app-facing 链路成立
  - 案例展示状态语义纠偏
- 凡未在本文书中明确放行的内容，一律视为不在本轮实施范围内。

## 2. 当前轮总裁决

- 工厂详情当前必须进入一轮受控修复。
- 本轮正式拆成两单：
  - `A 单`：本地前端结构去重与展示修复
  - `B 单`：云端真值与接口链路收口
- `A / B` 两单必须并行立项、分轨治理、分别验收。
- `A / B` 两单可串行或并行实施，但不得混成无边界的单轮大改。

## 3. 当前轮主目标与非目标

### 3.1 当前轮只解决

1. 首屏与正文职责去重
2. 地区显示真值收口
3. `formal-info` 从 UI 壳子升级为真实能力
4. 案例展示状态语义纠偏

### 3.2 当前轮不追求

- 企业详情系统整体重构
- 公司详情 / 供应商详情同步大改
- 详情模板系统重建
- 企业真值体系迁移重做
- 与当前问题无直接关系的样式大翻修

## 4. 执行环境与拓扑真源

- 前端仅在本地。
- `BFF` 在阿里云。
- `Server` 在阿里云。
- 当前唯一正式 app-facing 验证隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

正式约束：

1. 本地前端只能处理展示层与消费层问题。
2. 云端真值与接口问题不得伪装成本地页面问题。
3. app-facing 正式链路判断，以云端真实返回为准。
4. 本地预览通过，不等于云端链路已成立。
5. 联调与验收必须通过隧道走云端真实 app-facing 面。

## 5. 当前已确认事实

### 5.1 结构事实

- 当前工厂详情与公司详情不是同一套头图结构。
- 公司详情当前为：
  - 标题左上浮在图上
  - 指标压在图底安全区
- 工厂详情旧代码入库态中，仍保留：
  - 图下白卡承接主信息
- 当前运行态 / 设计态已确认：
  - 工厂首屏承接画册主视觉

正式修订：

- “工厂首屏已承接画册主视觉职责”这一前提，基于当前运行态 / 设计态确认成立。
- 即使代码入库态仍留有旧 Hero 结构，也不得否定本轮去重裁决。

### 5.2 云端真值事实

通过云端真实接口核对，已确认存在公开口径冲突，例如：

- 工厂名：`重庆海川展览工厂`
- 企业名：`重庆坤特展览展示有限公司`
- 省市：`四川省 / 成都市`
- 地址：`重庆市江北区...`

正式定性：

- 上述现象属于云端公开真值冲突，不属于前端本地排版误读。

### 5.3 `formal-info` 实测事实

云端实测：

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

当前返回：

- `404 Cannot GET .../formal-info`

正式定性：

- `formal-info` 当前 app-facing 路由未接通到可用态。

### 5.4 案例展示事实

- `cases=[]` 并不等于能力未接通。
- 当前企业无公开案例，也不等于系统未做完。
- 当前若前端把 `cases=[]` 展示成“暂未接通”，会造成状态语义误导。

### 5.5 图源事实

当前工厂详情中至少存在两路潜在首图来源：

- `boardProfile.showcaseImageFileAssetIds`
- `visualGallery.albumImageUrls`

正式风险：

- 若不冻结工厂 Hero 图源优先级，前端在隐藏正文企业画册后，存在首屏无图或图源漂移风险。

## 6. 核心冻结规则

### 6.1 首屏唯一主视觉规则

- 工厂详情首屏 Hero 冻结为唯一主视觉载体。
- 首屏 Hero 只允许承担：
  - 画册主图展示
  - 厂名展示
  - 认证 / badge 展示
  - 核心公开指标展示
- 首屏既已承接上述职责，正文不得再次重复承接同类职责。

### 6.2 企业画册去重规则

- 工厂详情页正文独立“企业画册”区块必须隐藏。
- 工厂详情页只允许保留一套画册主视觉载体。
- 该载体固定为首屏 Hero。

### 6.3 工厂 Hero 图源优先级规则

工厂详情首屏 Hero 图源正式冻结为以下优先级：

1. `boardProfile.showcaseImageFileAssetIds`
2. `visualGallery.albumImageUrls`
3. 合法页面级 fallback 图源

补充裁决：

- `showcase` 真值优先级第一，但 app-facing 必须先将 `showcase` file truth 投影为可展示 URL surface。
- 前端不得直接把 `fileAssetId` 当成 `imageUrl` 使用。
- 仅当 `showcase` 与 `album` 都无可用图时，才允许进入 fallback。

### 6.4 首屏四指标规则

当前轮工厂首屏底部安全区固定承载以下四类指标：

1. 地区
2. 认证
3. 厂房面积
4. 团队规模

除以上四项外，其他字段不得以“顺手补充”的方式进入首屏主摘要。

### 6.5 首屏四指标缺值规则

地区：

- 无值时隐藏该指标位
- 不显示“暂未补充”
- 不允许前端本地拼接猜测值

认证：

- 无有效公开认证态时，显示未认证态或按既有 badge 规则展示
- 不允许出现结构塌陷

厂房面积：

- 无值时隐藏该指标位
- 不显示 `0 平方` 或伪值
- 不显示占位文案

团队规模：

- 无值时隐藏该指标位
- 不显示“暂未补充”
- 不显示推测值

缺值后的布局规则：

1. 只渲染有值项
2. 指标区自动重排
3. 不保留空占位卡槽
4. 不允许为了对齐而显示无意义占位文案

### 6.6 月产能规则

- `月产能` 从工厂详情页当前轮全部移除。
- 移除范围包括但不限于：
  - 首屏摘要
  - 核心能力补充位
  - 其他 pill / 提示位

正式裁决：

- `月产能` 不作为当前工厂详情公开展示主字段。

### 6.7 地区显示真值规则

- 工厂详情地区显示执行统一公开真值优先级。
- 正式要求如下：
  - 优先使用 `location` 公开展示真值
  - 回退逻辑必须冻结
  - 不允许页面本地自由拼接行政区
  - 不允许 `header / basic / location` 三套口径漂移并存

### 6.8 名称显示规则

- 工厂详情中的“厂名”与“企业名”必须区分来源与用途，不得混用。
- 必须明确：
  - 首屏主标题展示什么
  - 正式企业名称展示什么
  - 数据来源分别来自哪一层
  - 不允许同页内出现主标题与正式名称打架

### 6.9 `formal-info` 规则

- “查看企业信息”从本轮起定义为正式能力链路。
- 成立条件为：
  1. 前端存在真实点击入口
  2. `BFF` 存在正式 `route / surface`
  3. `Server` 存在正式 `query / service / presenter`
  4. 空态、缺失态、异常态有明确口径
- 只存在弹层 UI、不存在真实 route 或真实返回的状态，不得标记为“已打通”。

### 6.10 案例展示状态规则

状态 A：已接通但当前无公开案例

- 展示文案：`暂无公开案例`

状态 B：能力未接通

- 允许展示：`暂未接通` 或等价技术态文案

正式裁决：

- 禁止将状态 A 写成状态 B。
- app-facing 若需支撑 A/B 区分，必须由云端返回明确可判定语义；前端不得靠空数组自行猜测“未接通”。

### 6.11 资质摘要规则

- 资质与口碑中的资质摘要不允许直接暴露英文状态词。
- `营业执照 · approved` 属于不合格展示。
- 当前允许的方向仅包括：
  - 仅显示资质名
  - 资质名 + 中文状态，例如 `已认证`

### 6.12 核心能力布局规则

- 核心能力模块按双列结构处理：
  - 左列：工艺类型 + 核心产品
  - 右列：设备清单

### 6.13 设备清单布局硬规则

1. 每列固定展示 `3` 个设备项
2. 列内纵向排列
3. 超过 `3` 个后横向扩列
4. 不允许退化为单列长列表
5. 不允许实现层自由改成单行流式乱排

验收示例：

- `1-3` 个设备项：`1` 列
- `4-6` 个设备项：`2` 列
- `7-9` 个设备项：`3` 列

### 6.14 详细介绍规则

- 详细介绍维持左对齐。
- 该项为低优先级视觉校正项，不得高于结构去重、真值收口、链路成立等主问题。

## 7. A/B 拆单边界

### 7.1 A 单

`A 单` 只处理本地前端可独立完成的内容：

- 工厂 Hero 对齐公司同类 overlay 结构
- 厂名进入首图 overlay
- `地区 / 认证 / 厂房面积 / 团队规模` 压入首图底部安全区
- 图下白卡不再承载重复首屏信息
- 正文独立企业画册隐藏
- Hero 图源按冻结优先级接入
- 页面内移除 `月产能`
- 资质摘要去掉英文状态尾巴
- 案例空态文案改为“暂无公开案例”
- 核心能力改双列结构
- 设备清单按“每列 3 个，横向扩列”实现
- 首屏四指标按缺值规则自动重排

### 7.2 B 单

`B 单` 处理必须依赖 `BFF / Server / 云端真值` 的内容：

- 地区真值优先级收口
- “重庆工厂 + 成都省市 + 重庆地址”错配来源排查与修复
- `formal-info route / surface / query` 打通
- 厂名 / 企业名 / 地址口径收口
- 案例展示状态所需的 app-facing 语义收口
- `showcase` file truth 到可展示 URL surface 的 app-facing 投影

## 8. No-Go 边界

本轮明确禁止：

1. 重构整套企业详情系统
2. 新建第二套工厂专属详情体系
3. 在前端本地硬修地区文本遮丑
4. 把 `formal-info` 弹层 UI 当成能力已完成
5. 把“无案例”写成“未接通”
6. 同步扩写公司详情、供应商详情整站改版
7. 扩大到企业身份真值系统重做
8. 把 `A / B` 两单糅成一轮全栈大改
9. 联调阶段临时翻规格
10. 前端自行改写图源优先级
11. 对缺值规则进行实现层自由发挥

## 9. Formal Conclusion

- 工厂详情页当前已存在实质性结构重复问题，必须修。
- 首屏既已承接企业画册职责，则正文独立企业画册必须隐藏。
- 地区错误已被升级确认为云端真值冲突，不得由前端遮丑式修补。
- `formal-info` 当前为 app-facing 路由未接通，不得视为已完成。
- 案例展示必须区分“无数据”与“未接通”，防止状态语义误导。
- Hero 图源优先级、设备清单硬规则、首屏四指标缺值规则，均已冻结，不允许实现层自由发挥。
- 当前轮必须按 `A 单前端结构去重 + B 单云端真值/接口收口` 双轨推进，不做重系统。
