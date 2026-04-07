---
owner: 联调发布 Agent
status: frozen
purpose: Record the independent development-stage integration verification conclusion for `我的楼 Round 1`, freezing that the current app-facing chain is not yet passable and may not advance to release-prep, launch approval, or closure.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_round1_result_verification_supplemental_review_conclusion_addendum.md
  - docs/00_ssot/my_building_round1_integration_release_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
---

# 《我的楼 Round 1 development-stage integration release verification 独立复核结论单》

## 1. Current Object

- 当前对象：
  - `我的楼专项开发主线`
  - `我的楼 Round 1 development-stage integration release verification`
- 当前复核类型：
  - independent integration verification

## 2. Independent Conclusion

- 当前独立复核结论：
  - `not passed yet`
- 当前已独立确认：
  - tunnel、真实 topology、运行态证据、回滚方案均已形成可引用证据
  - 当前 app-facing list/detail 链确实来自真实云端 runtime，而不是本地伪数据
- 当前未通过事实固定为：
  - active app-facing `GET /api/app/my/projects/{projectId}` response 仍缺少：
    - `publicProject.viewerProjectRelation`
  - direct upstream `GET /server/my/projects/{projectId}` 已显式返回：
    - `publicProject.viewerProjectRelation = owner`
  - 因此当前缺口已收敛为：
    - active BFF app-facing detail carrier gap

## 3. Verified Topology And Runtime Result

- 当前已独立确认的 topology：
  - `http://127.0.0.1:8080 -> 47.108.180.198:80 -> Nginx -> BFF:3000`
  - 当前 app-facing `my/projects` 上游实际使用：
    - `Server:3101`
- 当前已独立确认的通过项：
  - tunnel reachable
  - 当前 host / tunnel / local address 符合冻结口径
  - `GET /api/app/my/projects` grouped list 结构正确
  - `GET /api/app/my/projects/{projectId}` 仍为 `publicProject + privateProgress`
  - `401` / `404` app-facing 错误归一仍在冻结边界内
  - `我的楼 -> 我的项目 -> detail` 的 IA 与前端 surface 未越界
- 当前未通过项：
  - app-facing detail carrier gate
  - end-to-end owner / non_owner surface observability

## 4. Root Cause Snapshot

- 当前 active BFF release source 已独立确认仍为旧版：
  - [my-project.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/my_project/my-project.service.ts) 的本地仓库版本已包含 `viewerProjectRelation` shaping
  - 但 active release `/srv/releases/bff/20260404160902/apps/bff/src/routes/my_project/my-project.service.ts` 的对应实现仍未把该 carrier 写入 app-facing detail response
- 因此当前问题性质固定为：
  - runtime alignment gap at active BFF release
  - not a Server truth gap
  - not a Flutter consumption gap

## 5. Veto And Stage Meaning

- 当前 veto 影响固定为：
  - contract / frontend-experience veto at app-facing detail chain
- 当前正式阶段含义：
  - 仍停留在 `development-stage integration verification`
  - `No-Go` for integration verification pass
  - `No-Go` for release-prep
  - `No-Go` for launch approval
  - `No-Go` for closure

## 6. Next Unique Action

- 下一轮唯一动作：
  - 由总控向 `BFF Agent` 发出单点 `runtime alignment` 派工
- 当前禁止直接进入：
  - release-prep
  - launch approval
  - closure
