---
owner: Codex 总控
status: active
purpose: Freeze the next bounded object that reopens enterprise_hub V1 specifically for the stage-1 enterprise display workbench relayout, so the workbench/card-first restructuring does not proceed as a floating frontend polish round.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - docs/04_frontend/mobile_province_city_picker_unification_frontend_surface_addendum.md
freeze_date_local: 2026-04-17
---

# 《企业展示工作台 Stage 1 relayout bounded object 裁决单》

## 1. Scope

- 本裁决单只回答两件事：
  - `enterprise_hub V1` 当前重新打开的唯一 bounded object 是什么
  - 当前是否需要新的《阶段门禁核查表》
- 本裁决单不代表：
  - `stage 2` cloud truth / BFF / backend 补链自动解锁
  - release-prep
  - production release

## 2. Current Situation

- 当前正式现状已经冻结为：
  - `enterprise_hub V1` 当前没有新的 active sub-object
  - `EXH-006A + EXH-006` 之前的 correction chain 已转入 `maintenance-only`
- 但当前用户已明确指定一个新的、独立的产品目标：
  - 将 `企业展示工作台` 从分散填表页重构为以公域展示结果为中心的编辑器
  - 让 `优秀公司 / 优秀工厂 / 优秀供应商` 共用同一展示骨架
  - 明确保留已发布后的正式修改通道
- 因此当前不能把这轮任务误判为：
  - 原有 `maintenance-only` 里的零散修补
  - 只改视觉样式、不需要重新开对象的前端小抛光

## 3. Next Bounded Object Conclusion

- 当前唯一 next bounded object candidate 正式裁定为：
  - `企业展示工作台 Stage 1 relayout`
- 当前对象只覆盖以下范围：
  1. 展示标识优先的信息架构重排
  2. 企业画册区前移
  3. 地图区独立承接
  4. 基础资料区缩窄到当前真正主编辑字段
  5. 联系人区与案例编辑器位置重排
  6. company / factory / supplier 共享同一工作台骨架
  7. 已发布 `published change corridor` 的保留与复核
- 当前对象明确不包含：
  - company 公域列表缺失字段的云端补链
  - 企业画册真实云端写链补齐
  - 详情页、公域列表、首页推荐位的跨层统一改造

## 4. Why This Is A Real Bounded Object

- 当前正式判断如下：
  - 这不是“改几个 section 顺序”那么简单
  - 也不是可绕过文书冻结的前端孤立视觉 round
- 原因固定为：
  - 旧 frontend freeze 当前明确把 `联系人 / 基础资料 / 板块画像 / 案例 / 提交` 固定为首屏主顺序
  - 当前新目标要求：
    - `展示标识` 上移到最顶
    - company 收掉 `服务城市 / 最大项目规模 / 资质说明`
    - 基础资料收掉 `一句话简介 / 详细地址`
    - 联系人公开开关移位
    - 画册区与地图区成为主编辑流
  - 以上都属于正式 surface boundary 变化，而不是局部 copy tweak
- 因此正确动作不是直接改代码，而是：
  - 先把该对象作为正式 bounded object 打开

## 5. Whether A New Stage Gate Checklist Is Required

- 结论：
  - `需要`
- 原因固定为：
  - `gate_register_v1.md` 已要求：
    - 进入新的 stage prompt bundle 前，必须先提交《阶段门禁核查表》
  - `enterprise_hub V1` 当前没有新的 active sub-object
  - 当前任务已经明确打开了一个新的 bounded object
  - 因此不得沿用旧的 `maintenance-only` 结论继续直接发实现派工

## 6. Formal Conclusion

- 当前唯一 next bounded object：
  - `企业展示工作台 Stage 1 relayout`
- 当前正式意义：
  - 这是一个真实的 bounded object
  - 不是浮动前端 polish round
  - 也不是 `stage 2` cloud 补链的自动前置替代品
- 当前下一步必须先做：
  - 漂移说明
  - 新的《阶段门禁核查表》
  - 新的 frontend surface freeze
- 当前仍然：
  - `No-Go for direct stage-2 cloud implementation`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 7. Next Unique Action

- 下一轮唯一动作：
  - 提交《企业展示工作台 Stage 1 relayout 阶段门禁核查表》
