---
owner: Codex 总控
status: active
purpose: >
  Record the current Flutter-side dual-certification surface and exhibition bid
  guard truth, so later threads do not treat personal certification, shell
  qualification fields, or bid hard-gate handoff as accidental drift or
  future-only planning.
layer: L5 Frontend
decision_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/dual_certification_cloud_runtime_alignment_receipt_addendum.md
  - docs/04_frontend/project_showcase_trade_language_and_guard_alignment_frontend_truth_note.md
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/profile/profile-personal-certification-ocr.service.ts
  - apps/server/src/modules/profile/profile-personal-certification-write.service.ts
  - apps/bff/src/routes/profile/profile-read.service.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/bff/src/routes/bid/bid.service.ts
  - apps/mobile/lib/core/boot/app_shell_context.dart
  - apps/mobile/lib/core/boot/app_shell_context_consumer.dart
  - apps/mobile/lib/features/profile/data/profile_identity_consumer_layer.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/navigation/profile_identity_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart
  - apps/mobile/test/profile_identity_contract_compat_test.dart
  - apps/mobile/test/profile_page_test.dart
  - apps/mobile/test/shell_app_test.dart
---

# 双重认证与竞标守卫 frontend truth note

## 1. Scope

- 本说明只覆盖当前 `公司认证与我的身份`、`shell/context`、`展览楼竞标守卫` 三者之间的现行前端口径。
- 本说明不扩成：
  - 第二个身份中心
  - 审核后台
  - 独立的个人实名认证楼层

## 2. 当前 live truth

- `我的认证` 当前已经是 live truth，不再是 future-only 升级项。
- `2026-04-14` 当前 live cloud runtime 已对齐到：
  - `Server = /srv/releases/server/20260414235030`
  - `BFF = /srv/releases/bff/20260414235030/apps/bff`
- 当前竞标资格必须同时满足：
  - 当前组织类型属于 `supplier` 或 `both`
  - 企业认证已通过
  - 我的认证已通过
  - 我的认证未锁定到其他账号
  - 当前账号与我的认证匹配
- 当前双重认证不是前端假判断：
  - `Server` 已持有个人认证 OCR、持久化与 bid submit 资格硬门禁
  - `BFF` 已把相关读侧字段与错误文案聚合到 app-facing surface
  - `Flutter App` 只负责展示、提交流程与 handoff

## 3. 当前页面与路由口径

- `我的认证` 当前固定挂在既有 `公司认证与我的身份` 家族内。
- 当前页面必须承接：
  - `当前认证状态`
  - `当前我的认证`
  - `正式认证资料`
  - `我的认证真值`
- 当前路由固定为：
  - `ProfileIdentityRoutes.certificationCurrent`
  - `ProfileIdentityRoutes.personalCertificationSubmit`
- 后续线程不得因为“我的认证”已接入，就另起：
  - 第二套身份中心
  - 第二套公司切换入口
  - 第二套审核结果页族

## 4. 当前数据承接口径

- `shell/context` 当前必须稳定承接：
  - `personalCertificationStatus`
  - `personalCertificationQualified`
  - `personalCertificationLockedToOtherActor`
- `profile/certification/current` 当前必须稳定承接：
  - nested `personalCertification`
- 当前前端守卫不得本地猜测以下状态：
  - 我的认证是否已匹配当前账号
  - 我的认证是否锁定其他账号
  - 我的认证是否可替换

## 5. 当前提交流程口径

- `提交我的认证` 当前只承接最小正式链：
  - `init -> direct upload -> confirm -> OCR -> submit`
- 当前输入边界固定为：
  - `1` 张身份证正面图片
- 当前页面只承接：
  - 图片选择
  - 上传确认
  - OCR 结果核对
  - 正式提交
- 当前页面不扩成：
  - 多证件中心
  - 手工审核工作台
  - 独立风险控制台

## 6. 当前竞标守卫口径

- `立即参与竞标` 与 `查看竞标结果` 当前统一先检查：
  - 登录
  - 组织
  - 组织类型是否属于 `supplier / both`
  - 企业认证
  - 我的认证
- 当前必须明确区分：
  - `组织类型属于 supplier / both`
  - 与
  - `当前成员角色显示为 supplier_*`
  不是同一件事
- 若用户在 `公司认证与我的身份` 页看到：
  - 企业认证已通过
  - 我的认证已通过
  但竞标仍被拦住，当前优先检查的不是认证页，而是：
  - 当前主体是否仍是 demand-only 组织
  - 当前 shell 是否已回读到正确的 `organizationType`
- 若 `我的认证` 未通过，当前固定引导到：
  - `公司认证与我的身份`
- 若 `我的认证` 已锁定到其他账号，当前必须显示锁定文案，不得伪装成普通未认证。
- 若 `shell/context` 已给出 `personalCertificationQualified=false`，当前不得继续放行竞标。
- 若当前主体是 demand-only，当前必须明确提示：
  - 需要切换到 `supplier` 或 `both` 主体
  - 不是简单要求把当前成员角色改成 `supplier_*`

## 6.1 当前身份变更通道

- 当前可见通道固定为：
  - `公司与组织 -> 切换当前公司/组织`
  - `我的楼首页 -> 成员管理`
- 当前限制固定为：
  - 现有组织进入编辑态后，`组织类型` 为锁定展示
  - 不支持直接把已存在主体从 `需求方` 改成 `供应商`
- 因此若当前主体是 demand-only：
  - 应优先切换到已有 supplier/both 主体
  - 若没有，则应再创建一个 supplier/both 主体，再切换过去

## 6.2 当前主体显示与切换回读规则

- `我的公司` 与 `公司与组织` 当前主体的解析顺序固定为：
  - 先看 `shellContext.organizationId`
  - 再回退 `organization/mine.items[].current`
- 理由固定为：
  - 切换主体后，`shell/context` 是 App 级当前主体真值
  - `organization/mine` 中的 `current` 标记可能短暂滞后
  - 前端不得因为列表里的旧 `current=true` 把页面重新拉回旧主体
- 当前主体的企业认证展示固定为：
  - 若 `profile/certification/current.organizationId` 与当前主体一致，优先使用该认证真值
  - 不得优先显示滞后的 `organization/mine.certificationStatus`
- `我的公司` 与 `公司与组织` 当前摘要卡的状态呈现固定为单行三标签：
  - `成员已开通`
  - `企业未认证 / 企业认证中 / 企业已认证 / 企业认证未通过 / 企业已过期`
  - 当前成员角色，如 `需求管理员 / 供应商管理员`
- 当前不得再单独使用无主语的：
  - `已开通`
  作为公司摘要状态词
- 当前需要明确区分：
  - `需求方 / 供应商 / 需求方 / 供应商` 是组织类型
  - `需求管理员 / 供应商管理员` 是当前成员角色
- 若 switch 接口返回值不完整，但前端回读已确认目标主体生效，当前处理固定为：
  - 先 reload `shell/context`
  - 再 reload `organization/mine`
  - 若目标主体已经成为当前主体，则按 `切换成功` 处理
  - 不得继续停留在 `切换当前未完成`

## 7. Anti-revert Rule

- 后续线程当前不得把以下行为当成“误改”直接回退：
  - 删除 `当前我的认证`
  - 删除 `我的认证真值`
  - 删除 `提交我的认证`
  - 把 `我的认证` 改回只存在于文案提示
  - 移除 `shell/context` 中的 `personalCertification*` 字段承接
  - 移除 `shell/context.organizationType`
  - 把展览楼竞标资格改回只看企业认证
  - 把展览楼竞标资格改回“必须是 `supplier_*` 成员角色才允许继续”
  - 把 `提交我的认证` 改回手填 fileId 或非三段式上传

## 8. 回写要求

- 若后续线程继续修改这组能力，必须同步更新：
  - 本说明
  - `docs/00_ssot/latest_user_confirmed_change_ledger.md`
  - `docs/04_frontend/project_showcase_trade_language_and_guard_alignment_frontend_truth_note.md`
  - 对应 Flutter 回归测试

## 9. Formal Conclusion

- 当前双重认证与竞标守卫现行口径正式记为：
  - `dual-cert live`
  - `organization-type gated`
  - `profile-family bounded`
  - `server-hard-gate backed`
  - `shell-qualified`
  - `frontend-handoff only`
- 当前需明确区分：
  - `需求方 / 供应商` 是组织类型
  - `需求管理员 / 供应商管理员` 是当前成员角色
  - 竞标守卫当前看的是：
    - `organizationType`
    - 双重认证
    - `qualifiedForCurrentActor`
    - 项目态与 owner 关系
  - 不是：
    - `supplier_* roleKey` 单独一项
