---
owner: Codex 总控
status: frozen
purpose: Freeze the pre-integration-release gate state for `我的楼 Round 1`, recording that the mainline may now enter development-stage integration release verification without implying release-prep, launch approval, or closure.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_round1_result_verification_supplemental_review_conclusion_addendum.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md
---

# 《我的楼 Round 1 联调发布前门禁核查表》

## 1. Scope

- 本门禁核查表只服务于：
  - `我的楼专项开发主线`
  - `我的楼 Round 1 development-stage integration release`
- 本门禁核查表只回答：
  - 当前是否允许进入联调发布
  - 当前联调发布只允许验证什么
  - 哪些门禁已通过
  - 哪些门禁仍未通过
  - 哪些是一票否决
- 本门禁核查表不等于：
  - release-prep pass
  - launch approval
  - closure pass

## 2. Gate Basis

- 当前联调发布前门禁依据冻结为：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [development_stage_cloud_host_override_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/development_stage_cloud_host_override_addendum.md)
  - [my_building_round1_increment_dispatch.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_increment_dispatch.md)
  - [my_building_round1_result_verification_supplemental_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_result_verification_supplemental_review_conclusion_addendum.md)
  - [my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md)

## 3. Passed Gates

- 真源门禁：
  - 通过
  - `我的楼` 当前 truth / contracts / bounded implementation chain 已冻结且未出现第二真源根。
- 架构边界门禁：
  - 通过
  - 仍保持：
    - `Flutter App -> BFF only`
    - `BFF` 不持有 business truth
    - `Server` 是唯一 business truth owner
    - visible buildings 仍只限 `exhibition / messages / profile`
- 派工边界门禁：
  - 通过
  - 当前后端 / BFF / 前端实现均已落在 frozen dispatch boundary 内。
- 结果校验门禁：
  - 通过
  - `我的楼 Round 1` 补充结果校验现已通过。
- 运行态对齐门禁：
  - 通过
  - active `/server/my/projects/{projectId}` 已直接返回 `publicProject.viewerProjectRelation`。
- 开发态拓扑门禁：
  - 通过
  - 当前开发阶段 host / tunnel / local address 仍冻结为：
    - `47.108.180.198`
    - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
    - `http://127.0.0.1:8080`

## 4. Failed Gates

- release-prep gate：
  - 未通过
  - 当前尚未形成 release-prep 证据链。
- launch / release gate：
  - 未通过
  - 当前尚未形成正式上线放行链。
- closure gate：
  - 未通过
  - 当前尚未形成主线 closure 结论。

## 5. Veto Gates

- 当前联调发布仍必须继续受以下 veto 约束：
  - 不得借联调发布新增 scope
  - 不得误开放 hidden building
  - 不得把 `profile` 写成 truth owner
  - 不得把 `我的楼` 写成第二论坛首页或第二 dashboard
  - 不得把 `我的项目` 写成 `项目工作台`
  - 不得把 owner manage shell 落成真实 action execution
  - 不得把 `docs-frozen` 写成 `runtime fully open`
  - 不得产出发布口径
- 任一 failed veto gate 继续直接阻断阶段。

## 6. Current Release Integration Scope

- 当前联调发布只允许验证：
  - 本地前端 + 云端 BFF / 后端 的真实拓扑闭环
  - 当前 tunnel / runtime access 证据
  - `我的楼 -> 我的项目 -> 单项目 detail` 主线闭环
  - `publicProject + privateProgress` / `publicProject + privateSummary` 运行态承接
  - owner / non-owner surface 分流当前是否与冻结口径一致
  - 当前回滚方案与门禁状态
- 当前联调发布不包括：
  - release-prep
  - launch approval
  - closure

## 7. Stage Go / No-Go

- 当前阶段结论：
  - `Go` for development-stage integration release verification
  - `No-Go` for release-prep
  - `No-Go` for launch approval
  - `No-Go` for closure

## 8. Formal Conclusion

- 当前正式结论如下：
  - `我的楼 Round 1` 现在允许进入 `联调发布 Agent`
  - 当前联调发布只等于 development-stage integration verification
  - 当前不等于允许上线

## 9. Next Unique Action

- 下一轮唯一动作：
  - 先向 `联调发布 Agent` 发出 integration-only prompt bundle
