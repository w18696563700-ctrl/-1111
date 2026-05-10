# Mobile Release Versioning SOP

## 1. 版本真源

移动端版本唯一真源是：

```text
apps/mobile/pubspec.yaml
version: x.y.z+n
```

- `x.y.z` 是 App version。
- `n` 是 build number。
- Android `versionName` / `versionCode` 和 iOS `CFBundleShortVersionString` / `CFBundleVersion` 必须从 Flutter build name / build number 派生。
- 不以 Android 工程、iOS 工程、Git tag、CI run number、release artifact 或商店后台记录作为当前阶段的版本真源。

## 2. 人工 bump 触发时机

只在准备正式移动端发布前人工 bump。

适用场景：

- 准备 TestFlight、App Store、Play Internal 或 Play Production 前。
- 上一次发布包已经生成，下一次正式包需要新的 build number。
- 商店拒绝重复 build number，需要重新出包。
- hotfix、patch、minor、major 发布前。

不适用场景：

- 日常本地开发。
- 普通 push 或 merge。
- 普通业务功能提交。
- 云端 BFF 或 Server 发布。
- 只调整 workflow、脚本或文档门禁。

## 3. 允许修改的文件

人工 bump release commit 只允许修改：

```text
apps/mobile/pubspec.yaml
```

且只允许修改其中的：

```yaml
version: x.y.z+n
```

## 4. 禁止混入的文件

release commit 禁止混入：

- Flutter 业务代码。
- Flutter 测试失败快照或临时文件。
- Android 工程文件。
- iOS 工程文件。
- `.github/workflows/**`。
- `packages/tooling/**`。
- `apps/bff/**`。
- `apps/server/**`。
- `apps/admin/**`。
- `docs/**`。
- `infra/env/**`。
- `.tmp/**`。
- `artifacts/**`。
- `runtime/**`。

重点禁止混入：

- `infra/env/formal_cloud_target.env`
- `apps/mobile/test/failures/`
- 任何云端环境文件。
- 任何业务修复代码。

## 5. 版本号规则

版本格式必须是：

```text
x.y.z+n
```

规则：

- `x` = major。
- `y` = minor。
- `z` = patch。
- `n` = build number。
- build number 每次正式发布必须递增。
- build number 不允许归零。
- build number 不允许复用。
- Android `versionCode` 和 iOS `CFBundleVersion` 必须来自同一个 build number。

示例：

- patch 发布：`1.0.0+1` -> `1.0.1+2`
- minor 发布：`1.0.1+2` -> `1.1.0+3`
- major 发布：`1.1.0+3` -> `2.0.0+4`

仅重新出包但 App version 不变时，build number 仍必须递增：

```text
1.0.1+2 -> 1.0.1+3
```

## 6. Release Commit 规则

commit message 使用：

```text
chore(mobile): bump version to 1.0.1+2
```

commit 内容规则：

- 只允许包含 `apps/mobile/pubspec.yaml`。
- 不允许包含业务代码。
- 不允许包含测试失败文件。
- 不允许包含云端环境文件。
- 不允许包含 workflow 或 tooling 改动。
- 不允许顺手格式化其他文件。

提交前必须检查：

```bash
git diff -- apps/mobile/pubspec.yaml
git status --short
```

## 7. 发布前检查顺序

1. 检查当前工作区：

```bash
git status --short
```

2. 确认没有无关脏改进入 release commit。

3. 只修改：

```text
apps/mobile/pubspec.yaml
```

4. 执行移动端版本预检：

```bash
bash packages/tooling/mobile_version_preflight_check.sh
```

5. 确认 preflight 通过，且 Xcode 静态 `CURRENT_PROJECT_VERSION` / `MARKETING_VERSION` 只属于已知 WARN。

6. 创建 release commit，且只包含：

```text
apps/mobile/pubspec.yaml
```

7. 手动触发 GitHub Actions `Mobile Release Gate`。

8. 输入与 `pubspec.yaml` 完全一致的：

- `app_version`
- `build_number`
- `platform`
- `release_channel`
- `confirm_no_auto_bump = YES`

9. `Mobile Release Gate` 通过后，才允许进入构建或真实 release 方案。

## 8. 失败条件

出现以下任一情况，必须停止：

- `apps/mobile/pubspec.yaml` 中的版本号不是 `x.y.z+n`。
- build number 小于等于 `0`。
- 正式发布时 build number 没有比上一次正式发布递增。
- release commit 混入除 `apps/mobile/pubspec.yaml` 以外的文件。
- Android 没有读取 `flutter.versionName` / `flutter.versionCode`。
- iOS 没有读取 `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`。
- `Mobile Release Gate` 输入与 `pubspec.yaml` 不一致。
- `confirm_no_auto_bump` 不是 `YES`。
- 工作区存在未解释的脏改并准备混入 release commit。

## 9. 通过条件

必须同时满足：

- `apps/mobile/pubspec.yaml` 是 release commit 的唯一修改文件。
- `version: x.y.z+n` 格式合法。
- build number 大于 `0`。
- 正式发布时 build number 已递增。
- `mobile_version_preflight_check.sh` 通过。
- `Mobile Release Gate` 通过。
- 没有自动 bump。
- 没有自动 tag。
- 没有自动上传。
- 没有接入 push 或 merge 自动触发。

## 10. 为什么当前不创建 tag

当前阶段不创建 tag，原因：

- 现在只是建立人工版本门禁和版本规则。
- 尚未形成正式 release artifact。
- 尚未完成商店上传。
- 尚未完成真机验收。
- 尚未冻结 rollback 点。

过早创建 tag 会制造发布事实假象，导致版本、构建产物和实际商店状态不一致。

## 11. 为什么当前不接入自动 bump

当前阶段不接入自动 bump，原因：

- 版本号仍需要人工判断 patch、minor、major。
- build number 递增规则尚未和商店上传、tag、release commit、rollback 策略完全闭合。
- 自动 bump 容易和 dirty worktree、并行功能分支、手动 release 门禁产生漂移。
- 当前最稳路径是人工 bump + 手动 preflight + 手动 release gate。

## 12. 回滚方式

如果版本号修改尚未提交：

```bash
git diff -- apps/mobile/pubspec.yaml
```

人工改回原 `version:` 即可。

如果已经形成 release commit：

```bash
git revert <release-commit>
```

除非明确处在未共享本地分支且获得批准，否则不使用 `git reset` 回滚。

## 13. 后续扩展位

后续可单独设计并审批：

- release commit 检查脚本，确保只包含 `apps/mobile/pubspec.yaml`。
- tag 命名规则，例如 `mobile-v1.0.1+2`。
- GitHub Actions artifact 构建，但仍不自动上传商店。
- TestFlight / Play Internal 上传 workflow。
- App Store / Play Console 正式发布流程。
- release notes 生成。
- 真机 smoke receipt。
- rollback / hotfix 规则。
