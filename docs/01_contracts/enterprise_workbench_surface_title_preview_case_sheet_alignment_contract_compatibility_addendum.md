# Enterprise Workbench Surface Title Preview Case Sheet Alignment Contract Compatibility Addendum

## Contract Impact
- No app-facing API path changes.
- No BFF or Server payload schema changes are required.
- Client consumes existing fields only:
  - route query `boardType`
  - route query `mode=published_change`
  - published-change snapshot case fields already present in mobile models
  - published-change board profile showcase image url map

## Client-only Adjustments
- Route title calculation becomes board-aware.
- Published-change preview section becomes collapsible by frontend state only.
- Case detail sheet may build a local inline detail view from current preview context when sufficient case fields are already present on the tapped card.
