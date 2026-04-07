---
owner: Codex 总控
status: frozen
purpose: Freeze the single bounded cloud-only deployment repair package for `Personal minimal edit`, limiting the next action to active cloud runtime alignment on `nginx :80 -> bff :3000 / server :3001` plus cloud object-storage runtime without reopening local runtime or expanding package scope.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_minimal_edit_cloud_runtime_gap_audit_addendum.md
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/server/src/modules/profile/profile.controller.ts
  - apps/server/src/modules/upload/upload-write.service.ts
  - apps/server/src/modules/identity/entities/user.entity.ts
---

# `Personal minimal edit cloud deployment repair` 边界冻结单

## 1. Scope

- 本轮唯一对象只限：
  - `Personal minimal edit`
  - active cloud runtime
  - `nginx :80 -> bff :3000 / server :3001`
  - cloud object-storage runtime
- 本轮唯一目标只限：
  - 让 active cloud runtime 真正承接：
    - `POST /api/app/profile/personal/nickname`
    - `POST /api/app/profile/personal/avatar`
    - `POST /api/app/file/upload/init` with `businessType=profile` and `fileKind=avatar`
  - 让云端对象存储 runtime 为头像上传链提供正式 transport
  - 让昵称与头像链路通过 cloud ingress `:80` 形成 live success proof
- 本轮明确不是：
  - 新功能开发
  - 本地 runtime 修复
  - OCR
  - 实名
  - 公司 / 认证包
  - 审核系统
  - 全平台部署重构

## 2. Current Accepted Baseline

- 当前 repo 源码已经具备 `Personal minimal edit` 所需 bounded source implementation。
- 当前 active cloud runtime 失败并非源码缺口，而是运行态未部署到当前 repo 版本。
- 当前 cloud ingress 仍固定为：
  - `nginx :80 -> bff :3000`
  - `nginx :80 -> server :3001`
- 当前 active cloud `BFF :3000` 仍是旧 release，不包含：
  - `personal/nickname`
  - `personal/avatar`
- 当前 active cloud `Server :3001` 仍是旧 release，上传规则仍停留在：
  - `businessType=project`
- cloud host 已安装 Docker，但本包所需 object-storage runtime 尚未正式部署。
- 本地 Docker 尝试已经被认定为误操作，并已清理与记账；当前不允许回到 local runtime 主线。

## 3. Frozen Repair Object

- 本轮冻结后的唯一修复包是：
  - `Personal minimal edit cloud deployment repair`
- 该包只允许包含 4 类动作：
  - cloud object-storage runtime deployment
  - cloud BFF active release replacement
  - cloud Server active release replacement
  - active ingress verification
- 该包不允许外扩到：
  - infra platform rewrite
  - container-platform redesign
  - unrelated building deployment

## 4. Allowed Repair Families

### 4.1 Cloud object-storage runtime

- 允许在云服务器上部署 `MinIO Docker` 容器。
- 该容器只为当前 upload transport 提供 runtime。
- 本轮必须对齐：
  - endpoint
  - public endpoint
  - bucket
  - access key / secret
- 本轮必须验证：
  - presigned PUT 成立
  - confirm verify 成立

### 4.2 Cloud BFF active release replacement

- 允许将当前 repo 对应的 BFF 版本部署到 active 链。
- 修复目标只限：
  - `:3000`
  - `nginx :80 -> :3000`
- active BFF 必须真正包含：
  - `/api/app/profile/personal/nickname`
  - `/api/app/profile/personal/avatar`
- 不允许只替换 staging-smoke `:3100` 而保留 active `:3000` 不变。

### 4.3 Cloud Server active release replacement

- 允许将当前 repo 对应的 Server 版本部署到 active 链。
- 修复目标只限：
  - `:3001`
  - `nginx :80 -> :3001`
- active Server 必须真正包含：
  - `profile/avatar` upload binding
  - `avatar_file_asset_id` truth carrier
  - personal nickname/avatar commands
- 不允许只替换 staging-smoke `:3101` 而保留 active `:3001` 不变。

### 4.4 Active ingress verification

- 本轮只允许验证两条 live 功能链：
  - 昵称保存
  - 头像上传
- 以及其受控失败保护：
  - invalid nickname
  - invalid upload init
  - invalid fileAssetId
  - unauthorized
- 所有最终验收都必须通过 active cloud ingress `:80` 完成。
- 只打内部端口 `3000 / 3001 / 3100 / 3101` 的验证，不得单独视为完成。

## 5. Explicit In-scope

- 云端 `MinIO Docker` 部署
- bucket / access key / public endpoint 对齐
- active `BFF :3000` 替换到当前 repo 对应版本
- active `Server :3001` 替换到当前 repo 对应版本
- `nginx :80` continuity check
- `nickname` live chain verification
- `avatar` live chain verification

## 6. Explicit Out-of-scope

- 本地 Docker / 本地 MinIO / 本地 BFF / 本地 Server
- 整套平台容器化架构重做
- BFF / Server 新平台迁移
- OCR
- 实名
- 公司编辑
- 认证简化
- 审核后台
- payment / billing
- `V2.3`
- 其他 building runtime repair

## 7. Acceptance Standard

- Cloud active ingress `:80` 下：
  - `POST /api/app/profile/personal/nickname` 不再返回 `Cannot POST /bff/profile/personal/nickname`
- Cloud active ingress `:80` 下：
  - `POST /api/app/file/upload/init` 对 `profile/avatar` 不再返回 `businessType=project`
- 云端对象存储 runtime 已可用：
  - presigned PUT 成立
  - confirm verify 成立
- 昵称成功链成立：
  - 写入成功
  - shell / profile readback 可见
- 头像成功链成立：
  - init
  - direct upload
  - confirm
  - commit
  - shell / profile readback
- 失败态仍 fail-closed：
  - invalid nickname
  - invalid avatar fileAsset
  - unauthorized
- 不引入新的 deployment drift：
  - nginx upstream continuity 清楚
  - active port mapping 清楚
  - release source 清楚

## 8. Stage Gate Checklist

### Passed gates

- repo source 已具备 `Personal minimal edit`
- cloud blocker 已被精确定位
- cloud host 已具备 Docker 基础能力
- active ingress / active port / active release 已被识别清楚

### Failed gates

- active BFF release 未对齐当前 repo
- active Server release 未对齐当前 repo
- cloud object-storage runtime 未正式部署
- active cloud ingress live chain 当前仍失败

### Veto gates

- 若本轮转回 local runtime，直接 veto
- 若本轮扩成 infra 大改造，直接 veto
- 若本轮不经过 `:80` 只测内部端口，直接 veto
- 若本轮扩到 OCR / 实名 / 认证 / 审核，直接 veto

## 9. Stage Decision

- `Go for bounded cloud deployment repair execution`

## 10. Mistaken Operation Back-reference

- 本轮必须继续回指：
  - [personal_minimal_edit_cloud_runtime_gap_audit_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/personal_minimal_edit_cloud_runtime_gap_audit_addendum.md)
- 其记录内容继续有效：
  - local MinIO attempt was mistaken
  - local runtime path is closed
  - cloud verification path remains authoritative

## 11. Next Unique Action

- 输出并执行：
  - `Personal minimal edit cloud deployment repair execution`
- execution 完成后，必须先做 active ingress 验收。
- 未通过 active ingress 验收，不得进入下一包。
