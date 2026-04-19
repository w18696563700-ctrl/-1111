---
title: Profile Safety OCR Stopgap Unlock Addendum
status: frozen
date: 2026-04-09
---

# Profile Safety OCR Stopgap Unlock Addendum

## Decision

`Profile Safety P0` is extended with a temporary OCR-only stopgap for profile automation.

This addendum opens only:

- nickname hard-rule auto-approval
- avatar OCR text extraction
- avatar OCR text rule interception
- automatic profile replacement when the stopgap returns a clear allow result

This addendum does not open:

- AI image moderation
- OCR QR-code dedicated detection
- OCR stamp / figure / watermark governance
- third-party managed human review
- new app-facing contracts
- new BFF state machines

## Scope

The stopgap applies only to:

- `POST /api/app/profile/personal/nickname`
- `POST /api/app/profile/personal/avatar`

`bio / intro` remains on the existing P0 path:

- hard-rule block
- otherwise `pending_review`

## Runtime Boundary

Nickname:

- keep current server-side format validation
- keep current hard-rule engine
- if rules block, create a rejected submission and return controlled rejection
- if rules allow, create an approved submission and replace the approved nickname immediately

Avatar:

- keep current `init -> direct upload -> confirm`
- keep current `FileAsset` ownership / image / size checks
- generate a signed object access URL from the confirmed avatar object
- call Alibaba Cloud OCR unified recognition on that signed URL
- normalize extracted text and run the existing profile hard-rule library against that text
- if OCR text hits rules, create a rejected submission and keep the old avatar public
- if OCR succeeds and extracted text is clean or empty, create an approved submission and replace the approved avatar immediately
- if OCR is disabled, unavailable, times out, or returns an indeterminate failure, keep the current P0 fallback and send the avatar submission to `pending_review`

## Persistence and Audit

No new table is introduced.

The existing tables remain the single carrier:

- `profile_safety_submissions`
- `content_safety_snapshots`
- `content_safety_audit_logs`

The stopgap may persist:

- `engine_type=rule` for nickname automatic decisions
- `engine_type=ocr` for avatar OCR automatic decisions or OCR-to-manual fallback
- `rule_decision=allow|block|manual_review`
- OCR metadata such as provider request id, OCR status, and extracted-text length or excerpt

`reviewed_by` remains `null` for machine-made automatic decisions.

## Contract Delta

There is no app-facing or BFF contract delta in this addendum.

Allowed response status reuse:

- `approved`
- `rejected`
- `pending_review`
- `resubmitted`

## Configuration

The stopgap introduces server runtime configuration for Alibaba Cloud OCR:

- `ALIYUN_OCR_ENABLED`
- `ALIYUN_OCR_ACCESS_KEY_ID`
- `ALIYUN_OCR_ACCESS_KEY_SECRET`
- `ALIYUN_OCR_REGION_ID`
- `ALIYUN_OCR_ENDPOINT`
- `ALIYUN_OCR_CONNECT_TIMEOUT_MS`
- `ALIYUN_OCR_READ_TIMEOUT_MS`

If OCR configuration is absent or disabled, the avatar path must fail closed into `pending_review`, not silent public approval.

## Rollback

Rollback is configuration-first:

- set `ALIYUN_OCR_ENABLED=false`

After rollback:

- nickname stays on rule-based auto-approval from this addendum
- avatar returns to the prior P0 fallback of manual review after file validation
