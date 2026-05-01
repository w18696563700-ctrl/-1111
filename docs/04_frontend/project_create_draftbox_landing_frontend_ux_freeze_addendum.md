---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-only UX fix for project create success landing, draftbox clarity, and project edit progress copy.
layer: L5 Frontend
---

# Project Create Draftbox Landing Frontend UX Freeze Addendum

## 1. Scope

This addendum freezes a bounded Flutter UX fix for:

- the project create success landing target;
- the create button copy;
- the owner-side draftbox landing route;
- the edit-draft progress copy.

## 2. Current Problem

After filling project basic information, the current create page copy says:

- `保存项目基本信息并跳转至我的项目`

The submit action does land in `我的项目`, but the newly created project is a
`draft`. A first-time user is not told to look in the draftbox, and the list may
prefer a non-draft stage after loading. This makes the saved project look
missing even though the backend state is correct.

## 3. Frozen UX Truth

### 3.1 Create Page Button

The create-page primary button copy is frozen as:

- `保存并跳转至我的项目草稿箱`

Display rule:

- `保存并跳转至` uses the normal filled-button label style.
- `我的项目草稿箱` must be red and bold.
- This requires rich text or an equivalent rich label widget; a single plain
  `Text` widget is not sufficient.

### 3.2 Create Success Landing

After project create succeeds, Flutter must navigate to the owner-side draftbox:

```text
/exhibition/my/projects?workspace=published&stage=draft&projectId={projectId}
```

Route meaning:

- `workspace=published` means the owner-side "我的发布" workspace.
- `stage=draft` means the draft stage must be selected on arrival.
- `projectId={projectId}` identifies the newly created project for lightweight
  highlight or positioning.

### 3.3 My Project List Arrival Behavior

When `stage=draft` is present in route query:

- `MyProjectListPage` must select the draft stage on first load;
- payload-preferred stage selection must not override the explicit route stage;
- if `projectId` is present and the item exists in the selected stage, the card
  should receive a lightweight highlight.

### 3.4 Edit Draft Progress Copy

On the edit project page, the publish progress title row is frozen as:

- left: `发布进度`
- right red note: `（本页仅做基础信息核对和修改）`

The progress step copy is frozen as:

- step title: `进入预发布列表`
- step subtitle: `补齐五类资料`

This copy means the current page is not the five-material completion page. It
only sends the user toward the prepublish list after basic information is ready.

## 4. Non-goals

This hotfix must not:

- add a new draftbox page;
- add or change BFF routes;
- add or change Server state machines;
- change project lifecycle states;
- change contracts;
- change cloud deployment;
- rework the five-material upload flow;
- redesign the whole prepublish list.

## 5. Minimum Acceptance

- The create button visibly says `保存并跳转至我的项目草稿箱`.
- `我的项目草稿箱` is red and bold.
- Create success lands on `我的发布 -> 草稿`.
- The newly created project is highlighted when it is present in the draft list.
- The edit page progress card shows the red note.
- The second progress step shows `进入预发布列表 / 补齐五类资料`.
- Existing entries to `我的项目`, `我的竞标`, prepublish, bidding, and active
  project stages remain valid.

