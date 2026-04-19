---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server-owned truth and rescan-job boundary for CS-033 historical content rescan.
layer: L2 Backend Truth
---

# CS-033 存量内容复扫 P2-A Backend Truth Addendum

## 1. 当前包范围

本文件只冻结 `CS-033` 当前最小 Server truth/read-model 承接：

- 存量内容复扫 job truth
- bounded candidate selection truth
- bounded review-task handoff truth

## 2. 当前真值归属

当前 `Server` 继续是唯一 rescan truth owner。

当前仍沿用既有 truth carrier：

- `review_tasks`
- `audit_logs`
- `security_events`
- 既有内容快照与举报/审核上游证据

本包新增的唯一 dedicated truth carrier 只允许是：

- `governance_rescan_jobs`

本包不新增 user-side truth table。

## 3. 当前 candidate selection 规则

当前 rescan candidate 只允许来自：

- 既有 forum content truth
- 既有内容快照
- 既有举报 / 审核结果
- 既有规则基线与最小 AI reserved-carrier planning

当前 candidate selection 不允许被写成：

- 自动处罚 truth
- 用户侧历史中心 truth
- 全量治理台 truth

## 4. 当前 job truth 规则

`governance_rescan_jobs` 的最小字段只允许冻结为：

- `id`
- `scope_type`
- `status`
- `window_start`
- `window_end`
- `candidate_count`
- `flagged_count`
- `reason`
- `rule_set_version`
- `engine_mode`
- `created_by`
- `created_at`
- `completed_at`
- `updated_at`

当前最小 `status` family 固定为：

- `queued`
- `running`
- `completed`
- `failed`
- `cancelled`

## 5. 当前 handoff 规则

- rescan 命中项若需人工处理，只允许复用既有 `review_tasks`
- `CS-033` 不得新建第二套 admin review truth
- `CS-033` 不得新建 penalty/appeal full desk truth
- `CS-033` 不得自动落处罚结论

## 6. 当前明确不纳入项

- 自动处罚 truth
- AI runtime gateway truth
- penalty / appeal full desk truth
- user-side rescan history truth
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`

## 7. 当前 Formal Conclusion

`CS-033 P2-A` 的 Server truth/read-model 边界已冻结：

- `Server` 继续是唯一 truth owner
- 只允许 bounded rescan job truth 与 review-task handoff
- 不得越界打开自动处罚、用户侧中心、AI runtime completion 或更大治理中心
