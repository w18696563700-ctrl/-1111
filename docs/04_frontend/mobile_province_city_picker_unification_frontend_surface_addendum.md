# Mobile Province/City Picker Unification Frontend Surface Addendum

## 1. Surface Goal

- Mobile location selection must look consistent.
- Province/city selection must no longer appear as raw code fields or ad-hoc chip lists.

## 2. Shared Surface

- The frozen shared surface is:
  - tap a select-like field or filter button
  - open a picker modal
  - top row uses `取消 / 选择城市 / 确定`
  - left column = province
  - right column = city

## 3. Required Replacements

- The following frontend patterns are frozen out:
  - `所在省编码`
  - `所在市编码`
  - local-only key-city lists for a formal city selector
  - handwritten city text for a field that is meant to be standardized
- The following surfaces must use the unified picker:
  - organization create/edit
  - exhibition home manual location
  - enterprise board city filter
  - project create location select

## 4. Workbench Surface

- `企业展示工作台` base profile area must present:
  - `注册城市` as read-only select-like surface with source handoff to organization edit
  - `成立日期` as read-only select-like surface with source handoff to certification
  - `合作方式` as selectable tags, not comma-separated free text
  - `案例城市` as picker-selected city
  - `举办日期` as picker-selected date

## 5. Non-goals

- This addendum does not upgrade district/county coverage to full-country truth.
- Current district selection may continue to exist only where legacy city supplements already exist.
