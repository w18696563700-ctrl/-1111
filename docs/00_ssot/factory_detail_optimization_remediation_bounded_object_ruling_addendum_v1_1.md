---
owner: Codex 总控
status: active
purpose: Freeze the current next bounded object for enterprise_hub V1 as the factory-detail optimization and remediation round, so the work does not proceed as a floating frontend-only polish round or as an unbounded full-stack rewrite.
layer: L0 SSOT
freeze_date_local: 2026-04-18
based_on:
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - 用户当前轮运行态截图与云端 app-facing 实测结果
---

# 《工厂详情优化修复 bounded object 裁决单 V1.1》

## 1. Scope

- 本裁决单只回答两件事：
  - `enterprise_hub V1` 当前重新打开的唯一 bounded object 是什么
  - 当前是否需要新的《阶段门禁核查表》
- 本裁决单不代表：
  - 直接进入 release-prep
  - 直接进入 production release
  - 自动放行企业详情系统整体重构

## 2. Current Situation

- 当前正式现状已经冻结为：
  - `enterprise_hub V1` 当前没有新的 active sub-object
  - 旧的 public entity correction / reassessment 链已转入 `maintenance-only`
- 但当前用户已明确提供新的运行态事实与修复目标：
  - 工厂详情首屏已承接画册主视觉职责
  - 正文独立企业画册与首屏职责重复
  - 云端公开详情存在地区 / 名称 / 地址口径冲突
  - `formal-info` app-facing 路由当前返回 `404`
  - 案例展示存在“无数据 / 未接通”语义混淆风险
- 因此当前不能把这轮任务误判为：
  - 旧 maintenance-only 下的零散 follow-up
  - 只改几个 section 顺序的前端小抛光
  - 不需要重新开对象的临时修补

## 3. Current Unique Bounded Object Conclusion

- 当前唯一 next bounded object candidate 正式裁定为：
  - `工厂详情优化修复与真值收口`
- 当前对象只覆盖以下范围：
  1. 工厂详情首屏与正文职责去重
  2. 工厂详情 Hero 图源优先级冻结
  3. 工厂详情地区 / 厂名 / 企业名 / 地址口径收口
  4. `formal-info` app-facing 正式链路成立
  5. 案例展示“无数据 / 未接通”状态语义纠偏
  6. 核心能力双列与设备清单硬规则冻结
- 当前对象明确不包含：
  - 公司详情 / 供应商详情同步大改
  - 企业详情系统模板化重构
  - 企业身份真值体系整体迁移
  - 与当前对象无关的整站视觉翻修

## 4. Why This Is A Real Bounded Object

- 当前正式判断如下：
  - 这不是单纯前端视觉 round
  - 也不是可以跳过文书冻结的局部 copy tweak
- 原因固定为：
  - 首屏图源优先级会触及：
    - `showcase file truth`
    - `app-facing display URL surface`
  - 地区 / 名称 / 地址冲突会触及：
    - `location`
    - `header/basic`
    - `displayAddress`
    - `organization / listing` 公开口径边界
  - `formal-info` 不是现有 UI 即完成，而是：
    - route
    - surface
    - query
    - presenter
    的完整成立问题
  - 案例展示也不是单一前端文案问题，而是：
    - app-facing 返回态
    - 前端展示态
    的双端收口问题
- 因此正确动作不是直接发零散实现，而是：
  - 先把当前对象作为正式 bounded object 打开

## 5. Whether A New Stage Gate Checklist Is Required

- 结论：
  - `需要`
- 原因固定为：
  - `gate_register_v1.md` 已要求：
    - 进入新的 stage prompt bundle 前，必须先提交《阶段门禁核查表》
  - `enterprise_hub V1` 当前没有新的 active sub-object
  - 当前任务已经明确打开了一个新的 bounded object
  - 当前对象同时跨越：
    - frontend
    - BFF
    - Server
    - app-facing 验收
  - 因此不得沿用旧的 `maintenance-only` 结论继续直接发实现派工

## 6. Formal Conclusion

- 当前唯一 next bounded object：
  - `工厂详情优化修复与真值收口`
- 当前正式意义：
  - 这是一个真实的 bounded object
  - 不是浮动前端 polish round
  - 也不是整套详情系统重构许可
- 当前下一步必须先做：
  - 冻结主文书
  - 提交新的《阶段门禁核查表》
  - 按 `SSOT -> contracts -> backend truth -> BFF -> frontend` 补齐分层文书
  - 发出 A / B 双轨派工单
- 当前仍然：
  - `No-Go for direct full-system rewrite`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 7. Next Unique Action

- 下一轮唯一动作：
  - 以《工厂详情优化修复 Stage Gate Checklist V1.1》为门禁入口，正式发出 A / B 双轨派工并持续收回执直到 Gate 4 收口
