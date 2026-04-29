# Counterpart Conversation Identity And Grouping Phase 1 Rule Freeze Addendum

## 0. Decision

- Current stage: Phase 1 bounded optimization.
- Formal implementation scope: counterpart conversation identity display, certification summary read surface, project grouping, and local back behavior.
- Server remains the only truth owner for counterpart identity, certification summary, and viewer/project relation.
- BFF only validates, trims, and forwards Server read models.
- Flutter only renders returned fields and must not infer nickname, company name, certification state, or project relation from text.

## 1. In Scope

1. Message interaction list keeps one counterpart-level card per `conversationId`.
2. The counterpart card may display avatar, nickname, company name, and project count.
3. Counterpart conversation header displays nickname first and company name second when nickname exists.
4. Avatar tap opens a read-only counterpart certification summary.
5. Project groups are split by Server-provided `projectRelation`.
6. The page back action first returns from selected-project view to project-list view; only a second back exits the route.

## 2. Out Of Scope

1. No generic IM refactor.
2. No enterprise home page rebuild.
3. No credit score, penalty, blacklist, or rating expansion.
4. No payment, order, bid state-machine changes.
5. No nickname editing feature.
6. No historical data migration.

## 3. Field Source Rules

| Field | Truth owner | Rule |
|---|---|---|
| `counterpart.organizationId` | Server | Current counterpart organization in the conversation aggregate. |
| `counterpart.nickname` | Server | Counterpart user nickname when a user anchor exists; nullable. |
| `counterpart.companyName` | Server | Approved certification legal name, then organization name, then display fallback. |
| `counterpart.displayName` | Server | Backward-compatible display label; should equal the company display fallback in Phase 1. |
| `counterpart.avatarUrl` | Server | Counterpart user avatar URL signed by Server support service. |
| `counterpart.certificationSummary` | Server | Approved organization certification summary only; nullable if unavailable. |
| `projectGroups[].projectRelation` | Server | `my_published` when current organization owns the project; `my_bid` when current organization participates as bidder; otherwise `unknown`. |

## 4. UI Rules

1. If nickname exists, show nickname as primary text and company name as secondary text.
2. If nickname does not exist, show company name as primary text and avoid a fake nickname label.
3. Certification summary missing must be rendered as a controlled empty state, not guessed.
4. `projectRelation=unknown` must not be forced into `my_published` or `my_bid`.
5. Back navigation must not skip the internal project-list state.

## 5. Stop Rules

- Stop if Server cannot produce `projectRelation` without guessing.
- Stop if certification summary would require exposing license images or private documents.
- Stop if BFF starts calculating identity or project relation.
- Stop if Flutter infers fields from project titles, card types, or display strings.

## 6. Gate

- Day 1 result: Go for L2 contracts.
- Formal release remains blocked until Server/BFF/Flutter tests and runtime verification pass.
