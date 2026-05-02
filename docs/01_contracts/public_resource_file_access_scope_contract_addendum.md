---
owner: Codex 总控
status: frozen
layer: L2 Contracts
freeze_date_local: 2026-05-02
purpose: >
  Freeze the app-facing and server-facing contract delta that adds the bounded
  `public_resource` access scope to shared file/access while preserving the
  existing public-resource download contract and owner-private attachment
  boundaries.
inputs_canonical:
  - docs/00_ssot/public_resource_file_access_minimal_unlock_boundary_freeze_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_shared_file_access_contract_drift_repair_addendum.md
  - docs/01_contracts/openapi.yaml
---

# public_resource file/access scope contract addendum

## 1. Scope

This addendum covers only the shared file-access scope delta needed by public
resources.

It does not introduce a new download endpoint and does not change upload,
project attachment, bid material, payment, or credit-scoring contracts.

## 2. App-facing Contract

Path remains:

```text
GET /api/app/file/access
```

Required query remains:

```text
fileAssetId: string
mode: download
```

Optional query is extended:

```ts
type FileAccessScope = 'owner_private' | 'bid_material' | 'public_resource';
```

Compatibility rule:

- Existing public-resource Flutter callers may omit `accessScope`.
- When `accessScope` is omitted and no owner-private project attachment binding
  exists, Server may resolve a valid published app-shared public resource
  binding by `fileAssetId`.
- New or explicit callers may pass `accessScope=public_resource`.

## 3. Server-facing Contract

BFF forwards to:

```text
GET /server/file/access
```

Forwarded query:

```ts
{
  fileAssetId: string;
  mode: 'download' | 'preview';
  projectId?: string;
  accessScope?: 'owner_private' | 'bid_material' | 'public_resource';
}
```

Public resource scope rules:

- `accessScope=public_resource` only authorizes published app-shared public
  resources.
- It must not authorize owner-private project attachments.
- It must not authorize arbitrary `FileAsset` rows.

## 4. Response Contract

Response remains:

```ts
type FileAccessResponse = {
  fileAssetId: string;
  mode: 'preview' | 'download';
  accessUrl: string;
  fileName: string;
  mimeType: string;
  expiresAt: string;
  contentLengthBytes?: number;
};
```

Response must not expose:

- `objectKey`
- bucket name
- storage credentials
- upload session internals

## 5. Error Contract

Existing file-access error family remains valid:

- `FILE_ACCESS_INVALID`
- `FILE_ACCESS_NOT_FOUND`
- `FILE_ACCESS_PERMISSION_DENIED`
- `FILE_ACCESS_UNAVAILABLE`
- `AUTH_SESSION_INVALID`

No new error code is required for the minimum unlock.

## 6. Formal Conclusion

The shared file-access family now formally admits a bounded
`public_resource` scope. Business truth remains in Server:

- public resource catalog truth: `project_public_resources`
- file object truth: `file_asset`
- signing truth: Server + storage adapter
- BFF: forwarding and response shaping only
