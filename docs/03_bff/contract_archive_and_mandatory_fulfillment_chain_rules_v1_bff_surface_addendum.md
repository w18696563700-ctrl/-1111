owner: Codex 总控
status: draft
purpose: Freeze the BFF-side aggregation and shaping boundary for contract archive and mandatory fulfillment continuity under the current app truth stack without creating a second contract, inspection, rating, dispute, or archive owner.
layer: L3 BFF
---

# 合同归档与履约强制入链规则 V1 BFF Surface Addendum

## Scope
- 这份 addendum 仅用于第三组 `docs/03_bff` 施工面，冻结以下合同履约最小走廊的 `BFF` 聚合边界：
  - `order/detail`
  - `order/create`
  - `contract/detail`
  - `contract/confirm`
  - `contract/amend`
  - `milestone/list`
  - `milestone/submit`
  - `inspection/detail`
  - `inspection/submit`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/open`
  - `dispute/withdraw`
- 本文档不直接解锁实现，也不等于放开全链路：
  - `daily-progress`
  - `archive/confirm`
  - `archive/export`
  - 任何 `Server` admin 的合同履约治理路径
- 本文件只确认 `BFF` 聚合/封装层面边界，避免与当前 `project_publish_board_boundary_freeze_addendum.md` 冲突。

## Alignment Basis
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Addendum Role
- L0 / L2 / L3 Backend 已完成基础冻结后，L3 BFF 的职责升级为：
  - 固定本轮可见 app-facing surface 的聚合范围
  - 固定可发起/可转发/可投影的字段最小集
  - 固定受限状态 copy 与不可见策略
  - 固定对 downstream continuation 的边界，不将其解释为“履约链已就绪”
- 这份 addendum 不应被误读为：
  - `BFF` 成为合同、里程碑、验收、争议、评分的业务真相owner
  - 开放 `rating` / `dispute` 全链路实现
  - 放开 `daily-progress` / `archive-confirm` / `archive-export`
  - 实现 `admin` 审核面或处罚/封禁链

## Current BFF Route-group Surface
- 本轮与该文书相关的 BFF surface 仅来自 `exhibition / project / bid / order / contract / milestone / inspection / rating / dispute` 路由族的最小前端承接。
- 真正已冻结的 app-facing 执行入口是：
  - `GET /api/app/order/detail`
  - `POST /api/app/order/create`
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- 未经独立冻结的不开放：
  - `POST /api/app/contract/history`
  - `POST /api/app/inspection/history`
  - `POST /api/app/daily-progress/*`
  - `POST /api/app/archive/*`
  - `POST /api/app/dispute/close`（若未在同一轮追加）

## Aggregation Responsibility Boundary
- `BFF` 只可做：
  - request-id 和 trace-id 透传
  - context（actor / organization / roleKeys / certificationStatus）归一化
  - 命令转发与最小响应整形
  - 控制态失败码（统一 envelope）输出
  - continuation 锚点透出（`orderId`, `contractId`, `inspectionId`, `milestoneId`）
  - 与已冻结 `RegisteredInstanceEntry` 的最小承接（如果上游存在）
- `BFF` 禁止：
  - 创造第二套合同/履约/争议状态机
  - 在本地判断 `archive-ready`
  - 在本地发起 contract/amend 的有效性最终裁决
  - 在本地判定 dispute 可进入下一步而不依赖 `Server` truth
  - 生成、更新、导出 archive 相关真相

## Non-owner Boundary
- `BFF` 不得拥有：
  - `Order` / `Contract` / `Milestone` / `Inspection` / `Rating` / `Dispute` 的业务真相存储
  - `contract` 审核结论真相
  - `archive` 与 `archive-export` 真相
  - 争议裁决真相、处罚真相、黑白名单真相
  - `Admin` 审核流真相
- `BFF` 不得持久化：
  - `contract.state`
  - `milestone.state`
  - `inspection.state`
  - `dispute.state`
  - `order.state` 派生字段

## Order Boundary
- `POST /api/app/order/create`：
  - `BFF` 可做：
    - 提交命令转发到 `Server`
    - 只处理统一 envelope（success/forbidden/unavailable）
  - `BFF` 不可做：
    - 发起订单真实性结论判断
    - 在本地新增订单派生链逻辑
- `GET /api/app/order/detail`：
  - `BFF` 可形状：
    - 最小订单透传投影（订单 id、状态、对象快照、continuation anchors）
    - 嵌套继续动作锚点（用于 contract/rating/dispute
      的已有容器跳转）
  - `BFF` 不可做：
    - `orderId` 下沉到 dispute 的新入口真相
    - 把 `rating`/`dispute` 路径当作履约归档完整通过

## Contract Boundary
- `GET /api/app/contract/detail`：
  - `BFF` 仅投影合同最小读模型：`contractId`、`orderId`、`state`、`summary`
  - 不新增：
    - 合同历史列表
    - 合同条款编辑器
    - 法务审核状态替代
  - `BFF` 不可把 `contracts.state` 及 `amend_count` 当成前端可变状态控制。
- `POST /api/app/contract/confirm`：
  - `BFF` 仅透传确认命令，并输出固定 `contractId/state/summary`
  - `BFF` 不可处理确认闭环业务规则
- `POST /api/app/contract/amend`：
  - `BFF` 仅透传 amendment 请求，允许返回最小成功结构
  - `BFF` 不可决定 amendment 限次/频控是否通过；仅传播 `Server` 判定错误

## Milestone Boundary
- `GET /api/app/milestone/list`：
  - `BFF` 仅返回 `items[]` 投影（最小列表和必要分页）
  - 不在 BFF 扩展 milestone 工作流字段
- `POST /api/app/milestone/submit`：
  - `BFF` 仅转发提交与透传 `milestoneId/state/summary`
  - 不在本地实现 milestone 完整提交条件计算
  - 不在本地推导 order.completed

## Inspection Boundary
- `GET /api/app/inspection/detail`：
  - `BFF` 仅投影最小字段：`inspectionId`、`milestoneId`、`state`、`summary`
- `POST /api/app/inspection/submit`：
  - `BFF` 仅做命令转发与 envelope 整形
- `POST /api/app/inspection/recheck`：
  - `BFF` 仅做请求转发与固定字段回包
- 禁止：
  - 本地进行验收合格判定
  - 本地进行 recheck/revision 次数强校验
  - 本地推导 `milestone.completed` 或 `order.completed`

## Rating and Dispute Continuation Boundary
- `GET /api/app/rating/entry` 与 `POST /api/app/rating/submit`：
  - `BFF`仅承接最小入场信息，不得将其视为履约归档完成信号
  - 默认 `rating/submit` 仍属于 continuation 下游，不作为本轮完成条件
- `POST /api/app/dispute/open` 与 `POST /api/app/dispute/withdraw`：
  - `BFF`仅转发命令并透传统一受限/拒绝响应
  - 不在本地决定争议成立、处罚、封禁、恢复、申诉转交
- `BFF` 禁止：
  - 将 dispute 的存在与否推断为 contract/inspection 的最终完结
  - 在前端直接暴露 admin adjudication 语义

## Archive-dependent Gating Boundary
- 母蓝图里提到 archive-ready，但本轮 L3 冻结明确：
  - `rating`、`dispute` 的可用不代表 archive 已完整
  - `archive` 真相只允许 `Server` 真值决策并输出
- `BFF` 只能在消费端消费一条清晰信号：
  - 当前对象不可用/不可提交（来自 `Server`）
- `BFF` 严禁：
  - 造成本地 `archiveReady` 字段
  - 用 `Server` 未返回的字段替代 archive-ready 推断
  - 将 contract/amend、milestone/submit、inspection/recheck 的成功返回解释为可直接触发 `rating.submit` 或争议闭环的业务通过

## File Truth Boundary
- 文件与证据承接继续遵循既有 `FileAsset` + upload 三段式真值链：
  - `init -> direct upload -> confirm`
- `BFF` 可承接 file asset id 到 `evidenceFileAssetIds`
- `BFF` 不可承接：
  - raw URL
  - `objectKey`
  - 任何本地文件缓存为真相

## Error Shaping Boundary
- `BFF` 输出只允许下列本轮错误语义（按 app-facing 代码）到统一 envelope：
  - `CONTRACT_ENTRY_UNAVAILABLE`
  - `CONTRACT_CONFIRM_INVALID`
  - `CONTRACT_INVALID_STATE`
  - `CONTRACT_AMEND_INVALID`
  - `CONTRACT_AMEND_LIMIT_REACHED`
  - `MILESTONE_SUBMIT_INVALID`
  - `MILESTONE_INVALID_STATE`
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_SUBMIT_INVALID`
  - `INSPECTION_INVALID_STATE`
  - `INSPECTION_RECHECK_INVALID`
  - `INSPECTION_RECHECK_LIMIT_REACHED`
  - `RATING_ENTRY_UNAVAILABLE`
  - `RATING_SUBMIT_INVALID`
  - `RATING_INVALID_STATE`
  - `DISPUTE_INVALID_STATE`
- `BFF` 不得：
  - 新增本地错误命名空间
  - 用 admin-only 错误码替换 app-facing 入口响应
  - 在失败时篡改或吞掉核心错误来源

## Cross-building Consumption Rules
- `exhibition/project/bid/order/contract/inspection/rating/dispute` 等前端消费路径只能拿到本文件冻结的 `BFF` 形状。
- 其他 building（如 `profile`、`message`）不得把本包的 continuation 视作可直接治理入口。
- `message` 仅能消费 `RegisteredInstanceEntry` touchpoint（若存在）里的最小治理提示，不可承接完整争议信息。

## Forbidden Admin/Operation Surfaces
- 下列 `Server Admin` 路径不能在 BFF 层代理或改道：
  - `GET /server/admin/*/contract/*`
  - `POST /server/admin/*/contract/*`
  - `GET /server/admin/*/milestone/*`
  - `POST /server/admin/*/inspection/*`
  - `GET /server/admin/*/dispute/*`
  - `POST /server/admin/*/dispute/*`
- 本包也不得新增新的 admin bridge 到 app-facing。

## Explicit Non-goals
- 不开 `daily-progress` 路由族（不是本轮 `BFF` surface）
- 不开 `archive-confirm` / `archive-export`
- 不开合同历史、里程碑履约监控台、验收档案台
- 不开 admin 审核中心、处罚台、申诉台
- 不开 `BFF` 自研治理状态机
- 不开 release/上线动作

## Control Statement
- 如果本包的冻结与 `project_publish_board_boundary_freeze_addendum.md` 冲突，以该 board boundary 为准；本 addendum 不得越权放大到 bid/order/contract 后续链路。
- 当前 `BFF` 层面仅冻结“可承接、可透传、可整形、可拒绝”边界，不承接合同归档真值和最终可行性裁定。

## Formal Conclusion
- 本轮 `docs/03_bff` 对 `合同归档与履约强制入链规则 V1` 的 surface 冻结结论：
  - `BFF` 仅可承接当前契约族与连续项的 app-facing 聚合；
  - 续航路由（`rating/dispute`）保持 continuation 受限状态；
  - `archive` 与 `admin` 真相与决策不进入 `BFF`。
