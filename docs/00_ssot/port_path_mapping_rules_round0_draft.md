owner: Codex 总控
status: draft
purpose: 固定当前可见端口/路径映射缺口并给出后续补齐点。
layer: L0 SSOT

# 《端口/路径映射规则初稿》

## A. 本轮已确认
- 本轮隧道映射用于访问验证：
  - `127.0.0.1:8080 -> 47.108.180.198:80`
- 平台当前主入口与验证入口均通过该映射访问。

## B. BFF / Server 挂载核验项（本轮需闭环）
1. BFF 是否已在云端被 Nginx 映射到 80 端口前端路径；
2. Server 是否在 BFF upstream 正常可达；
3. `/health/live`、`/health/ready` 与 `/health/bff/*`、`/health/server/*` 是否按回路验证；
4. `/api/app/*` 与 `/server/admin/*` 是否映射在标准路径。

## C. 当前缺口（待复核，不代表已阻塞 implementation）
- 若某路径在 8080 映射下返回 404，属于本轮“盘点缺口”；
- 缺口需要在 Round 0 由结果校验 Agent 与联调发布 Agent 标注证据闭环；
- 缺口不自动允许补开发，必须先形成“缺口清单 + 轮次解锁条件”。

## D. 后续补齐方向
- 在不改旧资产前提下，建立：
  - 统一的 Round 0 路径映射签名；
  - 按文书确认的最小路径可达性清单；
  - 非本轮范围路径（如未放开的 bid/order/dispute 后链）维持禁放行。
