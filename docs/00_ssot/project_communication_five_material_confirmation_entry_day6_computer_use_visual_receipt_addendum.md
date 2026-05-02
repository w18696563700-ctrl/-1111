---
owner: Codex 总控
status: accepted
purpose: >
  Record Day 6 Computer Use visual acceptance for the project communication
  five material confirmation entry minimum loop.
layer: L5 Frontend Visual Receipt
verification_scope: Flutter macOS app visual acceptance through existing SSH tunnel
inputs_canonical:
  - docs/00_ssot/project_communication_five_material_confirmation_entry_min_loop_day1_freeze_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day2_flutter_structure_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day4_flutter_verification_receipt_addendum.md
  - docs/00_ssot/project_communication_five_material_confirmation_entry_day5_cloud_readonly_receipt_addendum.md
evidence:
  - docs/00_ssot/evidence/20260502-project-communication-five-material-confirmation-computer-use.png
---

# 《项目沟通五类资料确认入口 Day 6 Computer Use 视觉验收回执》

## 1. 总裁决

Day 6 结论为 `Conditional Pass`。

当前 Flutter macOS 视觉验收确认：

- `项目工作入口` 内已出现 `资料确认` 固定区。
- 五类资料确认入口固定展示。
- 底部聊天输入栏不再显示 `确认` 主入口。
- 点击资料项只触发本地状态提示，不发送聊天确认卡。

本回执不代表：

- 五类资料真实确认状态已由 Server 持久化。
- `已确认` 绿色状态已经在真实业务数据中可用。
- iOS / Android 真机视觉验收已完成。
- Browser Use 网页验证已完成。

## 2. 本轮目标

完成第 6 天视觉验收：

- 用当前工作区重新启动 Flutter macOS App。
- 通过既有 8080 SSH 隧道消费云端 BFF。
- 进入 `消息 -> 项目沟通 -> 项目页`。
- 目视核对五类资料入口、底部输入栏和点击反馈。
- 保存正式截图证据。

## 3. 本轮范围

本轮只包含：

- Flutter macOS 本地运行态。
- Computer Use 页面观察和点击。
- 截图证据归档。
- 视觉验收回执。

本轮不包含：

- BFF / Server / contracts 代码改动。
- 云端部署、重启、Nginx reload、数据库变更。
- POST / PUT / PATCH / DELETE 业务接口验证。
- 真机安装包验证。

## 4. 执行过程

### 4.1 旧运行态裁决

启动前发现本机已有旧 `mobile.app` 运行态。

该旧运行态页面仍显示：

- `项目工作入口` 内没有 `资料确认` 固定区。
- 底部输入栏仍有 `确认` 按钮。

裁决：

- 该状态不作为本轮失败结论。
- 原因是旧进程无法证明已加载 Day 3 当前工作区改动。
- 已停止旧 Flutter macOS 运行态并重新启动当前工作区构建。

### 4.2 当前工作区启动

启动方式：

```bash
SMOKE_SKIP_TUNNEL=1 APP_INITIAL_ROUTE="/messages" ./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

运行边界：

- runtime entry mode: `ssh_tunnel`
- BFF base URL: `http://127.0.0.1:8080/api/app`
- Web target: 不存在，Browser Use 网页路径不作为主线。

## 5. 视觉验收结果

已通过：

- 页面可从 `互动中心 -> 项目沟通 -> 进入沟通` 到达项目沟通页。
- 顶部 `当前项目沟通` 卡保留。
- `项目工作入口` 保留原有三个入口：
  - `进入审核`
  - `后续承接状态`
  - `项目相册`
- `项目工作入口` 内新增并固定展示 `资料确认` 区。
- 五类资料入口显示为：
  - `效果图确认`
  - `材质图确认`
  - `尺寸图确认`
  - `设备物料清单确认`
  - `服务清单确认`
- 当前账号 / 当前项目资料状态不可读时，页面显示：
  - `资料状态暂不可读`
  - 各按钮状态为 `暂不可读`
- 点击 `效果图确认` 后，本地提示为：
  - `资料状态暂不可读。`
- 底部输入栏只保留：
  - `附件`
  - `图片`
  - 文本输入框
  - 发送按钮
- 底部输入栏未显示 `确认` 按钮。

截图证据：

- `docs/00_ssot/evidence/20260502-project-communication-five-material-confirmation-computer-use.png`

## 6. 未完成项

本轮未完成：

- iOS 真机视觉验收。
- Android 真机视觉验收。
- Browser Use 网页验收。
- 五类资料 `已确认` 绿色真实业务态验收。
- 后端确认状态持久化验收。

## 7. 风险点

已确认风险：

- Flutter Web target 不存在，本轮不能用 Browser Use 作为主线页面验证。
- 当前项目返回 `资料状态暂不可读`，因此未覆盖 `待确认` 或 `已确认` 真实数据视觉态。
- `已确认` 仍不能由前端推断为业务真值。
- 当前工作区存在本任务外的 BFF / Server / messages / shell 脏改，本轮未触碰、未清理。

## 8. 下一轮建议

最稳路径：

- 停在当前 Flutter 最小闭环和 Computer Use 视觉验收结果。

最低成本路径：

- 只补一次真实账号 / 可读项目的视觉复验，验证 `待确认` 展示。

当前阶段最适合路径：

- 若用户要看绿色 `已确认`，先回到 Gate 1 冻结五类资料确认状态 contracts。

风险最大路径：

- 未冻结 contracts 就直接改 BFF / Server 状态机，或让 Flutter 自行把文件存在推断为 `已确认`。
