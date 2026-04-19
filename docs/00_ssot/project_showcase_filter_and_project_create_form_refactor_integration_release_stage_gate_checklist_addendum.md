---
owner: Codex 总控
status: frozen
purpose: Freeze the pre-integration-release gate state for the project showcase filter and project create form refactor object, recording that the bounded mainline may now enter development-stage integration verification without implying release-prep, launch approval, or production release.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_topology_and_tunnel_rules_round0.md
  - docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_result_verification_review_conclusion_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
---

# 《项目展示筛选与创建表单重构联调发布前门禁核查表》

## 1. Scope

- 本门禁核查表只服务于：
  - `项目展示筛选与创建表单重构`
  - `development-stage integration release verification`
- 本门禁核查表只回答：
  - 当前是否允许进入联调发布
  - 当前联调发布只允许验证什么
  - 哪些门禁已通过
  - 哪些门禁仍未通过
  - 哪些是一票否决
- 本门禁核查表不等于：
  - release-prep
  - launch approval
  - production release

## 2. Passed Gates

- 真源门禁：
  - 通过
  - 当前 truth / contract / backend / BFF / frontend / receipt / verification chain 已完整登记到 `docs/**`
- 架构边界门禁：
  - 通过
  - 仍保持：
    - `Flutter App -> BFF only`
    - `BFF` 不持有 business truth
    - `Server.project` 是唯一 business truth owner
- 派工边界门禁：
  - 通过
  - backend / BFF / frontend 实现均保持在 frozen dispatch boundary 内
- 结果校验门禁：
  - 通过
  - 当前 dual-field create / legacy-title create / list filter / expired unavailable 都已独立通过
- 开发态拓扑门禁：
  - 通过
  - 当前 host / tunnel / local address 仍冻结为：
    - `47.108.180.198`
    - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
    - `http://127.0.0.1:8080`

## 3. Failed Gates

- release-prep gate：
  - 未通过
- launch / release gate：
  - 未通过
- closure gate：
  - 未通过

## 4. Veto Gates

- 不得借联调发布新增 scope
- 不得把 `title` compatibility 删除
- 不得把 `plannedEndAt` 改写成正式完结或 persisted state
- 不得扩到：
  - `my/projects`
  - workbench
  - 附件公开
  - 审核状态机
  - 交易后链
  - 企业所在地筛选
- 不得产出 release-prep 或 production release 口径

## 5. Current Integration Scope

- 当前联调发布只允许验证：
  - 本地前端 + 云端 BFF / 后端 + 隧道访问的真实拓扑闭环
  - `project/create` dual-field mode
  - `project/create` legacy-title mode
  - `project/list` 四个 query 的真实过滤
  - 列表卡片六项主信息在真实返回下的消费闭环
  - `project/detail` 双字段优先消费
  - expired public continuation unavailable
- 当前联调发布不包括：
  - release-prep
  - launch approval
  - production release

## 6. Stage Go / No-Go

- 当前阶段结论：
  - `Go` for development-stage integration release verification
  - `No-Go` for release-prep
  - `No-Go` for launch approval
  - `No-Go` for production release

## 7. Formal Conclusion

- 当前正式结论如下：
  - `项目展示筛选与创建表单重构` 现在允许进入 `联调发布 Agent`
  - 当前联调发布只等于 development-stage integration verification
  - 当前不等于允许上线

## 8. Next Unique Action

- 下一轮唯一动作：
  - 先向 `联调发布 Agent` 发出 integration-only prompt bundle

