---
owner: Codex 总控
status: frozen
purpose: Freeze the full current-phase truth boundary for the enterprise display workbench, including its canonical route family, completion meaning, and cross-layer ownership, without widening into admin publish governance or a second company backend.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/my_company_enterprise_display_entry_prd_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/enterprise_hub/**
  - apps/bff/src/routes/enterprise_hub/**
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
---

# 企业展示工作台 V1 真源冻结单

## 0. Current Validity Notice

- 本文仍保留为企业展示工作台 V1 的历史冻结文书。
- 但以下条款自 `2026-04-11` 起不再描述当前 runtime truth：
  - `## 10. Board Type Rule` 中“一个 organization 仅允许一条 enterprise listing”
  - `## 3. Current-Phase Complete Meaning` 中“case 编辑 / 删除”不计入当前完整边界的旧表述
- 上述条款已被以下文书正式覆盖：
  - `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`

## 1. Scope

- 当前冻结对象只限：
  - `公司 / 工厂 / 供应商` 三类企业展示工作台
  - 工作台 canonical route family
  - 当前用户侧 create / continue / submit 闭环
- 当前不包含：
  - `个人/团队` 正式专区
  - Admin 审核台
  - 发布后上下线运营
  - 推荐位运营
  - 新的企业真相根

## 2. Current Product Meaning

- `企业展示入驻` 的公开第一入口继续固定为：
  - `我的楼 / 我的资产 -> 企业展示入驻`
  - 用户必须先在选择层里选择 `公司 / 工厂 / 供应商`
- `/exhibition/enterprise/apply` 的产品定位正式冻结为：
  - 企业展示入驻工作台
  - 在用户完成板块选择后，作为正式 landing 承接页
  - 继续承接当前组织自己的展示资料维护、案例补充、申请提交、状态续办
- 公域企业列表与工作台语义必须分开：
  - 公域企业列表用于浏览企业展示
  - 企业展示入驻用于进入自己的企业展示工作台

## 3. Current-Phase Complete Meaning

- 当前“完整企业展示工作台”只按当前用户侧 contract 范围定义为完整。
- 其完成标准固定为：
  - 可读取当前组织的企业展示工作台快照
  - 可创建或刷新当前申请草稿
  - 可维护完整 `basic` 字段面
  - 可维护完整 board-profile 字段面
  - 可通过 shared upload corridor 上传企业展示图片
  - 可维护最多 6 张企业画册图片，按确认上传顺序保存与展示
  - 可在工厂板块维护最多 6 张实景展示图
  - 可新增案例并回读已有案例
  - 可为单个案例维护最多 6 张图片，且首图默认承担封面
  - 可明确看到提交阻塞项
  - 可基于真实认证状态完成提交
  - 可查看提交后的申请状态
- 当前不把以下能力计入“本轮完整”：
  - 工作台内图片上传编排器
  - 工作台内视频管理
  - 已发布展示编辑与上下线
  - 多草稿列表与版本回溯
  - case 编辑 / 删除

## 4. Canonical Path Family

- 当前工作台 app-facing canonical path family 冻结为：
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - `POST /api/app/exhibition/enterprise-hub/applications`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/company`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/supplier`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases`
  - `POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit`
  - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
- 当前工作台必须继续显式 handoff 到既有认证主线：
  - `/profile/certification/current`
- 当前工作台必须直接复用既有企业认证主线：
  - 营业执照上传
  - OCR 自动识别
  - 认证主体与统一社会信用代码回填
- 当前不得在企业展示工作台里再发明第二套营业执照上传字段。

## 5. Workbench Read Truth

- 当前必须新增一条专用 workbench read carrier：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
- 该 read model 必须至少承接：
  - 当前组织下 enterprise listing 摘要
  - 当前 primary board type
  - latest application 摘要
  - basic 当前值
  - boardProfile 当前值
  - primary contact 当前值
  - case 列表
  - 当前企业认证状态快照
  - submit readiness 与 blocker 列表
- 其中：
  - `basic` 必须继续承接 `logo / album / fullIntro`
  - `fullIntro` 当前用户侧上限冻结为 `2000` 字
  - factory `boardProfile` 必须额外承接 `showcaseImageFileAssetIds`
  - case 读模型必须继续承接 `caseMediaFileAssetIds`
- 该 read model 不得变成：
  - 企业展示公域榜单
  - 第二个 profile index
  - Admin 运营摘要

## 6. Submit Gate Truth

- 当前提交 gate 必须按真实真相判断，不允许前端猜。
- 当前 submit-ready 最小条件冻结为：
  - 当前存在可编辑申请草稿
  - `basic` 最小必填已完成：
    - `name`
    - `shortIntro`
    - `provinceCode`
    - `provinceName`
    - `cityCode`
    - `cityName`
  - primary board profile 最小必填已完成
  - 至少已有 1 个案例
  - 至少已有 1 个 primary/public contact
  - 当前组织企业认证状态为 `approved`
  - enterprise hub 内部认证快照已同步为 `approved`

## 7. Certification Sync Truth

- enterprise hub 当前不得要求用户重复手填一套“企业认证快照”。
- 认证快照真相来源冻结为：
  - 现有 organization certification truth
- 企业展示工作台的 write 链当前必须在 create-draft / submit 前后，同步：
  - `listing.legalNameSnapshot`
  - `listing.unifiedSocialCreditCodeSnapshot`
  - `listing.verificationStatusSnapshot`
  - `enterprise_certification_snapshot`
- 当前不得在前端伪造：
  - 新的认证字段真相
  - 第二套营业执照上传主链
- 当前工作台基础资料区必须读成：
  - 企业主体认证继续从 `公司认证与我的身份` 同步而来
  - 基础资料区不得再重复铺设认证同步卡、营业执照上传状态卡或 OCR 成功状态卡
  - 工作台只消费认证真值与提交 blocker，不再复制第二套认证办理面

## 8. Shared Upload Truth

- 当前企业展示工作台新增图片上传时，必须继续走现有 shared corridor：
  - `init -> direct upload -> confirm`
- 当前 enterprise-display 合法 upload binding 冻结为：
  - `businessType = enterprise_display`
  - `fileKind = enterprise_logo`
  - `fileKind = enterprise_album`
  - `fileKind = enterprise_factory_showcase`
  - `fileKind = enterprise_case_media`
- 当前上传绑定必须满足：
  - `businessId = 当前 organization 已拥有的 enterpriseId`
  - 只允许当前 organization scope 绑定自己的 enterprise listing
  - 文件真值仍然是 `FileAsset`
  - `objectKey` 仍然只是存储位置
- 当前前端允许的简化行为冻结为：
  - 联系人最小字段齐备后，首次上传图片或首次保存资料时可自动补建草稿
  - 自动补建只是在前端代用户先完成 create-draft，再继续既有上传链
  - 联系人输入本身不等于已建草稿，只有 create-draft 成功后才形成正式 listing 草稿

## 8A. Base Profile Truth

- 当前工作台基础资料区必须冻结为：
  - 只允许上传 `Logo`
  - 不再提供 `头图` 上传位
  - `注册城市` 以 `我的公司 -> 当前 organization` 真值为准
  - `成立日期` 以 `公司认证营业执照 OCR` 真值为准
  - `注册城市` 与 `成立日期` 当前只允许在工作台内只读显示，不做页内 source-jump
  - `详细地址` 必填，允许结合设备定位能力做当前位置回填
  - `合作方式` 以显式可选标签承接，不再用逗号分隔自由文本
- 当前前端不得伪造：
  - 可编辑的第二套注册城市选择器
  - 可编辑的第二套成立日期输入源
  - 冒充“点一下跳去别页修改”的假选择器
  - 不存在的高德地图选点页
  - 冒充可手写输入框的 register-city / foundedAt UI

## 9. Case Media Rule

- 当前单个企业案例的图片上限冻结为：
  - `6`
- 当前 `caseCoverFileAssetId` 规则冻结为：
  - 允许显式传入
  - 若未显式传入且 `caseMediaFileAssetIds` 非空，则默认取第一张图片作为封面
- 当前不允许：
  - 一个案例无图但要求图片预览能力
  - 单案例无限追加图片
- case 文本摘要继续保留为一案一段说明，不升级成论坛动态流。

## 10. Board Type Rule

- 当前 organization 仅允许拥有一条 enterprise listing。
- 该 listing 的 `primaryBoardType` 一旦建立，当前用户侧工作台不允许随意切换到另一主板块继续写入。
- 当 listing 已存在时：
  - 工作台 board type 必须锁定为 listing 当前 primary board type

## 11. Non-goals

- 不做工作台内的发布 / 下线动作
- 不做 recommendation slot 占位配置
- 不做 `个人/团队` 用户侧 write path
- 不把 `企业展示工作台` 提升成新的“我的公司后台”

## 12. Formal Conclusion

- 当前正式结论固定为：
  - `企业展示工作台 V1` 已从“技术审核页”升级为“当前用户侧可测试工作台”
  - 它是 `企业展示` 的次级维护页，不是公开展示入口
  - 它当前直接复用现有企业认证主线，不再重复发明一套执照上传表单
  - 它当前补齐了真实图片上传、工厂实景图与案例多图能力，并把城市/成立日期回收到我的公司真相
  - 它的“完整”只按当前 app-facing contract 范围计算，不包含 admin publish lifecycle
