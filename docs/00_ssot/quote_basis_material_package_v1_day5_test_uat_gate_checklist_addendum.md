---
owner: Codex 总控
status: completed
purpose: Record Day5 regression, 8080 tunnel UAT, and stage-gate judgment for Quote Basis Material Package V1.
layer: L0 SSOT
date_local: 2026-04-27
---

# 《报价依据资料包 V1 Day5 测试回归 / 隧道 UAT / 阶段门禁核查表》

## 1. Scope

本核查表只覆盖 `报价依据资料包 V1` Day5：

- 5 类资料枚举：
  - `effect_image`
  - `construction_doc`
  - `material_sample`
  - `equipment_material_list`
  - `service_list`
- DB 约束与 legacy 兼容：
  - DB check 允许五类 + legacy `other_material`
  - Server 新写入只允许五类
  - `other_material` 不进入接单方 `bid-materials` 投影和 `bid_material` 下载权限
- BFF 投影与 `file/access` 透传：
  - `/api/app/project/bid-materials`
  - `/api/app/file/access?accessScope=bid_material`
- Flutter：
  - 发布方五类上传入口
  - 接单方第二步五格九宫格
  - `查看 / 下载` 使用 `accessScope=bid_material`
  - 不暴露 owner 上传 / 删除 / 绑定能力

本核查不声明真实账号完整 UAT 已完成；真实账号完整路径仍需用户用已登录账号手动跑。

## 2. Local Regression Evidence

| Layer | Command | Result | Coverage |
| --- | --- | --- | --- |
| Server | `npm run build` | Pass | Server TypeScript build |
| Server | `node --test test/project-attachment-corridor.test.cjs` | Pass, 26 tests | DB constraint, five-kind bind, legacy `other_material` rejection, bid-material projection, owner-private access rejection, `bid_material` supplier access, owner denied, legacy denied |
| BFF | `npm run build` | Pass | BFF TypeScript build |
| BFF | `node --test test/project-bid-material.test.cjs test/file-access-forwarding.test.cjs` | Pass, 7 tests | five-kind read model, BFF projection, stable error copy, `projectId + accessScope=bid_material` forwarding |
| Flutter | `flutter analyze ...` | Pass | Target exhibition files and tests |
| Flutter | `flutter test test/project_attachment_prepublish_and_bid_materials_test.dart test/project_attachment_corridor_test.dart` | Pass, 18 tests | five-grid render, no owner capability leak, `accessScope=bid_material` click path, owner upload corridor |
| Flutter | `flutter test test/shell_app_test.dart --plain-name "bid submit default content no longer exposes technical disclosure copy"` | Pass | Five-step bid-submit surface, no old project-attachment / P0-Pay user-facing copy |

## 3. Local Gate Checks

| Check | Result | Evidence |
| --- | --- | --- |
| 5 类枚举 | Pass | Server/BFF/Flutter tests include all five V1 kinds |
| DB 约束 | Pass | Server migration test asserts `chk_project_attachments_attachment_kind` contains five kinds + legacy `other_material` |
| Server 新写不收 `other_material` | Pass | `bind rejects legacy other_material for V1 writes` |
| BFF 投影 | Pass | `project bid-material service forwards canonical read-only projection` |
| Flutter 九宫格 | Pass | `bid submit keeps step one only until continue bid` renders five materials |
| 下载 / 查看权限 | Pass local | Flutter sends `accessScope=bid_material`; BFF forwards `projectId + accessScope`; Server allows qualified supplier and rejects owner / legacy kind |
| owner 能力泄漏 | Pass local | Flutter tests assert no owner upload / delete / bind / preview controls on bidder side |

## 4. 8080 Tunnel UAT

Tunnel base:

```bash
http://127.0.0.1:8080
```

Probe results:

| Probe | Result | Interpretation |
| --- | --- | --- |
| `GET /api/app/project/bid-materials?projectId=probe` | `404 AUTH_RESOURCE_UNAVAILABLE`, message `当前项目附件暂不可用，请稍后再试。`, `source=server` | Route is reachable through tunnel, but active cloud runtime still carries old copy and is not aligned to local Day5 BFF/Server source |
| `GET /api/app/file/access?fileAssetId=probe&mode=download&projectId=probe&accessScope=bid_material` | `401 AUTH_SESSION_INVALID`, message `当前登录状态已失效，请重新登录后再试。`, `source=bff` | Route is mounted and controlled; unauthenticated request is correctly stopped before file access |
| `GET /api/app/project/bid-materials` | `400 AUTH_RESOURCE_UNAVAILABLE`, message `当前项目不可用。`, `source=bff` | Missing `projectId` is controlled by BFF, not a route-level 404 |

## 5. Veto Items

| Veto | Status | Reason |
| --- | --- | --- |
| Cloud active runtime aligned to local source | Veto open | `/api/app/project/bid-materials` still returns old `项目附件` copy, proving cloud BFF/Server has not been deployed/restarted to this Day5 source |
| Real-account full UAT | Veto open | No authenticated publisher / supplier account flow was executed in this run |
| Production acceptance | Veto open | Local tests pass, but cloud runtime drift remains |

## 6. Gate Judgment

Current judgment:

- `Go` for local source/test closure.
- `Go` for Flutter manual review using local frontend against known cloud caveat.
- `No-Go` for cloud acceptance, production release, or “云端已完成” claim.

Required next step before cloud acceptance:

1. Deploy / activate the updated Server and BFF package on Aliyun.
2. Re-run the same 8080 probes.
3. Expected cloud `bid-materials` unavailable copy must become `当前项目材料清单暂不可读，请稍后再试。`
4. Run authenticated publisher + supplier manual UAT for:
   - 发布方五类上传
   - 接单方五格读取
   - 接单方 `查看 / 下载`
   - owner 能力不泄漏

## 7. Final Day5 Status

Day5 local engineering closure is complete.

Cloud stage gate remains blocked by active runtime drift.
