---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded PRD for moving the enterprise-display entry owner into `我的楼 / 我的资产`, while keeping enterprise-hub truth, contracts, and write carriers inside the existing frozen family.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/profile_ia_cleanup_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
---

# 我的楼企业展示入驻入口 PRD 冻结单

## 1. Scope

- 本轮唯一对象只限：
  - `我的楼 / 我的资产`
  - `企业展示入驻` 入口 owner
  - `公司 / 工厂 / 供应商 / 个人/团队` 四类企业展示入驻选择
- 本轮唯一目标只限：
  - 把组织侧“上传企业形象与基本资料”的入口 owner 收回到 `我的楼 / 我的资产`
  - 让用户从 `我的楼` 进入后，按板块进入对应企业展示工作台
  - 明确区分“发布项目”和“企业展示入驻”两条链路
- 本轮明确不是：
  - enterprise-hub 新 contract
  - 新的企业真相模型
  - 新的上传协议
  - 第二套公司后台
  - 第二套 exhibition shell

## 2. Current Baseline And Problem

- `enterprise_hub` 当前公域主链已存在：
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
  - 列表页
  - 详情页
  - 入驻页
- 当前问题固定为：
  - `企业入驻` 的第一入口语义仍偏公域，用户需要在 `exhibition` 里进入
  - `企业展示入驻` 当前放在 `我的公司` 内，层级偏深，用户不容易从 `我的楼` 资产视角理解这件事
  - `企业展示入驻` 当前点击后仍落到公域企业列表，用户会把它误读成“看榜单”，而不是“进入我的企业展示入驻工作台”

## 3. Product Goal

- 用户从 `我的楼` 理解这件事时，必须读成：
  - 我在管理自己的展示资产
  - 我在选择我要进入哪一种企业展示板块
  - 我会直接进入该板块的企业展示工作台，继续完善自己的展示资料
- 用户不得读成：
  - 我在进入一个新的企业后台
  - 我在进入第二个 profile 工作台
  - 我在进入公域企业列表或榜单

## 4. Frozen Product Decisions

### 4.1 入口 owner 迁移

- `企业展示入驻` 的第一入口 owner 冻结为：
  - `我的楼 / 我的资产`
- 该入口必须出现在：
  - `我的资产` 分组内
  - `我的论坛` 下方
- 当前入口语义冻结为：
  - 展示资产 handoff
  - 不是新的 truth owner
  - 不是综合企业控制台
  - 不是新的一级 family

### 4.2 首次点击后的交互

- 点击 `企业展示入驻` 后，前端必须先弹出一个板块选择层。
- 当前必须展示四项：
  - `公司`
  - `工厂`
  - `供应商`
  - `个人/团队`
- 用户选定任一正式板块后，必须直接进入该板块工作台页：
  - `公司 -> /exhibition/enterprise/apply?boardType=company`
  - `工厂 -> /exhibition/enterprise/apply?boardType=factory`
  - `供应商 -> /exhibition/enterprise/apply?boardType=supplier`
- `个人/团队` 当前只允许作为：
  - 受控选择位
  - 待后续正式专区接通前的 placeholder handoff
- 当前明确不允许：
  - 为 `个人/团队` 临时伪造新的企业榜单
  - 为 `个人/团队` 发明新的 contracts / route family / truth owner
- 当前明确不允许：
  - 点击后直接进入公域企业列表
  - 在弹层里混入第二层复杂流程
  - 先显示空白中转页再跳

### 4.3 入驻页的定位修正

- `/exhibition/enterprise/apply` 继续保留为：
  - 现有写链路 carrier
  - 草稿创建与资料提交 carrier
  - 企业展示入驻工作台
- 但它不再作为：
  - 公域企业列表的附属页
  - 企业详情页的一键直达入口
- 当前用户理解顺序冻结为：
  1. 在 `我的楼 / 我的资产` 选择板块
  2. 直接进入对应企业展示工作台
  3. 在工作台里维护资料、案例、认证与提交
- 当前完整工作台边界改由：
  - `enterprise_display_workbench_v1_truth_freeze_addendum.md`
    单独冻结

## 5. Explicit In-scope

- `我的楼 / 我的资产` 新增 `企业展示入驻` 入口
- 入口放在 `我的论坛` 下方
- 点击后弹出四选项
- `公司 / 工厂 / 供应商` 选择后直接进入对应企业展示工作台
- `个人/团队` 作为受控 placeholder 选择位露出
- 工作台与项目展示主链语义彻底区分

## 6. Explicit Out-of-scope

- `contracts / openapi.yaml` 变更
- `Server` enterprise query/write truth 变更
- `BFF` route family 变更
- 上传 init / confirm 流重写
- 公域企业列表页大改版
- 新的企业审核台
- 新的企业 ranking / 推荐算法

## 7. Acceptance Standard

- 用户从 `我的楼 / 我的资产` 能看到 `企业展示入驻`，且位置在 `我的论坛` 下方。
- `我的公司` 不再保留 `企业展示入驻`。
- 点击后先看到四种选择，而不是直接进表单。
- 选择 `公司 / 工厂 / 供应商` 后，直接进入对应企业展示工作台。
- 选择 `个人/团队` 后，前端以受控 placeholder 方式反馈，不伪造新榜单。
- 企业详情页不再保留进入工作台的公开 CTA。
- 工作台 route 必须作为 `企业展示入驻` 的正式承接页存在。
- `我的楼` 没有被改造成第二个企业运营后台。
- `enterprise_hub` 没有被改成新的 truth root。

## 8. Formal Conclusion

- 当前正式结论固定为：
  - `企业展示入驻` 的第一入口 owner 收回 `我的楼 / 我的资产`
  - 四项选择先于资料填写，其中三项进入正式工作台，一项保留受控 placeholder
  - `企业展示入驻` 与公域企业列表彻底分开
  - `/exhibition/enterprise/apply` 作为正式工作台 landing 保留
- 当前 freeze type 固定为：
  - `my-company enterprise-display entry PRD freeze only`

## 9. Next Unique Action

- 当前唯一下一步固定为：
  - 冻结前端界面说明与阶段门禁核查表
  - 然后在 `apps/mobile` 内实施 bounded UI and route refinement
