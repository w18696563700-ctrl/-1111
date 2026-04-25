---
owner: Codex 总控
status: frozen
layer: L0-L5 SSOT
freeze_date_local: 2026-05-18
purpose: Freeze permissions for bid award, order, fulfillment, rating, credit, and acceptance.
---

# 项目交易链路权限表

## 1. Roles

| Role | Meaning |
|---|---|
| `buyer` | 项目发布方组织 |
| `seller` | 中标/承接方组织 |
| `other_bidder` | 未中标竞标方组织 |
| `outside_org` | 非项目相关组织 |
| `admin` | 后台审计/运维，只读或受控治理动作 |

## 2. Command Permissions

| Action | buyer | seller | other_bidder | outside_org | Server rule |
|---|---:|---:|---:|---:|---|
| Award bid | yes | no | no | no | buyer org must equal project owner org |
| Read bid result | yes | own result | own result | no | scoped by project/bid organization |
| Read order | yes | yes | no | no | org must be buyer or seller |
| Submit milestone | no | yes | no | no | seller only, active order only |
| Submit inspection | yes | no | no | no | buyer only, active order only |
| Pass inspection | yes | no | no | no | buyer only, submitted inspection only |
| Submit rating | yes | yes | no | no | completed order only; rater must be buyer or seller |
| Trigger credit | no direct | no direct | no direct | no direct | Server derives from rating truth |

## 3. Read Permissions

| Object | buyer | seller | other_bidder | outside_org |
|---|---:|---:|---:|---:|
| Project public display | yes | yes | yes | yes, public trimmed |
| Bid package | yes | own only | own only | no |
| Award truth | yes | result only | result only | no |
| Order detail | yes | yes | no | no |
| Contract detail | yes | yes | no | no |
| Milestone list | yes | yes | no | no |
| Inspection detail | yes | yes | no | no |
| Counterparty rating entry | yes | yes | no | no |
| Credit aggregate | public/controlled | public/controlled | public/controlled | public/controlled |

## 4. Veto Rules

- 任一 write command 缺少 `projectId / bidId / orderId` 中的必要锚点，必须拒绝。
- 任一 write command 的当前组织不在 Server 计算的业务边界内，必须拒绝。
- `outside_org` 不能通过 BFF routeTarget/actionKey 获得真实订单或互评入口。
- Admin 不能用普通 App 路由绕过业务权限。
- 任何验收证据不得以 owner 单账号冒充双账号闭环。
