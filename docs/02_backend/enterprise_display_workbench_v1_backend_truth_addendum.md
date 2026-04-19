---
owner: Codex 总控
status: frozen
purpose: Freeze the Server-side truth for the enterprise display workbench V1, including the workbench query carrier, submit-readiness semantics, and certification snapshot sync semantics.
layer: L2 Backend
freeze_date_local: 2026-04-10
inputs_canonical:
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/**
  - apps/server/src/modules/organization/**
---

# 企业展示工作台 V1 Backend Truth 冻结单

## 1. Scope

- 当前 backend freeze 只覆盖：
  - `server/exhibition/enterprise-hub/workbench`
  - enterprise certification snapshot sync
  - submit readiness 真值判定
  - enterprise-display shared upload binding
  - factory showcase image truth
  - case media default-cover rule

## 2. Read Truth

- `Server` 必须新增：
  - `GET /server/exhibition/enterprise-hub/workbench`
- 该 path 只允许在当前 actor 携带有效 organization scope 时读取。
- `Server` 必须从以下对象组合当前 workbench payload：
  - `enterprise_listing`
  - `enterprise_application`
  - `enterprise_profile_company`
  - `enterprise_profile_factory`
  - `enterprise_profile_supplier`
  - `enterprise_case`
  - `enterprise_contact`
  - `enterprise_media_asset_ref`
  - `organization_certifications`
  - `enterprise_certification_snapshot`

## 3. Certification Sync Truth

- 当前 organization certification 仍是唯一认证真源。
- enterprise hub 只允许消费它的 snapshot。
- 当前 write truth 必须在以下节点执行 sync：
  - create application
  - submit application
- sync 内容固定为：
  - listing 上的 legal-name / uscc / verification-status snapshot
  - `enterprise_certification_snapshot` 的 upsert
- 当前工作台基础资料不得再复制一套营业执照上传字段；只允许消费认证真值并 handoff 到认证主线。

## 4. Shared Upload Binding Truth

- `Server` 当前必须允许 enterprise display 复用 shared upload corridor。
- 当前 enterprise-display upload binding 固定为：
  - `businessType = enterprise_display`
  - `fileKind = enterprise_logo`
  - `fileKind = enterprise_album`
  - `fileKind = enterprise_factory_showcase`
  - `fileKind = enterprise_case_media`
- 当前 init / confirm 必须校验：
  - `businessId` 指向现有 `enterprise_listing.id`
  - 该 listing 属于当前 organization scope
  - 文件真值继续冻结为 `FileAsset`

## 5. Submit Rule

- `submitApplication` 当前必须先执行认证快照同步，再做 submit gate 校验。
- `ensureCertificationMinimum` 当前不得只判断“存在任一 snapshot”。
- 当前必须判断：
  - 至少存在一条 `certStatus = approved` 的 enterprise certification snapshot

## 6. Media Truth

- factory showcase 图片真值当前冻结为：
  - `enterprise_profile_factory.showcase_image_file_asset_ids`
  - 最多 `6` 张
- case media 真值当前继续冻结为：
  - `enterprise_case.case_media_file_asset_ids`
  - 最多 `6` 张
- case cover 规则当前冻结为：
  - 允许显式传入 `case_cover_file_asset_id`
  - 若未传且 case media 非空，则默认取第一张

## 7. Workbench Readiness Rule

- `Server` 必须返回 submit-readiness 真值，不允许前端猜。
- blocker 文案当前必须来源于真值判定结果，至少覆盖：
  - 未创建申请草稿
  - 基础资料未完成
  - 板块画像未完成
  - 案例未补齐
  - 主联系人缺失
  - 企业认证未通过
  - 当前最近申请不可编辑，需重新创建草稿
- readiness 不得把“展示图片未上传”单独升格为 submit 硬 blocker。

## 8. Board Lock Rule

- 当 `enterprise_listing` 已存在时：
  - create-application 若接收到不同 `applyBoardType`，必须拒绝
- 当前 backend 不允许把一个 organization 的 listing 主板块在用户侧静默改写。

## 9. Non-goals

- 不在本轮补 case update / delete
- 不在本轮补发布 lifecycle 用户侧动作
- 不在本轮补 `个人/团队`

## 10. Formal Conclusion

- 当前 backend 真值固定为：
  - 一条专用 workbench query
  - 一条认证快照自动同步链
  - 一组 enterprise-display 共享上传绑定
  - 一条工厂实景图与案例多图真值规则
  - 一套 submit-ready 真值 gate
