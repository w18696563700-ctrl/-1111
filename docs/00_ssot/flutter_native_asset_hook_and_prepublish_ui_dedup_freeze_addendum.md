# Flutter native asset hook 与预发布页 UI 去重冻结 addendum

状态：本轮冻结

## 1. 本轮最小闭环

本轮只处理两类问题：

1. 本地 Flutter `Invalid SDK hash / native asset hook` 环境阻塞。
2. `预发布补资料并发布页` 的三个展示层问题：
   - 底部固定 CTA 悬浮遮挡和重复。
   - 发布进度卡下方说明文字与诚意金明细重复。
   - 绿色通道二选一在主卡和规则展开区重复出现。

本轮不改变发布状态机、上传三步流、诚意金后端规则、BFF / Server / OpenAPI / contracts / 数据库。

## 2. 环境修复范围

当前 `Invalid SDK hash` 定位在本地生成缓存：

`apps/mobile/.dart_tool/hooks_runner/objective_c/**`

允许动作：

- 删除 `apps/mobile/.dart_tool/hooks_runner/objective_c` 本地生成缓存。
- 重新运行 `flutter analyze --no-pub`。
- 重新运行目标 Flutter tests。
- 重新运行 Flutter App 以生成截图。

不允许动作：

- 不删除源码。
- 不删除 pub cache。
- 不删除整个 `.dart_tool`，除非本轮再次确认并升级范围。
- 不运行 `flutter pub get`，除非后续明确确认需要。
- 不改 BFF / Server / contracts。

说明：`.dart_tool/hooks_runner/objective_c` 是 Flutter native asset hook 的生成缓存。删除属于本地文件删除动作，执行前必须动作时确认。

## 3. UI 去重范围

### 3.1 底部固定 CTA

来源：

- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `bottomPinnedBuilder: _buildBottomPublishCta`

本轮规则：

- 仅在 `预发布补资料并发布页` 隐藏底部固定 CTA。
- 页面内仍保留真实操作入口：
  - 添加资料
  - 刷新状态
  - 支持 / 暂不支持项目真实性诚意金机制
  - 确认并发布
  - 返回草稿继续编辑
  - 作废并归档

### 3.2 发布进度说明

来源：

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart`
- `_ProjectPublishProgressCard`

本轮规则：

- 在 `预发布补资料并发布页` 调用进度组件时，只展示 5 步进度条。
- 不展示进度说明卡。
- 不展示进度区内的诚意金明细。
- 通过参数控制，仅影响本页，不全局删除共享组件能力。

### 3.3 绿色通道二选一

来源：

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_detail_prepublish_workbench_support.dart`
- 主卡内 `_SincerityFreezeFeedbackStrip`
- 规则展开区 `_SincerityRuleDetails`

本轮规则：

- 保留主卡内唯一的二选一入口：
  - 支持项目真实性诚意金机制
  - 暂不支持项目真实性诚意金机制
- 规则展开区不再重复显示二选一按钮。
- 规则展开区仍保留：
  - 当前状态
  - 金额归属
  - 当前说明
  - 内测说明
  - 刷新状态
  - 诚意金红字规则说明

## 4. 验收标准

- `flutter analyze --no-pub` 通过。
- 目标 Flutter tests 不再因 `Invalid SDK hash` 阻塞。
- 截图显示底部不再被固定大 CTA 遮挡。
- 发布进度区不再显示大段说明文字和诚意金明细。
- 绿色通道二选一只出现一次。
- 不删除现有真实功能。
- 云端只读 health 可回读；若不可用，只标记未验证，不伪装通过。

## 5. 不做事项

本轮不做：

- 不改 BFF。
- 不改 Server。
- 不改 OpenAPI / contracts。
- 不改数据库。
- 不改状态机。
- 不改上传三步流。
- 不改诚意金后端支付 / 冻结 / 退款规则。
- 不部署、不重启云端服务。
- 不清理非本轮 dirty files。

## 6. 风险说明

- 当前仓库已有大量非本轮 dirty files，验收时必须区分本轮改动与既有改动。
- 如果删除 `objective_c` hook 缓存后仍出现 `Invalid SDK hash`，需要另行确认是否扩大清理到更大的 `.dart_tool` 生成缓存范围。
- 当前 Server 仍可能保留诚意金真实支付门禁；本轮只处理 Flutter 展示层，不声称后端规则已变化。
