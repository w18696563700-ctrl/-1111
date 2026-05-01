---
owner: Codex 总控
status: frozen
purpose: Record the Stage 4 remediation and recheck decision for Project Communication Notification And Preview Capability Pack V1.
layer: L0 SSOT
---

# Project Communication Notification And Preview Capability Pack V1 Stage 4 Remediation Recheck Addendum

## A. 一句话结论

Stage 4 prerequisite remediation is complete enough to enter a degraded
implementation path.

This is not a real system-push closeout. APNs/FCM credential evidence and
true-device notification UAT remain blocked. The allowed implementation scope is
limited to notification truth, device-token route shape, push outbox/noop
adapter or adapter-mock, bounded notification center, controlled file preview,
and confirmation-card softLink.

## B. 当前阶段

Stage 4 prerequisite remediation and recheck.

## C. 本轮目标

Remove the implementation blockers recorded in:

- `docs/00_ssot/project_communication_notification_preview_v1_stage4_prerequisite_nogo_addendum.md`

without modifying active cloud runtime, without touching unrelated dirty cloud
changes, and without claiming real APNs/FCM push readiness.

## D. 已完成项

### Clean Cloud Implementation Workspace

A package-specific cloud worktree now exists:

- Worktree:
  - `/srv/worktrees/project-communication-notification-preview-v1`
- Branch:
  - `codex/project-communication-notification-preview-v1`
- Base head observed:
  - `e1de046`
- Worktree status:
  - clean at creation and recheck

The previous dirty cloud workspace remains untouched:

- `/srv/git/exhibition-infra-monorepo`
- Its unrelated dirty changes are not used as the implementation surface for
  this package.

### Branch Strategy

All Server and BFF implementation work for this package must happen in:

- `/srv/worktrees/project-communication-notification-preview-v1`
- branch `codex/project-communication-notification-preview-v1`

The original dirty workspace must be treated as read-only evidence only for
this package until separately governed.

### Change-Return Mechanism

Because the cloud repository has no visible remote, the formal return mechanism
for this package is `patch bundle`.

Patch evidence root:

- `/srv/patches/project-communication-notification-preview-v1`

Required package-return procedure after any cloud implementation slice:

```bash
cd /srv/worktrees/project-communication-notification-preview-v1
git status --short > /srv/patches/project-communication-notification-preview-v1/<run-id>.status.txt
git diff --binary HEAD > /srv/patches/project-communication-notification-preview-v1/<run-id>.diff
git diff --stat HEAD > /srv/patches/project-communication-notification-preview-v1/<run-id>.stat.txt
git bundle create /srv/patches/project-communication-notification-preview-v1/<run-id>.bundle HEAD codex/project-communication-notification-preview-v1
```

Local integration must use:

```bash
scp root@47.108.180.198:/srv/patches/project-communication-notification-preview-v1/<run-id>.* <local-evidence-dir>/
git apply --check <local-evidence-dir>/<run-id>.diff
```

Only after `git apply --check` passes may the patch be applied locally for
formal repository integration. Passwords must not be recorded in any document,
log, command transcript, or receipt.

### Current-Round Cloud Implementation Procedure

Cloud implementation is allowed only in the isolated worktree above.

Allowed during Day2-Day9 degraded implementation:

- edit Server code in the isolated cloud worktree
- edit BFF code in the isolated cloud worktree
- run targeted Server/BFF build and tests in the isolated cloud worktree
- produce patch bundle evidence
- keep active runtime unchanged until a later integration/release gate

Blocked until later explicit release gate:

- switching `/srv/apps/server/current`
- switching `/srv/apps/bff/current`
- restarting `exhibition-server`
- restarting `exhibition-bff`
- running production migrations
- claiming cloud runtime alignment
- claiming real APNs/FCM push UAT

### Cloud Runtime Baseline Rechecked

No active runtime mutation was performed by this remediation. Final read-only
recheck observed that another cloud runtime alignment has occurred outside this
package after the earlier No-Go receipt. The active runtime is healthy, but the
release/current target is now:

- Server current:
  - `/srv/releases/server/20260501032743-membership-read-surface-cleanup`
- BFF current:
  - `/srv/releases/bff/20260501032743-membership-read-surface-cleanup/apps/bff`
- Services:
  - `exhibition-server`: active
  - `exhibition-bff`: active
  - `nginx`: active
- 8080 health smoke:
  - `/health/bff/live`: 200
  - `/health/bff/ready`: 200
  - `/health/server/live`: 200
  - `/health/server/ready`: 200

This runtime drift does not invalidate the isolated implementation worktree,
but it means any later release/UAT stage must record a fresh rollback target
before changing `current`.

## E. 未完成项

The following are intentionally not fixed because no credential or true-device
evidence exists:

1. APNs credential availability.
2. FCM credential availability.
3. True-device real push UAT.
4. Real sound / vibration / lock-screen notification delivery acceptance.

These are not silently waived. They are converted into a formal degraded-path
boundary for this package.

## F. 风险/冲突

### Remaining Blocked Claims

- Do not claim real iOS push.
- Do not claim real Android push.
- Do not claim sound / vibration / lock-screen notification acceptance.
- Do not claim true-device notification UAT.
- Do not claim production release alignment.
- Do not reuse the earlier `20260501013500-project-conversation-workbench-v1`
  active-runtime target as a rollback target without fresh readlink evidence.

### Controlled Degraded Path

The implementation may close:

- Server-owned notification truth.
- Server-owned unread / mark-read truth for notification-center items.
- Device-token registration route shape and storage.
- Push delivery outbox / attempts.
- Noop adapter or adapter-mock behavior when APNs/FCM credentials are absent.
- BFF notification forwarding and error mapping.
- Flutter bounded notification-center UI.
- Controlled file preview.
- Confirmation-card softLink.

Real provider delivery must remain a later credential-and-device gate.

## G. 证据清单

Cloud remediation evidence:

- `git worktree add -b codex/project-communication-notification-preview-v1 /srv/worktrees/project-communication-notification-preview-v1 <base-head>`
- `/srv/worktrees/project-communication-notification-preview-v1`
  - branch: `codex/project-communication-notification-preview-v1`
  - head: `e1de046`
  - `git status --short`: empty
- `/srv/patches/project-communication-notification-preview-v1`
  - patch-bundle evidence root created

Cloud runtime evidence:

- `readlink -f /srv/apps/server/current`
  - `/srv/releases/server/20260501032743-membership-read-surface-cleanup`
- `readlink -f /srv/apps/bff/current`
  - `/srv/releases/bff/20260501032743-membership-read-surface-cleanup/apps/bff`
- `systemctl is-active exhibition-server exhibition-bff nginx`
  - all active
- `curl http://127.0.0.1:8080/health/bff/live`
  - 200
- `curl http://127.0.0.1:8080/health/bff/ready`
  - 200
- `curl http://127.0.0.1:8080/health/server/live`
  - 200
- `curl http://127.0.0.1:8080/health/server/ready`
  - 200

Tooling evidence in isolated worktree:

- Server package scripts visible:
  - `build`
  - `start`
  - `start:dev`
  - `start:prod`
  - `test:upload-transport`
- BFF package scripts visible:
  - `build`
  - `start`
  - `start:dev`
  - `start:prod`

## H. 是否通过本阶段门禁

Yes, with degradation.

Stage 4 passes only for degraded implementation.

## I. 下一步建议

Allowed next stage:

- Day2-Day9 degraded implementation.

Implementation boundaries:

- Server/BFF implementation must happen in the isolated cloud worktree.
- Flutter implementation remains local only.
- BFF must remain forwarding/shaping/error mapping only.
- Server remains notification, unread, preview-permission, delivery-attempt, and
  softLink truth owner.
- Push provider delivery must use a noop/adapter-mock path until APNs/FCM
  credentials are provided.
- Release/current switching remains blocked until the later integration/release
  gate.

## J. Go / No-Go 裁决

`Go for Day2-Day9 degraded implementation`.

Still `No-Go` for:

- real APNs/FCM push UAT
- real sound / vibration / lock-screen notification acceptance
- production release/current switching
- cloud runtime mutation
- claiming implementation as released
