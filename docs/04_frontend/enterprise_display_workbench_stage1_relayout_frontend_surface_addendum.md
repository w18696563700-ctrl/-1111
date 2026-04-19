---
owner: Codex 总控
status: active
purpose: Freeze the stage-1 frontend surface for the enterprise display workbench relayout so the workbench becomes a card-first public-result editor while preserving current truth-derived readonly fields and published-change semantics.
layer: L3 Frontend
inputs_canonical:
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_drift_note_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_stage_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - docs/04_frontend/mobile_province_city_picker_unification_frontend_surface_addendum.md
freeze_date_local: 2026-04-17
---

# 《企业展示工作台 Stage 1 relayout frontend surface freeze》

## 1. Scope

- 当前冻结只覆盖：
  - `/exhibition/enterprise/apply`
  - enterprise published change workbench 的同构页面结构
  - 本地 Flutter 工作台结构重排
- 当前冻结不覆盖：
  - stage-2 cloud truth / BFF / backend 补链
  - 公域列表字段扩展
  - 详情页整体重排
  - release-prep
  - production release

## 2. Global Layout Rule

- 三类工作台：
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
  必须共享同一主骨架顺序：
  1. 展示标识
  2. 企业画册
  3. 地图
  4. 基础资料
  5. 联系人
  6. 案例编辑器
- 支撑区块当前单独裁决为：
  - `案例库` 继续保留，但不是本轮 relayout 的固定骨架项
  - `上游真值 / 认证摘要` 继续遵守既有语义裁决，只能作为条件区块出现，不是固定骨架项
  - `提交区` 继续保留在页面尾部，但不属于这轮“首屏主编辑骨架”的一部分
- 当前不允许再把旧顺序：
  - `板块画像 -> 基础资料 -> 展示标识 -> 联系人 -> 案例`
  作为现行默认顺序回退

## 3. Display Identification Rule

- `展示标识` 必须成为首个主编辑区块。
- 当前区块至少承接：
  - Logo 上传
  - 企业名称，只读，与认证公司名对齐
  - 公司位置，只读，来自注册地 / 组织真值，只显示省市
  - board profile 第一主字段
  - board profile 第二主字段
  - 企业信用评分占位
- company 当前首屏只读+可编辑组合固定为：
  - Logo
  - 企业名称
  - 公司位置
  - 展会类型
  - 服务项目
  - 信用评分占位
- 当前明确禁止：
  - 用手填公司名替代认证名称
  - 用手填省市替代注册地真值
  - 把信用占位伪装成真实 `0 分`
  - 把该字段命名回 `注册城市`
- 当前命名纪律固定为：
  - 顶部展示区只能使用：
    - `公司位置`
    - `企业位置`
    - 或等价且不暗示法定注册地的命名
- 当前与旧语义裁决的关系固定为：
  - `上游真值 / 认证摘要` 的“条件区块”语义继续有效
  - 本轮只是允许把 truth-derived company name / province-city 摘要化后放进 `展示标识` 顶部，不得据此恢复常驻大块只读卡

## 4. Company Surface Rule

- company 当前主编辑流必须移除：
  - `服务城市`
  - `最大项目规模`
  - `资质说明`
- 当前原因固定为：
  - `服务城市` 对设计公司在此阶段不是有效区分字段
  - `最大项目规模` 属于平台当前不可验证自证
  - `资质说明` 会引入额外真伪治理负担
- 上述字段当前不得再占据 company 的主编辑流、首屏展示流、主提交心智流。

## 5. Album Rule

- `企业画册` 必须位于展示标识之后。
- 当前结构必须支持：
  - 最多 `6` 张
  - 横向滑动浏览
  - 独立确认上传按钮
- 若当前 stage-1 尚无完整云端画册写链：
  - 前端必须诚实展示当前接入程度
  - 不得伪装成已完成的正式云端画册真值闭环
- `团队规模` 与 `合作方式` 的高密信息可压在画册卡底部文字层：
  - 文字位于图片最下侧
  - 不得严重遮挡主体图像

## 6. Map Rule

- `地图` 区必须位于画册之后、基础资料之前。
- 当前地图能力承接规则固定为：
  - 继续基于现有企业位置真值与解析动作
  - 若只解析到文字地址或无坐标，不得伪装成高德地图预览已完整接通
- 当前允许：
  - 用位置真值状态卡承接 stage-1 地图区
- 当前不允许：
  - 写死“地图已接通”之类的误导文案

## 7. Basic Info Rule

- 基础资料区当前只保留：
  - 公司介绍文本框
  - 团队规模
  - 合作方式
- 当前基础资料区必须移除：
  - 一句话简介
  - 详细地址
- `contactVisible` 必须从基础资料区移出，归入联系人区。

## 8. Contact Rule

- 联系人区继续承接：
  - 联系人姓名
  - 联系人手机号
  - 公开展示联系人开关
- 当前不允许再把公开展示联系人开关放在基础资料区。

## 9. Case Rule

- `案例编辑器` 保留在联系人区之后。
- `案例城市` 与 `举办时间` 必须纵向单列排列，不做双列并排。
- `案例城市` 继续使用统一城市选择器。
- 已发布后的案例编辑与保存必须继续走 current change snapshot，不得误改为 live。

## 10. Published Change Rule

- 本轮 relayout 不得削弱：
  - published change snapshot / live snapshot 区分
  - revision required 继续编辑同一条 change request
  - 返回变更工作台
- 当前任何视觉重排都不得把已发布后的正式修改通道隐藏或误导成“提交后不可修改”。

## 11. Conditional Helper Blocks Rule

- `案例库` 当前继续存在，但它的正式角色仍然是：
  - 已保存案例的回读资产区
  - 不是当前 stage-1 relayout 的固定骨架项
- `上游真值` 与 `认证摘要` 当前继续遵守既有语义裁决：
  - `上游真值` = 条件显示的阻断解释区
  - `认证摘要` = 异常态或非完成态提示区
- 当不存在阻断、缺值、认证异常时：
  - 不显示常驻 `上游真值` 卡
  - 不显示常驻 `认证摘要` 卡

## 12. Non-goals

- 不在本轮补齐公域列表的云端字段缺口
- 不在本轮补齐企业画册完整云端写链
- 不在本轮伪造真实信用系统
- 不在本轮把工作台改造成 release-ready 结论

## 13. Anti-revert

- 不得把 `展示标识` 重新降回 Logo-only 次级区块
- 不得把 company 的 `服务城市 / 最大项目规模 / 资质说明` 恢复到主编辑流
- 不得把 `一句话简介 / 详细地址` 恢复为基础资料主路径
- 不得把联系人公开开关放回基础资料区
- 不得把 `案例库` 误写成本轮固定骨架项
- 不得把 `上游真值 / 认证摘要` 恢复成常驻大块卡片
- 不得把顶部位置字段命名回 `注册城市`
- 不得把 stage-1 结果误报为 stage-2 cloud truth 完成
