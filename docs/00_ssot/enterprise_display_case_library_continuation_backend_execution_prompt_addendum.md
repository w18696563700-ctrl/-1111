---
owner: Codex 总控
status: active
purpose: Execution prompt for the backend-first package that implements enterprise display case-library continuation under the frozen contract and truth boundaries.
layer: L0 SSOT
---

# 《enterprise display case library continuation backend execution prompt》

## 执行角色

- Backend Agent

## 读取顺序

执行前必须强制阅读：

1. [enterprise_display_case_library_continuation_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md)
2. [enterprise_display_case_library_continuation_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md)
3. [enterprise_display_case_library_continuation_backend_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_backend_stage_gate_checklist_addendum.md)
4. [docs/01_contracts/openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 唯一目标

你这轮只负责在 `Server` 落实 `案例库继续编辑` 的第一包后端真相。

当前唯一目标固定为：

1. 实现 `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
2. 实现 `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
3. 明确 direct case continuation 只适用于：
   - `未发布 / draft-editable`
4. 当目标 case 已进入 published-governed 语义时：
   - direct update 必须拒绝并返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`

## 允许修改

- `apps/server/src/modules/enterprise_hub/**`
- 与本轮最小后端闭环直接相关的最小测试文件

## 禁止事项

- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不实现 `changes/current` runtime
- 不新增第二套 case truth
- 不把 case 归属改成 `user-owned`
- 不顺手扩到频次治理

## 必须完成

1. `GET /cases/{caseId}`
- 返回单案例 edit carrier
- 只返回当前 organization scope 下可维护的 `listing-owned case`

2. `PUT /cases/{caseId}`
- 接住：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- 不接 `boardType`

3. 边界核落
- 如果目标 case 属于 `未发布 / draft-editable` 语义：
  - direct update 合法
- 如果目标 case 已进入 published-governed 语义：
  - direct update 不合法
  - 返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`

4. workbench 语义一致性
- `cases[]` 继续只当摘要列表
- 不要求把完整 edit carrier 再塞回 workbench list projection

## 最低测试要求

至少补齐：

1. `GET /cases/{caseId}` 能返回完整 edit carrier
2. `PUT /cases/{caseId}` 能更新 case 真值
3. `PUT /cases/{caseId}` 不接受 `boardType` 搬迁
4. organization scope 外访问被拒绝
5. published-governed case direct update 返回 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`

## 完成标准

结果必须证明：

1. `Server` 已具备 direct case continuation truth
2. case 仍然是 `listing-owned`
3. direct path 与 published corridor 的边界已经落地

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把整个 backend package 写成已完成
