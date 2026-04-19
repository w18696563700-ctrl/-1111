---
owner: Codex 总控
status: active
purpose: 冻结我的项目四阶段丝滑化规则，只覆盖顶部四分栏、阶段归类、主动作约束、后果提示与弱理解用户可感知的最小流程引导。
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/project_publish_object_cluster_l5_frontend_consumption_consistency_refresh_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/project/project-write.service.ts
---

# 《我的项目四阶段丝滑化规则冻结单》

## 1. 范围

- 本冻结单只覆盖 `我的项目` 的用户可见阶段组织与最小引导规则。
- 本冻结单只锁以下对象：
  - `我的项目` 列表页顶部四分栏
  - `我的项目` 列表卡片的当前阶段与下一步动作
  - `我的项目` 详情页顶部阶段承接与下一步引导
  - `提交 / 发布 / 删除 / 撤回 / 下架 / 关闭` 的用户侧后果提示
- 本冻结单不进入：
  - 合同改写
  - 持久化改写
  - 具体接口实现
  - 管理后台模板上传实现
  - 公域项目展示页改造

## 2. 当前冻结结论

- `我的项目` 不再以 `进行中 / 历史项目` 作为当前最高优先级的首层用户分组。
- `我的项目` 当前最高优先级首层结构，正式冻结为顶部四个分栏：
  - `草稿`
  - `已递交`
  - `已发布`
  - `进行中`
- 这四个分栏的正式目标不是“把所有状态名展示出来”，而是：
  - 让用户一眼知道自己现在处于哪一阶段
  - 让用户只看到当前阶段真正应该做的下一步
  - 让用户在点击关键动作之前先知道动作后果
- 当前所有 `我的项目` 用户可见文案必须以简体中文输出，不得把系统内部状态值直接暴露给终端用户。

## 3. 顶部四分栏冻结

### 3.1 分栏顺序

- 顶部四分栏顺序正式冻结为：
  1. `草稿`
  2. `已递交`
  3. `已发布`
  4. `进行中`
- 当前正式禁止：
  - 把 `进行中` 放在第一位并吞并其他阶段
  - 把 `历史项目` 继续当作首层总分栏
  - 把技术状态值直接拿来当用户可见标题

### 3.2 阶段归类

- 以当前合同中的项目状态枚举为基础，用户侧正式归类冻结为：
  - `草稿`
    - 当前仍可继续编辑
    - 当前仍可直接删除
    - 当前尚未进入递交承诺
  - `已递交`
    - 当前已经递交
    - 当前尚未进入公域正式发布
    - 当前不允许直接硬删除
  - `已发布`
    - 当前已经进入公域展示或公开承接阶段
    - 当前尚未进入订单与履约继续处理主面
    - 当前不允许删除
  - `进行中`
    - 当前已经进入授标、订单、合同、履约或其直接后续承接
    - 当前不允许删除
    - 当前只能走业务继续处理或关闭链

### 3.3 历史项目降级

- `历史项目` 现正式降级为：
  - 次级归档视角
  - 只允许作为后续补充分层或筛选条件存在
- `历史项目` 当前不再拥有：
  - `我的项目` 首层导航决定权
  - `我的项目` 阶段心智主入口决定权

## 4. 四阶段动作规则冻结

### 4.1 草稿

- `草稿` 当前正式允许主动作：
  - `继续编辑`
  - `删除此项目`
- `草稿` 当前正式禁止主动作：
  - `下架`
  - `关闭`
  - `进入订单继续处理`

### 4.2 已递交

- `已递交` 当前正式不允许直接硬删除。
- `已递交` 当前应承接的主动作正式冻结为：
  - `查看详情`
  - `撤回到草稿`
  - `作废 / 归档`
- 若 `撤回到草稿` 与 `作废 / 归档` 尚未实现，当前页面必须明确表达“待开放”，不得假装这些动作已经存在，也不得继续把“删除”混充为递交后退路。

### 4.3 已发布

- `已发布` 当前正式不允许删除。
- `已发布` 当前应承接的主动作正式冻结为：
  - `查看详情`
  - `补充资料`
  - `下架 / 关闭`
- `已发布` 当前正式禁止继续展示：
  - `删除此项目`
  - `撤回到草稿`

### 4.4 进行中

- `进行中` 当前正式禁止删除。
- `进行中` 当前正式只允许承接：
  - `进入订单详情`
  - `进入合同详情`
  - `进入履约与验收继续处理`
  - `进入业务关闭链`
- `进行中` 当前正式禁止被表达为：
  - 仍可自由回退的普通草稿
  - 仍可下架的普通已发布项目

## 5. 丝滑化引导规则冻结

### 5.1 列表页

- `我的项目` 列表页顶部必须先给出四分栏，再给出列表内容。
- 每个分栏都必须带一句用户可理解的阶段说明。
- 每张项目卡片必须同时给出：
  - 当前阶段
  - 当前最推荐的下一步
- 当前正式禁止：
  - 在同一张卡片里同时堆出互相冲突的动作
  - 让用户先点进详情页才知道当前能不能删
  - 用笼统的“功能状态”“当前结果”替代具体阶段说明

### 5.2 详情页

- `我的项目` 详情页顶部必须先显示：
  - 已保存的项目基础信息摘要
  - 当前阶段
  - 当前下一步说明
- 详情页中的动作区必须服从所在阶段，不得跨阶段混放。
- 当某项能力尚未开放时，必须明确写成：
  - `当前待开放`
  - 或 `当前仅支持查看`
- 当前正式禁止：
  - 让按钮消失但不给原因
  - 让用户通过报错提示才知道规则

### 5.3 关键动作后果提示

- 用户在点击 `提交` 前，必须被明确提示：
  - 提交后项目将进入 `已递交`
  - 递交后不能直接删除
  - 如需回退，应走 `撤回到草稿`
- 用户在点击 `发布` 前，必须被明确提示：
  - 发布后项目将进入 `已发布`
  - 发布后不能删除
  - 后续如需退出公域，应走 `下架 / 关闭`
- 用户在点击 `删除` 前，必须被明确提示：
  - 只有草稿可以删除
  - 删除后不可恢复

## 6. 现状与过时口径处理

### 6.1 当前可直接沿用

- 当前下列规则仍可直接沿用：
  - `草稿可删除`
  - `已发布后的资料补充走廊`
  - `进入订单后只能走订单与履约承接`
- 当前下列资产仍可直接沿用：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/bff/src/routes/my_project/my-project.service.ts`
  - `apps/server/src/modules/project/project-write.service.ts`
  - `apps/server/src/modules/my_project/my-project.presenter.ts`

### 6.2 正式降级的旧口径

- 以下旧口径现正式降级为历史基线，不再拥有当前用户侧首层分组决定权：
  - `docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md`
    中关于 `进行中 / 历史项目` 的首层分组条款
  - `docs/00_ssot/my_project_entry_and_single_project_private_carry_frontend_consumption_freeze_addendum.md`
    中关于双分组列表的首层消费条款
- 当前实现文件
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
  中把 `historicalProjects` 直接表达为 `已正式完结项目` 的用户侧文案，
  现正式降级为过时载体文案，不再代表当前正式口径。

## 7. 优先级

- 在 `我的项目` 的用户侧阶段分组、动作分配、后果提示、弱理解用户引导四个问题上，当前唯一最高优先级文书固定为：
  - `docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md`
- 如与更早的双分组冻结口径冲突，以本冻结单为准。
- 如与当前代码实现冲突，以本冻结单作为后续修正方向，代码实现本身不反向成为真源。
