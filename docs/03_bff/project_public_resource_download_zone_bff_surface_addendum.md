---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF-side app-facing surface for the public resource download zone,
  mapping the single read-only catalog path while reusing shared file access
  and forbidding any template-config proxy or second download system.
layer: L4 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/03_bff/project_detail_document_zone_and_public_resource_download_bff_surface_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/file
---

# 《公共资源下载区 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `公共资源下载区` 的 BFF list mapping
  - shared file-access download reuse
- 本冻结单不进入：
  - template-config proxy
  - second download path family
  - implementation

## 2. Canonical Mapping Freeze

- 当前唯一合法 BFF app-facing 映射固定为：
  - `GET /api/app/project/public-resources`
    -> `GET /server/projects/public-resources`
- 当前 zone 的实际下载继续复用：
  - `GET /api/app/file/access`
    with `mode=download`

## 3. Shaping Boundary

- BFF 当前只做：
  - path mapping
  - response shaping
  - controlled error normalization
- BFF 当前不得做：
  - 资源目录真值
  - 资源分类再解释
  - 本地硬编码资源卡片拼装

## 4. Template-config Proxy Prohibition

- BFF 当前不得代理：
  - `/server/admin/config/templates*`
  到 App 侧
- BFF 当前不得把 `template_config` response
  改写成 `公共资源下载区` catalog。

## 5. File Access Boundary

- BFF 当前不得为 `公共资源下载区` 新开：
  - `/api/app/project/public-resources/download`
  - `/api/app/project/public-resources/access`
- 当前下载与访问语义继续全部复用 shared file-access family。

## 6. Formal Conclusion

- 当前 `公共资源下载区` 的 BFF authority 正式冻结为：
  - one catalog path
  - shared file-access reuse
  - no template-config proxy
