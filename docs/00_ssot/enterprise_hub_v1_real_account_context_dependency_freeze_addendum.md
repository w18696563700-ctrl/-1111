# Enterprise Hub V1 真实账号上下文依赖冻结说明

---
owner: Codex 总控
status: draft
purpose: Freeze and record the dependency that enterprise_hub V1 currently lacks full organization-context capable account/runtime entry for business-layer release gating.
layer: L0 SSOT
---

## 说明对象

本说明适用于 `enterprise_hub V1`，用于把当前真实账号上下文缺口固定为一条可追溯的阶段记忆。

## 背景事实（已观察）

- 当前 `/api/app/exhibition/enterprise-hub/applications` 在无真实组织上下文条件下可返回：
  - `code=ENTERPRISE_HUB_PERMISSION_DENIED`
- 当前 `/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}` 与
  `/api/app/exhibition/enterprise-hub/applications/{applicationId}` 在无对应业务实体时可返回 `404` 业务态。
- 这些结果来自路径及路由已打通，而不是 404 溯源于路由不存在。
- 因此前轮重试发布未通过，并非“功能未写完”而是“真实账号组织上下文与可验证业务数据前置条件未满足”。

## 冻结结论

在“下一阶段开发”进入前，必须固定以下边界：

1. 本轮继续推进的 `enterprise_hub` 实施，可认为“功能链路已接入”。
2. 同时必须承认并冻结“真实账号/组织上下文未接入”这条阻断前置。
3. 在该项补齐前，不能将当前 403/404 的业务状态视作最终发布阻断以外的代码缺陷。
4. 发布层面的可交付判定仍需在下列条件齐备后才重新恢复：
   - 有效组织上下文的账号链路通畅；
   - 至少有一条可被前端消费的 `enterprise` 与 `application` 可验证数据；
   - detail 与 application 主链路在上述前提下返回预期业务态。

## 下一阶段动作（遗忘防遗忘）

- 在下一阶段入口文档、任务说明、发布准入清单中必须带上本说明链接。
- 任何联调发布阶段，不得再重复提交“路由不存在”作为失败归因。
- 真正阻断项仅在于“未补齐真实组织上下文与业务数据前置”，而非当前 BFF/Server 运行性。
