---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 route table for `项目名称申请查看`, listing the canonical
  app-facing paths, their roles, and the implementation-sequencing notes for
  the next stages.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/03_bff/project_name_access_request_bff_surface_freeze_addendum.md
---

# 《项目名称申请查看路由表》

## 1. Canonical App-facing Route Table

| method | path | role | note |
|---|---|---|---|
| `GET` | `/api/app/project/list` | public read | 增加 `displayTitle + nameAccess`；首页红框继续消费 `cityName / areaSqm / plannedStartAt` |
| `GET` | `/api/app/project/detail` | public read | 增加 `displayTitle + nameAccess`；详情页发起申请 |
| `POST` | `/api/app/project/name-access/request` | command | requester 发起项目名称查看申请 |
| `GET` | `/api/app/project/name-access/thread/detail` | read | review thread 受控详情 |
| `GET` | `/api/app/my/projects/{projectId}/name-access/pending` | private read | owner fallback review list |
| `POST` | `/api/app/my/projects/{projectId}/name-access/{requestId}/approve` | command | owner 同意 |
| `POST` | `/api/app/my/projects/{projectId}/name-access/{requestId}/reject` | command | owner 拒绝 |
| `GET` | `/api/app/message/interactions` | public/private read mix | `项目沟通` lane 受控扩面承接会话化入口 |

## 2. Sequencing Note

| route group | stage note |
|---|---|
| `project/list` / `project/detail` | 可与首页红框改版并行准备，但真实名称遮罩必须以后端/BFF为准 |
| `project/name-access/request` and owner review commands | 必须先落 Server，再落 BFF |
| `message/interactions` extension + `thread/detail` | 需在 bounded extension 复签后再进入实现 |

## 3. Explicit No-Go Paths

- 当前明确不使用：
  - `/api/app/message/index`
- 当前明确不新造：
  - generic `/api/app/messages/*` thread write family
  - direct-to-Server mobile path

