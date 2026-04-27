---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for the edit-page supplement-note
  convergence, compact owner-private document-zone readback, cloud attachment
  chain evidence collection, and bounded cloud hotfix release, so Day2-Day4
  may proceed in order without skipping truth-source verification.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_edit_supplement_and_document_zone_convergence_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_attachment_prepublish_and_bid_materials_backend_truth_addendum.md
  - docs/02_backend/project_detail_document_zone_and_public_resource_download_backend_truth_addendum.md
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/data/services/project_attachment_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/models/project_attachment_read_models.dart
  - apps/bff/src/routes/my_project/my-project-attachment.service.ts
  - apps/server/src/modules/project/project-attachment.service.ts
  - apps/server/src/modules/upload/upload-write-command.support.ts
---

# 《编辑页文书区收敛与云上附件链路 Day2-Day4 阶段门禁核查表》

## 1. Stage Objective

当前阶段唯一目标固定为：

1. Day2：完成本地前端只读收敛。
2. Day3：定位 live release、live DB、live schema、live bucket 与附件链路证据。
3. Day4：只对已查实失败点做最小云上修复，并保留回滚点。

当前明确非目标：

1. 新附件真相。
2. 新 attachment kind。
3. 新状态机。
4. 新 lifecycle。
5. 支付、询价、竞标工作台扩写。

## 2. Passed Gates

- `真源冻结门禁`：
  - passed
  - Day1 已冻结：
    - 编辑页 `补充说明` 独立
    - 红框说明隐藏
    - 正式附件主真相继续是 `project_attachments`
    - 正式卡片必须显示文件名和查看 / 预览
- `架构边界门禁`：
  - passed
  - 继续保持：
    - Flutter App -> BFF -> Server
    - BFF 不拥有第二状态机
    - Server 拥有附件业务真相
- `合同边界门禁`：
  - passed
  - 既有 owner-private attachment family 已冻结：
    - `GET /api/app/my/projects/{projectId}/attachments`
    - `POST /api/app/my/projects/{projectId}/attachments`
    - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- `上传真相门禁`：
  - passed
  - 已有三步上传链继续固定：
    - `init -> direct upload -> confirm`
  - `FileAsset` 与 `project_attachments` 的分工已明确冻结
- `范围收敛门禁`：
  - passed
  - 当前对象已压缩为：
    - 编辑页文案收敛
    - owner-private 文书区正式回读
    - 云上附件链路核查与最小热修

## 3. Failed Gates

- `live 数据源清晰门禁`：
  - failed
  - 当前还未形成本轮专门的 live 证据单，尚未把：
    - active release
    - active DB
    - active schema
    - active bucket
    一次性核准入库
- `专门测试项目链路门禁`：
  - failed
  - 当前还没有用本轮专门测试项目完整跑过：
    - upload init
    - direct upload
    - confirm
    - bind
    - list 回读
- `请求日志证据门禁`：
  - failed
  - 当前还没有针对本轮专门测试项目补齐：
    - BFF ingress / upstream 请求日志
    - Server 业务入口日志
    - DB 写入证据
    - OSS 对象证据
- `云上修复放行门禁`：
  - failed
  - 在 live 数据源和证据链未查清前，Day4 不得放行
- `release-prep 门禁`：
  - failed
  - 当前尚未形成本轮最小发布包、回滚点和上线收口单

## 4. Veto Gates

- 若以下任一项未清楚，直接阻断 Day4：
  1. 不知道当前 active BFF / Server release 是哪一版
  2. 不知道 live DB 连接到哪一套真实数据
  3. 不知道写入成功应落到哪张表 / 哪个 bucket
  4. 不能证明请求是否真的触发 `init / confirm / bind`
- 当前不得：
  1. 新增表
  2. 新增状态机
  3. 新增生命周期
  4. 新建第二附件 truth family
  5. 以本地 upload confirm 伪装正式附件回显
  6. 在未查清 live 数据源前猜测式热修云上

## 5. Stage Go / No-Go Decision

- `Go` for：
  1. Day2 本地前端只读收敛
  2. Day3 云上真源定位与证据采集
- `Conditional Go` for：
  1. Day4 云上最小修复
  - 前提固定为：
    - live release 已核准
    - live DB / schema / bucket 已核准
    - 专门测试项目已跑出完整链路证据
    - 失败点已明确落到具体一跳
- `No-Go` for：
  1. 在 Day3 证据缺失情况下直接进入 Day4
  2. 借本轮顺手重做附件工作流
  3. 越权重命名 attachment truth kind

## 6. Current Gate Meaning

当前允许的含义：

1. 可以继续完成本地前端标题、解释文案、清爽态和 `items / attachments`
   双口径兼容。
2. 可以继续用云上环境做只读核查和专门测试项目链路证据采集。
3. 可以在证据闭环后，对查实失败点做最小修复与回归。

当前不允许的含义：

1. 不能把 Day1 冻结单解释成云上修复自动放行。
2. 不能把 BFF 返回形状 drift 当成唯一根因。
3. 不能在未证实写链断点前同时大改 Flutter / BFF / Server。

## 7. Next Unique Action

下一步唯一动作固定为：

1. 完成 Day2 本地前端收敛并跑 `flutter test` 与 `flutter build macos`。
2. 之后输出《云上附件链路证据单》。
