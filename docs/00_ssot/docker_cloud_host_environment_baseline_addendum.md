---
owner: Codex 总控
status: draft
purpose: Freeze the minimum formal baseline for Docker installation, Docker Compose availability, and container-ready cloud host posture without forcing an immediate full containerized runtime migration.
layer: L0 SSOT
---

# Docker 云主机环境基线补充单

## 1. Scope
- This addendum freezes the minimum formal baseline for:
  - Docker installation on the cloud host
  - Docker Compose availability on the cloud host
  - container-ready host posture for infra dependencies and future runtime evolution
  - the boundary between current runtime reality and future containerization
- It does not by itself freeze:
  - a mandatory full Docker runtime for `BFF`
  - a mandatory full Docker runtime for `Server`
  - Kubernetes
  - CI/CD implementation
  - deployment commands or cloud shell procedures

## 2. Current Reality And Frozen Truth

### 2.1 Frozen project stack and cloud shape
- The frozen stack already includes:
  - PostgreSQL
  - Redis
  - S3-compatible OSS
  - Nginx
- The frozen cloud shape remains:
  - one host
  - two processes
  - two ports
  - Nginx in front

### 2.2 Current repo assets already present
- The repo already contains Docker-related baseline assets:
  - `infra/docker-compose.yml`
  - `infra/scripts/bootstrap_cloud_host.sh`
  - `infra/scripts/smoke.sh`
- Therefore Docker is not a new concept in this repo; it is an already-present
  baseline that has not been enforced consistently on the active cloud host.

### 2.3 Current runtime reality
- The currently scanned cloud runtime may still run as:
  - `systemd`
  - `node`
  - `nginx`
  - `postgresql`
  - `redis`
  - `minio`
- That runtime is acceptable as the current active reality.
- But the absence of Docker on the cloud host is treated as an environment
  baseline gap.

## 3. Total-control Ruling
- Docker installation on the formal cloud host is now classified as:
  - high-priority environment baseline work
- It is not yet classified as:
  - a veto gate for the current identity-permission backend truth round
- Therefore:
  - identity and permission truth implementation may continue
  - Docker host-baseline work must run as a parallel environment-hardening track
  - no team may quietly ignore this gap as “optional forever”

## 4. Canonical Decisions

### 4.1 Docker installation baseline
- The formal cloud host must have:
  - Docker Engine installed
  - Docker Compose plugin available
  - Docker service enabled
  - Docker service startable and inspectable
- The baseline is satisfied only when the host can prove:
  - `docker --version`
  - `docker compose version`
  - `docker info`
  - service status visibility

### 4.2 Current-round runtime boundary
- Installing Docker does not mean the current `Server` and `BFF` runtime must
  immediately move into containers.
- The current approved runtime may remain:
  - `systemd`-managed `Server`
  - `systemd`-managed `BFF`
  - `nginx` in front
- A future move of `Server` or `BFF` into containers requires its own frozen
  truth and rollout plan.

### 4.3 Infra-dependency boundary
- Docker readiness is especially important for:
  - local or cloud dependency parity
  - optional containerized infra services such as:
    - PostgreSQL
    - Redis
    - MinIO
- Docker installation allows the cloud host to execute the repo’s existing
  container-oriented smoke and bootstrap baselines without forcing immediate
  app-runtime containerization.

### 4.4 No hidden deployment drift rule
- Docker must not be introduced by stealth in one environment only.
- If the cloud host becomes Docker-ready, that readiness must be formally
  recorded.
- If Docker is later used to carry runtime services, that change requires:
  - new release truth
  - new rollback truth
  - new verification evidence

## 5. Current Minimum Acceptance Standard
- The Docker cloud-host baseline is considered complete only when all of the
  following are true:
  - Docker Engine is installed
  - Docker Compose plugin is installed
  - Docker service is enabled and startable
  - the host can run `docker compose` against `infra/docker-compose.yml`
  - the repo smoke path no longer fails purely because Docker is absent
- This acceptance standard is for host readiness only.
- It does not require current `Server` and `BFF` to be containerized.

## 6. Current Non-goals
- no immediate `Server` container migration
- no immediate `BFF` container migration
- no Nginx container migration
- no production data move caused only by Docker installation
- no secret or credential record in formal docs
- no forced runtime-port redesign

## 7. Risk Freeze
- If Docker stays absent on the formal cloud host:
  - infra parity remains weak
  - repo bootstrap and smoke scripts remain partially unusable
  - future environment migration cost rises
  - disaster recovery and environment rebuild speed degrade
- If Docker is installed but silently used to change runtime topology:
  - release truth drift occurs
  - rollback truth drift occurs
  - verification evidence becomes ambiguous

## 8. Work-split Freeze
- Docker host-baseline work belongs to:
  - environment / release / runtime hardening track
- It does not belong to:
  - frontend feature track
  - BFF route-semantics track
  - backend business-truth track
- Backend Agent may report Docker absence as risk.
- Total control must schedule Docker readiness as a dedicated environment task.

## 9. Dispatch Conclusion
- Docker installation on the formal cloud host is now an approved parallel task.
- The approved target is:
  - install Docker
  - install Docker Compose plugin
  - make the host container-ready
  - keep current `Server` and `BFF` runtime unchanged unless separately frozen
- This addendum is sufficient to justify a dedicated cloud environment dispatch.
