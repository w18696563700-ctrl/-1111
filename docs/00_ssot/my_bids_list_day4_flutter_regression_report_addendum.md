---
owner: Codex 总控
status: frozen
purpose: >
  Record Day-4 Flutter regression for the repaired `GET /api/app/my/bids`
  contract drift, without changing Flutter behavior.
layer: Result Verification
freeze_date_local: 2026-04-29
based_on:
  - docs/04_frontend/my_bids_list_project_no_preview_frontend_consumption_note.md
  - docs/00_ssot/my_bids_list_contract_drift_stage_gate_checklist_addendum.md
---

# 《我的竞标列表第 4 天 Flutter 回归报告》

## 1. 结论

Flutter 本轮不需要降级修。

`我的竞标` 页面当前已通过定向回归：

- 能消费 `projectTitle`
- 能消费 `projectNo`
- 能消费 `quoteAmount`
- 能消费 `proposalSummaryPreview`
- 能显示 `沟通与投标`
- 不需要把 `projectNo` 改成选填
- 不需要吞掉 `/api/app/my/bids` contract drift

## 2. 执行记录

### 2.1 定向 MyProject 回归

命令：

```bash
flutter test test/my_project_private_carry_test.dart --name "我的项目先分成我的发布和我的竞标|我的项目路由可以直接钉到我的竞标 workspace"
```

结果：

- PASS
- 2 tests passed

覆盖：

- `我的发布 / 我的竞标` 切换
- `我的竞标` 列表渲染
- `沟通与投标` 入口显示
- 路由直达 `workspace=bids`

### 2.2 Shell 主链回归

命令：

```bash
flutter test test/shell_app_test.dart --name "shell keeps my bids and message interactions refreshed across building switches|core v1 local chain runs from bid submit to my bids, interactions, thread and snapshot"
```

结果：

- PASS
- 2 tests passed

覆盖：

- building 切换后 `my bids` 仍可刷新
- bid submit 成功后进入 `我的竞标`
- `我的竞标` 与 messages interaction / thread / snapshot 主链未断

## 3. 整文件回归

命令：

```bash
flutter test test/my_project_private_carry_test.dart
```

最终补跑结果：

- PASS
- 16 tests passed

覆盖：

- `我的发布 / 我的竞标` 切换
- `我的竞标` 列表渲染
- `项目编号 / 报价金额 / 方案摘要 / 沟通与投标` 展示
- 预发布、已发布、归档、进行中等同文件既有承接用例

## 4. 必要入口检查

只读检查 `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_bid_workspace_support.dart`：

- 当前主动作：
  - `canOpenBidThread = true` -> `沟通与投标`
  - `canOpenBidResult = true` -> `查看竞标结果`
  - fallback -> `查看项目详情`
- 当前未实现：
  - `snapshotReadable = true` -> 从 `我的竞标` 直接打开 `竞标摘要`

裁定：

- `snapshotReadable` 直达 `竞标摘要` 是后续扩展位。
- 本轮只登记，不实现。

## 5. 是否允许进入第 5 天

允许进入第 5 天。

理由：

- `我的竞标` 定向回归通过。
- shell 主链回归通过。
- `my_project_private_carry_test.dart` 全文件回归通过。
- Flutter contract gate 仍保持。
- 当前阻塞仍在云上 BFF runtime 是否部署最新 read-model。

## 6. 风险点

- 云上 Server 若版本落后，BFF 透传后仍可能拿不到 `projectNo / proposalSummaryPreview`。
- `snapshotReadable` 尚未在 `我的竞标` 列表形成直达摘要 CTA。

## 7. 策略判断

- 更稳：保持 Flutter 不改，修 BFF 漏透传。
- 更省成本：只跑定向 Flutter 回归，不重构页面。
- 更适合当前阶段：先恢复列表显示，再另开摘要入口。
- 风险更大：借本轮去改项目详情或竞标摘要 CTA。
