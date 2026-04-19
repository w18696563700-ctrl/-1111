---
owner: Codex 总控
status: frozen
purpose: Record the stage gate checklist for the bounded frontend-only implementation round that moves the enterprise-display entry owner into `我的楼 / 我的资产`, exposes four chooser options, and cleans the enterprise-list bottom actions.
layer: L0 SSOT
freeze_date_local: 2026-04-09
---

# 《我的楼企业展示入驻前端实现轮阶段门禁核查表》

## 1. Scope

- 当前对象只限：
  - `我的楼 / 我的资产 -> 企业展示入驻` handoff
  - `优秀公司 / 优秀工厂 / 优秀供应商` 列表差异化
  - `个人/团队` 受控选择位露出
  - 工作台能力审核页整理
- 当前实施范围只限：
  - `docs/**`
  - `apps/mobile/**`
- 当前明确不包含：
  - contracts 变更
  - BFF 变更
  - Server truth 变更

## 2. passed gates

- 当前 docs freeze gate：
  - passed
- 当前 frontend surface freeze gate：
  - passed
- 当前 route family existence gate：
  - passed
- 当前 app-facing API reuse gate：
  - passed
- 当前 bounded entry-owner refinement gate：
  - passed
- 当前 no-new-truth-owner gate：
  - passed
- 当前 no-fake-personal-team-list gate：
  - passed
- 当前 no-public-apply-entry gate：
  - passed

## 3. failed gates

- 当前独立结果校验 gate：
  - failed
- 当前视觉验收截图 gate：
  - failed
- 当前 release-prep gate：
  - failed
- 当前 launch gate：
  - failed

## 4. veto gates

- 不得改写 `docs/01_contracts/**`
- 不得新增 `Server` 直连
- 不得发明新的企业真相
- 不得把 `我的楼` 漂成企业管理后台
- 不得把 `enterprise apply` 重写成第二套流程
- 不得为 `个人/团队` 临时伪造正式榜单
- 不得保留展示详情页到工作台的公开直达按钮
- 不得做超出 `apps/mobile` 的实现性扩写
- 不得用参考图替代本 app 已冻结真实字段

## 5. stage go / no-go decision

- 当前结论：
  - `Go`
- 当前允许进入的阶段只限：
  - bounded frontend implementation
- 当前不允许进入的阶段只限：
  - release-prep
  - launch approval
  - cross-layer truth rewrite

## 6. Current Meaning

- 这份门禁核查表的唯一含义是：
  - 允许 `apps/mobile` 在现有 contracts 和真实字段边界内，实施入口 owner 迁移、四项选择层，以及三类列表的底部动作清理
- 它不意味着：
  - 功能已完成验收
  - 运行时真实数据已经齐备
  - 可以跳过后续测试与截图验证

## 7. Next Action

- 当前唯一下一步固定为：
  - 在 `apps/mobile` 实施代码改动
  - 跑最小测试
  - 输出变更结果与剩余风险
