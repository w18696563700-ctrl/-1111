---
owner: Codex 总控
status: accepted
purpose: >
  Record Day 5 cloud read-only runtime receipt and final closure for the
  project communication five material confirmation entry minimum loop.
layer: L4 Runtime Receipt
verification_scope: Cloud read-only health checks and Flutter BFF boundary check
inputs_canonical:
  - docs/00_ssot/project_communication_five_material_confirmation_entry_min_loop_day1_freeze_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day2_flutter_structure_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day4_flutter_verification_receipt_addendum.md
---

# 《项目沟通五类资料确认入口 Day 5 云端只读联调回执》

## 1. 总裁决

Day 5 结论为 `Conditional Pass`。

已完成云端 BFF / Server 只读 health check，且本轮 Flutter 资料确认入口仍通过 App -> BFF 的 `/api/app` 边界读取资料。

本回执不代表：

- 五类资料真实确认状态已经由 Server 持久化。
- 云端已经支持五类资料逐项确认状态机。
- 本轮已经完成 Browser Use / Computer Use 页面点击验收。
- 本轮已经部署、重启或修改云端。

## 2. 本轮目标

在不改云端的前提下完成第 5 天只读联调：

- 检查 BFF active runtime live 状态。
- 检查 Server active runtime live 状态。
- 核对 Flutter 资料确认入口仍消费 BFF `/api/app` 路径。
- 明确前端完成和云端运行时确认的边界。

## 3. 本轮范围

本轮只包含：

- `GET /health/bff/live`
- `GET /health/server/live`
- Flutter 资料读取路径只读核对。
- 形成最终只读 runtime receipt。

本轮不包含：

- POST / PUT / PATCH / DELETE。
- 部署、重启、Nginx reload、数据库变更。
- BFF / Server / contracts 改动。
- 五类资料确认状态持久化。

## 4. 云端只读验证回执

验证基准：

- 隧道入口：`http://127.0.0.1:8080`
- 请求方式：`GET`
- 写操作：未执行

### 4.1 BFF live

命令：

```bash
curl -i --max-time 10 http://127.0.0.1:8080/health/bff/live
```

结果：

- HTTP status: `200 OK`
- service: `exhibition-bff`
- port: `3000`
- response timestamp: `2026-05-02T11:17:09.830Z`

### 4.2 Server live

命令：

```bash
curl -i --max-time 10 http://127.0.0.1:8080/health/server/live
```

结果：

- HTTP status: `200 OK`
- service: `exhibition-server`
- port: `3001`
- response timestamp: `2026-05-02T11:17:09.830Z`

## 5. Flutter 边界核对

本轮核对的资料读取入口：

- `ExhibitionConsumerLayer.loadProjectAttachments`
- `ExhibitionConsumerLayer.loadProjectBidMaterials`

对应读取路径：

- `/api/app/my/projects/{projectId}/attachments`
- `/api/app/project/bid-materials`

结论：

- Flutter 仍通过 App-facing BFF `/api/app` 边界消费资料。
- 未发现本轮资料确认入口直接调用 Server 或 Admin API。
- 点击五类资料按钮的 Day 4 测试已确认不会向项目沟通消息接口发送确认卡 POST。

## 6. 最终验收结论

当前最小闭环达到：

- 五类资料确认入口固定在项目工作入口。
- 聊天输入栏不再作为五类资料确认主入口。
- 五类展示名固定：
  - `效果图确认`
  - `材质图确认`
  - `尺寸图确认`
  - `设备物料清单确认`
  - `服务清单确认`
- Flutter scoped test / analyze 已通过。
- 云端 BFF / Server live 只读健康检查已通过。
- 本轮未触碰 BFF / Server / contracts / 云端配置。

当前未达到：

- Server 持久化五类资料逐项确认状态。
- BFF 返回五类资料逐项确认状态。
- `已确认` 作为生产业务真值。
- 真机或 Browser Use 视觉验收。

## 7. 风险点

已确认风险：

- 当前 contracts 没有五类资料逐项确认状态字段。
- 云端 live 只证明 BFF / Server 进程存活，不证明五类确认状态能力已上线。
- 当前工作区存在本任务外的 BFF / Server / messages / shell 脏改，本回执未归属、未清理。
- 若下一轮要求真实确认持久化，必须回到 SSOT / contracts 门禁。

## 8. 下一轮建议

推荐下一轮只做二选一：

- 若继续保持低风险：做 Browser Use / Computer Use 页面验证，产出视觉验收回执。
- 若要真实业务闭环：先冻结五类确认状态字段、状态机、接口契约，再进入 BFF / Server / Flutter 联动实现。

不得在未冻结 contracts 的情况下，把当前 Flutter-only `待确认 / 未提交 / 暂不可读` 显示升级为正式业务状态。
