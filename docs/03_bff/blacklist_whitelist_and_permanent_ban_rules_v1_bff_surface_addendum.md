---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side aggregation and shaping boundary for governance summary, appeal submit handoff, and blocked-state copy under the existing App truth system, without introducing a second permission, risk, or ban truth owner.
layer: L3 BFF
---

# 黑白名单与永久封禁规则 V1 BFF Surface Addendum

## 1. 范围
- 本文件是第四组 `docs/03_bff` 冻结包，限定为：
  - `profile` 建筑下的风控治理摘要查询承接
  - 用户侧治理申诉提交透传承接
  - admin 治理动作的 app-facing 闭包错误/受限 copy 映射
  - 风控标签在 `shell / profile / exhibition` 的展示边界
- 本文件不直接解锁实现，仅冻结本轮 BFF 聚合边界，不创建新的业务真相。
- 本文件不直接引入：
  - 全量风控中心
  - 全量处罚历史
  - 全量申诉历史
  - 完整黑白名单/永久封禁管理台
  - BFF 内部处罚或永久封禁状态机

## 2. 对齐依据
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## 3. 当前角色定义
- L0 + L2 + L3 Backend 已冻结了：
  - 风控治理覆盖语义（watchlist/blacklist/permanent-ban/penalty/appeal）
  - 对应 app-facing 与 admin path 家族
  - 审批与处罚真相的归属边界
- 该 BFF 包的职责是：
  - 固定本轮可承接的 app-facing 风控承接面
  - 固定可透传/可整形的返回形状
  - 固定受限态 copy 与 blocked copy 的投影边界
  - 固定 app-facing/ admin-facing 的职责分离，不越界承接 admin 真值

## 4. 当前 BFF Route-group Surface
- 与该单文书直接相关的 app-facing 路径为：
  - `GET /api/app/profile/governance/status`
  - `POST /api/app/profile/governance/appeals`
- 与该单文书直接相关的 server admin 路径（仅 Server 承载）：
  - `GET /server/admin/governance/penalties`
  - `GET /server/admin/governance/penalties/{penaltyId}`
  - `POST /server/admin/governance/penalties`
  - `GET /server/admin/governance/appeals`
  - `GET /server/admin/governance/appeals/{appealCaseId}`
  - `POST /server/admin/governance/appeals/{appealCaseId}/decide`
  - `POST /server/admin/governance/whitelist-memberships`
  - `POST /server/admin/governance/whitelist-memberships/{whitelistMembershipId}/revoke`
  - `POST /server/admin/governance/permanent-bans`
- 不得在本文件内新增：
  - `/risk/*`, `/ban/*`, `/penalty/*`, `/appeal/*` 等裸 route 家族
  - 任何 user-side 罚单列表/申诉列表/处罚明细/封禁明细
  - 任何 public 黑白名单目录类路由
  - 任何超出 `profile/governance` 的治理查询路由

## 5. BFF 可执行聚合边界
- `BFF` 只可做：
  - request-id 与 trace 透传
  - actor / organization / roleKeys / certificationStatus 归一化
  - governance status 最小 read-model 整形
  - 受控 blocked / unavailable copy 输出
  - 申诉提交动作的统一 envelope 整形
- `BFF` 禁止：
  - 创建或持有 `penalties / appeal cases / permanent_bans / whitelist-memberships` 真相
  - 决定处罚生命周期
  - 决定上链/下链式封禁边界
  - 决定权限是否可覆盖 `permission_matrix.md`
  - 替代 `Server` 的 admin 风控审批

## 6. 非 owner 边界
- `BFF` 不得作为真值 owner：
  - `governance_penalties`
  - `governance_appeal_cases`
  - `governance_permanent_bans`
  - `governance_whitelist_memberships`
  - `organizations.status` 的替代决策
  - `organization_members.member_status` 的替代决策
  - `roleKeys / certificationStatus` 的决策源
- `BFF` 不得持久化：
  - 处罚生效链
  - 封禁生效链
  - 申诉决定链
  - 任何单独的治理状态缓存作为业务真相

## 7. Profile 风控摘要边界
- `GET /api/app/profile/governance/status` 仅做最小摘要承接，建议支持字段：
  - `organizationId`
  - `governanceStatus`
  - `whitelistStatus`
  - `appealEntryState`
  - `currentPenalty`
  - `traceId`
- `currentPenalty` 限制为现有服务可见最小字段，不得返回历史列表或审计链：
  - `penaltyId`
  - `penaltyType`
  - `status`
  - `effectiveFrom`
  - `effectiveUntil`
  - `reasonSummary`
  - `appealAllowed`
- `BFF` 不得把治理摘要升格为：
  - 全量处罚历史
  - 风控评分模型
  - 权限替代判断结果
  - admin 审核内部说明原文

## 8. Appeal 提交边界
- `POST /api/app/profile/governance/appeals` 只承接：
  - `penaltyId`
  - `reason`
  - `evidenceFileAssetIds`（可选）
- `BFF` 可整形响应：
  - `appealCaseId`
  - `penaltyId`
  - `status`
  - `traceId`
- `BFF` 不得：
  - 返回审批决定
  - 假设可直接进入历史中心
  - 在客户端新增 chat/谈判型申诉交互
  - 以 2xx 隐式吞掉 `Server` 端拒绝

## 9. Shell/消费边界
- `shell` 上下文可继续消费治理摘要字段，不可消费治理源对象真相。
- `exhibition / project / bid / order / contract / inspection / dispute` 的 continuation copy 只允许按已有 frozen path 展示受限态，不得将其解释为已实现完整处罚/申诉链。
- `message` 不能作为 `appeal list / appeal detail / penalty detail` 的消费口子。
- 如与 `project_publish_board_boundary_freeze_addendum.md` 冲突，以 board freeze 优先。

## 10. 文件真相边界
- 沿用现有三段式上传与 `FileAsset` 真相链：
  - `init -> direct upload -> confirm`
- `BFF` 仅透传 `FileAsset` id（如 `evidenceFileAssetIds`），不得透传：
  - raw URL
  - `objectKey`
  - 本地文件路径
  - 未经证据链确认的 evidence 元数据真相

## 11. 错误码与 unavailable 边界
- 本文件仅允许将以下 `GOVERNANCE` 错误家族输出为 app-facing envelope：
  - `GOVERNANCE_STATUS_UNAVAILABLE`
  - `GOVERNANCE_APPEAL_SUBMIT_INVALID`
  - `GOVERNANCE_PENALTY_RESOURCE_UNAVAILABLE`
  - `GOVERNANCE_PENALTY_APPLY_INVALID`
  - `GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE`
  - `GOVERNANCE_APPEAL_DECIDE_INVALID`
  - `GOVERNANCE_WHITELIST_GRANT_INVALID`
  - `GOVERNANCE_WHITELIST_REVOKE_INVALID`
  - `GOVERNANCE_PERMANENT_BAN_INVALID`
  - `GOVERNANCE_INVALID_STATE`
- 禁止在 BFF 新增额外治理错误命名空间或将 admin-only 错误直接下发给 app。

## 12. Admin-bridge 禁止
- 下列 admin 路径仅允许 `Server` 直出，不可被 BFF 改道或代理：
  - `GET /server/admin/governance/penalties`
  - `POST /server/admin/governance/penalties`
  - `GET /server/admin/governance/appeals`
  - `POST /server/admin/governance/appeals/{appealCaseId}/decide`
  - `POST /server/admin/governance/whitelist-memberships`
  - `POST /server/admin/governance/permanent-bans`
- `BFF` 不可新增 `server/admin` 聚合 shim。

## 13. 显式非目标
- 不通过本文件承诺：
  - 组织内黑白名单目录化浏览
  - 用户端处罚/封禁历史完整中心
  - 处罚自动化豁免逻辑
  - 申诉自动化裁决
  - 永久封禁解除链路
  - `apps/bff` 代码实现

## 14. 与当前项目发布最小走廊的执行禁令
- 本文件列举的 route 家族仅用于本轮 app-aligned surface 对齐。
- 不意味着放开 bid/order/contract 后链的完整实现权。
- 若与发布最小走廊冲突，以 `project_publish_board_boundary_freeze_addendum.md` 为先。

## 15. 正式结论
- 本轮 `docs/03_bff` 对该单文书的冻结结论为：
  - `BFF` 仅承接 `profile/governance` 与申诉提交的聚合层
  - 处罚、封禁、白名单、申诉真相与决策全部留给 `Server` 管理
  - `BFF` 不得成为新治理状态机 owner，不得越权拓展路由真相体系
  - app-facing 与 admin-facing 边界已闭环，且不影响现有 `permission_matrix.md`、`organization`、`roleKeys`、`certificationStatus` 真相边界
