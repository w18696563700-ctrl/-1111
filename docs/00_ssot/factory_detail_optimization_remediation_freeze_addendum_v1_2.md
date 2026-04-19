---
owner: Codex 总控
status: frozen
purpose: Refresh the main freeze document for the factory-detail remediation round so the formal freeze text matches the actual 2026-04-19 runtime after cloud deployment and authenticated smoke verification.
layer: L0 SSOT
freeze_date_local: 2026-04-19
supersedes:
  - docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/factory_detail_optimization_result_verification_conclusion_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_backend_execution_receipt_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_bff_execution_receipt_addendum_v1_1.md
  - docs/00_ssot/factory_detail_optimization_frontend_execution_receipt_addendum_v1_1.md
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-location.service.ts
---

# 《工厂详情优化修复冻结单 V1.2》

## 1. 文书信息

- 文书名称：
  - `工厂详情优化修复冻结单 V1.2`
- 文书性质：
  - 当前轮正式冻结主文刷新件
- 文书定位：
  - 不是重新开新对象
  - 而是把 `V1.1` 主文中已经过时的执行前事实，刷新为 `2026-04-19` 当前 app 运行态已验证事实
- 当前裁决级别：
  - `可入库`
  - `可挂门禁`
  - `可作为当前轮关单后的正式真源`

## 2. 适用范围

- 本文书继续只服务于本轮 `enterprise_hub / 工厂详情优化修复与真值收口` 对象。
- 本文书继续不放行：
  - 企业详情系统整体重构
  - 公司详情 / 供应商详情同步大改
  - 模板系统重建
  - 企业身份真值系统重做
  - 与当前对象无关的整站视觉翻修

## 3. 当前轮最终状态

- 当前轮 `A 单`：
  - 已完成
- 当前轮 `B 单`：
  - 已完成
- 当前轮 `Gate 1`：
  - `PASS`
- 当前轮 `Gate 2`：
  - `PASS`
- 当前轮 `Gate 3`：
  - `PASS`
- 当前轮 `Gate 4`：
  - `PASS`

正式依据见：

- [factory_detail_optimization_result_verification_conclusion_addendum_v1_1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/factory_detail_optimization_result_verification_conclusion_addendum_v1_1.md)

## 4. 执行环境与拓扑真源

- 前端仅在本地。
- `BFF` 在阿里云。
- `Server` 在阿里云。
- 当前唯一正式 app-facing 验证隧道固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

正式约束继续不变：

1. 本地前端只能处理展示层与消费层问题。
2. 云端真值与接口问题不得伪装成本地页面问题。
3. app-facing 正式链路判断，以云端真实返回为准。
4. 本地预览通过，不等于云端链路已成立。
5. 联调与验收必须通过隧道走云端真实 app-facing 面。

## 5. 当前已确认事实

### 5.1 结构事实

- 工厂详情首屏当前已承接主视觉职责。
- 工厂详情正文当前不再重复渲染独立“企业画册”主视觉承接区。
- 工厂详情当前 live path 继续按：
  - Hero 主视觉
  - 正文信息区
  的分工运行。

### 5.2 云端真值事实

`2026-04-19` 经 `8080` 云端真实面复核，之前的：

- `重庆工厂 + 四川省 / 成都市 + 重庆地址`

这一组公开真值冲突，当前已收口。

当前实际返回为：

- factory list：
  - `provinceName = 重庆市`
  - `cityName = 重庆市`
- factory detail：
  - `header.name = 重庆海川展览工厂`
  - `basicInfo.legalName = 重庆坤特展览展示有限公司`
  - `location.publicDisplayAddress = 重庆市江北区...`
  - `serviceAreas.registered_location = 重庆市 / 重庆市`

正式定性：

- `V1.1` 中记录的公开真值冲突，当前已从运行态修复为已收口状态。

### 5.3 formal-info 实测事实

`2026-04-19` 经 `8080` 云端真实面复核：

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

当前不再是 `404`。

当前实际行为为：

- 未带合法 auth carrier：
  - `401 AUTH_SESSION_INVALID`
- 带合法 bearer：
  - `200 OK`
  - 返回目标企业正式资料 truth

正式定性：

- `formal-info` 当前已进入真实受控鉴权链路，不再是未接通路由。

### 5.4 案例展示事实

- 当前 detail response 已显式返回：
  - `casesState = empty`
- 当前 `cases=[]` 在已接通链路上明确表示：
  - 当前无公开案例
- 当前不再需要前端依赖空数组自行猜测“无数据 / 未接通”。

### 5.5 图源事实

当前工厂详情 Hero 图源已按以下运行态事实成立：

- `boardProfile.showcaseImageUrls`
- `boardProfile.showcaseImageFileAssetIds`
- `visualGallery.albumImageUrls`

正式解释：

- `showcase` 的业务真值仍来源于 file truth
- 但 app-facing 已先把 file truth 投影成展示型 URL surface
- 前端当前消费的是可展示 URL，而不是直接消费 `fileAssetId`

## 6. 核心冻结规则

### 6.1 首屏唯一主视觉规则

- 工厂详情首屏 Hero 继续冻结为唯一主视觉载体。
- 正文不得再次重复承接：
  - 画册主图
  - 主标题
  - 首屏主摘要

### 6.2 企业画册去重规则

- 工厂详情页正文独立“企业画册”区块继续保持隐藏。
- 工厂详情页只允许保留一套画册主视觉载体。
- 该载体固定为首屏 Hero。

### 6.3 工厂 Hero 图源优先级规则

工厂详情首屏 Hero 图源当前正式冻结为：

1. `boardProfile.showcaseImageUrls`
2. `visualGallery.albumImageUrls`
3. 合法页面级 fallback 图源

补充裁决：

- `showcase` 的业务优先级仍高于 `album`
- 但 app-facing 必须先完成：
  - `showcase file truth -> display URL surface`
- 前端不得直接把 `showcaseImageFileAssetIds` 当成 `imageUrl`

### 6.4 首屏四指标规则

当前轮工厂首屏底部安全区继续只承载：

1. 地区
2. 认证
3. 厂房面积
4. 团队规模

除以上四项外，其他字段不得进入首屏主摘要。

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

缺值后的布局规则继续固定为：

1. 只渲染有值项
2. 指标区自动重排
3. 不保留空占位卡槽
4. 不允许为了对齐显示无意义占位文案

### 6.6 月产能规则

- `月产能` 继续不作为当前工厂详情公开展示字段。
- 当前只约束 public detail 展示面，不约束 workbench 写入面。

### 6.7 地区显示真值规则

- 工厂详情地区显示继续优先使用 `location` 公开展示真值。
- 当前运行态中，`location` 已进一步优先使用 `publicDisplayAddress` 推断出的 canonical municipality truth。
- 不允许：
  - 页面本地自由拼接行政区
  - `header / basic / location` 三套口径继续漂移并存

### 6.8 名称显示规则

- 工厂详情当前正式收口为：
  - 首屏主标题：
    - `factoryName`
  - 正式企业名称：
    - `legalName`
- 不允许主标题与正式名称混用或打架。

### 6.9 formal-info 规则

- “查看企业信息”继续定义为正式能力链路。
- 当前真实成立条件明确为：
  1. 前端存在真实点击入口
  2. `BFF` 存在正式 `route / surface`
  3. `Server` 存在正式 `query / service`
  4. 未带合法 auth carrier 时返回受控失败
  5. 带合法认证上下文时可真实读取目标企业正式资料

### 6.10 案例展示状态规则

状态 A：已接通且当前无公开案例

- `casesState = empty`
- 展示文案：
  - `暂无公开案例`

状态 B：能力未接通

- 不得再由前端凭空根据空数组猜测
- 应由 route failure、transport failure、或未来明确的 app-facing 状态语义表达

### 6.11 资质摘要规则

- public detail 摘要区不允许直接暴露原始英文状态词。
- `approved` 这类原始英文状态，不得直接以 `营业执照 · approved` 形式暴露给用户。

### 6.12 核心能力布局规则

- 当前工厂详情 public surface 继续按双列结构处理：
  - 左列：工艺类型 + 核心产品
  - 右列：设备清单

### 6.13 设备清单布局硬规则

- 设备清单继续执行：
  1. 每列固定展示 3 个设备项
  2. 列内纵向排列
  3. 超过 3 个后横向扩列
  4. 不允许退化为单列长列表
  5. 不允许实现层自由改成单行流式乱排

### 6.14 详细介绍规则

- 详细介绍继续维持左对齐。
- 该项仍属于低优先级视觉校正项，不得高于：
  - 结构去重
  - 真值收口
  - 链路成立

## 7. 当前轮执行结论

结论一

- 工厂详情页此前存在的结构重复问题，当前已完成受控修复。

结论二

- 首屏承接画册主视觉职责后，正文独立企业画册已保持隐藏。

结论三

- 地区错误已完成从云端真值冲突到运行态真值收口的修复。

结论四

- `formal-info` 已从 `404` 未接通升级为：
  - 未鉴权受控失败
  - 已鉴权真实可读

结论五

- 案例展示当前已具备明确的已接通空态语义：
  - `casesState = empty`

结论六

- Hero 图源优先级、设备清单硬规则、首屏四指标缺值规则，当前均已在实现侧和运行态闭合。

结论七

- 当前轮 `A 单 + B 单` 双轨对象已完成，不需要继续以本对象名义复开实施轮。

## 8. 当前文书对 V1.1 的正式修正

`V1.2` 对 `V1.1` 的正式修正固定为：

1. `V1.1` 中“云端真值冲突仍存在”的表述，只保留为历史输入，不再作为当前现态事实。
2. `V1.1` 中“formal-info 当前仍为 404”的表述失效，现态已变为受控鉴权链路。
3. `V1.1` 中 `Hero` 图源优先级写成 `showcaseImageFileAssetIds > albumImageUrls > fallback`，技术上已修订为：
   - `showcaseImageUrls > albumImageUrls > fallback`
4. `V1.1` 中 `A 单本地前端立即可修单` 的表述过于乐观，当前正式解释为：
   - 前端结构去重可先行推进
   - 但 Hero 最终稳定按 showcase 出图，需要 `B 单` 提供展示型 URL surface 配合

## 9. Formal Conclusion

- `V1.2` 当前是贴合 `2026-04-19` 运行态的正式冻结主文。
- `V1.1` 继续保留为执行前冻结版本。
- 若后续没有新污染或新回退，本对象后续不再需要继续升级 `V1.3`。
