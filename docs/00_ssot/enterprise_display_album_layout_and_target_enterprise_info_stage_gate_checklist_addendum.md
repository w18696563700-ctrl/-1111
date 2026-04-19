---
owner: Codex 总控
status: active
purpose: Freeze the stage gate checklist for the bounded round that upgrades the three enterprise detail windows into album-style pages and introduces gated target-enterprise formal-info read without reopening unrelated filter scope.
layer: L0 SSOT
freeze_date_local: 2026-04-15
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/certification_license_field_collection_contracts_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - docs/04_frontend/profile_dual_certification_bid_guard_frontend_truth_note.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# 《企业展示详情画册化与目标企业信息查看 Stage Gate Checklist》

## 1. 当前目标包

- 当前目标包固定为：
  - `三个企业展示窗口详情页画册化改版`
  - `目标企业正式信息查看入口`
  - `双重认证点击门禁`
- 当前明确不包含：
  - 筛选口径调整
  - 现有筛选功能删减或改写
  - 当前用户自己的认证中心改版
  - 新的独立企业认证楼层
  - Admin 审核台扩面

## 2. passed gates

- `真源门禁`：PASS
  - 当前边界、目标与角色分工已在本地 `docs/` 内冻结。
- `架构边界门禁`：PASS
  - 当前仍保持：
    - 前端只在本地开发
    - `BFF` 与后端只在云端开发
    - `Flutter App -> BFF -> Server` 单链路不变
- `状态机门禁`：PASS
  - 本轮不新增企业展示申请状态机，也不新增认证状态机。
- `阶段控制门禁`：PASS
  - 当前唯一目标、非目标、角色边界与推进顺序已可冻结。

## 3. failed gates

- 当前 failed gates 固定为：
  - 当前公开企业详情 contract 只承接：
    - `header`
    - `basicInfo`
    - `boardProfile`
    - `serviceAreas`
    - `cases`
    - `certifications`
    - `reviewSummary`
    - `contacts`
    不承接目标企业正式认证文字信息读取。
  - 当前 `GET /api/app/profile/certification/current` 只锚定：
    - 当前登录用户
    - 当前组织
    不能合法承接“查看对方企业信息”。
  - 当前跨三类企业统一的 `企业画册` 真值未冻结：
    - 工厂现有 `showcaseImageFileAssetIds`
    - 公司与供应商没有同语义统一画册字段
  - 当前展示页 UI 仍偏字段清单回读，未达到“点进去像企业画册”的目标。

以上失败项不等于本轮直接否决，
它们是本轮必须先经 docs-first 冻结后再进入实施的对象。

## 4. veto gates

- 不得复用：
  - `GET /api/app/profile/certification/current`
  作为“目标企业信息查看”数据源。
- 不得把当前用户私域 `我的公司 / 公司认证与我的身份` 页面偷接成公开企业详情的目标企业读取入口。
- 不得把 OCR preview object 伪装成正式目标企业信息真值。
- 不得把 `fileAssetId` 直接当作公网图片 URL 使用。
- 不得在本地修改：
  - `apps/bff/**`
  - `apps/server/**`
- 不得借本轮删除、弱化或改写现有筛选功能。
- 不得借本轮新增第二套认证中心、第二套身份中心或第二套企业信息私域入口。

## 5. stage go / no-go decision

- 当前 gate decision 正式固定为：
  - `Go for docs-first freeze`
  - `Go for bounded frontend visual refactor planning`
  - `No-Go for direct reuse of current-user certification current path`
  - `No-Go for end-to-end implementation before contract freeze`
  - `No-Go for filter scope changes`

更具体地说：

- 可以先推进：
  - 总控文档冻结
  - 新 contract / backend truth / BFF surface / frontend surface 冻结
  - 只消费现有公开字段的详情页视觉骨架设计
- 当前不能直接推进：
  - 目标企业信息按钮联通
  - 统一企业画册真值的最终实现
  - 任何需要云端新 read path 的前后端联调

## 6. 当前下一步唯一动作

- 当前下一步唯一动作固定为：
  - `由总控先冻结四层文档，再发 6 角色执行口令`

四层文档顺序固定为：

1. `docs/01_contracts`
   - 冻结目标企业正式信息查看 path 与统一企业画册字段面
2. `docs/02_backend`
   - 冻结后端真值归属、双重认证硬门禁与公开读取裁剪规则
3. `docs/03_bff`
   - 冻结 app-facing 聚合、错误归一与 visibility trim
4. `docs/04_frontend`
   - 冻结详情页画册化布局、按钮锁定态与弹层消费规则

## 7. Formal Conclusion

- 当前总控结论固定为：
  - 本轮需求可以继续推进
  - 但必须先走 docs-first 冻结
  - 当前完整实现不是 frontend-only 问题
  - “三个窗口点进去像企业画册”与“查看对方企业正式信息”必须拆成：
    - `前端画册式排版`
    - `云端受控 formal-info read`
- 只有在 contract / backend / BFF / frontend 四层冻结完成后，
  才允许发出正式 implementation prompt bundle。
