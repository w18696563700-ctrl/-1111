---
owner: Codex 总控
status: frozen
purpose: Freeze the material supplement return loop while project communication free-send remains locked.
layer: L0 SSOT
freeze_scope: Project communication material supplement request, publisher supplement, and bidder re-review loop only
---

# 《项目沟通资料补充回流 Addendum V1》

## 1. 总裁决

资料确认中出现 `needs_supplement` 时，消息楼只负责承接提示、入口和回流，不开放自由聊天作为补充回复通道。

发布方必须回到真实项目资料页面补充或替换对应 `attachmentKind` 的报价依据资料。Server 保存新的 `ProjectAttachment` / `FileAsset` 真值后，自动向竞标方写入项目沟通业务事件与 unread，竞标方再回到对应资料确认页重新预览和确认。

本 Addendum 不修改服务费预授权、支付、合同、BidAward、Order / Contract seed、最终合同金额确认，不把消息楼扩展为 IM / 私信 / 群聊 / 客服系统。

## 2. 当前最小闭环

| 阶段 | 触发方 | 真实动作 | Server truth | 消息楼职责 | 裁决 |
|---|---|---|---|---|---|
| 要求补充 | 竞标方 | 在资料确认页对某项发布方资料提交补充意见 | `project_communication_material_reviews.reviewState = needs_supplement` | 通知发布方并提供业务入口 | 保留 |
| 发布方补充 | 发布方 | 在我的项目真实资料页补充或替换同一 `attachmentKind` 文件 | `ProjectAttachment` / `FileAsset` | 不承接自由聊天回复 | 必须走真实页面 |
| 补充回流 | Server | 检测同项目同 `attachmentKind` 的 `needs_supplement` review，写业务事件给竞标方 | ProjectCommunication message / notification / unread | 展示“已补充，请重新确认” | 必须 Server 写入 |
| 重新确认 | 竞标方 | 重新打开对应资料确认页，App 内预览后确认或继续要求补充 | material review 当前 sourceVersionToken | 跳转入口与状态提示 | 复用既有确认页 |

## 3. 状态规则

| 状态 | 含义 | 下一步 |
|---|---|---|
| `needs_supplement` | 当前资料被竞标方退回补充 | 发布方从真实项目资料页补充对应资料 |
| 新 `ProjectAttachment` 已绑定 | 对应资料来源已变化 | Server 向竞标方回流补充完成消息 |
| 当前 sourceVersionToken 与旧 review 不一致 | 旧 review 不再代表当前资料 | Workbench 投影为 `pending_review`，等待竞标方重新确认 |
| `confirmed` | 竞标方已确认当前版本资料 | 可继续竞标提交或后续流程 |

不得通过 Flutter 本地状态把 `needs_supplement` 改成 `pending_review` 或 `confirmed`。

## 4. 分层边界

| 层级 | 裁决 |
|---|---|
| Server | 持有 FileAsset、ProjectAttachment、material review、业务事件、notification、unread 真值。 |
| BFF | 只透出 Server 事件、workbench entry、routeTarget、unread，不创造补充状态。 |
| Flutter | 只做入口、提示、跳转、预览、确认动作和刷新展示。 |
| 消息楼 | 是交互枢纽，不是资料真值 owner，不承接自由聊天补充回复。 |
| 我的楼 / 项目资料页 | 是发布方补充报价依据资料的真实业务页面。 |

## 5. 幂等规则

补充回流事件的幂等上下文必须至少包含：

- `projectId`
- `attachmentKind`
- 新 `ProjectAttachment.id`
- 新 `fileAssetId`
- `reviewerOrganizationId`
- `bidId` / `review.id`
- `eventType`

同一发布方补充动作重复提交不得重复生成消息、通知或 unread；不同资料、不同竞标方、不同 bid / review、不同新文件不得互相去重。

## 6. No-Go

本轮不得：

- 因资料补充而解锁项目级自由发送。
- 用聊天消息替代真实资料补充。
- 让 Flutter 本地伪造补充完成或重新确认状态。
- 让 BFF 持有资料补充业务真值。
- 删除旧 review 审计记录。
- 扩展支付、钱包、保证金、结算、发票、合同金额确认或履约链路。

## 7. 四类判断

| 判断项 | 裁决 |
|---|---|
| 最稳 | Server 在 ProjectAttachment bind 后写业务事件，并由 workbench sourceVersionToken 自然回到待确认。 |
| 最省成本 | 不扩 OpenAPI / generated，不改 DB schema，复用现有 ProjectAttachment、material review、notification 和 workbench。 |
| 最适合当前阶段 | 先打通 `needs_supplement -> publisher supplement -> bidder re-review` P0 闭环。 |
| 风险最大 | 直接放开聊天让双方用自由文本补充资料，导致资料真值和审计链路漂移。 |
