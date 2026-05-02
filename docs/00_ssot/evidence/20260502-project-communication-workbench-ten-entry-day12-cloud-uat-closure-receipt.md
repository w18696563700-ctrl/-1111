---
owner: Codex 总控
status: accepted
purpose: >
  Record Day 12 cloud UAT closure evidence for the project communication
  workbench 10-entry review surface.
layer: L6 Runtime / Computer Use UAT Evidence
verification_scope: Aliyun BFF/Server release, 8080 probes, controlled write smoke, dual-account Computer Use UAT
created_at: 2026-05-02
canonical_inputs:
  - docs/00_ssot/project_communication_workbench_ten_entry_review_day1_freeze_addendum.md
  - docs/01_contracts/project_communication_workbench_ten_entry_review_contract_field_table_day2_addendum.md
  - docs/02_backend/project_communication_workbench_ten_entry_review_server_truth_day3_addendum.md
  - docs/03_bff/project_communication_workbench_ten_entry_review_bff_route_read_model_day2_addendum.md
  - docs/04_frontend/project_communication_workbench_ten_entry_review_day4_flutter_structure_addendum.md
evidence:
  - docs/00_ssot/evidence/20260502-project-communication-workbench-day12-ten-entry-workbench.png
  - docs/00_ssot/evidence/20260502-project-communication-workbench-day12-effect-confirmed-detail.png
  - docs/00_ssot/evidence/20260502-project-communication-workbench-day12-quote-needs-supplement-detail.png
---

# 《项目沟通工作台 10 入口 Day 12 云端 UAT 收口回执》

## 1. 总裁决

Day 12 结论为 `Conditional Pass`。

本轮最小闭环已经闭合：

- Aliyun BFF / Server 已发布到当前 runtime。
- 8080 health 探针通过。
- 工作台 10 个入口可由 BFF read-model 返回并被 Flutter 消费。
- 8 个资料审阅项可复用真实资料文件，支持 `已确认` 和 `需补充` 持久化状态。
- 双账号 Computer Use UAT 已验证核心链路：发布资料被确认、竞标资料被反馈、红绿状态在页面可见、真实资料可预览。
- 合同确认和最终成交金额确认仅作为入口 / 状态位保留，本轮未开通真实合同确认写入、最终金额写入或平台服务费扣费。

本回执不代表：

- APNs / FCM / 震动已经开通。
- 合同确认已经完成。
- 最终成交金额已经写入并进入收费。
- Office / Excel 文件已完成内联预览能力。
- Admin 争议处理台已经开通。

## 2. 本轮范围

本轮完成范围：

- 项目沟通工作台 10 个入口：
  - 发布方资料 5 个。
  - 竞标资料 3 个。
  - 成交确认 2 个。
- 8 个资料审阅项：
  - 查询资料源文件。
  - 审阅状态读取。
  - 受控 `确认无误` 写入。
  - 受控 `需要补充` 写入和反馈展示。
- Aliyun BFF / Server 发版。
- 8080 runtime 探针。
- 双账号 Computer Use UAT。
- 截图与收口证据归档。

本轮不包含：

- 手机系统通知、震动、APNs、FCM。
- 真实扣费、结算、钱包、发票、退款。
- 合同确认真实写入。
- 最终成交金额真实写入。
- Admin 争议台。
- DB 手工改业务数据。
- Nginx / systemd unit 配置改造。

## 3. Runtime Release 回执

### 3.1 当前 active runtime

只读复核结果：

| Layer | Service | Active release |
| --- | --- | --- |
| Server | `exhibition-server` | `/srv/releases/server/20260502225353-project-communication-workbench-source-files-server` |
| BFF | `exhibition-bff` | `/srv/releases/bff/20260502225353-project-communication-workbench-source-files-bff` |

服务状态：

| Service | Status |
| --- | --- |
| `exhibition-server` | `active` |
| `exhibition-bff` | `active` |

### 3.2 8080 health 探针

| Method | URL | Result |
| --- | --- | --- |
| `GET` | `http://127.0.0.1:8080/health/bff/live` | `200 OK`, `service=exhibition-bff` |
| `GET` | `http://127.0.0.1:8080/health/server/live` | `200 OK`, `service=exhibition-server` |

### 3.3 Migration 边界

本轮使用自动 migration 路径交付 8 资料审阅真值持久化。

记录的 migration 名称：

- `20260502_project_communication_material_review_truth`

本轮未做：

- 手工改业务数据。
- 手工补写审阅状态。
- 手工改 Nginx。
- 手工改 systemd unit。

## 4. Rollback 路径

已复核的 rollback 文件：

| Layer | Rollback file |
| --- | --- |
| Server | `/srv/shared/rollback-server-before-20260502225353-project-communication-workbench-source-files.txt` |
| BFF | `/srv/shared/rollback-bff-before-20260502225353-project-communication-workbench-source-files.txt` |
| Server previous release fallback | `/srv/shared/rollback-server-before-20260502222714-project-communication-workbench-ten-entry.txt` |
| BFF previous release fallback | `/srv/shared/rollback-bff-before-20260502222714-project-communication-workbench-ten-entry.txt` |

回滚口径：

- 仅在 runtime 5xx、核心 route 不可达、migration 阻断启动、或 10 入口 read-model 明显破坏主链路时触发。
- 回滚只切换 `current` release 并重启对应服务。
- 不做数据库手工回滚，除非另起数据库回滚门禁。

## 5. 双账号 UAT 结果

UAT 使用两个真实测试账号，回执中不记录手机号、密码、token 或 cookie。

UAT 项目：

- `教育装备展 - 新东方教育`

UAT 候选对象：

- 发布方组织：`江北嘴嘴帅`
- 竞标方组织：`重庆海川展览工厂`

### 5.1 10 入口工作台

结果：`Pass`

观察结果：

- 页面显示 `发布方资料 / 竞标资料 / 成交确认` 三组。
- 发布方资料 5 个入口存在：
  - `效果图确认`
  - `尺寸图 / 施工图确认`
  - `材质图 / 材料样板确认`
  - `设备物料清单确认`
  - `服务清单确认`
- 竞标资料 3 个入口存在：
  - `项目理解确认`
  - `报价表确认`
  - `进度安排确认`
- 成交确认 2 个入口存在：
  - `合同确认`
  - `最终成交金额确认`
- 底部聊天框没有恢复确认主入口。

截图：

- `docs/00_ssot/evidence/20260502-project-communication-workbench-day12-ten-entry-workbench.png`

### 5.2 发布资料确认链路

结果：`Pass`

验证项：

- `效果图确认` 状态为 `已确认`。
- 详情页读取到真实发布资料源文件：
  - 文件名：`11364610-663F-4C81-907B-79BFBA379AFB_1_102_o.jpeg`
  - MIME：`image/jpeg`
- 图片预览可打开的 Computer Use 观察已通过；正式截图仅归档资料详情页，避免保留整屏截图。
- 当前账号只能查看该资料审阅结果，不能替对方重复确认。

截图：

- `docs/00_ssot/evidence/20260502-project-communication-workbench-day12-effect-confirmed-detail.png`

### 5.3 竞标资料反馈链路

结果：`Pass with preview fallback`

验证项：

- `报价表确认` 状态为 `需补充`。
- 详情页读取到真实竞标资料源文件。
- 最近反馈展示：
  - `UAT smoke: 请补充最终报价合计。`
- 状态在工作台中显示为红色 `需补充`。
- Excel / Office 类文件当前走受控预览兜底，不作为本轮失败项。

截图：

- `docs/00_ssot/evidence/20260502-project-communication-workbench-day12-quote-needs-supplement-detail.png`

### 5.4 合同确认 / 最终成交金额

结果：`Pass by boundary`

验证项：

- `合同确认` 入口可见。
- `最终成交金额确认` 入口可见。
- 当前状态为 `暂不可读` / 未开通写入。
- 本轮没有执行合同确认写入。
- 本轮没有执行最终成交金额写入。
- 本轮没有触发平台服务费扣费。

## 6. 受控写 Smoke 回执

本轮只允许以下受控写 smoke：

| 写入类型 | 结果 | 边界 |
| --- | --- | --- |
| 资料确认 | `Pass` | 仅写 8 资料审阅项，不写合同、金额、扣费。 |
| 资料反馈 | `Pass` | 仅写反馈文本和状态，不写聊天消息作为真值。 |
| 合同确认 | `Not executed` | 本轮未授权真实写入。 |
| 最终成交金额确认 | `Not executed` | 本轮未授权真实写入，不触发扣费。 |

已验证状态：

- `publisher_effect_image_review`：`confirmed`
- `bid_quote_sheet_review`：`needs_supplement`

## 7. 本地测试回执

### 7.1 Server

命令：

```bash
cd apps/server && node --test test/project-communication-workbench-material-review.test.cjs
```

结果：

- `5` tests passed.

覆盖：

- 10 入口 read-model。
- 竞标方确认发布资料。
- 发布方不能替自己确认发布资料。
- 发布方反馈竞标报价表。
- stale source token 写入拒绝。

### 7.2 BFF

命令：

```bash
cd apps/bff && node --test test/project-communication-workbench-transport.test.cjs
```

结果：

- `3` tests passed.

覆盖：

- workbench controller route materialized。
- BFF 转发 GET 并保留 Server review state。
- BFF 转发资料审阅 POST，拒绝成交确认类写入。

### 7.3 Flutter

命令：

```bash
cd apps/mobile && flutter test --no-pub test/project_communication_five_material_confirmation_entry_test.dart
```

结果：

- `4` tests passed.

覆盖：

- 10 固定入口。
- Server response 后确认变绿。
- 反馈变红。
- 成交确认入口可见但不扣费。

## 8. 未开通项

以下事项明确保留但暂不开通：

| 未开通项 | 原因 | 后续门禁 |
| --- | --- | --- |
| APNs / FCM / 震动 | 用户已明确先不要做；不属于 10 入口最小闭环。 | 系统通知二阶段方案和真机门禁。 |
| 合同确认真实写入 | 可能进入合同生效与交易流程。 | 合同确认专项冻结。 |
| 最终成交金额真实写入 | 涉及平台服务费收费基准。 | 支付 / 服务费 / 扣费专项冻结。 |
| 真实扣费 | 高风险资金行为。 | 支付门禁、回滚、对账、UAT 单独批准。 |
| Office / Excel 内联预览 | 当前仅验证受控兜底，不影响资料状态真值。 | 文件预览能力专项。 |
| Admin 争议台 | 不属于本轮 app 工作台闭环。 | Admin / governance 专项。 |
| 多人已读 / 系统通知联动 | 与资料审阅闭环无直接关系。 | 消息二阶段专项。 |

## 9. 风险与边界

已知残余风险：

- 现有截图覆盖核心 UAT 页面和资料详情，但不是完整录屏。
- `application/octet-stream` / Office 类资料当前不能证明内联预览体验完整，只能证明真实源文件进入详情页并受控兜底。
- 合同确认和最终成交金额入口只验证可见和不可误写，不验证成交业务闭环。
- 当前工作区存在大量历史脏改；本回执只新增 Day 12 evidence 文件和截图，不代表所有脏改都属于本轮。

边界裁决：

- 本轮完成的是 `资料审阅确认 / 反馈` 最小闭环。
- 资金、合同、系统通知、Admin 争议台全部留到后续专项。
- BFF 不持有业务真值。
- Flutter 不造确认状态。
- Server 是 8 资料审阅状态唯一真值 owner。

## 10. Git 级别整理建议

当前建议按以下提交组整理，不建议把所有脏改一次性提交：

| Commit group | 范围 | 说明 |
| --- | --- | --- |
| `docs: freeze project communication workbench ten-entry truth` | `docs/00_ssot/**`, `docs/01_contracts/**`, `docs/02_backend/**`, `docs/03_bff/**`, `docs/04_frontend/**` | 文书冻结、contracts 字段表、Server truth、BFF route、Flutter 施工图、Day 12 evidence。 |
| `server: add project communication material review truth` | `apps/server/src/modules/project_communication/**`, `apps/server/src/core/migrations/migrations.ts`, `apps/server/test/project-communication-workbench-material-review.test.cjs` | 8 资料审阅持久化、权限、查询、确认、反馈、migration。 |
| `bff: expose project communication workbench routes` | `apps/bff/src/routes/message_interaction/**`, `apps/bff/test/project-communication-workbench-transport.test.cjs` | app-facing read-model 和命令转发，不落库。 |
| `mobile: implement project communication ten-entry workbench` | `apps/mobile/lib/features/exhibition/**`, `apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart` | 10 入口、详情页、确认 / 反馈表单、红绿灰橙状态。 |
| `contracts: regenerate app api contract artifacts` | `docs/01_contracts/openapi.yaml`, `packages/contracts/**` | 需单独审阅生成物和手改脚本差异，避免混入业务代码提交。 |

暂不建议提交：

- 与本轮 10 入口无关的 unread / message badge / shell 改动。
- 与 public pool recovery 相关的文书和测试。
- 未确认归属的历史脏改。

## 11. 最终收口

Day 12 达到当前最小闭环：

- 云端 runtime 已发布。
- 10 入口页面已在真实 App 中可见。
- 8 资料审阅状态可真实写入和回读。
- 真实发布资料和竞标资料已进入详情页。
- 红绿状态和反馈文案可见。
- 合同 / 最终金额 / 扣费未越权开通。
- 未开通项已明确列入后续专项。

下一轮建议：

1. 先做 git 分组审阅，剥离本轮和非本轮脏改。
2. 对 `contracts` 生成物做一次单独 diff review。
3. 再决定是否开启合同确认 / 最终成交金额专项，不要和资料审阅闭环混在一个发布里。
