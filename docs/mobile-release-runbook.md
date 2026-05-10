# Mobile Release Runbook

This runbook defines the manual pre-commit release sequence for the mobile app.

It connects these gates:

- `docs/mobile-release-versioning-sop.md`
- `packages/tooling/mobile_version_preflight_check.sh`
- `packages/tooling/mobile_release_commit_guard.sh`
- `.github/workflows/mobile-release-gate.yml`

Current stage does not do:

- automatic version bump
- automatic tag creation
- automatic push
- App Store, TestFlight, or Play Console upload
- Git hook installation
- push, pull_request, or merge automatic trigger

## 1. 使用场景

Use this runbook before a formal mobile release version commit.

Applicable scenarios:

- preparing for TestFlight
- preparing for App Store
- preparing for Play Internal
- preparing for Play Production
- mobile hotfix release
- mobile patch release
- mobile minor release
- mobile major release

Not applicable scenarios:

- daily local development
- ordinary feature commit
- ordinary push or merge
- BFF or Server cloud release
- workflow-only, tooling-only, or document-only changes

## 2. 执行前条件

Before starting:

1. Read `docs/mobile-release-versioning-sop.md`.
2. Confirm the intended target version, for example `1.0.1+2`.
3. Confirm the previous formal mobile build number.
4. Confirm the release commit must include only `apps/mobile/pubspec.yaml`.
5. Confirm these gates exist:

```text
packages/tooling/mobile_version_preflight_check.sh
packages/tooling/mobile_release_commit_guard.sh
.github/workflows/mobile-release-gate.yml
```

6. Check the worktree:

```bash
git status --short
```

If unrelated dirty files exist, they must stay outside the release commit.

## 3. 人工 bump 步骤

Only edit:

```text
apps/mobile/pubspec.yaml
```

Only change the mobile version field:

```yaml
version: x.y.z+n
```

Version examples:

- patch release: `1.0.0+1` -> `1.0.1+2`
- minor release: `1.0.1+2` -> `1.1.0+3`
- major release: `1.1.0+3` -> `2.0.0+4`
- rebuild with same App version: `1.0.1+2` -> `1.0.1+3`

Do not edit Android or iOS project files for this release version commit.

## 4. 本地检查步骤

Run the mobile version preflight:

```bash
bash packages/tooling/mobile_version_preflight_check.sh
```

Expected checks:

- `apps/mobile/pubspec.yaml` uses `version: x.y.z+n`.
- build number is greater than `0`.
- Android reads `flutter.versionName`.
- Android reads `flutter.versionCode`.
- iOS `CFBundleShortVersionString` reads `$(FLUTTER_BUILD_NAME)`.
- iOS `CFBundleVersion` reads `$(FLUTTER_BUILD_NUMBER)`.
- static Xcode `CURRENT_PROJECT_VERSION` / `MARKETING_VERSION` entries are reported as WARN only.

Review the diff:

```bash
git diff -- apps/mobile/pubspec.yaml
git status --short
```

## 5. Release Commit 检查步骤

Stage the only allowed file:

```bash
git add apps/mobile/pubspec.yaml
```

Run the release commit guard:

```bash
bash packages/tooling/mobile_release_commit_guard.sh
```

The guard must pass before creating the release commit.

The release commit must include only:

```text
apps/mobile/pubspec.yaml
```

Commit message format:

```bash
git commit -m "chore(mobile): bump version to 1.0.1+2"
```

Do not include workflow, tooling, docs, business code, cloud env, runtime, artifact, or test failure files in this commit.

## 6. GitHub Mobile Release Gate 触发步骤

After the release commit exists, manually trigger GitHub Actions:

```text
Mobile Release Gate
```

Use `Run workflow` and provide:

- `app_version`: for example `1.0.1`
- `build_number`: for example `2`
- `platform`: `ios`, `android`, or `both`
- `release_channel`: `internal`, `testflight`, `play-internal`, or `production-dry-run`
- `confirm_no_auto_bump`: `YES`

The workflow must confirm:

- input version equals `apps/mobile/pubspec.yaml`
- `packages/tooling/mobile_version_preflight_check.sh` passes
- no automatic version bump
- no Git tag creation
- no git push
- no Flutter build
- no App Store, TestFlight, or Play Console upload
- no `pubspec.yaml` changes
- no Android or iOS project file changes

## 7. 失败处理

Stop immediately if any gate fails.

Preflight failure:

- Fix `apps/mobile/pubspec.yaml` if the version format or build number is invalid.
- Stop if Android or iOS no longer derives version values from Flutter.
- Treat static Xcode version entries as known WARN only unless a separate project-file fix is approved.

Release commit guard failure:

- Inspect staged files.
- Unstage any file that is not `apps/mobile/pubspec.yaml`.
- Do not commit until the guard passes.

GitHub Mobile Release Gate failure:

- Compare workflow inputs with `apps/mobile/pubspec.yaml`.
- Re-run only after the mismatch is resolved.
- Do not treat a failed gate as release-ready.

Blocked dirty files:

- They may remain in the worktree only if they are not staged for the release commit.
- They must not enter the release commit.

## 8. 禁止事项

Do not:

- auto bump the version
- auto create tags
- auto push
- upload to App Store, TestFlight, or Play Console
- install or modify Git hooks
- add push, pull_request, tag, release, or merge automatic triggers
- include business code in the release version commit
- include `infra/env/**`
- include `docs/**`
- include `.github/workflows/**`
- include `packages/tooling/**`
- include `apps/mobile/test/failures/**`
- include `runtime/**`
- include `artifacts/**`
- include Android project files
- include iOS project files

## 9. 回滚方式

If the version change is not committed yet:

```bash
git diff -- apps/mobile/pubspec.yaml
```

Manually restore the previous `version:` value.

If the release version commit already exists:

```bash
git revert <release-commit>
```

Do not use `git reset` unless the branch is local-only, unshared, and the owner explicitly approves that exact operation.

## 10. 后续扩展位

Future extensions must be separately approved:

- release notes template
- mobile tag naming, for example `mobile-v1.0.1+2`
- GitHub Actions artifact build
- TestFlight upload workflow
- Play Internal upload workflow
- App Store or Play Console production workflow
- real-device smoke receipt
- rollback and hotfix SOP
- GitHub Release draft workflow
