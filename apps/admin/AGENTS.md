# Admin AGENTS

## Scope
- Own the minimal `Admin` console only.
- Use controlled `Server` Admin APIs directly.

## Allowed
- Review console skeletons
- Project review skeletons
- Template configuration skeletons
- Audit log console skeletons
- Basic ticketing console skeletons

## Forbidden
- Going through `BFF`
- Writing a second business truth
- Direct database writes that bypass `Server` rules
- Replacing audit or review flows with client-only behavior
