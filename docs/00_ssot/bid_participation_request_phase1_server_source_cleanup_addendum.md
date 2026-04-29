# 申请参与竞标 Phase 1C Server Source Cleanup 冻结单

## 0. 总裁决

- 当前是否允许删除历史 `project_name_access_requests` 数据：No-Go
- 当前是否允许删除旧 `project_name_access` route：No-Go
- 当前是否允许 Server 停止向消息楼/项目沟通主列表产出旧 `project_name_access_request` 卡片：Go
- 当前是否允许 BFF/Flutter 同步做展示收口：Go

本冻结单只处理展示源头收口：旧「项目名称查看申请」不再作为项目沟通主流程卡片产出；历史数据、历史详情 route 和排障能力保留。

## 1. 本轮做什么

| 项 | 冻结结论 |
|---|---|
| Server source | `CounterpartConversationProjectNameAccessSource` 不再注册进 counterpart conversation 主卡片源 |
| 历史数据 | 保留，不迁移、不物理删除 |
| 旧 route | 保留 `project_name_access` thread detail / approve / reject 的历史兜底能力 |
| BFF | 继续兼容旧 card type 解析，但不把旧卡片作为主流程展示对象 |
| Flutter | 项目沟通主入口不再优先/展示旧项目名称申请卡片 |
| 参与竞标申请页 | 主界面隐藏线程 ID、项目 ID、申请 ID，仅保留状态、项目名称和业务说明 |

## 2. 本轮不做什么

- 不删除 `project_name_access_requests` 表。
- 不删除旧 `project_name_access` controller/service/entity。
- 不把旧数据批量迁移成 `bid_participation_requests`。
- 不改变 `BidParticipationRequest` 状态机。
- 不改变报价依据资料、文件访问、竞标提交的准入真相。
- 不触发支付、预授权、扣款或回调。

## 3. 职责边界

| 层 | 边界 |
|---|---|
| Server | 业务真相 owner；本轮只停止旧卡片 source 进入消息楼聚合 |
| BFF | app-facing 可见性裁剪和兼容解析；不计算申请状态 |
| Flutter | 展示减法和入口收口；不判断最终权限 |

## 4. 验收标准

| 验收项 | 标准 |
|---|---|
| 旧卡片源头 | `project_name_access_request` 不再从 counterpart conversation 主 source 输出 |
| 新主链 | `bid_participation_request` pending / approved / rejected 继续正常 |
| 历史兼容 | 旧 `project_name_access` thread route 保留，不因本轮改动断链 |
| 信息减法 | 参与竞标申请页不再直出线程 ID / 项目 ID / 申请 ID |
| 安全边界 | 未申请/拒绝仍不能看资料；通过后仍可查看资料并继续竞标 |

## 5. 风险与防线

| 风险 | 防线 |
|---|---|
| 误删历史数据 | 本轮禁止 migration 删除或迁移历史表 |
| 历史详情断链 | 旧 route 和旧 parser 保留 |
| 项目沟通列表缺项目 | 只停发旧名称申请卡片；bid、order、clarification、bid participation 卡片继续产出 |
| Flutter 解析历史数据失败 | BFF/Flutter 保留旧类型兼容解析，不作为主流程入口 |

## 6. 下一阶段门禁

只有以下条件全部满足，才允许进入云端联调：

1. Server 测试确认旧卡片 source 不再进入 counterpart conversation。
2. BFF/Flutter 测试确认旧卡片不会作为主流程展示。
3. 参与竞标申请页信息减法通过 widget test 或 targeted analyze。
4. 本地关键测试通过。
