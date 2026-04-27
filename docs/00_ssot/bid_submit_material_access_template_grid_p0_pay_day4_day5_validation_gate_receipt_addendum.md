---
owner: Codex 总控
status: frozen
purpose: >
  Record Day4 testing/copy acceptance, Day5 tunnel route UAT evidence, and the
  stage-gate decision for the bid-submit material list-only and platform
  service-fee copy refinement round.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/bid_submit_material_access_template_grid_p0_pay_copy_ruling_addendum.md
  - docs/04_frontend/bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md
---

# 《竞标提交页材料清单与平台服务费文案 Day4-Day5 验收及阶段门禁核查表》

## 0. 结论

当前闭环可以交付为 `Flutter + 文书` 前端收口。

本轮已经完成：

1. 竞标方项目附件只展示清单，不展示项目附件预览入口。
2. 竞标方页面没有 owner 附件上传、删除、选择、绑定能力泄漏。
3. 服务费区不再把 `P0-Pay` 作为用户可见名称。
4. 服务费区移除重复方案字段，保留平台服务费规则确认、报价有效期、通道和三项确认。
5. 报价有效期固定为 `12 / 24 / 36 / 48 / 60 / 72 小时`，默认 `48 小时`。
6. 提交体继续使用既有 `quoteValidUntil`，不改 BFF / Server 合同字段。
7. 竞标方材料清单读取异常不再以 `403` 或“账号 / 权限异常”作为主要体验，只显示清单暂不可读。
8. 本轮未修改 BFF / Server 权限，未开放竞标方附件预览，未引入支付账户绑定。

保留限制：

- 隧道已验证到云上 BFF / Server 路由层，但缺少真实登录态、真实项目和真实竞标账号注入，因此不能声明“真实账号云端完整竞标提交 UAT 已通过”。
- 当前可以进入后续 `bid-material access` 独立阶段的文书冻结；不得直接进入后端放权实现。

## 1. Day4 测试与回归

### 1.1 已通过用例

目标用例：

```bash
cd apps/mobile
flutter test test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- 通过。
- 覆盖竞标方展开提交页后能看到 `effect_image / construction_doc` 清单。
- 覆盖页面不出现 `预览图片` / `预览文书`。
- 覆盖页面不出现 owner 侧 `选择项目附件` / `上传并形成正式附件` / `删除当前文书`。
- 覆盖 `other_material` 从竞标方材料区被拒绝渲染。
- 覆盖 `403` / `file access` 类返回不会把“账号 / 权限 / file access”暴露成用户主体验。

目标用例：

```bash
cd apps/mobile
flutter test test/shell_app_test.dart --plain-name "bid submit service fee uses fixed validity and user-facing copy"
```

结果：

- 通过。
- 覆盖服务费区显示 `平台成交服务费确认`。
- 覆盖用户界面不显示 `P0-Pay`。
- 覆盖默认显示 `48小时`。
- 覆盖提交请求体仍包含可解析的 `quoteValidUntil`，且默认剩余时长落在 `47-48` 小时范围。
- 覆盖三份必传文档的 `attachmentFileAssetIds` 仍进入提交体。
- 覆盖服务费区不显示 `工艺说明` / `搭建流程` / `交付节点` / `风险说明` / `补充报价附件 ID（可选）`。

辅助已通过用例：

```bash
cd apps/mobile
flutter test test/shell_app_test.dart --plain-name "bid submit default content no longer exposes technical disclosure copy"
flutter test test/shell_app_test.dart --plain-name "bid submit keeps compact template download actions available"
```

结果：

- 通过。
- 覆盖模板下载区仍可用，三类模板入口保持第一行三列承接。
- 覆盖竞标提交默认内容不回退到旧技术披露文案。

### 1.2 未作为本轮通过声明的用例

`test/shell_app_test.dart` 全量运行仍存在既有无关失败，不作为本轮通过声明来源。

保留判断：

- 该失败不来自本轮材料清单、服务费文案、报价有效期或 `quoteValidUntil` 改动。
- 本轮只声明目标 widget / flow 用例通过。
- 若要做全量 shell 绿灯，需要另开测试债清理阶段，不混入本轮。

## 2. Day4 文案验收

### 2.1 材料清单

通过项：

- 竞标方材料卡片只展示：
  - 文件名
  - 资料类型
  - 文件类型
  - 创建时间
  - `当前阶段仅展示清单，预览尚未开放。`
- 不展示项目附件：
  - 预览入口
  - 下载原文件入口
  - 打开文件入口
  - owner 上传入口
  - owner 删除入口
  - owner 绑定入口

异常文案：

- 读取失败统一显示：
  - 标题：`项目附件暂不可读`
  - 内容：`当前项目附件清单暂不可读，请稍后再试。`
- `403` 不再作为用户主体验。
- 不把 BFF / Server 的 `file access`、账号异常或权限字样暴露给竞标方。

### 2.2 平台服务费区

通过项：

- 标题使用 `平台成交服务费确认`。
- 主按钮使用 `确认服务费规则并继续提交`。
- 用户可见区域不出现 `P0-Pay`。
- 用户可见区域不展示内部交易任务 ID、authorizationId、商户订单号、回调地址或调试 JSON。
- 服务费区不再重复收集方案字段；方案资料仍归属第二步方案说明和第三步必传文档。

### 2.3 报价有效期

通过项：

- 用户只从固定选项选择有效期。
- 默认值为 `48 小时`。
- Flutter 在提交前内部换算为 `quoteValidUntil`。
- 不开放自由 ISO 时间输入。

## 3. Day5 隧道 UAT 记录

### 3.1 隧道状态

本轮通过本地隧道访问云上服务：

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

验证结果：

- 旧本地 8080 隧道进程曾存在但无 HTTP 响应。
- 旧隧道退出后重新启动同一转发命令。
- 新隧道可通过 `http://127.0.0.1:8080` 到达云上 Nginx。

### 3.2 云上路由探针

通过隧道验证：

- `GET /` 返回 `200`，证明本地 8080 到云上 80 链路可用。
- `GET /api/app/project/bid-materials?projectId=probe` 返回受控 `404`，message 为 `当前项目附件暂不可用，请稍后再试。`
- `GET /api/app/shell/context` 无登录态返回受控 `401`。
- `POST /api/app/exhibition/trade-tasks/probe/fixed-price-bids` 在缺少必要字段时返回受控 `400 P0_PAY_REQUEST_INVALID`，证明 P0-Pay fixed-price bid 路由族可达且在做请求校验。
- `GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary` 无登录态返回受控 `401`。

直接云主机本机探针同步确认：

- Nginx active。
- 80 / 3000 / 3100 / 3201 端口存在监听。
- 云上 `/api/app/project/bid-materials?projectId=probe` 返回受控不可用，而不是网络断裂。

### 3.3 未完成项

未完成真实账号完整路径：

- 未拿到本轮可使用的真实登录态、真实竞标账号、真实项目 ID 与 session/token 注入。
- 因此未通过 Computer Use 完成“项目核对 -> 材料清单 -> 报价 -> 必传文档 -> 服务费确认”的真实云端可视化点击链路。

阶段判断：

- 该缺口阻止“真实账号云端完整 UAT 通过”的声明。
- 该缺口不阻止本轮 `Flutter + 文书` 前端闭环交付，因为本轮明确不改 BFF / Server 权限，不开放竞标方预览。

## 4. 阶段门禁核查表

### 4.1 通过项

- 真相冻结门禁：通过。Day1 L0 ruling 和 L5 frontend surface 已冻结。
- 架构边界门禁：通过。本轮 Flutter 仍只消费 BFF，不直连 Server，不直连 OSS。
- BFF / Server 边界门禁：通过。本轮没有改 BFF / Server 权限，没有放宽 `file/access`。
- 附件权限门禁：通过。竞标方只读附件清单，不展示项目附件预览入口。
- owner 能力隔离门禁：通过。竞标方页面未暴露 owner 附件上传、删除、绑定入口。
- 字段裁剪门禁：通过。服务费区不再展示重复方案字段和内部编号。
- 命名门禁：通过。竞标提交服务费区用户可见文案不出现 `P0-Pay`。
- 报价有效期门禁：通过。固定选项、默认 `48 小时`、提交体保留 `quoteValidUntil`。
- 支付账户绑定门禁：通过。本轮未新增支付宝、微信、银行卡或默认支付账户绑定。
- 文案验收门禁：通过。材料清单异常文案不把 `403`、账号异常或权限异常作为主体验。
- 隧道路由门禁：通过。8080 隧道已到达云上 BFF / Server 路由层，并返回受控响应。

### 4.2 失败项 / 未通过声明项

- 全量 `shell_app_test.dart`：未作为本轮通过项；存在既有无关失败，需要另开测试债阶段。
- 真实账号云端完整 UAT：未通过声明；缺少本轮可用真实登录态与真实竞标账号。
- Computer Use 可视化云端联调：未通过声明；同样受登录态和真实账号输入缺口限制。

### 4.3 Veto 项

当前闭环无 veto。

以下事项若进入本轮则直接 veto：

- 在本轮开放竞标方项目附件预览。
- 复用 owner-private `file/access` 给竞标方放权。
- 在竞标提交材料区展示 owner 上传、删除、绑定能力。
- 把 `P0-Pay` 作为用户可见板块名、按钮名或状态名。
- 重新开放报价有效期 ISO 自由输入。
- 引入支付账户绑定、钱包、资金池或通用支付中心。
- 未冻结 L0/L2/L3/L4 就进入 `bid-material access` 后端实现。

### 4.4 阶段决策

- Day4 测试与文案验收：`Pass`。
- Day5 隧道路由 UAT：`Route-level Pass`。
- Day5 真实账号完整 UAT：`Not Claimed`。
- 当前 `Flutter + 文书` 闭环：`Go for delivery`。
- 生产发布或真实账号完整云端验收：`No-Go until real session UAT`。
- 后续 `bid-material access`：`Go only for independent docs freeze`，不得直接实现后端预览权限。

## 5. 哪个更稳 / 更省成本 / 更适合当前阶段

- 更稳：当前只收口 Flutter 表面和文案，不改 BFF / Server 权限，不开放竞标方预览。
- 更省成本：前端隐藏项目附件预览入口，保留清单投影和既有 `quoteValidUntil` 字段。
- 更适合当前阶段：先交付竞标提交页可理解、低误导、低风险的最小闭环，再单独冻结 bid-material 专用访问阶段。
- 风险更大：直接把 owner-private 附件访问放给所有竞标方，或把服务费确认扩成支付账户绑定 / 通用支付中心。

## 6. 后续扩展位

后续若开放竞标方附件预览，必须单独进入 `bid-material access` 阶段：

1. L0：冻结 bidder 预览资格、项目状态、组织关系、附件类型边界。
2. L2：新增或修订专用 app-facing contract，不复用 owner-private 语义。
3. L3：Server 持有权限真相、审计和访问范围。
4. L4：BFF 只做会话整合、转发、错误归一和可见性裁剪。
5. L5：Flutter 只消费新专用投影，才恢复预览入口。

本轮不得把上述扩展位误认为已经实现。
