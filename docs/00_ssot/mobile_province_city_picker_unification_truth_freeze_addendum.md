# Mobile Province/City Picker Unification Truth Freeze Addendum

## 1. Scope

- This addendum freezes the unified province/city selection truth for the Flutter App.
- It applies to every mobile entry that asks the user to select a China province/city pair.

## 2. Frozen Rule

- User-facing standardized province/city input must not use:
  - handwritten province or city names
  - handwritten provinceCode / cityCode
  - feature-local partial city lists
- Mobile must use one shared nationwide province/city dataset and one shared picker interaction.
- The frozen interaction is:
  - top action row with `取消 / 选择城市 / 确定`
  - two-column picker
  - province on the left
  - city on the right

## 3. Frozen Coverage

- The current mandatory coverage is:
  - `我的公司 / 组织创建或编辑`
  - `企业展示工作台` register-city source handoff
  - `企业展示公开列表` city filter
  - `展览首页` manual location select
  - `项目创建` province/city select
- Any later mobile page that introduces province/city selection must reuse the same picker and shared dataset.

## 4. Date Rule

- Mobile date fields that are meant to be selected by the user must use picker selection, not handwritten free text.
- `企业展示工作台 -> 成立日期` stays a truth-derived field:
  - source = business-license OCR truth from certification
  - no second manual input source is allowed inside the workbench
  - frontend must present it as a select-like read surface, not a handwritten text input illusion

## 5. Workbench Field Rule

- `注册城市` in enterprise display workbench still belongs to `我的公司 -> organization` truth.
- The workbench must not create a second editable register-city source.
- `合作方式` must no longer be exposed as comma-separated free text.
- The mobile workbench must use explicit selectable tags for cooperation modes.

## 6. Shared Dataset Rule

- Mobile now freezes one generated nationwide lookup asset:
  - `apps/mobile/assets/location/china_province_city.json`
- This asset is a generated lookup dataset, not handwritten business source.
- It is formally registered as a static lookup-data exemption from the default handwritten line-limit gate.

## 7. Current Dataset Baseline

- The current asset baseline contains:
  - `34` province-level divisions
  - `361` city-level entries used by the picker
- Direct-admin municipalities and SAR entries must round-trip with app-consistent city codes.

## 8. Conclusion

- Formal conclusion:
  - Flutter App province/city selection truth is now unified
  - handwritten location-code entry is no longer an allowed user-facing pattern
  - later mobile region selectors must extend the shared picker, not fork their own list or text input
