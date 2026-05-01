---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for the supplier display workbench homepage round, allowing only docs freeze, local Flutter implementation, local verification, screenshots, and readonly tunnel smoke.
layer: L0 SSOT
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_stage_gate_checklist_addendum.md
  - docs/04_frontend/supplier_workbench_homepage_frontend_surface_addendum.md
freeze_date_local: 2026-05-01
---

# 《供应商展示工作台首页化阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `供应商展示工作台首页化`
- 当前门禁只服务于：
  - Day 1 docs freeze
  - Day 2 local Flutter homepage shell
  - Day 3 local module drill-in and preview connection
  - Day 4 local verification, screenshots, readonly tunnel smoke
- 当前门禁不代表：
  - BFF implementation unlock
  - Server implementation unlock
  - contracts change unlock
  - database change unlock
  - cloud deployment unlock
  - release-prep
  - production release

## 2. Passed Gates

- 真源门禁：
  - 当前只能消费 existing workbench / published-change / case / status data。
  - 首页字段映射表已经明确每块来源。
  - 延期项已经冻结为 non-goals。
- 架构边界门禁：
  - Flutter App 仍只通过 BFF 读取。
  - BFF 仍只做 app-facing aggregation，不在本轮改动。
  - Server 仍是 enterprise display truth owner，不在本轮改动。
  - 本轮不新增 global private route family。
- 契约门禁：
  - 不新增 OpenAPI 字段。
  - 不新增 analytics / review / activity feed contract。
  - 不修改 existing canonical path。
- 前端门禁：
  - 只允许本地 Flutter 展示层重排、折叠、入口化。
  - 不删除 existing field。
  - 不新增 fake data。
  - 不新增 fake button。
  - 不改 bottom nav route。
- 体验门禁：
  - 首页不展示无真值支撑的曝光、访客、询盘、收藏实数。
  - 首页不做客户评价管理页。
  - 首页不做最新动态。
  - 首页不把联系供应商当成私域工作台主 CTA。
- published change 门禁：
  - live public display 与 current change draft preview 必须继续分离。
  - 保存修改不得被解释为直接更新线上展示。

## 3. Failed Gates

- analytics truth gate：
  - failed，本轮不得展示真实统计指标。
- review management gate：
  - failed，本轮不得做客户评价管理页。
- activity feed gate：
  - failed，本轮不得做最新动态。
- BFF implementation gate：
  - failed，本轮不得修改 BFF。
- Server implementation gate：
  - failed，本轮不得修改 Server。
- contracts gate：
  - failed，本轮不得修改 OpenAPI / contracts。
- cloud deployment gate：
  - failed，本轮不得动云端部署。

## 4. Veto Gates

- no BFF edits
- no Server edits
- no OpenAPI / contracts edits
- no database edits
- no cloud deployment edits
- no fake analytics
- no fake review list
- no fake activity feed
- no public supplier CTA as private workbench primary action
- no bottom navigation route changes
- no weakening of published-change corridor
- no deleting existing field; only regroup, collapse, or move behind entries

## 5. Day Gate Decisions

| Day | Gate | Decision |
|---|---|---|
| 第 1 天 | docs freeze + field mapping | Allowed |
| 第 2 天 | supplier homepage shell | Allowed after docs freeze lands |
| 第 3 天 | module drill-in + preview | Allowed after Day 2 analyze / route smoke passes |
| 第 4 天 | verification + screenshots + readonly tunnel smoke | Allowed after Day 3 module flow passes |

## 6. Passed Gates Summary

- passed gates:
  - 真源门禁
  - 架构边界门禁
  - 契约不变门禁
  - 前端展示层门禁
  - published change 保留门禁

## 7. Failed Gates Summary

- failed gates:
  - analytics truth gate
  - review management gate
  - activity feed gate
  - BFF implementation gate
  - Server implementation gate
  - contracts gate
  - cloud deployment gate

## 8. Stage Go / No-Go Decision

- whether the next stage is allowed:
  - `Allowed`
- 当前仅允许进入：
  - supplier homepage local Flutter implementation
  - local targeted tests
  - screenshot verification
  - readonly tunnel smoke
- 当前明确 `No-Go`：
  - BFF / Server / contracts / database / cloud implementation
  - analytics / review / activity feed implementation
  - release-prep
  - production release

## 9. Next Unique Action

- 下一轮唯一动作：
  - 实施 `供应商展示工作台首页化` 的 local Flutter 页面骨架、模块入口、预览摘要、底部动作栏，并做本地验证。
