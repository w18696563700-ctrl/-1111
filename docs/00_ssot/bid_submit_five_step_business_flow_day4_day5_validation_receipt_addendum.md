---
owner: Codex 总控
status: frozen
purpose: >
  Record Day4 testing and copy acceptance, Day5 tunnel route UAT evidence, and
  the stage-gate decision for the bid-submit five-step business-flow
  restructuring round.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/bid_submit_five_step_business_flow_ruling_addendum.md
  - docs/04_frontend/bid_submit_five_step_business_flow_frontend_surface_addendum.md
---

# 《竞标提交页五步业务流 Day4-Day5 验收及阶段门禁核查表》

## 0. 结论

当前五步流 Flutter 重排闭环可以交付为 `Flutter + 文书` 当前阶段成果。

本轮已验证：

1. 页面按 `核对项目 -> 查看项目详情材料 -> 填写竞标价格与服务费确认 -> 上传文档和方案说明 -> 提交竞标` 执行。
2. 页面不再重复展示 `项目附件`，第二步只展示 `项目详情材料` 清单。
3. 竞标方材料区没有预览、打开、下载、上传、删除、绑定入口。
4. `方案说明` 位于第四步，定义为接单方给发布方的总体方案概述。
5. 报价有效期默认 `48小时`，提交前换算为 `quoteValidUntil`。
6. 最终提交只保留一个 `提交竞标` 主动作。
7. 存在 P0-Pay taskId 时走 fixed-price bid + service-fee authorization + authorize-init；无 taskId 时回落旧 `POST /api/app/bid/submit`，不再用 `projectId` 伪装 taskId fallback。
8. 本轮未修改 BFF / Server，未开放附件预览，未扩大材料类型范围。

保留限制：

- Day5 已完成 8080 隧道路由层 UAT。
- 真实账号完整点击链路由产品侧手动执行，本文件只提供验收清单和结果归档位；未声明真实账号完整 UAT 已通过。

## 1. Day4 测试与回归

### 1.1 目标测试结果

已通过：

```bash
cd apps/mobile
flutter test test/shell_app_test.dart --plain-name "bid submit default content no longer exposes technical disclosure copy"
flutter test test/shell_app_test.dart --plain-name "bid submit service fee uses fixed validity and user-facing copy"
flutter test test/shell_app_test.dart --plain-name "bid submit disabled copy points to missing quote and service fee confirmations"
flutter test test/shell_app_test.dart --plain-name "bid submit success stays in minimum bid continuation only"
flutter test test/shell_app_test.dart --plain-name "core v1 local chain runs from bid submit to my bids, interactions, thread and snapshot"
flutter test test/shell_app_test.dart --plain-name "bid submit blocks submission when any required attachment is missing"
flutter test test/project_attachment_prepublish_and_bid_materials_test.dart
```

### 1.2 覆盖项

| 验收项 | 结果 | 证据 |
| --- | --- | --- |
| 五步顺序 | 通过 | `shell_app_test.dart` 顺序滚动断言第一至第四步，底部只有 `提交竞标` |
| 无重复项目附件 | 通过 | `项目附件` 不出现，第二步为 `第二步 查看项目详情材料` |
| 无预览入口 | 通过 | 无 `预览图片` / `预览文书`，且材料区不调用 `/api/app/file/access` |
| 无 owner 管理能力泄漏 | 通过 | 无 `选择项目附件` / `上传并形成正式附件` / `删除当前文书` / `绑定` |
| 无打开/下载入口 | 通过 | 无 `打开` / `下载原文件` |
| 方案说明第四步 | 通过 | `方案说明` 输入位于 `第四步 上传文档和方案说明` 之后 |
| 默认 48 小时 | 通过 | UI 显示 `48小时`，P0-Pay 请求体 `quoteValidUntil` 距当前约 47-48 小时 |
| P0-Pay 提交体 | 通过 | 含 `quoteAmount`、`quoteValidUntil`、三份 `attachmentFileAssetIds`、方案快照字段 |
| 旧提交体 | 通过 | 含 `projectId`、`quoteAmount`、`proposalSummary`、三份必传 `FileAsset` id |
| 互斥分流 | 通过 | P0-Pay 路径不触发旧 `bid/submit`；无 taskId 路径不触发 P0-Pay route |
| 无 P0-Pay 工程名 | 通过 | 竞标提交用户界面不显示 `P0-Pay` |
| 无服务费独立按钮 | 通过 | 不显示 `确认服务费规则并继续提交`，只保留底部 `提交竞标` |

## 2. Day4 文案验收

### 2.1 空态 / 错误态

| 场景 | 当前文案 | 结果 |
| --- | --- | --- |
| 材料清单不可读 | `项目材料暂不可读` / `当前项目材料清单暂不可读，请稍后再试。` | 通过 |
| 材料清单 403 / file access 类异常 | 不暴露 `账号` / `权限` / `file access` 为主体验 | 通过 |
| 材料清单为空 | `当前项目还没有开放材料` | 通过口径冻结 |

### 2.2 禁用态

| 场景 | 当前文案 | 结果 |
| --- | --- | --- |
| 报价未填 | `请先填写有效的竞标报价。` | 通过 |
| 服务费确认未勾选 | `请先勾选全部平台服务费确认项。` | 通过 |
| 方案说明未填 | `请先填写方案说明。` | 通过 |
| 文档未上传 | `请先完成并确认附件：...，再继续提交竞标。` | 通过 |
| 无 taskId fallback | 无 taskId 时走旧 `POST /api/app/bid/submit`，不把 `projectId` 当 P0-Pay taskId | 通过 |

用户理解判断：

- 用户能看到下一步需要补什么。
- 不会误解为账号异常、权限坏了、或附件预览入口故障。
- 不会在第三步中途触发 bid 创建或预授权。

## 3. Day5 隧道路由 UAT

### 3.1 隧道状态

本轮使用：

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

实际执行为后台 forward，当前本机 `8080` 已监听并转发到云上 `80`。

### 3.2 路由探针结果

| 路由 | 方法 | 状态 | 结论 |
| --- | --- | --- | --- |
| `/health/bff/live` | GET | `200` | BFF live |
| `/health/server/live` | GET | `200` | Server live |
| `/api/app/exhibition/home` | GET | `200` | App-facing BFF 基线可达 |
| `/api/app/project/detail?projectId=probe-project` | GET | `404 AUTH_RESOURCE_UNAVAILABLE` | 项目详情路由可达；probe 项目不存在 |
| `/api/app/project/bid-materials?projectId=probe-project` | GET | `404 AUTH_RESOURCE_UNAVAILABLE` | 材料清单路由可达；probe 项目不存在 |
| `/api/app/bid/submit` | POST `{}` | `401 AUTH_SESSION_INVALID` | 旧提交路由可达并受登录态保护 |
| `/api/app/exhibition/trade-tasks/probe-task/fixed-price-bids` | POST `{}` | `400 P0_PAY_REQUEST_INVALID` | P0-Pay fixed-price bid route 可达并做字段校验 |
| `/api/app/exhibition/trade-tasks/probe-task/fixed-price-bids/probe-bid/service-fee-authorizations` | POST `{}` | `400 P0_PAY_REQUEST_INVALID` | 服务费预授权创建 route 可达并做字段校验 |
| `/api/app/exhibition/trade-tasks/probe-task/fixed-price-bids/probe-bid/service-fee-authorizations/probe-auth/authorize-init` | POST `{}` | `400 P0_PAY_REQUEST_INVALID` | authorize-init route 可达并做字段校验 |
| `/api/app/exhibition/trade-tasks/probe-task/fixed-price-bids/probe-bid/service-fee-authorizations/probe-auth` | GET | `401 AUTH_SESSION_INVALID` | 预授权状态 route 可达并受登录态保护 |

Day5 结论：

- 项目详情 route：可达。
- 材料清单 route：可达。
- 旧竞标提交 route：可达。
- P0-Pay route family：可达。
- 真实账号完整点击链路：等待产品侧手动结果录入。

## 4. 真实账号手动验收清单

| 步骤 | 产品侧手动检查项 | 结果 |
| --- | --- | --- |
| 1 核对项目 | 能从项目详情进入竞标提交；第一步显示项目名称、编号、地点、时间；点击后折叠 | 待产品侧填写 |
| 2 查看项目详情材料 | 只显示效果图/尺寸图清单；无预览、打开、下载、上传、删除、绑定 | 待产品侧填写 |
| 3 报价与服务费 | 填报价后出现预计服务费；默认 48 小时；三项确认勾选；无独立提交按钮 | 待产品侧填写 |
| 4 上传文档和方案说明 | 方案说明在第四步；三份必传文档可上传并确认 | 待产品侧填写 |
| 5 提交竞标 | 页面底部只有一个 `提交竞标`；提交后进入正确结果态 | 待产品侧填写 |

## 5. 阶段门禁核查表

### 5.1 通过项

- 真相冻结门禁：通过。L0 ruling 与 L5 frontend surface 已冻结。
- 架构边界门禁：通过。Flutter 仍只通过 BFF；未直连 Server。
- BFF / Server 边界门禁：通过。本轮未改云上 BFF / Server。
- 附件权限门禁：通过。竞标方只读材料清单，无预览入口。
- owner 能力隔离门禁：通过。竞标页无 owner 上传、删除、绑定能力。
- 字段归属门禁：通过。方案说明在第四步，服务费区不混入方案字段。
- 提交流程门禁：通过。底部单一 `提交竞标`；P0-Pay 与旧提交互斥。
- 报价有效期门禁：通过。默认 `48小时`，提交体仍有 `quoteValidUntil`。
- 文案验收门禁：通过。错误态和禁用态指向可操作下一步。
- 隧道路由门禁：通过。8080 到云上 BFF / Server route layer 可达。

### 5.2 失败项 / 未通过声明项

- 真实账号完整云端点击链路：未由 Codex 声明通过，等待产品侧手动验收结果。
- Computer Use 真实账号可视化联调：未执行通过声明，原因是本轮由产品侧负责真实账号点击。
- 后端预览权限：未进入本轮。
- 材质图范围扩展：未进入本轮。
- Server 权威服务费预估接口：未进入本轮。

### 5.3 Veto 项

当前 Flutter 重排闭环无 veto。

以下事项仍为后续阶段 veto 边界：

- 未冻结 `bid-material access` 就开放竞标方附件预览。
- 把 owner-private `file/access` 直接放给竞标方。
- 未冻结 `bid-material kind expansion` 就把材质图纳入竞标方材料范围。
- 未冻结 Server 预估接口就把 Flutter 预计服务费当收费真相。
- 在本轮新增支付账户绑定、钱包、余额或通用支付中心。

### 5.4 是否允许进入后续阶段

结论：

- `Go`：当前 Flutter 五步流重排闭环可交付。
- `Go`：可以进入产品侧真实账号手动验收记录归档。
- `Go with new gate only`：后端预览权限、材质图范围、服务费预估接口必须分别进入后续独立文书冻结和阶段门禁。
- `No-Go`：不得直接进入后端放权、材质图扩展或服务费预估接口实现。

## 6. 当前最小闭环 / 暂不开通 / 扩展位

- 当前最小闭环：Flutter 五步竞标提交页 + 材料清单只读 + 服务费确认 + 统一提交分流。
- 需要保留但暂不开通：竞标方附件预览、材质图、Server 提交前权威服务费预估、支付账户绑定。
- 后续扩展位：`bid-material access`、`bid-material kind expansion`、`service-fee estimate`、`payment account binding`。

## 7. 稳定性判断

- 更稳：保持 BFF / Server 权限与合同不动，只交付 Flutter 五步流重排。
- 更省成本：复用现有项目详情、材料清单、上传、旧提交和 P0-Pay route family。
- 更适合当前阶段：先完成用户可理解的竞标提交闭环，再拆后端预览和材质图独立阶段。
- 风险更大：本轮同时开放附件预览、材质图、Server 预估接口或支付账户绑定。
