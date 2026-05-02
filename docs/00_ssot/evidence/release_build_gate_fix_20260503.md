---
owner: Codex 总控
status: receipt
layer: release build gate
recorded_at_local: 2026-05-03
scope: Phase A.3 release build blocker repair only
---

# Release Build Gate Fix 20260503

## Conclusion

This receipt freezes the release build repair boundary after Phase A.3 stopped
before deployment.

No deployment, migration, current symlink switch, service restart, payment
callback, or material-review write smoke is authorized by this receipt.

## Release Source Rule

Release source remains:

- `origin/main`
- exact commit must be verified before every release candidate build
- current working branches such as `codex/1` or local untracked files must not be
  copied into cloud release directories

## Fixed Build Blockers

### BFF Runtime Source

The BFF runtime guard source lives under:

- `apps/bff/src/core/runtime/runtime-config.service.ts`
- `apps/bff/src/core/runtime/runtime-startup.guard.ts`

The root `.gitignore` keeps generic `runtime/` directories local-only, but now
explicitly allows this BFF source directory. These two files are production
source files and must be tracked by Git.

### BFF Contracts During Release Build

The BFF imports generated contracts through the monorepo relative path:

- `packages/contracts/src/generated/*`

Therefore BFF release builds must be run from a full source staging tree that
contains both `apps/bff` and `packages/contracts`. Building only from the copied
module directory can resolve stale `/srv/releases/packages` content and fail
with outdated error-code types.

Required Phase A.3 build order for BFF:

1. Extract the verified `origin/main` archive to a source staging directory.
2. Build from `source/apps/bff`.
3. Copy the built BFF package into the new `/srv/releases/bff/<release-id>`
   directory only after the build succeeds.

### Admin Release Build

Admin release builds use:

```bash
npm run build
```

The script now calls:

```bash
next build --webpack
```

This avoids the Next/Turbopack release-directory failure where
`node_modules` is a symlink pointing outside the app filesystem root. The
existing `with-formal-cloud-env.cjs` wrapper remains the source of formal cloud
target environment loading.

## Re-entry Criteria For Phase A.3

Phase A.3 may be retried only after:

- `origin/main` contains the tracked BFF runtime source files.
- Server, BFF, and Admin builds pass from the verified release source.
- `packages/contracts/src/generated/error-codes.ts` includes the Forum
  interaction error codes used by BFF.
- No current symlink has been changed.
- No migration has been executed.
