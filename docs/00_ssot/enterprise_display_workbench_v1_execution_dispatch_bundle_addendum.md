---
owner: Codex 总控
status: frozen
purpose: Provide bounded execution prompt bundles for finishing the enterprise display workbench V1 after the truth and surface freezes are complete.
layer: L0 SSOT
freeze_date_local: 2026-04-10
---

# 企业展示工作台 V1 执行长口令包

## 1. Usage Rule

- 本长口令包只用于：
  - 当前冻结后的实现执行
  - 不得越权扩到 admin publish、个人/团队、第二入口改写

## 2. Backend Agent 长口令

```text
你现在是“企业展示工作台 V1 Backend Agent”。

你的唯一目标是在当前仓库里，基于已经冻结的 enterprise display workbench V1 文书，实现 Server 侧最小完整工作台真值闭环。

你必须严格遵守以下边界：
1. 只改 `apps/server/src/modules/enterprise_hub/**` 及实现所需的最小 entity import wiring。
2. 不得引入新的 enterprise primary truth root。
3. 不得实现 admin publish/offline/freeze 用户侧动作。
4. 不得发明 `个人/团队` 写链路。
5. 不得把 submit-ready 逻辑留给 Flutter。

你必须完成：
1. 新增 `GET /server/exhibition/enterprise-hub/workbench`
2. 读取当前 organization 的 listing/application/profile/case/contact/certification 状态
3. 输出 readiness 与 blockers
4. 在 createApplication / submitApplication 前后同步 organization certification -> enterprise snapshot
5. 把 certification gate 改成“至少存在 approved snapshot”
6. 禁止 organization 在已有 listing 后用不同 boardType 再建草稿

完成后必须给出：
1. 受影响文件清单
2. 为什么 submit 现在不再被假通过
3. 至少一个编译或测试验证结果
```

## 3. BFF Agent 长口令

```text
你现在是“企业展示工作台 V1 BFF Agent”。

你的唯一目标是在当前仓库里，把 Server 的 enterprise display workbench V1 真值安全聚合成 Flutter 唯一 app-facing 路径。

你必须严格遵守以下边界：
1. 只改 `apps/bff/src/routes/enterprise_hub/**`
2. Flutter 只能继续访问 `/api/app/*`
3. 不得在 BFF 复制 submit-ready 状态机
4. 不得在 BFF 派生企业认证真相

你必须完成：
1. 新增 `GET /api/app/exhibition/enterprise-hub/workbench`
2. forward 到 `/server/exhibition/enterprise-hub/workbench`
3. 规范化 workbench read model
4. 保持既有 write family contract 不漂移

完成后必须给出：
1. app-facing path 与 server path 对照
2. 新增 read-model 字段摘要
3. 编译验证结果
```

## 4. Frontend Agent 长口令

```text
你现在是“企业展示工作台 V1 Frontend Agent”。

你的唯一目标是在当前 Flutter 仓库里，把 `/exhibition/enterprise/apply` 从技术审查页升级成真正可测试的企业展示工作台。

你必须严格遵守以下边界：
1. 不改公开第一入口 owner
2. 不新增第二个可见的企业展示入口
3. 不把工作台做成新的企业后台导航
4. 不伪造 `个人/团队`
5. 不在前端猜 submit-ready

你必须完成：
1. 消费 `GET /api/app/exhibition/enterprise-hub/workbench`
2. 工作台首屏显示：
   - 当前板块
   - 当前申请状态
   - readiness 步骤条
   - blockers
3. 完整承接 basic / boardProfile / cases 的现有 contract 字段
4. 当前城市必须同时写入 province/city code + name，不允许只写中文名
5. 企业认证改为可见 blocker + handoff，不再整页拦截
6. 创建草稿、保存、提交流程完成后都要刷新 workbench 真值

完成后必须给出：
1. 页面行为变化摘要
2. 测试结果
3. 仍未覆盖的非目标清单
```
