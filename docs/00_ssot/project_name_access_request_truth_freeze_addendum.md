---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Day-1 truth for `项目名称申请查看`, covering the public
  masked-title read rule, the organization-scoped request truth, the home-card
  summary-field swap, and the controlled messages handoff without inventing a
  second chat state machine or a new project visibility carrier.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_truth_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
---

# 《项目名称申请查看 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `首页红框项目卡片摘要替换`
  - `公域项目名受控可见`
  - `项目名称申请查看`
  - `消息楼会话化承接` 的 Day-1 语义冻结
- 本冻结单不覆盖：
  - generic DM / group chat
  - 新项目可见性状态机
  - 项目审核状态机
  - 竞标 / 定标 / 履约后链
  - `message/index` 旧提醒楼回收利用

## 2. Final Truth Conclusion

- `project/list` 与 `project/detail` 继续是公域 read surface。
- `my/projects`、`workbench`、owner private carry 继续是私域 surface。
- 当前新增对象不是新 `visibility/displayStatus` truth。
- 当前新增对象只是在既有公域项目 read model 之上增加：
  - 项目名称遮罩规则
  - 查看申请真值
  - owner 审批后可见的组织级授权
- 首页红框卡片的摘要改版继续只消费既有字段：
  - `cityName`
  - `areaSqm`
  - `plannedStartAt`

## 3. Public Name Visibility Rule

- 项目真实身份真值继续是：
  - 新项目优先 `exhibitionName + brandName`
  - 历史兼容继续允许回落到 `title`
- 对未授权 non-owner 的公域 `project/list` 与 `project/detail`：
  - 不再下发真实项目名称
  - 只允许下发 `displayTitle`
  - `displayTitle` 的未授权占位语义固定为：
    - `项目名称需申请查看`
- 当前正式写死：
  - 项目名称遮罩只影响公域读投影
  - 不得把它误写成项目下架、隐藏、delist、审核中

## 4. Authorized Viewer Boundary

- 以下 actor 当前继续允许看到真实项目名称：
  - owner-side actor
  - 已被批准的申请组织下 actor
- 以下 actor 当前只允许看到遮罩名称：
  - 未获批 non-owner public viewer
- 当前批准效果正式固定为：
  - 对 `requesterOrganizationId` 生效
  - 不是对单个 user 生效
  - 不是全局放开给所有 viewer

## 5. `ProjectNameAccessRequest` Truth

- 当前新增唯一业务真值对象固定为：
  - `ProjectNameAccessRequest`
- canonical anchor 固定为：
  - `projectId + requesterOrganizationId`
- 最小状态集合固定为：
  - `pending`
  - `approved`
  - `rejected`
- 当前正式写死：
  - 同一 `projectId + requesterOrganizationId` 只允许一条 active `pending`
  - `approved` 后，该组织对该项目的公域名称读取转为 `visible`
  - `rejected` 后，项目名称继续保持遮罩

## 6. Request Event Chain

当前 Day-1 正式冻结的最小事件链为：

1. `PublicProjectReadMasked`
2. `ProjectNameAccessRequested`
3. `ProjectNameAccessReviewProjectionUpserted`
4. `ProjectNameAccessApproved | ProjectNameAccessRejected`
5. `PublicProjectNameVisibilityGranted` on approved only

当前明确禁止：

- 第二项目名称权限状态机漂浮在 BFF / Flutter
- 把 `message/interactions` 当成真值 owner
- 把项目名称申请写成项目生命周期状态

## 7. Messages Handoff Rule

- 为满足“消息楼出现一个聊天列表，点击进入对话框，弹出申请”的产品诉求，
  Day-1 只冻结一个受控版本：
  - 消息楼可以出现一条 `project_name_access` 会话化条目
  - 点击后进入一个受控 review thread surface
  - thread 内只允许 `system_seed / system_notice`
  - owner 在受控卡片上发起 approve / reject
- 该受控 review thread 正式固定为：
  - subordinate to `ProjectNameAccessRequest`
  - not generic chat truth
  - no input composer
  - no unread / typing / online / mute / archive lifecycle

## 8. Home Card Summary Swap

- 首页红框卡片当前正式改为展示：
  - `搭建地 = cityName`
  - `项目面积 = areaSqm`
  - `进场时间 = plannedStartAt`
- 当前正式写死：
  - 这三项都来自既有项目读模型
  - 不是新的 persistence truth
  - 不是新的筛选真值

## 9. Hard Boundary

- 不新造项目 `visibility` / `displayStatus`
- 不把 `viewerProjectRelation` 扩成权限矩阵
- 不把 `message/index` 伪装成当前互动中心
- 不新造 generic message center
- 不新造第二聊天状态机
- 不让 BFF 或 Flutter 本地决定“是否可见项目名称”

## 10. Stage Conclusion

- 当前已形成：
  - `项目名称申请查看 Day-1` 的 L0 truth boundary
- 下一步只允许：
  - `Go for L2/L3/L4/L5 freeze authoring`
- 当前仍：
  - `No-Go for implementation`
