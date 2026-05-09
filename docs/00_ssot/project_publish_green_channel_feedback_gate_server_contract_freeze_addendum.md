---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the updated publish gate for the internal-test project authenticity
  sincerity green channel. This addendum supersedes the older feedback-only
  observation boundary for the current App launch stage.
layer: L0 SSOT
freeze_date_local: 2026-05-04
version: V2
effective_scope: project_publish_green_channel_feedback_gate
---

# 《项目发布绿色通道已表态即放行冻结单》

## 0. 总裁决

本轮允许进入 `SSOT + contracts + Server + BFF + Flutter 错误兜底` 最小闭环。

当前用户反馈成立：Flutter 已经要求用户在“支持项目真实性诚意金机制 / 暂不支持项目真实性诚意金机制”中二选一，但云端 Server 发布门禁仍返回 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`，说明 Server 仍按旧“200 元项目真实性诚意金冻结 / paid”口径拦截发布。

## 1. 当前最小闭环

本轮最小闭环冻结为：

1. 发布前必须满足三类正式报价依据资料：
   - `effect_image`
   - `construction_doc`
   - `material_sample`
2. 项目真实性诚意金绿色通道必须存在。
3. 当前发布用户必须完成绿色通道二选一表态：
   - `support_freeze`
   - `oppose_freeze`
4. 选择任意一项均满足内测期发布门禁。
5. 内测期不再把真实冻结、真实支付、`paid`、`frozen` 作为普通发布的硬条件。
6. Server 是发布门禁真相 owner；BFF 只透传；Flutter 只展示和发起表态，不伪造发布成功。

## 2. 需要保留但暂不开通

本轮必须保留但暂不开通：

1. 200 元项目真实性诚意金订单、状态刷新、继续处理入口。
2. 正式期恢复真实支付 / 冻结的能力。
3. 退款、扣款、服务费、财务结算、发票。
4. Admin 绿色通道开关和统计看板。
5. 组织级多人表态合并规则。

## 3. 后续扩展位

后续单独冻结：

1. 正式期是否恢复 `paid/frozen` 硬门禁。
2. 绿色通道表态从 `userId + projectId` 升级为组织级门禁。
3. Admin 对项目真实性诚意金表态、风险和资料完整度的治理视图。
4. 对设备物料清单、服务清单是否升级为硬门槛的规则调整。

## 4. 发布门禁规则

| 条件 | 是否允许发布 | 说明 |
| --- | --- | --- |
| 三类必传资料不齐 | 否 | Server 必须拦截 |
| 三类必传资料齐，但未表态 | 否 | Server 必须拦截 |
| 三类必传资料齐，选择 `support_freeze` | 是 | 内测期已表态即放行 |
| 三类必传资料齐，选择 `oppose_freeze` | 是 | 内测期已表态即放行 |
| 三类必传资料齐，已有 `paid`，但未表态 | 否 | 本轮冻结“表态”为内测硬要求 |

表态真源为 `project_authenticity_sincerity_freeze_feedback`，当前最小闭环按 `userId + projectId` 判定 `myChoice`。组织级任意成员表态不在本轮扩展。

## 5. 分层责任

| 层 | 本轮职责 |
| --- | --- |
| Server | 校验三类正式附件和当前用户绿色通道表态，决定 `publishProject` 是否允许进入 `published` |
| BFF | 透传 `/api/app/project/publish` 结果，透传绿色通道表态接口和 pricing summary |
| Flutter | 保持当前 UI 和表态门禁，补齐错误兜底文案，不把真实冻结作为发布条件 |
| contracts | 主 OpenAPI / error codes / generated projection 承认绿色通道字段、路径和错误码 |
| 云端 | 只有部署门禁明确开启后才允许部署；本文件不授权直接部署 |

## 6. 不做事项

本轮不做：

1. 不改数据库结构。
2. 不新增 migration。
3. 不改变 `draft -> submitted -> published` 状态机。
4. 不删除项目真实性诚意金订单、支付、刷新、退款等保留能力。
5. 不让 BFF 或 Flutter 生成第二套业务真相。
6. 不把待上传草稿附件当正式附件。
7. 不部署云端、不重启服务，除非后续单独获得部署确认。

## 7. 四类判断

| 判断 | 结论 |
| --- | --- |
| 哪个更稳 | Server 按正式附件和当前用户表态做真实门禁，BFF/Flutter 只消费 |
| 哪个更省成本 | 复用现有反馈表和附件表，不新增数据库结构 |
| 哪个更适合当前阶段 | 三类资料 + 已表态即放行，符合上线初期绿色通道和民调口径 |
| 哪个风险更大 | 继续让 Flutter 本地放行，但 Server 仍按 paid 拒绝；或 BFF 伪造 publish 成功 |

## 8. Gate 结论

Gate 1 通过后允许进入实现。实现范围限定为 contracts 投影、Server 发布门禁、BFF 错误透传/文案、Flutter 错误兜底和对应测试。
