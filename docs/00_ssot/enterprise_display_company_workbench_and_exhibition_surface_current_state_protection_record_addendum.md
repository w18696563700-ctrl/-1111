---
owner: Codex 总控
status: frozen
purpose: Freeze the current-state protection record for the enterprise-display company workbench and the exhibition-facing company surfaces so later rounds cannot silently damage this board family.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_field_alignment_v1_revision_projection_contract_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
---

# 《企业展示优秀公司工作台与展览页现状保护记录》

## 1. Scope

- 本记录只冻结当前两组 surface 的现状边界：
  - `企业展示入驻工作台` 内的 `优秀公司工作台`
  - `展览页` 内的 `优秀公司` 列表与详情展示
- 本记录的目标不是重新定义 contract。
- 本记录的目标是把当前已形成的页面职责、入口边界、真值来源和已知限制冻结下来，防止后续误伤。

## 2. Protected Surface Family

### 2.1 私有维护面

- `优秀公司工作台`
  - route family:
    - `/exhibition/enterprise/apply?boardType=company`
- `优秀公司变更工作台`
  - route family:
    - `/exhibition/enterprise/apply?boardType=company&enterpriseId={enterpriseId}&mode=published_change`
- `案例编辑工作台`
  - route family:
    - `/exhibition/enterprise/cases/editor?boardType=company`
    - `/exhibition/enterprise/cases/editor?boardType=company&caseId={caseId}`
    - published-change family 继续带：
      - `enterpriseId`
      - `mode=published_change`

### 2.2 对外公开面

- `优秀公司列表`
  - route family:
    - `/exhibition/companies`
- `优秀公司详情`
  - route family:
    - `/exhibition/companies/detail?enterpriseId={enterpriseId}`

## 3. Current Responsibility Boundary

### 3.1 优秀公司工作台当前负责什么

- 负责维护：
  - 展示标识 / Logo
  - 公司名称只读真值展示
  - 公司位置只读真值展示
  - 公司板块画像：
    - 展会类型
    - 服务项目
  - 企业画册
  - 地图 / 位置
  - 基础资料
  - 联系人
  - 案例库列表
  - 提交入驻申请或提交公开变更

### 3.2 优秀公司工作台当前不再承担什么

- 不再把 `继续编辑案例` 直接塞回整页企业工作台内联编辑。
- `继续编辑案例` 与 `新增案例` 当前必须进入独立 `案例编辑工作台`。
- 这是当前已冻结的交互边界，不得在未更新本记录前静默回退到“企业工作台内嵌大案例编辑器”。

### 3.3 案例编辑工作台当前负责什么

- 只负责单条案例维护：
  - 案例标题
  - 展会类型
  - 案例城市
  - 举办时间
  - 案例摘要
  - 案例图片
  - 是否重点案例
  - 保存案例 / 保存修改
- `案例编辑工作台` 是独立页面壳。
- 但它不是独立状态机。
- 它底层仍然挂在同一个企业展示 truth family 上：
  - draft workbench case family
  - published-change case family

## 4. Public Exhibition Company Surface Current Rule

### 4.1 优秀公司列表当前语义

- `优秀公司列表` 是公开浏览面。
- 它只消费当前公开 listing 真值。
- 它不是工作台草稿面。
- 它不是 change snapshot 预演面。

### 4.2 优秀公司详情当前语义

- `优秀公司详情` 是公开详情面。
- 详情的地址、地图、Logo、画册、案例与企业信息只允许从当前公开 detail truth 投影。
- 详情页不得静默混用：
  - 私有 workbench 草稿值
  - 内部审核值
  - 仅 current change 可见值

## 5. Truth Source Freeze

### 5.1 名称真值

- `优秀公司工作台` 的公司名称只读值当前以认证主体真值为准。
- `优秀公司列表 / 详情` 的公司名称展示当前也要求与认证主体真值保持对齐。
- 后续若发生名称来源切换，必须先更新本记录。

### 5.2 位置与地址真值

- 工作台里：
  - `公司位置` 当前按认证地址解析出的省市 / 注册地真值展示。
- 详情里：
  - `详细地址` 当前要求与正式认证资料地址对齐。
  - 地图模式只在有真实可用 map truth 时展示。
  - 没有 map 能力时允许受控降级，但不得伪造地图已接通。

### 5.3 Logo / 画册真值

- 工作台回显：
  - 优先本地上传 bytes
  - 其次远端可展示 URL
  - 最后才是占位态
- 列表 / 详情：
  - 当前只允许消费可展示 URL
  - 不允许重新下发裸 OSS 直链导致 `403`

### 5.4 案例真值

- 单条案例编辑当前属于企业展示 truth family 的组成部分。
- 但交互入口必须独立成 `案例编辑工作台`。
- 不允许把“页面独立”误改成“案例拥有第二套独立发布状态机”。

## 6. Published-change Corridor Freeze

- 当优秀公司已经进入 published-change corridor 后：
  - `企业工作台` 进入 `变更工作台` 模式
  - `案例编辑工作台` 继续可独立进入
  - 但其保存仍写入同一条 current change carrier
- 不允许：
  - 继续让用户误以为是在直接编辑线上展示
  - 在锁定状态下继续把案例表单伪装成可写
  - 让案例编辑重新回流到旧的 direct continuation 路径

## 7. Known Current Limitations

- `变更工作台预览展示页` 当前仍是受控 preview，不等于正式线上详情。
- 预览区已开始消费当前可得 Logo / 画册媒体 URL。
- 但案例卡媒体 preview 仍未形成完整 projection family。
- 因此：
  - 当前允许“案例图在 preview 中不完整”
  - 不允许“用伪造媒体或错误来源媒体把 preview 伪装成完整”

## 8. Do-not-damage Rules

- 未经本记录更新，不得做以下变更：
  - 把 `继续编辑案例` 再次改回整页企业工作台内嵌编辑
  - 删除或绕过 `案例编辑工作台` 独立入口
  - 把工作台名称 / 位置真值改回旧 listing 优先
  - 把详情地址改回与认证地址脱钩
  - 把 Logo / 画册展示链改回裸 OSS 直链
  - 在 published-change 锁定态下重新放开案例编辑表单
  - 在公开列表 / 详情中混入私有 current change 值

## 9. Required Change Trigger

- 任何后续需求只要触及以下任一项，就必须先更新本记录：
  - 优秀公司工作台职责
  - 案例编辑工作台入口
  - published-change 案例编辑规则
  - 优秀公司列表 / 详情字段来源
  - Logo / 画册展示链
  - 认证地址与公开地址对齐规则

## 10. Current Judgment

- 当前 `优秀公司工作台 + 案例编辑工作台 + 展览页优秀公司公开面` 已形成一个受保护的最小板块家族。
- 后续只允许：
  - blocker 修复
  - 稳定性维护
  - 在不破坏本记录边界的前提下补媒体或文案收敛
- 后续不允许：
  - 借机重新混合页面职责
  - 借机拆出第二套案例发布状态机
  - 借机把公开面与私有面重新混源
