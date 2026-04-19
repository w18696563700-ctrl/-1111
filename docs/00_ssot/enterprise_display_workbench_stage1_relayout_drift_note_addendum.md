---
owner: Codex 总控
status: active
purpose: Record the formal drift between the previously frozen enterprise-display workbench frontend surface and the newly approved stage-1 relayout goal, so later threads do not revert the card-first structure back to the old form-centric workbench.
layer: L0 SSOT
based_on:
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - docs/04_frontend/mobile_province_city_picker_unification_frontend_surface_addendum.md
  - docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_ruling_addendum.md
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_bounded_object_ruling_addendum.md
freeze_date_local: 2026-04-17
---

# 《企业展示工作台 Stage 1 relayout 漂移说明单》

## 1. Scope

- 本漂移说明只记录：
  - 旧冻结文书与当前新目标之间的冲突点
  - 哪些旧口径应被补充或降级
- 本说明不直接代替：
  - 新的 frontend surface freeze
  - 新的阶段门禁核查表

## 2. Drift Source

- 当前漂移来源是：
  - 旧文书把 `企业展示工作台` 冻结为“表单完成度优先”的维护页
  - 当前产品目标改为“展示卡片结果优先”的编辑器
- 因此旧冻结文书并非整体失效，而是部分口径已不再适合作为现行唯一表述

## 3. Confirmed Drift Points

### 3.1 首屏顺序漂移

- 旧口径：
  - 首屏优先呈现 `联系人 / 基础资料 / 板块画像 / 案例资料 / 提交动作`
- 当前目标：
  - 首屏优先呈现 `展示标识 / 企业画册 / 地图 / 基础资料 / 联系人 / 案例编辑器`
- 正式结论：
  - 旧首屏顺序不再作为当前唯一有效顺序

### 3.2 company 主编辑字段漂移

- 旧口径：
  - company profile 继续承接 `服务城市 / 最大项目规模 / 资质说明`
- 当前目标：
  - company 主展示中移除这三项
- 原因固定为：
  - `服务城市` 对设计公司天然全国服务的区分度不足
  - `最大项目规模` 属于企业单方自证，平台当前无法形成可信校验
  - `资质说明` 会引入额外真伪审核负担，当前阶段不作为主展示主路径
- 正式结论：
  - 旧口径不得再被当作 company 主编辑区的默认回退依据

### 3.3 基础资料字段漂移

- 旧口径：
  - `一句话简介`
  - `详细地址`
  仍在基础资料主流中
- 当前目标：
  - 基础资料只保留：
    - 公司介绍
    - 团队规模
    - 合作方式
- 正式结论：
  - `一句话简介 / 详细地址` 不再作为当前基础资料主编辑区的主路径

### 3.4 联系人公开开关位置漂移

- 旧口径：
  - `contactVisible` 在基础资料区承接
- 当前目标：
  - 联系人公开开关必须并入联系人区
- 正式结论：
  - 不得再把联系人公开开关放回基础资料区

### 3.5 active sub-object 状态漂移

- 旧口径：
  - `enterprise_hub V1` 当前没有新的 active sub-object
- 当前动作：
  - 已正式打开 `企业展示工作台 Stage 1 relayout`
- 正式结论：
  - 后续线程不得再用“当前没有新对象”阻止本轮已批准的 stage-1 文书与前端工作

## 4. Non-drift Points That Still Hold

- 以下旧纪律继续有效：
  - 顶部位置字段仍必须是只读来源字段
  - 成立日期仍必须是只读来源字段
  - 案例城市仍使用统一城市选择器
  - 举办日期仍使用点选日期
  - published change corridor 仍不得弱化
  - 不得伪造信用评分
  - `上游真值 / 认证摘要` 仍然不是常驻大块卡片

## 5. Existing Semantics Ruling Reconciliation

- 当前与旧语义裁决的关系正式固定如下：
  - `enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_ruling_addendum.md`
    继续有效
  - Stage 1 relayout 不推翻以下旧裁决：
    - `上游真值` 只作为条件显示的阻断解释区
    - `认证摘要` 只作为异常态或非完成态提示区
    - `注册城市` 命名继续 `No-Go`
- 当前 Stage 1 新增的唯一允许动作是：
  - 在首屏 `展示标识` 顶部使用 truth-derived 的企业名称与省市摘要
  - 该字段只能命名为：
    - `公司位置`
    - `企业位置`
    - 或等价且不暗示法定注册地的命名
- 因此当前不得把：
  - 顶部摘要化位置展示
  误读为：
  - `上游真值` 常驻卡重新回归
  - `注册城市` 合法恢复

## 6. Anti-revert Notes

- 不得再把 `展示标识` 降回 Logo-only 的次级小区块
- 不得再把 company 的 `服务城市 / 最大项目规模 / 资质说明` 恢复成主编辑流
- 不得再把 `一句话简介 / 详细地址` 恢复成当前基础资料主路径
- 不得为了“少改代码”把 `contactVisible` 留在基础资料区
- 不得把 `上游真值 / 认证摘要` 恢复为常驻大块卡
- 不得把顶部位置字段重新命名为 `注册城市`
- 不得把 stage-1 relayout 误写成已完成的 stage-2 cloud truth 补链

## 7. Formal Conclusion

- 当前正式结论如下：
  - 旧 workbench frontend freeze 存在结构性漂移
  - 漂移已被正式记录
  - 后续应以新的 stage-1 relayout 文书为准推进
