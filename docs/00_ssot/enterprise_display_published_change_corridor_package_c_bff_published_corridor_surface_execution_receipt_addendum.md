# enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_execution_receipt_addendum

## 1. 修改文件清单

- `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.module.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.service.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.read-model.ts`
- `apps/bff/test/enterprise-hub-published-change-surface.test.cjs`

## 2. changes/current family 暴露说明

当前 app-facing / internal mirror 已补齐：

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company`
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory`
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier`
- `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
- `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
- `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`

当前全部只转发到既有 server truth：

- `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
- `PUT /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
- `PUT /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company`
- `PUT /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory`
- `PUT /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier`
- `POST /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
- `PUT /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
- `DELETE /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
- `POST /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
- `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`

当前 BFF 只做：

- command/read transport
- current session / current organization scope transport
- request payload trim
- response shaping
- controlled error mapping

当前 BFF 不做：

- current change carrier 伪造创建
- 第二套 published-change 状态机
- apply / review 治理真相改写

## 3. error mapping 说明

当前 corridor family 已稳定承接并归一：

- `AUTH_SESSION_INVALID`
  - `当前登录态不可用，请重新登录后再试。`
- `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `当前组织身份不可进入或修改正式修改通道，请重新进入我的楼后再试。`
- `ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
  - `当前企业展示不可用，请返回企业展示工作台后再试。`
- `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE`
  - `当前企业展示暂不支持进入正式修改通道。`
- `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
  - `当前企业展示修改状态暂不可编辑或提交，请刷新后再试。`

补充：

- `GET /changes/current` 不会在 BFF 侧隐式建单
- `POST /changes/current/cases` 显式拒绝 `boardType`
- `PUT /changes/current/cases/{caseId}` 同样不接受 `boardType`

## 4. approved / applied 边界说明

当前 BFF surface 只透传 server truth，不混淆：

- `approved`
  - 只表示审核通过
  - 不代表 live listing 已更新
- `applied`
  - 才表示 live listing 已完成更新

当前 `GET /changes/current/status` 与 `GET /changes/current.currentChangeRequest.changeStatus`
都直接承接 server 返回的 `changeStatus`，没有在 BFF 做任何状态合并、派生或替换。

## 5. 测试清单

- `apps/bff/test/enterprise-hub-published-change-surface.test.cjs`

覆盖：

1. app-facing 与 internal controller 都暴露 `changes/current` family
2. `GET /changes/current` 只走 canonical read transport，不带副作用创建 carrier
3. `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE` 与 `ENTERPRISE_HUB_INVALID_STATE_TRANSITION` 能稳定透给 app-facing
4. `approved / applied` 在 BFF surface 明确保持分离
5. published corridor case create 不接受 `boardType`

## 6. build / test 结果

- `cd apps/bff && npm run build`
  - `PASS`
- `cd apps/bff && node --test test/enterprise-hub-published-change-surface.test.cjs`
  - `PASS`
  - `5 / 5`

## 7. 是否允许进入 Package D

- `no`

说明：

- 当前只证明 `Package C / BFF published-corridor surface package` 已具备最小 app-facing surface
- 是否进入 `Package D` 仍需由总控按后续 gate 单独判断
