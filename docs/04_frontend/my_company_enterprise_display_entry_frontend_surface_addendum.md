---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side surface for the `我的楼 / 我的资产 -> 企业展示入驻` handoff into the enterprise display workbench, without widening into a second company console or contract expansion.
layer: L3 Frontend
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - apps/mobile/AGENTS.md
  - docs/00_ssot/my_company_enterprise_display_entry_prd_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart
---

# 我的楼企业展示入驻前端界面冻结单

## 1. Scope

- 本轮只冻结：
  - `我的楼 / 我的资产` 新增 `企业展示入驻` 入口
  - 板块选择弹层
  - `公司 / 工厂 / 供应商` 三类企业展示工作台 landing
- 本轮不冻结：
  - 新 route family
  - 新 API
  - 新上传流程
  - 公域企业列表新结构

## 2. My Building Entry Rule

- `我的楼` 页 `我的资产` 分组下新增：
  - `企业展示入驻`
- 该入口位置固定为：
  - `我的论坛` 下方
- 该入口只能表现为：
  - bounded handoff row
- 该入口不得表现为：
  - dashboard 卡片组
  - 多列操作台
  - 企业后台主导航

## 3. Board Selection Sheet Rule

- 点击 `企业展示入驻` 后，必须使用轻量选择层。
- 当前推荐形态固定为：
  - bottom sheet
- Sheet 内当前固定为四项：
  - `公司`
  - `工厂`
  - `供应商`
  - `个人/团队`
- 每项允许带一行人话说明：
  - 公司侧强调设计搭建与服务履历
  - 工厂侧强调工艺产能与交付能力
  - 供应商侧强调展会物料租赁与供给响应
  - 个人/团队侧强调个人设计师、团队或班组专区预留

## 4. Workbench Landing Rule

- 选择某一正式板块后，必须直接 push 到其工作台路由：
  - `公司 -> enterprise/apply?boardType=company`
  - `工厂 -> enterprise/apply?boardType=factory`
  - `供应商 -> enterprise/apply?boardType=supplier`
- `个人/团队` 当前不进入新工作台路由，只允许显示受控提示反馈。
- 不允许先经过：
  - 空白占位页
  - 中间确认页
  - 公域企业列表页

## 5. Selection Surface Rule

- 选择层当前必须只承担：
  - 板块选择
  - 轻量说明
  - 受控 placeholder handoff
- 选择层不得承担：
  - 企业目录浏览
  - 复杂筛选
  - 资料预览
  - 多步确认

## 7. Existing Apply Route Rule

- `/exhibition/enterprise/apply` 仍为既有写链路主承接页。
- 它当前同时作为：
  - `企业展示入驻` 的正式 landing
  - 工作台续办页
  - 状态回跳页
- 企业详情页当前不再保留进入该页面的公开 CTA。
- 该页面当前应表现为：
  - 企业展示入驻工作台
  - 现有技术写链路承接页
  - 当前 workbench 真值页
- 其完整界面边界改由：
  - `enterprise_display_workbench_v1_frontend_surface_addendum.md`
    单独冻结
- 它不得再读作：
  - 公域企业列表附属页
  - 企业详情页 continuation button

## 8. Non-goals

- 不复制参考图的完整栏目结构
- 不发明新的筛选 contract
- 不将 `我的公司` 扩成企业资料总后台

## 9. Formal Conclusion

- 当前正式结论固定为：
  - `我的楼 / 我的资产` 可以新增一个 bounded `企业展示入驻` handoff row
  - 该 row 通过 bottom sheet 进入四项选择，其中三项进入正式工作台，一项保留受控 placeholder
  - `企业展示入驻` 与公域企业列表必须彻底分开
  - 当前不触碰新的 `contracts / bff / server` family widening
