# Enterprise Workbench Surface Title Preview Case Sheet Alignment Frontend Surface Addendum

## Surface Decisions
- Enterprise workbench app-bar title is board-specific and no longer uses the generic enterprise label.
- Published-change snapshot detail and preview remain visible but are collapsed by default to reduce vertical occupation.
- Preview case sheet prefers current-change context media when opened from published-change preview.
- Preview hero uses factory showcase images when available.

## Expected User-facing Effect
- `我的公司展示 / 我的工厂展示 / 我的供应商展示` no longer land on a page whose top title still says `企业展示工作台`.
- Published-change workbench becomes easier to scan because preview content is folded by default.
- Case cards opened from preview no longer jump back to another/live image set.
- Factory preview hero no longer falls into an empty image placeholder when showcase truth exists.
