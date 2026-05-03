---
owner: Codex 总控
status: accepted
layer: L6 Runtime / Controlled Smoke / Mobile UAT Evidence
recorded_at_local: 2026-05-03
release_commit: d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8
scope: Project communication workbench release acceptance receipt
---

# 发布验收回执 20260503

## 1. 最终裁决

本次发布验收裁决为 `PASS`。

本回执只归档已经完成的 runtime release、只读 smoke、受控写 smoke、双账号手机端 UAT 和截图证据。
本回执不新增业务写入，不代表开通支付、扣费、回调、合同确认或最终成交金额确认。

## 2. Release Source

| Item | Value |
| --- | --- |
| release commit | `d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8` |
| Server release | `/srv/releases/server/20260503040500-d97a3f2-main-phase-a3-server-native-fix` |
| BFF release | `/srv/releases/bff/20260503034500-d97a3f2-main-phase-a3` |
| Admin release | `/srv/releases/admin/20260503034500-d97a3f2-main-phase-a3` |
| DB backup | `/srv/backups/pre-deploy/20260503022000-f14e646-main-phase-a2-full.dump` |
| DB migration pending | `0` |

## 3. Cutover 结果

| Layer | Result | Notes |
| --- | --- | --- |
| Server | `PASS` | 首次 cutover 因 native dependency / GLIBC 兼容问题触发 No-Go 并 rollback；随后使用 native-fix release cutover 成功。 |
| BFF | `PASS` | 切换到新 BFF release 后 health / ready 通过；诊断脚本退出码 1 记录为脚本口径问题，不作为服务失败。 |
| Admin | `PASS` | 首次诊断误判旧 PID restart 期间 `status=143`；修正诊断口径后新 PID、cwd、health 和 journal 检查通过。 |

本轮 cutover 未执行 migration，未触发支付、扣费、回调、合同确认或最终成交金额确认。

## 4. 只读 Smoke 结果

结论：`Conditional Pass`。

已完成只读验证：

- Server / BFF / Admin current 指向新 release。
- Server / BFF / Admin health 通过。
- App-facing 公共 GET 通过。
- 未登录态 GET 验证通过。
- 登录态 shell / profile GET 通过。
- 项目沟通 / 消息 / 工作台 GET 通过。
- 文件预览只读验证通过。
- Admin health 和只读页面 / 列表验证通过。
- 权限越权只读验证未发现返回他人数据。

未执行内容：

- 未执行 POST / PUT / PATCH / DELETE。
- 未执行写 smoke。
- 未执行真实支付、扣费、回调。
- 未执行 migration、服务重启或 current 切换。

## 5. Controlled Write Smoke 结果

结论：`PASS`。

受控写入范围：

| Item | Value |
| --- | --- |
| projectId | `cc25fd27-75a6-4d50-88b3-a223af65be3a` |
| threadId | `7fb5fb88-4fd4-47a2-986a-ca25e46c5849` |
| bidId | `58522664-cd21-4677-8032-b34d411c71fa` |
| ownerOrgId | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| counterpartOrgId | `e6bf4567-016e-45f9-9420-9c950237690e` |

已执行受控写 smoke：

- 双测试账号登录成功。
- 登录态 shell / profile GET 成功。
- project communication thread / messages / workbench GET 成功。
- `bid_quote_sheet_review` 做 1 次受控资料审阅写入，结果为 `confirmed`。
- read-cursor 做 1 次受控写入。
- 发送 1 条短文本消息，内容前缀为 `UAT smoke 2026-05-03`。
- messages GET 复核该 UAT smoke 消息可见。
- workbench GET 复核 `bid_quote_sheet_review` 状态变化可见。

未执行内容：

- 未执行文件上传三步流。
- 未执行合同确认。
- 未执行最终成交金额确认。
- 未执行 award / bid submit / publish / archive / close。
- 未删除业务数据。
- 未手工改 DB。

## 6. 双账号手机端 UAT 结果

结论：`PASS`。

测试账号仅在回执中使用脱敏标识：

| Role | Account Mask | UI Organization |
| --- | --- | --- |
| owner | `186****1020` | `江北嘴嘴帅` |
| counterpart | `186****3700` | `重庆海川展览工厂` |

验证结果：

- owner 手机端登录成功。
- counterpart 手机端登录成功。
- owner 视角项目沟通 / 工作台可进入。
- counterpart 视角项目沟通 / 工作台可进入。
- 双方 UI 均显示 `报价表确认` 为 `已确认`。
- 双方 UI 均可见 `UAT smoke 2026-05-03` 消息。
- UI 结果与 API smoke 结果一致。
- 未发现页面空白、崩溃、404、401、5xx 或 transport error。

## 7. 截图 Evidence 路径

| Evidence | Path |
| --- | --- |
| owner 工作台确认状态 | `docs/00_ssot/evidence/mobile_uat_20260503/owner_workbench_message.png` |
| owner 消息可见 | `docs/00_ssot/evidence/mobile_uat_20260503/owner_message_visible.png` |
| counterpart 工作台确认状态 | `docs/00_ssot/evidence/mobile_uat_20260503/counterpart_workbench_message.png` |
| counterpart 消息可见 | `docs/00_ssot/evidence/mobile_uat_20260503/counterpart_message_visible.png` |

## 8. 禁止项确认

本次发布验收链路未触发：

- 真实支付。
- 平台服务费扣费。
- 支付回调。
- 合同确认。
- 最终成交金额确认。
- award / bid submit / publish / archive / close。
- 删除业务数据。
- 手工改 DB。

本归档轮额外确认未执行：

- migration。
- Server / BFF / Admin 重启或 current 切换。
- 业务代码修改。

## 9. 收口结论

本次 release commit `d97a3f26ed1370341f9cd2d9a4c8c532d6dd5ab8` 对应的 Server / BFF / Admin runtime 发布、只读 smoke、受控写 smoke 与双账号手机端 UAT 已形成闭环。

最终裁决：`PASS`。
