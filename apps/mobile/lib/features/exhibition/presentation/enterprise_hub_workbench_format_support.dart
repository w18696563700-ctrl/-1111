part of 'enterprise_hub_workbench_pages.dart';

String _placemarkAddress(List<Placemark> placemarks) {
  if (placemarks.isEmpty) {
    return '';
  }
  final placemark = placemarks.first;
  final values = <String>[];
  void addPart(String? value) {
    final normalized = _normalizedText(value);
    if (normalized == null || values.contains(normalized)) {
      return;
    }
    values.add(normalized);
  }

  addPart(placemark.administrativeArea);
  if (placemark.locality != placemark.administrativeArea) {
    addPart(placemark.locality);
  }
  addPart(placemark.subAdministrativeArea);
  addPart(placemark.subLocality);
  addPart(placemark.thoroughfare);
  addPart(placemark.subThoroughfare);
  addPart(placemark.name);
  return values.join();
}

String _locationFallbackAddress(DeviceLocationSnapshot snapshot) {
  return '当前位置：${snapshot.coordinatesLabel}';
}

DateTime? _parseIsoDate(String? value) {
  return _parseSupportedDate(value);
}

String _formatIsoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _formatChineseDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}年$month月$day日';
}

String _displayDateLabel(String? rawValue, {String fallback = ''}) {
  final normalized = _normalizedText(rawValue);
  if (normalized == null) {
    return fallback;
  }
  final parsed = _parseSupportedDate(normalized);
  if (parsed == null) {
    return normalized;
  }
  return _formatChineseDate(parsed);
}

String? _normalizeDateStorageValue(String? rawValue) {
  final normalized = _normalizedText(rawValue);
  if (normalized == null) {
    return null;
  }
  final parsed = _parseSupportedDate(normalized);
  if (parsed == null) {
    return normalized;
  }
  return _formatIsoDate(parsed);
}

DateTime? _parseSupportedDate(String? rawValue) {
  final normalized = _normalizedText(rawValue);
  if (normalized == null) {
    return null;
  }
  final direct = DateTime.tryParse(normalized);
  if (direct != null) {
    return direct;
  }
  final match = RegExp(
    r'^(\d{4})[年/-](\d{1,2})[月/-](\d{1,2})日?$',
  ).firstMatch(normalized);
  if (match == null) {
    return null;
  }
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime(year, month, day);
}

_WorkbenchImageItem? _mergeSingleWorkbenchImage({
  required _WorkbenchImageItem? current,
  required String? nextFileAssetId,
  String? nextImageUrl,
  required String fallbackLabel,
}) {
  final normalized = nextFileAssetId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return current?.fileAssetId == null ? current : null;
  }
  if (current?.fileAssetId == normalized) {
    return current!.copyWith(
      imageUrl: nextImageUrl,
      stage: _WorkbenchImageStage.ready,
      statusMessage: '已保存',
    );
  }
  return _WorkbenchImageItem.remote(
    fileAssetId: normalized,
    imageUrl: nextImageUrl,
    fallbackLabel: fallbackLabel,
  );
}

List<_WorkbenchImageItem> _mergeWorkbenchImageCollection({
  required List<_WorkbenchImageItem> current,
  required List<String> nextFileAssetIds,
  required Map<String, String> nextImageUrlMap,
  required String fallbackPrefix,
}) {
  final currentByFileAssetId = <String, _WorkbenchImageItem>{};
  for (final item in current) {
    final fileAssetId = item.fileAssetId?.trim();
    if (fileAssetId == null || fileAssetId.isEmpty) {
      continue;
    }
    currentByFileAssetId[fileAssetId] = item;
  }
  return nextFileAssetIds
      .map((fileAssetId) {
        final imageUrl = nextImageUrlMap[fileAssetId];
        final currentItem = currentByFileAssetId[fileAssetId];
        if (currentItem != null) {
          return currentItem.copyWith(
            imageUrl: imageUrl,
            stage: _WorkbenchImageStage.ready,
            statusMessage: '已保存',
          );
        }
        return _WorkbenchImageItem.remote(
          fileAssetId: fileAssetId,
          imageUrl: imageUrl,
          fallbackLabel: fallbackPrefix,
        );
      })
      .toList(growable: false);
}

String? _workbenchImageMimeType(String fileName) {
  final lowerName = fileName.trim().toLowerCase();
  if (lowerName.endsWith('.png')) {
    return 'image/png';
  }
  if (lowerName.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lowerName.endsWith('.gif')) {
    return 'image/gif';
  }
  if (lowerName.endsWith('.heic') || lowerName.endsWith('.heif')) {
    return 'image/heic';
  }
  if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  return null;
}

String _profileLabelOne(EnterpriseBoardType boardType) => switch (boardType) {
  EnterpriseBoardType.company => '展会类型',
  EnterpriseBoardType.factory => '工艺类型',
  EnterpriseBoardType.supplier => '供应品类',
};

String _profileLabelTwo(EnterpriseBoardType boardType) => switch (boardType) {
  EnterpriseBoardType.company => '服务项目',
  EnterpriseBoardType.factory => '核心产品',
  EnterpriseBoardType.supplier => '供应模式',
};

String _profileLabelThree(EnterpriseBoardType boardType) => switch (boardType) {
  EnterpriseBoardType.company => '服务城市（逗号分隔）',
  EnterpriseBoardType.factory => '设备清单',
  EnterpriseBoardType.supplier => '核心产品/服务（逗号分隔）',
};

String _profileLabelFour(EnterpriseBoardType boardType) => switch (boardType) {
  EnterpriseBoardType.company => '最大项目规模',
  EnterpriseBoardType.factory => '月产能说明',
  EnterpriseBoardType.supplier => '响应时效说明',
};

String _profileLabelFive(EnterpriseBoardType boardType) => switch (boardType) {
  EnterpriseBoardType.company => '资质说明',
  EnterpriseBoardType.factory => '配送半径说明',
  EnterpriseBoardType.supplier => '配送范围说明',
};

List<MapEntry<String, String>> _profileOneOptions(
  EnterpriseBoardType boardType,
) => switch (boardType) {
  EnterpriseBoardType.company => enterpriseWorkbenchCompanyExhibitionOptions,
  EnterpriseBoardType.factory => enterpriseWorkbenchFactoryProcessOptions,
  EnterpriseBoardType.supplier => enterpriseWorkbenchSupplierCategoryOptions,
};

List<MapEntry<String, String>> _profileTwoOptions(
  EnterpriseBoardType boardType,
) => switch (boardType) {
  EnterpriseBoardType.company => enterpriseWorkbenchCompanyServiceItemOptions,
  EnterpriseBoardType.factory => enterpriseWorkbenchFactoryProcessOptions,
  EnterpriseBoardType.supplier => enterpriseWorkbenchSupplierModeOptions,
};
