---
owner: Codex 总控
status: recorded
purpose: >
  Record the bounded cloud runtime alignment that promoted dual
  enterprise-plus-personal certification from repo-only implementation into the
  active Server and BFF releases, including migration application, active
  release pointers, and route verification results.
layer: L0 SSOT
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/profile/profile.controller.ts
  - apps/server/src/modules/profile/profile-personal-certification-ocr.service.ts
  - apps/server/src/modules/profile/profile-personal-certification-write.service.ts
  - apps/server/src/modules/shell/shell-query.service.ts
  - apps/server/src/modules/shell/shell.presenter.ts
  - apps/server/src/modules/upload/upload-write.service.ts
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/bff/src/routes/profile/profile-read.service.ts
  - apps/bff/src/routes/shell/shell.service.ts
  - apps/bff/src/routes/bid/bid.service.ts
---

# 双重认证云端运行时对齐执行回执

## 1. Incident

- 本地仓库已完成：
  - `我的认证` 真值链
  - 展览楼竞标双重认证守卫
  - Server/BFF 相关读写与错误映射
- 但云端 active runtime 初查仍缺少：
  - `personal_certifications` 表
  - 个人认证 app-facing / server-facing 路由
  - shell/context 中的 `personalCertification*` live 承接

## 2. Root Cause

- 当前云端 active release 仍停留在：
  - `Server` `/srv/releases/server/20260414171252`
  - `BFF` `/srv/releases/bff/20260414174134/apps/bff`
- 这两版运行时尚未包含本轮双重认证相关编译产物。
- 因此 repo 中的实现尚未进入 live cloud truth。

## 3. Execution

- 基于当时 active release 创建新 release：
  - `Server` `/srv/releases/server/20260414235030`
  - `BFF` `/srv/releases/bff/20260414235030/apps/bff`
- 仅覆盖本轮双重认证相关 source 与 dist：
  - `Server`
    - migration
    - personal certification OCR / submit
    - current-actor eligibility
    - shell context projection
    - upload `id_card_front`
  - `BFF`
    - profile command/read shaping
    - shell shaping
    - bid error mapping
- 切换 symlink：
  - `/srv/apps/server/current -> /srv/releases/server/20260414235030`
  - `/srv/apps/bff/current -> /srv/releases/bff/20260414235030/apps/bff`
- 重启：
  - `exhibition-server.service`
  - `exhibition-bff.service`

## 4. Active Runtime After Repair

- 当前 active release：
  - `Server = /srv/releases/server/20260414235030`
  - `BFF = /srv/releases/bff/20260414235030/apps/bff`
- 当前 service：
  - `exhibition-server.service = active`
  - `exhibition-bff.service = active`
- `ServerMigrationRunnerService` 已在本次启动时应用：
  - `20260414_personal_certification_dual_gate_truth`

## 5. Verification

- 数据库验证：
  - `public.personal_certifications` 已创建
  - 包含：
    - `organization_id`
    - `user_id`
    - `certification_status`
    - `id_card_front_file_id`
    - `provider_request_id`
    - `locked_at`
- server-facing 路由验证：
  - `POST http://127.0.0.1:3001/server/profile/certification/personal/submit`
    - 返回 `400 PERSONAL_CERTIFICATION_SUBMIT_INVALID`
    - 原因是缺少 `organizationId`
    - 说明路由已存在，不再是 `404`
  - `POST http://127.0.0.1:3001/server/profile/certification/personal/id-card/ocr`
    - 返回 `400 PERSONAL_CERTIFICATION_OCR_INVALID`
    - 原因是缺少 `organizationId`
    - 说明路由已存在，不再是 `404`
- app-facing 路由验证：
  - `POST http://127.0.0.1:3000/api/app/profile/certification/personal/submit`
    - 返回 `401 AUTH_SESSION_INVALID`
  - `POST http://127.0.0.1:3000/api/app/profile/certification/personal/id-card/ocr`
    - 返回 `401 AUTH_SESSION_INVALID`
  - 说明 app-facing 路由已生效，当前只剩鉴权前置
- 运行时编译产物验证：
  - active release 内已可检索到：
    - `personalCertificationQualified`
    - `Current personal certification is not approved for bid submit.`
    - `Current personal certification is locked to another actor for bid submit.`
    - `profile/id_card_front`
    - `certification/personal/submit`
    - `certification/personal/id-card/ocr`

## 6. Conclusion

- 本轮双重认证云端运行时对齐已完成。
- `我的认证` 不再只是本地仓库实现，已经进入 live cloud runtime。
- 展览楼竞标资格当前已具备：
  - Server 硬门禁
  - BFF app-facing 承接
  - Flutter shell/profile/bid guard 消费
- 后续若再次出现“竞标仍只看企业认证”或“我的认证路由 404”：
  - 应先核查 active release 是否偏离：
    - `Server 20260414235030`
    - `BFF 20260414235030`
  - 不得直接把问题重新归咎为“只有前端本地改了”

## 6.1 Subsequent Independent Runtime Verification

- `2026-04-15` 后续独立复核当前确认：
  - 本回执中的“运行时对齐已完成”只证明：
    - 迁移已落库
    - 路由已存在
    - active release 已切到目标版本
    - app-facing / shell / bid guard 读写链已承接
  - 当前尚不能单独证明：
    - 真实 supplier 样本在完成 `我的认证` 后一定可正向继续竞标
- 当前独立复核命中的 runtime blocker 为：
  - supplier 会话下：
    - `GET /api/app/profile/certification/current`
      返回 `certificationStatus=approved`
      但 `legalPerson=null`
      且 nested `personalCertification.certificationStatus=not_submitted`
  - 因此：
    - `POST /api/app/profile/certification/personal/submit`
      返回 `400 PERSONAL_CERTIFICATION_SUBMIT_INVALID`
      消息为 `当前公司认证缺少法人信息，请先更正公司认证资料。`
    - `POST /api/app/bid/submit`
      返回 `403 AUTH_PERMISSION_INSUFFICIENT`
      消息为 `当前我的认证尚未通过，暂不具备投标资格。`
- 当前独立复核对数据库的补充结论为：
  - `personal_certifications` 真表存在
  - 但当时 supplier 角色样本与该表的 join 返回 `0` 行
  - 因而当前只能证明：
    - 负向拦截成立
    - 正向 supplier smoke 不成立 / 不可证
- 当前 follow-up 结论固定为：
  - 这不是 `Flutter` 未消费，也不是 `BFF/Server` 路由未上线
  - 当前问题属于：
    - supplier 真实认证对象未闭环
    - 真实法定代表人样本未走完 `我的认证`
- 当前回执需要补充的文档漂移也已确认：
  - app-facing `POST /api/app/profile/certification/personal/id-card/ocr` 无鉴权实测虽为 `401`
  - 但返回体不一定是 `AUTH_SESSION_INVALID`
  - 独立复核命中了：
    - `{"code":"PERSONAL_CERTIFICATION_OCR_INVALID","message":"Field organizationId is required."}`
  - 因此后续线程不得再把这条 body 机械写死成唯一返回体

## 6.2 Supplier Runtime Forensics and Final Gate

- `2026-04-15` 云端 supplier 真样本进一步复核确认：
  - 当前命中的真实 supplier 会话对应：
    - 用户 `18696563700`
    - supplier 组织 `5564ecfa-0ef2-4545-a15c-bf1b66458d2a`
    - 组织名 `closure-dev-org-1774694443`
  - `GET /api/app/profile/certification/current` 在该 supplier scope 下稳定返回：
    - `certificationStatus=approved`
    - `legalPerson=null`
    - `personalCertification.certificationStatus=not_submitted`
    - `qualifiedForCurrentActor=false`
    - `lockedToOtherActor=false`
  - `POST /api/app/bid/submit` 在真实 published project 下稳定返回：
    - `403 AUTH_PERMISSION_INSUFFICIENT`
    - `reason=personal_certification_not_approved`
    - 说明当前 blocker 仍然是“双重认证未闭环”，不是后续业务规则
- 当前 root cause 已进一步收口为 runtime truth 问题，而不是 presenter / BFF 聚合问题：
  - supplier 组织当前企业认证记录：
    - `organization_certifications.submitted_at=2026-04-02`
    - 早于 `20260410_certification_license_field_collection_truth`
  - 因而当前这笔已批准企业认证沿用了旧 runtime truth：
    - `legal_person`
    - `business_type`
    - `registered_capital`
    - `business_term`
    - `business_scope`
    - 均未补齐
- 进一步对 supplier 企业认证 file truth 取证确认：
  - `organizations.business_license_file_id`
  - `organization_certifications.license_file_id`
  - 都指向 `34933cae-82d1-431b-9eea-daa6094c7879`
  - 但该 ID：
    - 不存在于当前 `file_asset`
    - 只存在于 legacy `file_assets`
    - 旧 carrier 类型为 `forum_draft_attachment/media`
- 对这个 legacy 对象直接做营业执照 OCR 后，识别结果为：
  - `重庆坤特展览展示有限公司`
  - `91500105MA5U58K346`
  - `法定代表人=王巍威`
  - 这与当前 supplier 组织 `closure-dev-org-1774694443 / 91350211M000100Y44` 不一致
- 因而当前 blocker 不能被错误表述为“只差补一个 legalPerson”：
  - 真相是：
    - supplier 企业认证对象错绑到了 legacy forum attachment carrier
    - 当前 supplier 企业认证缺少可被当前 runtime 消费的营业执照 file truth
    - 当前 supplier 样本本身不是合法可用的法定代表人闭环样本
- 当前 active runtime 也不存在可替代的真实 supplier 正向样本：
  - 全库仅有一条 `personal_certifications`
  - 其归属 `bdfb4523-aeb7-4b56-89a1-992170fb5d98 / 18676681020`
  - 不属于任何当前 supplier 组织
  - 当前 supplier 组织下也不存在 `id_card_front` file truth
- 本轮最终 gate 结论必须固定为：
  - `No-Go`
  - 原因不是代码未上线，而是：
    - `supplier runtime truth 未闭环`
    - `legacy file carrier/backfill 未闭环`
    - `当前 active runtime 不存在可执行真实 supplier 正向 smoke 的法定代表人样本`

## 6.3 Canonical Supplier Runtime Truth Repair and Positive Smoke

- `2026-04-15` 随后进一步执行确认，最终可行路径不是继续修坏掉的 `5564...` supplier org，也不是继续新建重复 supplier org，而是收口到唯一真实公司 canonical org：
  - 用户：
    - `18676681020 / ebb8d922-e7da-43fa-897b-360214dfd6e4`
  - canonical org：
    - `bdfb4523-aeb7-4b56-89a1-992170fb5d98`
    - `重庆展宏展览展示有限公司`
- 选择这条路径的原因已经由 runtime truth 证明：
  - 当前 `organizations.uscc` 有唯一约束
  - 同一真实公司不能保留多个正式 org truth
  - 前序新开的：
    - `bf4bf8ba-2128-4b43-a611-789dea991c67 supplier draft`
    - `a81303a3-379c-4a30-8a20-aec45d6a4d36 both draft`
  - 只是重复草稿对象，不能成为正式 supplier 样本
- 本次 runtime repair 实际执行为：
  - `organizations.organization_type`
    - `bdfb...: demand -> both`
  - `organization_members.role_key`
    - `74ed2ebe-306a-4080-9316-def72969b1e1: buyer_admin -> supplier_admin`
  - 禁用重复 draft membership：
    - `949d7ee2-8e3d-4244-8194-6e8d5d5358fb`
    - `61c244ea-68c3-4ca8-ae1e-6e99a00935a0`
  - 将该用户全部有效 session 统一收口到 canonical org `bdfb...`
  - 已写入正式 `audit_logs`
    - `request_id=runtime-repair-1776186411888`
    - `trace_id=runtime-repair-1776186411888-trace`
- 这次没有追加 `Server/BFF` 业务代码修复：
  - 原因是 blocker 已证实属于 runtime truth 与 bootstrap 目标收口问题
  - 当前现有双重认证实现已足够承接，只缺真实对象对齐
- 实际 app-facing 正向 smoke 结果如下：
  - `GET /api/app/profile/certification/current`
    - `organizationId=bdfb4523-aeb7-4b56-89a1-992170fb5d98`
    - `certificationStatus=approved`
    - `legalPerson=王帅`
    - `personalCertification.certificationStatus=approved`
    - `personalCertification.userId=ebb8d922-e7da-43fa-897b-360214dfd6e4`
    - `qualifiedForCurrentActor=true`
    - `lockedToOtherActor=false`
  - `POST /api/app/profile/certification/personal/submit`
    - 本轮无需再次提交
    - 原因是该 canonical supplier 样本已经真实存在：
      - `personal_certifications.organization_id=bdfb4523-aeb7-4b56-89a1-992170fb5d98`
      - `certification_status=approved`
      - `id_card_front_file_id=98335fd5-1195-466e-89c1-5a6cf062ef75`
  - `POST /api/app/bid/submit`
    - 使用 canonical org 自有 published project `97779e2d-50a0-4038-a0d8-1ee3b4d9d122`
    - 返回：
      - `403 AUTH_PERMISSION_INSUFFICIENT`
      - `reason=owner_relation_not_allowed`
    - 该返回说明：
      - 当前已经越过 `supplier_role_not_allowed`
      - 已经越过 `certification_not_approved`
      - 已经越过 `personal_certification_not_approved`
      - 阻断已推进到下一层真实业务规则
- 因而本回执的最终 gate 结论已从 `No-Go` 更新为：
  - `Go`
  - 判定依据：
    - 真实 supplier 样本下已不再被“我的认证未通过”这层门禁拦截
