---
owner: Codex 总控
status: draft
purpose: Freeze the future migration draft for containerizing BFF and Server together as separate runtime units after the current Docker host-baseline and identity rounds are completed.
layer: L0 SSOT
---

# BFF + Server 容器化迁移冻结单（草案）

## 1. Scope
- This file freezes only the future migration draft for:
  - containerizing `BFF`
  - containerizing `Server`
  - keeping them as separate runtime units
  - preserving the current Nginx-in-front topology
- This file does not by itself:
  - authorize immediate container migration
  - replace the current systemd runtime
  - redefine formal host topology
  - unlock current release work

## 2. Current Total-control Ruling
- The current approved order remains:
  1. keep `BFF` Agent and 后端 Agent as two separate execution roles
  2. complete the current identity-permission truth and aggregation work
  3. complete Docker host-baseline work on the formal host
  4. only then evaluate runtime containerization
- Therefore this file is a draft for future migration only.
- It does not change the current blocked or unblocked status of any active task.

## 3. Role Boundary Freeze
- `BFF Agent` and `后端 Agent` remain separate roles permanently.
- If runtime containerization happens later:
  - `BFF` enters containerization as one runtime unit
  - `Server` enters containerization as one runtime unit
- They must not be merged into one image, one process, or one ownership role.

## 4. Canonical Migration Principle
- Future containerization must keep:
  - one host
  - two runtime units
  - two internal app ports
  - Nginx in front
- After migration, the runtime shape should still remain logically:
  - `Nginx`
  - `BFF`
  - `Server`
- Containerization must change packaging and runtime carriage only.
- It must not change:
  - app-facing path semantics
  - truth ownership
  - role boundaries
  - audit obligations

## 5. Runtime-unit Freeze

### 5.1 BFF container
- one image
- one runtime service
- one health contract
- one rollback unit
- no business-truth ownership

### 5.2 Server container
- one image
- one runtime service
- one health contract
- one rollback unit
- the only business-truth owner

### 5.3 Gateway boundary
- Nginx remains the public ingress layer unless separately frozen otherwise.
- Nginx must continue to route:
  - app-facing traffic to `BFF`
  - admin or internal controlled traffic to `Server`

## 6. Dependency Boundary
- This draft does not require that all dependencies move into containers in the
  same round.
- The following may remain host-carried or separately containerized, as long as
  truth and connectivity stay controlled:
  - PostgreSQL
  - Redis
  - MinIO or OSS gateway
- But `BFF` and `Server` containerization must not silently redefine dependency
  truth or storage paths.

## 7. Migration Phases

### Phase A: Docker host baseline
- install Docker Engine
- install Docker Compose plugin
- make formal host container-ready
- keep current `systemd` runtime unchanged

### Phase B: containerization design freeze
- define container images
- define runtime ports
- define volume and secret mounting boundaries
- define health and readiness checks
- define log and trace carriage
- define rollback units

### Phase C: controlled runtime cutover
- cut `BFF` and `Server` to containers as separate runtime units
- preserve current Nginx canonical paths
- preserve current health endpoints
- preserve current release verification order

### Phase D: post-cutover verification
- runtime health
- canonical-path verification
- persistence truth verification
- append-only audit verification
- rollback drill verification

## 8. Hard Rules
- `BFF` and `Server` must be packaged separately.
- `BFF` and `Server` must be released separately even if migrated in one
  coordinated round.
- `BFF` and `Server` must be rollbackable separately, though one incident may
  still require a coordinated rollback.
- No container migration may silently redefine:
  - `GET /api/app/*` canonical paths
  - `Server` truth ownership
  - admin direct-to-server boundary
  - hidden-building exposure rules

## 9. Minimum Acceptance Gate For Future Migration
- The future migration may proceed only when all of the following are true:
  - Docker host baseline is complete on the formal host
  - formal host drift is resolved
  - current identity and core write-chain rounds are not in unstable flux
  - `BFF` image and `Server` image are separately buildable
  - coordinated smoke verification exists for:
    - Nginx -> BFF
    - BFF -> Server
    - health/live and health/ready
    - canonical app-facing paths
    - persistence and audit evidence
  - rollback path for both runtime units is frozen

## 10. Current Non-goals
- no Kubernetes
- no multi-host orchestration
- no service mesh
- no immediate migration in the current round
- no merging `BFF` and `Server` into one deployment unit
- no rewriting current modules just to fit containers

## 11. Dispatch Conclusion
- Future containerization is approved in principle.
- The approved direction is:
  - `BFF` and `Server` should be containerized together in a later migration
    stage
  - but still as two separate runtime units and two separate execution roles
- This remains a draft until:
  - Docker host baseline is completed
  - formal host drift is resolved
  - total control explicitly opens the containerization stage
