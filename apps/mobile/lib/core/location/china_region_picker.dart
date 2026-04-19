import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/location/china_region_catalog.dart';

class SelectLikeField extends StatelessWidget {
  const SelectLikeField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    this.required = false,
    this.helperText,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String? value;
  final String placeholder;
  final bool required;
  final String? helperText;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final display = value?.trim().isNotEmpty == true
        ? value!.trim()
        : placeholder;
    final displayStyle = value?.trim().isNotEmpty == true
        ? theme.textTheme.bodyLarge
        : theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );

    final content = InputDecorator(
      decoration: InputDecoration(
        label: _SelectFieldLabel(label: label, required: required),
        helperText: helperText,
        border: const OutlineInputBorder(),
        suffixIcon:
            trailing ??
            Icon(
              onTap == null
                  ? Icons.lock_outline_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
      ),
      child: Text(display, style: displayStyle),
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(child: content),
    );
  }
}

class _SelectFieldLabel extends StatelessWidget {
  const _SelectFieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    if (!required) {
      return Text(label, style: style);
    }
    return RichText(
      text: TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(
            text: '* ',
            style: style?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          TextSpan(text: label),
        ],
      ),
    );
  }
}

Future<ChinaCityOption?> showChinaCityPicker({
  required BuildContext context,
  required ChinaRegionCatalog catalog,
  String title = '选择城市',
  String? initialProvinceCode,
  String? initialCityCode,
  bool allowClear = false,
  String clearLabel = '不限',
}) async {
  final initialProvinceIndex = _provinceIndex(
    catalog,
    initialProvinceCode,
    initialCityCode,
  );
  var selectedProvinceIndex = initialProvinceIndex;
  var selectedCityIndex = _cityIndex(
    catalog.provinces[initialProvinceIndex],
    initialCityCode,
    allowClear,
  );

  final provinceController = FixedExtentScrollController(
    initialItem: initialProvinceIndex,
  );
  final cityController = FixedExtentScrollController(
    initialItem: selectedCityIndex,
  );

  final result = await showModalBottomSheet<ChinaCityOption?>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext popupContext) {
      return Localizations.override(
        context: popupContext,
        locale: const Locale('zh', 'CN'),
        child: StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(VoidCallback) setModalState,
              ) {
                final province = catalog.provinces[selectedProvinceIndex];
                final cityOptions = _pickerCityOptions(
                  province: province,
                  allowClear: allowClear,
                  clearLabel: clearLabel,
                );
                return Container(
                  height: 320,
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 52,
                        child: Row(
                          children: <Widget>[
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(cityOptions[selectedCityIndex].city),
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: provinceController,
                                itemExtent: 40,
                                onSelectedItemChanged: (int index) {
                                  final nextProvince = catalog.provinces[index];
                                  setModalState(() {
                                    selectedProvinceIndex = index;
                                    selectedCityIndex = 0;
                                    cityController.jumpToItem(0);
                                  });
                                  if (nextProvince.cities.isEmpty) {
                                    selectedCityIndex = 0;
                                  }
                                },
                                children: catalog.provinces
                                    .map(
                                      (province) => Center(
                                        child: Text(province.provinceName),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                key: ValueKey<String>(province.provinceCode),
                                scrollController: cityController,
                                itemExtent: 40,
                                onSelectedItemChanged: (int index) {
                                  setModalState(
                                    () => selectedCityIndex = index,
                                  );
                                },
                                children: cityOptions
                                    .map(
                                      (item) => Center(child: Text(item.label)),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
        ),
      );
    },
  );

  provinceController.dispose();
  cityController.dispose();
  return result;
}

Future<DateTime?> showChinaDatePicker({
  required BuildContext context,
  required String title,
  DateTime? initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) async {
  final lowerBound = minimumDate ?? DateTime(1900, 1, 1);
  final upperBound =
      maximumDate ?? DateTime.now().add(const Duration(days: 3650));
  var selectedDate = _clampDate(
    initialDate ?? DateTime.now(),
    lowerBound,
    upperBound,
  );
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext popupContext) {
      return Localizations.override(
        context: popupContext,
        locale: const Locale('zh', 'CN'),
        child: Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(popupContext),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 52,
                child: Row(
                  children: <Widget>[
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.of(popupContext).pop(),
                      child: const Text('取消'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () =>
                          Navigator.of(popupContext).pop(selectedDate),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.ymd,
                  initialDateTime: selectedDate,
                  minimumDate: lowerBound,
                  maximumDate: upperBound,
                  onDateTimeChanged: (DateTime value) => selectedDate = value,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PickerCityOption {
  const _PickerCityOption({required this.label, required this.city});

  final String label;
  final ChinaCityOption? city;
}

List<_PickerCityOption> _pickerCityOptions({
  required ChinaProvinceOption province,
  required bool allowClear,
  required String clearLabel,
}) {
  final options = <_PickerCityOption>[
    if (allowClear) _PickerCityOption(label: clearLabel, city: null),
    ...province.cities.map(
      (ChinaCityOption city) =>
          _PickerCityOption(label: city.cityName, city: city),
    ),
  ];
  return options;
}

int _provinceIndex(
  ChinaRegionCatalog catalog,
  String? initialProvinceCode,
  String? initialCityCode,
) {
  final byProvince = catalog.provinces.indexWhere(
    (province) => province.provinceCode == initialProvinceCode?.trim(),
  );
  if (byProvince >= 0) {
    return byProvince;
  }
  final matchedCity = catalog.cityByCode(initialCityCode);
  if (matchedCity == null) {
    return 0;
  }
  return catalog.provinces.indexWhere(
    (province) => province.provinceCode == matchedCity.provinceCode,
  );
}

int _cityIndex(
  ChinaProvinceOption province,
  String? initialCityCode,
  bool allowClear,
) {
  final cityIndex = province.cities.indexWhere(
    (city) => city.cityCode == initialCityCode?.trim(),
  );
  if (cityIndex < 0) {
    return 0;
  }
  return allowClear ? cityIndex + 1 : cityIndex;
}

DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
  if (value.isBefore(min)) {
    return min;
  }
  if (value.isAfter(max)) {
    return max;
  }
  return value;
}
