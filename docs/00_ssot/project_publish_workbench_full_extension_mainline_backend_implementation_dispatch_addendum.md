---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the authored backend implementation dispatch prompt for
  `发布项目工作台及延伸功能全链` so the cloud Server execution handoff text
  stays inside the already-frozen full-object scope, while real
  implementation dispatch issuance remains blocked by the current
  stage veto and root guardrail.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_package_level_implementation_unlock_assessment_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《发布项目工作台及延伸功能全链 backend implementation dispatch》

## 1. 当前阶段

- 主对象：
  - `发布项目工作台及延伸功能全链`
- 子阶段：
  - `backend implementation dispatch authoring`
- 当前必须明确：
  - 这份文书只是在 author 后端派工口令
  - 当前仍然不是 `real implementation dispatch issuance`
  - 当前仍不得直接发送给 `后端 Agent`

## 2. 当前唯一动作

- 供后续使用的 `后端 Agent` 执行口令如下。
- 当前口令已 author 完成，但在 `real implementation dispatch issuance` veto 单独解除前不得发送。

## 3. 后端 Agent 口令正文

```text
你是后端 Agent（仅云端），本轮不是重做整张交易工作台，也不是打开 trading flow implementation。你这轮只在《发布项目工作台及延伸功能全链》已经冻结好的 full-object 范围内，完成 Server 侧最小实现 authoring。

【一、唯一目标】
你这轮只完成 6 件事：
1. 保持并对齐 `workbench` 四容器 summary / handoff projection：
   - `project_chain`
   - `order_chain`
   - `fulfillment_chain`
   - `extension_boundary`
2. 保持并对齐当前已冻结的成熟 `project_chain` truth：
   - `project/create`
   - `project/detail`
   - `project/list`
3. 保持并对齐 `my_project` 的最小 private carry：
   - `my/projects`
   - `my/projects/{projectId}`
4. 闭合当前已冻结的 read-corridor truth：
   - `order/detail`
   - `contract/detail`
   - `milestone/list`
   - `inspection/detail`
5. 对以下节点只按 shell / handoff truth position 做最小 authoring：
   - `milestone/submit`
   - `inspection/submit`
   - `dispute/open`
6. 保持 upload 三段式与 `evidence / file_asset` 最小复用：
   - `init -> direct upload -> confirm`
   - `objectKey` 继续不是真值

【二、强制阅读】
- docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
- docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
- docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
- docs/00_ssot/project_publish_workbench_full_extension_mainline_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml

【三、只允许处理的范围】
- apps/server/src/modules/exhibition_workbench/**
- apps/server/src/modules/project/**
- apps/server/src/modules/my_project/**
- apps/server/src/modules/trading_read_corridor/**
- apps/server/src/modules/upload/**
- 与上述冻结对象直接相关的最小 supporting touch

【四、禁止事项】
- 不得重开 `order/create`
- 不得重开 `contract/confirm`
- 不得重开 `contract/amend`
- 不得重开 `inspection/recheck`
- 不得重开 `rating/*`
- 不得重开 `dispute/withdraw`
- 不得新增新 path family
- 不得新增第二状态机
- 不得把 `workbench` 写成 truth owner
- 不得把 `my_project` 写成 full-object truth owner
- 不得把 `objectKey` 写成业务真值
- 不得把 `milestone/submit`、`inspection/submit`、`dispute/open` 写成 active command truth family 已成立
- 不得把 shell / handoff 节点写成 runtime write chain 已闭环
- 不得把 `订单承接与履约承接主链` 重新抬成当前 full mainline

【五、必须落实的真义】
1. workbench 四容器承接
- `workbench` 只继续承担：
  - summary
  - handoff
- 不能被写成：
  - 第二状态机
  - 治理后台
  - 下游详情 truth owner

2. project_chain 最小 truth
- 只允许承接当前已冻结的成熟资产：
  - `project/create`
  - `project/detail`
  - `project/list`
- `projects` 仍是 project instance 的唯一 canonical carrier
- 不得扩到：
  - `bid / award / order conversion`

3. my-project 最小 private carry
- 只允许保持：
  - `my/projects`
  - `my/projects/{projectId}`
    的 private carry continuation
- 不得把 `my_project` 写成：
  - `workbench` 替代物
  - `order / contract / milestone / inspection` detail owner

4. order / fulfillment read corridor
- 只允许承接当前最小 read truth：
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
- controlled unavailable / invalid-state / frozen-boundary 继续由 `Server` 决定
- 不得把 route presence 写成 runtime 闭环完成

5. shell / handoff truth position
- `milestone/submit`
- `inspection/submit`
- `dispute/open`
  只允许保留为 shell / handoff truth position
- 不得把它们升级成：
  - active command truth family 已成立
  - runtime write chain 已闭环
- 若当前冻结边界不足以安全落地：
  - 必须 fail-closed 返回 blocker
  - 不得猜

6. upload / evidence 边界
- 只能复用：
  - `evidences`
  - `file_assets`
  - `init -> direct upload -> confirm`
- `objectKey` 继续不是真值
- 不得借此扩成 payment / moderation / reporting 第二协议族

【六、完成标准】
- `workbench` 四容器 summary / handoff 仍在冻结边界内
- `project_chain` 成熟资产未漂移
- `my_project` private carry 未漂移成详情 truth owner
- read-corridor 在当前冻结字段内可跑
- `milestone/submit`
- `inspection/submit`
- `dispute/open`
  要么在 shell / handoff 边界内可承接，要么给出 fail-closed blocker
- upload 三段式未被破坏
- 排除项没有被顺手带回

【七、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. `workbench` 四容器承接结果
4. `project/create / project/detail / project/list` 结果
5. `my/projects / my/projects/{projectId}` 结果
6. `order/detail / contract/detail / milestone/list / inspection/detail` 结果
7. `milestone/submit / inspection/submit / dispute/open` 的 shell / handoff 结果
8. upload / evidence 复用结果
9. 当前剩余阻断项
10. 是否可移交 `BFF Agent`

【八、输出禁令】
- 不要写“应该可以”
- 不要把 authoring 当成 send
- 不要把 shell / handoff 节点包装成 active command family
- 不要把 blocker 包装成 success
- 不要扩到排除项
- 只给真实代码修改与真实 smoke 结果
```

## 4. 只允许处理的目录范围

- 只允许写：
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/upload/**`
  - 与上述冻结对象直接相关的最小 supporting touch
- 不得扩到无关模块。

## 5. 禁止事项

- 不得重开：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/withdraw`
- 不得新增新 path family
- 不得新增第二状态机
- 不得把 `workbench` 写成 truth owner
- 不得把 `objectKey` 写成业务真值
- 不得把 shell / handoff 节点写成 runtime write chain 已闭环

## 6. 完成标准

- authoring 完成的标准只限：
  - prompt 文本已形成
  - 作用域已冻结
  - 禁止事项已写死
- 当前不得写成：
  - 后端代码已实现
  - 云端已验证通过
  - 可直接移交结果校验

## 7. Formal Conclusion

- `Go for package-level implementation unlock assessment authoring`
- `No-Go for real backend implementation dispatch issuance`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《发布项目工作台及延伸功能全链 package-level implementation unlock assessment》
