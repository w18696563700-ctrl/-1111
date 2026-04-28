---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day5 regression-verification and delivery receipt for the
  owner-facing exhibition project edit review flow after the bounded Flutter
  restructuring work of Day2-Day4, including targeted analyze/test evidence,
  macOS hand-test evidence, screenshot-level surface verification, and the
  current delivery decision.
layer: L0 SSOT
freeze_date_local: 2026-04-28
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_edit_page_review_flow_day1_truth_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_edit_surface_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/test/project_showcase_filter_create_refactor_test.dart
  - apps/mobile/test/project_publish_round_a_productization_test.dart
  - apps/mobile/test/project_attachment_corridor_test.dart
  - apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart
  - apps/mobile/test/my_project_private_carry_test.dart
---

# 《编辑项目页 Day5 回归验证与交付回执》

## 0. 总结论

本 Day5 已完成 `Flutter App` 本地回归验证与交付回执冻结。

当前最小闭环：

1. 创建页共享表单未被编辑页重排误伤。
2. 编辑页 `draft` 态的新页头、轻量生命周期卡、当前内容核对区已可见。
3. 预发布详情页的报价依据资料区与正式发布确认 authority 仍保留在 `我的项目详情`。
4. `查看我的项目详情` 回流路径成立。

需要保留但暂不开通：

1. 不在本轮手测里触发云上写动作：
   - `保存到预发布列表`
   - `仅保存草稿`
   - `检查无误，确定发布`
   - `返回草稿继续编辑`
   - `作废归档`
   - 附件上传 / 删除
2. 不扩到 BFF / Server / contracts 改动。
3. 不扩到全量壳层回归、golden、像素级截图测试。

后续扩展位：

1. 若要进入 Day6+ UAT，可增加 `submitted -> edit -> bottom return to prepublish detail` 的受控真人链路演练。
2. 若要进入更高强度回归，可补 `exhibition_mainline_flow_test.dart` 主链级用例。
3. 若要进入发布前 gate，可单开“云上真实附件写链路 + 预发布返回草稿”受控验证。

判断：

- 更稳：当前这轮只做 Flutter 本地验证，不碰 BFF / Server truth。
- 更省成本：优先跑 targeted analyze/test + 只读手测，不做全量重跑。
- 更适合当前阶段：先证明页面重排、报价资料区和回流路径没有断。
- 风险更大：在未单独授权的情况下直接触发云上状态写入或附件写链路。

## 1. Scope

本回执只覆盖：

1. `apps/mobile` targeted analyze。
2. 创建页、编辑页、报价依据资料区、回流路径的 targeted widget tests。
3. macOS 本地手测与截图级表面核对。
4. 交付判断与阶段门禁结论。

本回执不覆盖：

1. BFF / Server / DB / OSS 运行时改动。
2. 云上状态写入结果验收。
3. 附件真实上传结果验收。
4. 发布上线审批。

## 2. 阶段门禁核查表

### 2.1 passed gates

1. Flutter bounded scope gate：
   - 当前只验证 `apps/mobile`，未越权进入 BFF / Server。
2. Day1 truth alignment gate：
   - 验证对象与 `project_edit_page_review_flow_day1_truth_freeze_addendum.md` 对齐。
3. local analyze gate：
   - 相关文件 targeted analyze 通过。
4. targeted widget regression gate：
   - 创建页、编辑页、报价资料区、回流路径关键测试通过。
5. macOS hand-test gate：
   - 创建页、草稿编辑页、预发布详情页当前表面核对通过。

### 2.2 failed gates

1. 无持久 failed gate。

### 2.3 veto gates

1. 不得把本轮回归偷换成 BFF / Server 改造。
2. 不得在未单独确认的情况下把手测扩大成真实云上状态写入验收。
3. 不得把 `我的项目详情` 的正式发布 authority 迁移到编辑页。

### 2.4 gate decision

当前 Day5 gate decision 固定为：

- `Go for Flutter delivery within the bounded frontend scope`

## 3. 代码层验证回执

### 3.1 analyze

执行命令：

```bash
cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile
flutter analyze --no-pub \
  lib/features/exhibition/presentation/exhibition_trade_pages.dart \
  lib/features/exhibition/presentation/widgets/project_edit_surface_widgets.dart \
  lib/features/exhibition/presentation/pages/project_create_page.dart \
  lib/shell/navigation/app_router.dart \
  test/project_showcase_filter_create_refactor_test.dart \
  test/project_publish_round_a_productization_test.dart \
  test/project_attachment_corridor_test.dart \
  test/project_attachment_prepublish_and_bid_materials_test.dart \
  test/my_project_private_carry_test.dart
```

结果：

- `No issues found!`

### 3.2 widget tests

执行并通过的关键回归：

1. `test/project_showcase_filter_create_refactor_test.dart`
   - 全文件通过
   - 覆盖：
     - 创建页字段表面
     - 编辑页 `draft` 页头 / 生命周期 / 展开态
     - 编辑页 `submitted` 折叠态 / 顶部继续核对 / 底部回流
2. `test/project_publish_round_a_productization_test.dart --plain-name "Round A create page keeps selector, address row, and localized date display"`
3. `test/project_publish_round_a_productization_test.dart --plain-name "Round A province selector opens and confirms a province-city choice"`
4. `test/project_attachment_corridor_test.dart --plain-name "project edit accepts current BFF attachment list shape and keeps document zone compact"`
5. `test/project_attachment_prepublish_and_bid_materials_test.dart --plain-name "submitted my-project detail opens attachment corridor"`
6. `test/my_project_private_carry_test.dart --plain-name "预发布列表详情显示正式发布与回退动作"`

代码层结论：

1. 创建页省市选择器已可打开并确认。
2. 编辑页 `draft` / `submitted` 两态的结构约束成立。
3. 报价依据资料区在编辑页与预发布详情页两端都未丢。
4. 最终发布 authority 仍固定留在 `我的项目详情`。

## 4. macOS 手测与截图核对回执

### 4.1 创建页

手测路径：

- `展览 -> 去发布项目 -> 创建项目`

核对结果：

1. 首屏保留 `展会 / 品牌` 双字段。
2. `明价 / 询价` 双选仍在。
3. 点击 `省` 后可弹出 `选择省 / 市` sheet。
4. 选择并确认后，`北京市 / 北京市` 正常回填，`市` 自动带入。

截图级判断：

- 创建页共享表单结构正常，省市选择不再“点不动”。

### 4.2 编辑页 draft 态

手测路径：

- `我的 -> 我的项目 -> 草稿 -> 继续编辑`

核对结果：

1. 标题为 `编辑项目`，右上状态 badge 显示 `草稿`。
2. `当前生命周期` 卡只保留任务导向文案，不再重复展示一条独立状态行。
3. `当前内容核对` 作为单一核对区存在，并显示摘要：
   - 展会 / 品牌
   - 地点 / 时间
   - 预算 / 面积
4. `draft` 态默认展开，字段值完整回显。
5. 点击 `查看我的项目详情` 后，可回流到 `我的项目详情`。

截图级判断：

- 新页头、轻量生命周期卡、核对区摘要与默认展开规则成立。

### 4.3 预发布详情页

手测路径：

- `我的 -> 我的项目 -> 预发布列表 -> 补资料后确认发布`

核对结果：

1. `我的项目详情` 中仍保留：
   - `检查无误，确定发布`
   - `返回草稿继续编辑`
   - `作废归档`
2. `报价依据资料` 区独立存在。
3. 资料类型 chip 与列表区可见。
4. 正式发布确认 authority 仍在详情页，不在编辑页。

截图级判断：

- 预发布详情页继续承担 authority 面职责，未被编辑页重排抢走。

### 4.4 手测边界说明

本轮手测刻意未触发以下云上写动作：

1. `保存到预发布列表`
2. `仅保存草稿`
3. `检查无误，确定发布`
4. `返回草稿继续编辑`
5. `作废归档`
6. 附件上传 / 删除

原因：

- 当前更稳的做法是把 Day5 保持为 `Flutter 页面回归 + 只读手测`。
- 任何真实云上状态改写都应放到单独授权的受控联调或 UAT gate。

## 5. 交付判断

### 5.1 当前可交付内容

1. `编辑项目` 页顶部状态与轻量生命周期卡。
2. `当前内容核对` 折叠区与摘要头。
3. `draft` 默认展开、`submitted` 默认折叠的代码约束。
4. 顶部 `继续核对当前内容` 与底部回流按钮的代码级闭环。
5. 创建页省市选择器恢复可用。
6. 预发布详情页 authority 与报价依据资料区保留不变。

### 5.2 当前不纳入本回执的内容

1. 云上状态写结果正确性。
2. 云上附件写链路真实结果正确性。
3. BFF / Server schema / contract 级改动。

## 6. 结论

Day5 当前正式结论固定为：

1. 本轮 Flutter 前端重排改动已达到可交付状态。
2. 关键 analyze 与 targeted widget tests 已通过。
3. macOS 手测已确认创建页、草稿编辑页、预发布详情页的核心表面和回流路径未断。
4. 当前允许把这轮结果作为 `Flutter bounded delivery package` 继续向后推进。
