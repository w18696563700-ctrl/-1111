# 企业展示三板块独立化 Flutter 测试债清理执行回执补遗

## 文档元数据
- 日期：2026-04-19
- 阶段：Flutter test debt cleanup
- 总控：Codex
- 范围：`apps/mobile/test/enterprise_hub_routes_test.dart`

## 执行目标
- 将企业展示主路由大测试文件对齐到三板块 board-scoped family 当前真相。
- 清理 shared path 时代遗留的 fake transport handler、标题文案断言和 case editor 壳层旧假设。
- 让该文件重新成为可用的 Flutter 回归门。

## 派工与回执
- 子代理 `Helmholtz`：只读核查 canonical path 家族，确认 board-scoped family 与仍允许保留 shared bridge 的边界。
- 子代理 `Parfit`：只读归并早期红灯，输出 list/detail/workbench/published-change 四类历史问题分布。
- 总控本地集成：完成最终 patch、回归执行、回执落盘。

## 实施结果
- 在测试文件内新增 board-scoped path helper，统一生成 company / factory / supplier canonical test path。
- 将 list / detail / workbench / published-change 相关 fake handler 迁移到当前 board-scoped BFF family。
- 保留仍然设计为 shared bridge 的 endpoint 断言，不做误迁移。
- 将旧 `优秀公司 / 优秀工厂` 标题断言收口到当前 `公司展示 / 工厂展示 / 供应商展示` 口径。
- 将旧地图说明文案断言更新到当前 detail section 真相。
- 移除 case editor workbench 内嵌案例库后遗留的旧测试假设。
- 将一条 workbench 基础资料保存测试改为适配 `ListView` 延迟构建，而不是依赖目标 key 首屏即挂载。
- 将一条 case editor create-route 测试改写为当前真实且稳定的 route-level 合同：进入即处于 `保存案例` 语义，且不嵌套案例库动作。

## 写入文件
- `apps/mobile/test/enterprise_hub_routes_test.dart`

## 验证
- 执行命令：
  - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise workbench save basic ensures shell before basic save when contact is still empty"`
  - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise case editor create route starts in save-case mode without nested case library actions"`
  - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart`
- 结果：
  - 两条定向用例均通过
  - 整文件通过，结果为 `56 passed, 0 failed`

## 结论
- 本轮 Flutter test debt cleanup 已完成。
- `enterprise_hub_routes_test.dart` 当前已经与三板块独立化后的移动端实现重新对齐，可继续作为后续企业展示链路改动的回归门。
