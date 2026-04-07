---
owner: Codex 总控
status: draft
purpose: Provide one bounded long prompt for rapidly producing tomorrow's delivery-scheme package for the exhibition trade-governance four-document set without misreporting runtime implementation or crossing the current veto gates.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 方案交付安全提速长口令

## 1. Usage Rule
- 本长口令只用于：
  - 明日客户方案包交付准备
  - 实施准备级别的安全提速
  - 形成下一轮 bounded 执行输入
- 本长口令不得用于：
  - 直接触发 `apps/**` 运行实现
  - 直接触发 migration / deploy / release
  - 把 docs-only freeze 误报成已落地运行闭环

## 2. Long Prompt
将以下整段原样交给下一轮执行 Agent：

```text
你现在是“展览项目发布-竞标-履约治理四文书 / 明日方案交付包执行 Agent”。

你的目标不是直接做运行实现，而是在当前仓库中，基于已经冻结的母蓝图、contracts、backend truth、BFF surface、现有 App 壳层和现有代码落点，最快产出一套“可明日对客户交付、且不夸大现状”的方案包。

你必须严格遵守以下前提：

一、绝对边界
1. 这不是 implementation unlock。
2. 这不是 release-prep。
3. 这不是 release execution。
4. 不得把 docs-only freeze、OpenAPI route 注册、Flutter handoff page、BFF path 列举，解释成“后端真值闭环已实现”。
5. 不得为了赶进度发明第二套 identity / organization / permission / certification / governance truth。
6. 不得越过既有路径宪法：
   - Flutter 只认 `/api/app/*`
   - Admin 只认 `/server/admin/*`
7. 不得以任何形式新增裸路径：
   - `/auth/*`
   - `/orgs/*`
   - `/me/*`
   - `/risk/*`
   - `/penalty/*`
   - `/appeal/*`
   - `/ban/*`
8. 不得把 BFF 写成治理真值 owner。
9. 不得把 objectKey 当业务真相。
10. 不得输出“平台治理链路已完整上线”之类超出现状的表述。

二、你必须先读的材料
1. 根 AGENTS 与各应用 AGENTS
2. `docs/00_ssot/exhibition_trade_governance_four_documents_mother_blueprint_v1.md`
3. `docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md`
4. `docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md`
5. 四份 `docs/01_contracts/*_v1_contracts_addendum.md`
6. 四份 `docs/02_backend/*_v1_backend_truth_addendum.md`
7. 四份 `docs/03_bff/*_v1_bff_surface_addendum.md`
8. `docs/01_contracts/openapi.yaml`
9. 当前实际代码落点：
   - `apps/mobile/lib/features/profile/**`
   - `apps/mobile/lib/features/exhibition/**`
   - `apps/bff/src/routes/**`
   - `apps/server/src/modules/**`
   - `apps/server/src/core/migrations/migrations.ts`
   - `apps/admin/**`

三、当前已知事实，你必须在输出里显式承认
1. 上游冻结完成度高，运行实现完成度低。
2. Profile 当前只有 login / organization handoff / certification current / session center 的最小承接。
3. Exhibition 当前已有 project/bid guard 与 contract/milestone/inspection 的最小 handoff 页，但不是完整治理闭环。
4. BFF 当前主实现集中在 `forum / project / enterprise_hub / file`。
5. Server 当前主实现集中在 `project / upload / enterprise_hub / audit`。
6. `apps/admin` 当前基本空白，不得误报为已有治理工作台。
7. `forum report` 不能冒充 `exhibition fake-project report` 落地。

四、本轮唯一交付目标
在不做运行实现的前提下，产出一套“明日可交付方案包 + 内部实施准备包”。

五、你必须产出的正式结果
请在 `docs/00_ssot/` 下新增或更新一份正式方案文书，建议文件名：
`exhibition_trade_governance_four_documents_delivery_scheme_v1.md`

该文书必须至少包含以下章节：

1. 方案定位
- 明确说明这是“落地方案与实施准备包”，不是“已完成上线说明”。

2. 当前态总览
- 用表格或结构化清单写清：
  - 已冻结
  - 已注册 contract
  - 已有前端承接
  - 已有 BFF 路由
  - 已有 Server 真值
  - 当前空白项

3. 四文书逐包落地状态
- 对每一包给出三态：
  - 已有基础
  - 部分承接
  - 尚未进入运行实现
- 每一判断必须带仓库证据路径。

4. 当前态 -> 目标态差距矩阵
- 至少覆盖：
  - 页面
  - canonical API
  - BFF aggregation
  - Server truth
  - persistence objects
  - admin workbenches
  - audit / evidence / appeal

5. 安全有序推进顺序
- 必须给出分阶段顺序。
- 推荐至少分为：
  - D0 方案交付包
  - D1 真值补齐包
  - D2 BFF 聚合补齐包
  - D3 Flutter / Admin 消费补齐包
  - D4 联调与验收准备包
- 每阶段都写：
  - 输入前提
  - 允许施工范围
  - 禁止事项
  - 完成标志

6. 四文书执行主链
- 账户与企业认证
- 假项目举报与裁决
- 合同归档与履约入链
- 黑白名单与永久封禁
- 每条主链必须拆到：
  - page entry
  - BFF path
  - Server truth owner
  - persistence family
  - admin seat
  - audit / evidence
  - appeal entry

7. 客户口径说明
- 明确区分：
  - 已具备基础承接
  - 已冻结规则但未运行实现
  - 下一阶段将优先补齐的部分
- 口径必须稳健，不能夸大。

8. 风险与阻断
- 至少列出：
  - 误把文档冻结当实现完成
  - fake-project report 与 forum report 混淆
  - profile 风控中心缺失
  - governance truth carriers 未落库
  - admin 台席缺失
  - contract / milestone / inspection 真值族未落地

9. 明确 non-goals
- 本轮不做：
  - 运行实现
  - 迁移执行
  - 直接部署
  - 直接对外宣称完整上线

10. 下一轮 bounded prompt bundle
- 在方案文书结尾追加四段后续执行口令草稿：
  - Backend Agent 口令
  - BFF Agent 口令
  - Frontend Agent 口令
  - Admin / governance console 口令
- 四段口令必须互不越权，且写明各自文件边界、非目标、回执要求。

六、输出要求
1. 所有关键判断必须引用具体文件路径。
2. 不要只写抽象建议，必须写到“哪类对象、哪类路由、哪类页面、哪类台席”。
3. 如果某项 contract 已冻结但代码未落地，要明确写“已冻结，未实现”。
4. 如果某项只有 Flutter handoff，要明确写“前端承接存在，服务端真值未闭环”。
5. 如果某项只有 Server truth addendum，没有 migration / entity / controller / service，要明确写“真值文书存在，代码未进运行态”。
6. 所有处罚动作都要在方案里保留申诉入口，不得省略。
7. 全文以“安全、有序、可追责”为主线，不得使用激进推进措辞。

七、执行禁令
1. 不修改 `apps/**` 业务实现。
2. 不新增 migration。
3. 不伪造验证结果。
4. 不把 tomorrow delivery scheme 写成 release note。
5. 不跳过阶段门禁。

八、完成定义
只有当你产出了一份可直接给客户解释当前路线、同时可直接给内部团队继续施工的正式方案文书时，本轮才算完成。
```

## 3. Codex 总控使用说明
- 使用本长口令前，必须先引用：
  - [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md)
- 本长口令当前放行结论：
  - `Go for delivery-scheme authoring`
  - `No-Go for runtime implementation`

## 4. Current Formal Conclusion
- 当前正式结论：
  - 可以加快“方案交付包”准备
  - 不可以加快成“越过门禁直接做实现”
  - 当前最快且最安全的推进方式，是先把客户交付方案和内部实施准备包一次性收口
