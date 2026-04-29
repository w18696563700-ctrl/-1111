# Counterpart Conversation Identity And Grouping Contracts Addendum

## 0. Decision

This addendum extends the existing counterpart conversation app-facing read models. It is additive and backward compatible: existing `counterpart.displayName` remains, while explicit identity and grouping fields are added.

## 1. Counterpart Identity

`counterpart` in both list and detail responses must support:

```ts
type CounterpartConversationCounterpart = {
  organizationId: string;
  displayName: string;
  nickname: string | null;
  companyName: string;
  avatarUrl: string | null;
  role: "counterpart";
  certificationSummary: CounterpartCertificationSummary | null;
};
```

`displayName` is retained for compatibility. Flutter must prefer `nickname` as primary display text when present and use `companyName` as the company line.

## 2. Certification Summary

```ts
type CounterpartCertificationSummary = {
  certificationStatus: "approved";
  legalName: string;
  usccMasked: string | null;
  businessType: string | null;
  address: string | null;
  establishedAt: string | null;
  reviewedAt: string | null;
};
```

Rules:

- Only approved organization certification may be exposed.
- `usccMasked` must be masked before leaving Server.
- License image, OCR raw payload, reviewer id, and reject reason are not exposed in this Phase 1 surface.
- Missing certification summary is represented by `null`.

## 3. Project Relation

Each `projectGroups[]` item must include:

```ts
projectRelation: "my_published" | "my_bid" | "unknown";
```

Rules:

- `my_published`: current viewer organization owns the project.
- `my_bid`: current viewer organization is not the owner but reaches this project through approved/request/bid/message participation sources.
- `unknown`: project is missing or relation cannot be safely proven.

## 4. Layer Ownership

| Layer | Responsibility |
|---|---|
| Server | Calculates counterpart identity, certification summary, and `projectRelation`. |
| BFF | Validates and forwards fields; no identity or relation calculation. |
| Flutter | Renders fields and groups project list; no inference. |

## 5. Compatibility

- Existing clients can continue reading `displayName`.
- New clients should read `nickname`, `companyName`, `certificationSummary`, and `projectRelation`.
- No route rename is required.
