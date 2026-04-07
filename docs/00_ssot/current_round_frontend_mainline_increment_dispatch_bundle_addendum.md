---
owner: Codex 总控
status: draft
purpose: Freeze the current-round incremental dispatch order, role-specific receipt templates, rollback evidence minimum, and attachment-chain retest evidence minimum for the frontend-mainline-first round under the new six-role workflow.
layer: L0 SSOT
---

# 当前轮前端主线增量派工与回执证据包补充单

## Scope
- This addendum applies only to the current round started on `2026-03-28`.
- It freezes:
  - the current-round unique goal
  - the current-round incremental dispatch order
  - the role-specific standard receipt templates
  - the minimum rollback evidence pack
  - the minimum attachment-chain retest evidence pack
- It does not replace the six-role workflow baseline.
- It does not unlock release by itself.

## A. Current-round Unique Goal
- The current round freezes one unique goal only:
  - make the frontend mainline visible, understandable, and non-black-box first
- This means:
  - frontend is the current visible mainline
  - BFF and backend must follow that mainline with supporting increments
  - no sidecar implementation may outrun the current frontend mainline and
    become a second hidden project

## B. Current-round Gate Status
- The independent verification verdict for the current round is:
  - conditional pass
- Therefore:
  - result verification is not yet a full pass
  - integration and release work remains blocked
- The current blocked items are:
  - formal current-round incremental dispatch baseline
  - formal current-round standard receipt baseline
  - rollback evidence pack
  - attachment-chain retest evidence pack

## C. Current-round Dispatch Order
1. Codex 总控 issues the formal incremental dispatch order.
2. Frontend Agent executes the visible mainline increment locally.
3. BFF Agent executes cloud-side aggregation support only for the current
   frontend mainline.
4. Backend Agent executes cloud-side truth support only for the current
   frontend mainline.
5. Frontend, BFF, and backend all submit standard receipts back to Codex 总控.
6. Codex 总控 forwards the bundle to the result-verification agent.
7. Only a passed verification bundle may enter the integration and release
   agent.

## D. Current-round Topology Freeze
- Frontend works locally only.
- BFF and backend work in the cloud only.
- The only current valid local-to-cloud validation tunnel remains:
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84`
- The only current local access address remains:
  - `http://127.0.0.1:28790`
- The tunnel exists for access and validation only.
- The tunnel does not convert cloud development into local development.

## E. Current-round Increment Boundaries

### E1. Frontend Agent
- May do:
  - ordered exhibition home
  - project showcase
  - project detail
  - project publish workbench
  - workbench continuation visibility
  - UI loading, empty, error, permission, and tunnel-validation states
- Must not do:
  - local BFF code
  - local backend code
  - new business truth
  - fake-complete local mock completion

### E2. BFF Agent
- May do:
  - incremental shaping of the current app-facing project, workbench, and file
    upload paths
  - error normalization
  - timeout fallback
  - upload-signing and confirm handoff support
- Must not do:
  - second backend truth
  - second state machine
  - new parallel path families not frozen by current truth

### E3. Backend Agent
- May do:
  - incremental project read and write truth support
  - incremental file upload truth support
  - attachment truth support
  - audit and exception protection support
- Must not do:
  - local implementation masquerading as cloud work
  - state judgement pushed down into frontend or BFF
  - parallel replacement of existing project or file truth

### E4. Result-verification Agent
- May do:
  - independent review only
- Must not do:
  - implementation
  - integration release
  - range expansion

### E5. Integration / Release Agent
- Remains blocked until:
  - formal receipts exist
  - rollback evidence exists
  - attachment-chain retest evidence exists
  - result verification signs off

## F. Role-specific Standard Receipt Templates

### F1. Frontend Agent receipt
A. 本轮前端沿用项
B. 本轮前端新增项
C. 本轮前端修正项
D. 新增文件清单
E. 修改文件清单
F. 删除/废弃文件清单（如有）
G. 页面/组件/路由覆盖说明
H. 云端接口接入说明
I. 隧道命令与本地访问地址确认
J. 隧道验证结果
K. 未完成项
L. 风险与阻塞
M. 需要 BFF / 后端 / 联调配合项

### F2. BFF Agent receipt
A. 本轮 BFF 沿用项
B. 本轮 BFF 新增项
C. 本轮 BFF 修正项
D. 聚合/整形接口清单
E. 上传/签名/上下文处理说明
F. 错误码归一说明
G. 新增文件清单
H. 修改文件清单
I. 删除/废弃文件清单（如有）
J. 依赖的后端接口清单
K. 项目拓扑认知确认（前端本地 / BFF云端 / 后端云端 / 隧道存在）
L. 未完成项
M. 风险与阻塞
N. 需要前端 / 后端 / 联调配合项

### F3. Backend Agent receipt
A. 本轮后端沿用项
B. 本轮后端新增项
C. 本轮后端修正项
D. 数据模型/迁移清单
E. 接口实现清单
F. 状态机与权限说明
G. 审计与异常处理说明
H. 新增文件清单
I. 修改文件清单
J. 删除/废弃文件清单（如有）
K. 项目拓扑认知确认（前端本地 / 后端云端 / BFF云端 / 隧道存在）
L. 未完成项
M. 风险与阻塞
N. 需要 BFF / 前端 / 联调配合项

### F4. Result-verification Agent receipt
A. 验收对象
B. 验收依据
C. 现有资产复核结论
D. 增量施工复核结论
E. 拓扑边界复核结论
F. 隧道链路复核结论
G. 验收结论（通过 / 有条件通过 / 不通过）
H. P0 阻断项
I. P1 重要缺陷
J. P2 可延期优化项
K. 是否允许进入联调发布
L. 必须补做项
M. 下一步唯一动作

### F5. Integration / Release Agent receipt
A. 现有发布资产识别结论
B. 联调范围
C. 隧道访问验证结果
D. 本地前端—云端服务打通结果
E. 主链路回归结果
F. 配置与环境检查结果
G. 发布门禁检查结果
H. 上线风险清单
I. 回滚方案
J. 是否允许上线
K. 上线前必须补做项
L. 下一步唯一动作

## G. Minimum Rollback Evidence Pack
- The current round may not claim releasability without one rollback evidence
  pack per affected execution side.
- The minimum rollback evidence pack must include:
  - rollback owner
  - affected role
  - affected environment
  - rollback version pointer or release pointer
  - rollback trigger condition
  - rollback steps
  - expected rollback verification points
  - residual impact after rollback
- Where applicable:
  - frontend local rollback may point to route, branch, or build baseline
  - BFF rollback must point to cloud release or runtime rollback anchor
  - backend rollback must point to cloud release, migration, or config rollback
    anchor
- A generic reference to baseline policy is not enough.
- The current round requires execution-side rollback evidence, not baseline
  theory only.

## H. Minimum Attachment-chain Retest Evidence Pack
- The current round also requires one formal attachment-chain retest pack.
- The retest pack must verify the currently reused upload chain only:
  1. `POST /api/app/file/upload/init`
  2. direct upload
  3. `POST /api/app/file/upload/confirm`
- The retest pack must include:
  - test owner
  - test environment
  - tested path set
  - request evidence for `upload/init`
  - direct upload success evidence
  - request evidence for `upload/confirm`
  - returned `FileAsset` or equivalent truth reference evidence
  - audit or log evidence where required
  - failure mode if not passed
- This retest pack exists to prove:
  - the chain is still alive
  - the chain was reused rather than rebuilt
  - the current round did not silently break attachment intake

## I. Current-round Non-goals
- No immediate release unlock
- No inference of full pass before the missing evidence packs exist
- No new path family by dispatch text alone
- No role substitution by the verification agent

## J. Authority Rule
- This file is the formal current-round process baseline for:
  - dispatch
  - receipts
  - rollback evidence minimum
  - attachment-chain retest evidence minimum
- Chat-delivered engineering commands must conform to this file.
