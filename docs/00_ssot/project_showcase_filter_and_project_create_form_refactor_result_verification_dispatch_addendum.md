---
owner: Codex 总控
status: active
purpose: Freeze the independent verification dispatch for the project showcase filter and project create form refactor after backend, BFF, and frontend receipts are all available for the current bounded implementation round.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bff_implementation_dispatch_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_implementation_dispatch_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目展示筛选与创建表单重构独立复核派工单》

## 1. Scope

- 本派工单只适用于：
  - `项目展示筛选与创建表单重构`
- 本派工单只复核：
  - backend / BFF / frontend 本轮 bounded implementation round
- 本派工单不代表：
  - integration 放行
  - release-prep 放行
  - production release 放行

## 2. Receipt Gate

- 当前 receipt gate 已满足：
  - backend cloud receipt：
    - `/srv/apps/server/current/tmp/project_showcase_filter_and_project_create_form_refactor_backend_receipt_addendum.md`
  - BFF cloud receipt：
    - `/srv/apps/bff/current/tmp/project_showcase_filter_and_project_create_form_refactor_bff_receipt_addendum.md`
  - frontend local receipt：
    - [project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_frontend_receipt_addendum.md)

## 3. Current Verification Target

- 当前独立复核只回答 8 个问题：
  1. `apps/bff` full build 是否已在当前 verifier 环境独立通过
  2. app-facing dual-field create 是否真实闭合
  3. app-facing legacy-title create 是否仍然可用
  4. `project/list` 的 `provinceCode / cityCode / areaBucket / budgetBucket` 是否真实生效
  5. 项目展示列表卡片是否已按冻结后的主信息顺序消费真实字段
  6. `project/detail` 是否已双字段优先消费
  7. expired public continuation unavailable 是否已在 formal `80/8080` chain 上真实闭合
  8. 当前是否允许进入下一轮 review conclusion

## 4. Fixed Runtime Entry

- formal tunnel entry：
  - `http://127.0.0.1:8080`
- cloud formal chain：
  - `80 -> 3000 -> 3001`
- 当前固定真实账号样本：
  - `mobile = 18696563700`
  - `otpCode = 000000`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`

## 5. Fixed Known Samples

- expired public detail sample：
  - `projectId = 66f189e3-864a-4802-8cab-2e031857e8a2`
- backend direct dual-field sample：
  - `projectId = 363e63ee-6c24-4b29-b502-0656052cb93d`
- BFF app-facing dual-field sample：
  - `projectId = 93c4d3d8-9976-4231-bc98-a11111cb7142`
- BFF app-facing legacy-title sample：
  - `projectId = 07ad105e-da83-4880-b7f5-2bb50007ff11`

## 6. Mandatory Verification Steps

1. 先核对三份回执是否存在且对象一致。
2. 独立重跑 BFF full build：
   - `ssh root@47.108.180.198 'cd /srv/apps/bff/current && npm run build'`
3. 独立核对 formal health：
   - `GET http://127.0.0.1:8080/health/bff/live`
4. 使用真实登录态：
   - `POST /api/app/auth/otp/login`
   - `POST /api/app/profile/organization/switch`
5. 独立发起 dual-field create：
   - `POST /api/app/project/create`
   - body 至少包含：
     - `title`
     - `exhibitionName`
     - `brandName`
     - `buildingType`
     - `budgetAmount`
     - `areaSqm`
     - `provinceCode / provinceName`
     - `cityCode / cityName`
     - `detailAddress`
     - `scopeSummary`
     - `plannedStartAt`
     - `plannedEndAt`
6. 独立发起 legacy-title create：
   - `POST /api/app/project/create`
   - body 只保留：
     - `title`
     作为身份字段
   - 其余既有 create 必填字段继续提供
7. 独立核对 dual-field detail：
   - `GET /api/app/project/detail?projectId=<freshDualFieldProjectId>`
   - 必须确认：
     - `exhibitionName`
     - `brandName`
     - `title`
     三者语义一致
8. 独立核对 legacy-title detail：
   - `GET /api/app/project/detail?projectId=<freshLegacyProjectId>`
   - 必须确认：
     - `title` 存在
     - `exhibitionName = null`
     - `brandName = null`
9. 独立核对 filtered list：
   - `GET /api/app/project/list?provinceCode=650000&cityCode=650100&areaBucket=36_sqm&budgetBucket=8_10w`
   - 必须返回非空 `items`
   - 必须命中 dual-field 样本或 fresh dual-field project
10. 独立核对 expired list trimming：
   - 使用 expired 条件对应 query
   - 不能再把 expired 样本留在 public `project/list`
11. 独立核对 expired detail unavailable：
   - `GET /api/app/project/detail?projectId=66f189e3-864a-4802-8cab-2e031857e8a2`
   - 期望：
     - `404`
     - `code = AUTH_RESOURCE_UNAVAILABLE`
12. 独立重跑 frontend bounded proof：
   - `cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/project_showcase_filter_create_refactor_test.dart`
   - 必要时补跑：
   - `flutter analyze` 本轮修改文件 + 上述测试文件

## 7. Hard Rules

- 不得把回执改写成通过
- 不得把 fake/demo transport 当成通过
- 不得把 `items=[]` 写成筛选已闭合
- 不得把 `404 AUTH_RESOURCE_UNAVAILABLE` 写成前端或 BFF 失败
- 如任一关键步骤失败，必须原样记录状态码、错误码或 build 错误
- 当前无论结果如何，都不得写成 release-prep 或 production release

## 8. Expected Output

- 结果校验 Agent 输出必须至少回答：
  1. `apps/bff` full build 是否独立通过
  2. dual-field create 是否在 app-facing 路径下独立通过
  3. legacy-title create 是否在 app-facing 路径下独立通过
  4. `project/list` 四个 query 是否独立通过
  5. 紧凑卡片与双字段详情的前端 bounded proof 是否独立通过
  6. expired unavailable 是否独立通过
  7. 当前是否允许进入 review conclusion

## 9. Next Unique Action

- 下一步唯一动作：
  - 把本派工单对应的执行口令发给 `结果校验 Agent`
