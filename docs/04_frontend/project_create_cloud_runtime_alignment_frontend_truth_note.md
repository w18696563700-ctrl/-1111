---
owner: Codex 总控
status: active
purpose: >
  Record the current Flutter-side runtime alignment rule for the exhibition
  project create page so later threads do not treat the temporary
  `scopeSummary` requirement and success-only handoff behavior as accidental
  drift while the active cloud runtime is still behind the local repo source.
layer: L5 Frontend
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart
---

# 创建项目页 cloud runtime alignment frontend truth note

## 1. Scope

- 本说明只覆盖当前 `展览楼 -> 创建项目页` 的运行时对齐规则：
  - `保存项目基本信息并跳转至我的项目`
  - 创建成功后的列表承接
  - 创建失败时的显式错误提示
  - `范围说明(scopeSummary)` 的当前必填口径
- 本说明不改写：
  - `draft -> submitted -> published` 的后续状态机
  - `我的项目详情` / `预发布列表` 的既有发布确认规则
  - 本地 `Server source` 已发生但尚未上云的未来口径

## 2. 当前运行时事实

- 当前联调入口固定为：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- `2026-04-14` 云上 active ingress 实测中，`POST /api/app/project/create` 出现连续 `400`，因此移动端不会进入成功跳转分支。
- 当前 active cloud `Server` 部署产物仍要求 `scopeSummary` 为必填：
  - active dist path:
    - `/srv/releases/server/20260413134212/dist/modules/project/project-write.service.js`
  - observed rule:
    - `scopeSummary` 仍通过 required read 进入 create path
- 因此：
  - 本地 repo 中若已经把 `scopeSummary` 改成 optional source
  - 也不能反向视为当前 live truth
  - 当前 live truth 仍以 active cloud runtime 为准

## 3. 当前 Flutter 对齐规则

- 创建页主按钮当前固定为：
  - `保存项目基本信息并跳转至我的项目`
- 只有在 create 接口真正成功后，前端才允许：
  - 刷新 `我的项目`
  - 直接跳转 `我的项目` 列表页
- 当 create 接口失败时，前端必须：
  - 停留在当前创建页
  - 直接提示后端返回的错误消息
  - 不得把失败态伪装成“保存成功但没跳过去”
- 在 active cloud runtime 尚未更新前，创建页必须继续把：
  - `范围说明`
  - 视为当前必填项

## 4. Anti-revert Rule

- 后续线程当前不得把下列行为当成“误改”直接回退：
  - 把 `范围说明` 再次改回前端选填
  - 删除 create 失败后的 snackbar / 显式错误提示
  - 恢复“创建成功后停在当前成功卡，等待再点下一步”的旧承接
- 原因固定为：
  - 这些改动不是审美选择
  - 而是当前 active cloud runtime 与本地 repo source 暂时不一致时的前端对齐措施

## 5. 恢复条件

- 只有同时满足以下条件，后续线程才允许重新讨论把 `范围说明` 放回选填：
  1. cloud active `BFF / Server` 已完成新版本部署
  2. active create runtime 已验证允许 `scopeSummary` 为空
  3. `POST /api/app/project/create` 在空 `scopeSummary` 条件下返回成功
  4. Flutter 端联调已验证：
     - 保存成功
     - 直接跳到 `我的项目`
     - 新项目落入 `草稿`

## 6. Formal Conclusion

- 当前创建页前端口径正式记为：
  - `success-only direct handoff to 我的项目`
  - `failure stays in place with explicit backend message`
  - `scopeSummary required until active cloud runtime catches up`
- 后续若发生云端部署追平，不得只改代码不改文书；必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
