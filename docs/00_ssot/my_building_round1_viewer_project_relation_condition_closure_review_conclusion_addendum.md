---
owner: Codex 总控
status: frozen
purpose: Record the control review conclusion for the `viewerProjectRelation` condition-closure correction in `我的楼 Round 1`, freezing that the retained condition is now closed at the current implementation boundary.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_condition_closure_dispatch_addendum.md
  - docs/00_ssot/my_building_round1_result_verification_review_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
---

# 《我的楼 Round 1 viewerProjectRelation 条件闭环复签结论单》

## 1. Current Object

- 当前对象：
  - `我的楼专项开发主线`
  - `我的楼 Round 1` retained condition closure
- 当前裁决类型：
  - control review after bounded correction receipt

## 2. Current Review Conclusion

- 当前总控复核结论：
  - `通过`
- 当前已独立确认：
  - `GET /server/my/projects/{projectId}` 的 `publicProject` 已由 server-side 显式带出 `viewerProjectRelation`
  - list 仍未扩到 `viewerProjectRelation`
  - `my-project` 仍保持当前私域 detail route family
  - 未新增第二条 detail family
  - 未改写 `publicProject + privateProgress` contract

## 3. Current Closed Condition

- 当前已闭环条件固定为：
  - `MyProjectDetailReadModel.publicProject = ProjectReadModel`
  - `ProjectReadModel.viewerProjectRelation` required carrier
  - `my-project detail` server-side 显式携带该 carrier
- 当前正式不再保留：
  - `BFF fallback masks missing server-side carrier` 这一条件项

## 4. Independent Evidence

- 当前已独立确认：
  - [my-project.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.presenter.ts) 的 detail 读面显式写入 `viewerProjectRelation`
  - [my-project.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.query.service.ts) 在当前 `my-project detail` 链上显式派生 `owner / non_owner`
  - `apps/server`：
    - `./node_modules/.bin/tsc --noEmit` 通过
    - `./node_modules/.bin/nest build` 通过

## 5. Current Stage Meaning

- 当前允许含义：
  - 可以重提 `我的楼 Round 1` 结果校验补充复核
- 当前不允许含义：
  - 仍不等于 integration release pass
  - 仍不等于 release-prep pass
  - 仍不等于 closure pass

## 6. Next Unique Action

- 下一轮唯一动作：
  - 向 `结果校验 Agent` 发起《我的楼 Round 1 结果校验补充复核结论单》
