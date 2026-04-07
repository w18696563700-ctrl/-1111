---
owner: Codex 总控
status: frozen
purpose: Record the direct runtime evidence failure for the `viewerProjectRelation` carrier on `GET /server/my/projects/{projectId}`, freezing that the retained condition is not yet closed at the active Server runtime.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_condition_closure_review_conclusion_addendum.md
  - docs/00_ssot/my_building_round1_supplemental_review_rejection_and_evidence_next_action_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
---

# 《我的楼 Round 1 viewerProjectRelation 运行态补证失败结论单》

## 1. Current Object

- 当前对象：
  - `我的楼专项开发主线`
  - `我的楼 Round 1 viewerProjectRelation carrier proof`
- 当前结论类型：
  - direct runtime evidence review

## 2. Current Runtime Conclusion

- 当前直接运行态结论：
  - `不通过`
- 当前已直接确认：
  - `GET /server/my/projects/{projectId} = 200`
  - 但 active Server runtime 返回体中的 `publicProject.viewerProjectRelation` 不存在
- 当前证据链固定为：
  - 直打 `http://127.0.0.1:3101/server/*`
  - 不经过 `BFF`
  - 因此当前缺字段现象不能归因为 BFF fallback

## 3. What This Means

- 当前正式意味着：
  - 本地仓代码层面的 condition-closure 结论不能直接外推成 active runtime closure
  - 当前 active Server runtime 与当前仓库代码状态之间仍存在：
    - runtime alignment gap
    - deploy / build / running artifact gap
    - or equivalent execution-path mismatch
- 当前不允许写成：
  - `viewerProjectRelation condition fully closed`
  - `supplemental result verification passed`
  - `integration release eligible`

## 4. Fixed Facts

- 当前固定事实如下：
  - `[openapi]` 仍要求 `MyProjectDetailReadModel.publicProject = ProjectReadModel`
  - `ProjectReadModel.viewerProjectRelation` 仍是 required carrier
  - 仓库代码中：
    - `my-project.query.service.ts` 已显式派生该 carrier
    - `my-project.presenter.ts` 已显式写入该 carrier
  - 但 active runtime response 中：
    - 该 carrier 未被观察到

## 5. Current Stage Meaning

- 当前允许含义：
  - 进入一轮 bounded backend runtime-alignment correction
  - 只解决 active Server runtime 与当前仓库实现不一致的问题
- 当前不允许含义：
  - 不允许进入联调发布
  - 不允许进入 release-prep
  - 不允许进入 closure

## 6. Next Unique Action

- 下一轮唯一动作：
  - 向 `后端 Agent` 发起云端 runtime alignment / redeploy correction
