final class ConfigFlagKeys {
  const ConfigFlagKeys._();

  static const String buildingExhibitionVisible = 'building.exhibition.visible';
  static const String buildingMessagesVisible = 'building.messages.visible';
  static const String buildingProfileVisible = 'building.profile.visible';
  static const String buildingRenovationVisible = 'building.renovation.visible';
  static const String buildingCustomFurnitureVisible =
      'building.custom_furniture.visible';
  static const String platformLiveEnabled = 'platform.live.enabled';
  static const String platformGeoEnabled = 'platform.geo.enabled';
  static const String platformMapGaodeEnabled = 'platform.map.gaode.enabled';
  static const String uploadDirectEnabled = 'upload.direct.enabled';
}

class AppConfigManifest {
  AppConfigManifest._(Map<String, bool> flags)
    : flags = Map<String, bool>.unmodifiable(flags);

  final Map<String, bool> flags;

  factory AppConfigManifest.bootstrapDefaults() {
    return AppConfigManifest._(<String, bool>{
      ConfigFlagKeys.buildingExhibitionVisible: true,
      ConfigFlagKeys.buildingMessagesVisible: true,
      ConfigFlagKeys.buildingProfileVisible: true,
      ConfigFlagKeys.buildingRenovationVisible: false,
      ConfigFlagKeys.buildingCustomFurnitureVisible: false,
      ConfigFlagKeys.platformLiveEnabled: false,
      ConfigFlagKeys.platformGeoEnabled: false,
      ConfigFlagKeys.platformMapGaodeEnabled: false,
      ConfigFlagKeys.uploadDirectEnabled: true,
    });
  }

  bool isEnabled(String key) => flags[key] ?? false;

  bool get exhibitionVisible =>
      isEnabled(ConfigFlagKeys.buildingExhibitionVisible);

  bool get messagesVisible => isEnabled(ConfigFlagKeys.buildingMessagesVisible);

  bool get profileVisible => isEnabled(ConfigFlagKeys.buildingProfileVisible);

  bool get renovationVisible =>
      isEnabled(ConfigFlagKeys.buildingRenovationVisible);

  bool get customFurnitureVisible =>
      isEnabled(ConfigFlagKeys.buildingCustomFurnitureVisible);

  bool get liveEnabled => isEnabled(ConfigFlagKeys.platformLiveEnabled);

  bool get geoEnabled => isEnabled(ConfigFlagKeys.platformGeoEnabled);

  bool get gaodeMapEnabled => isEnabled(ConfigFlagKeys.platformMapGaodeEnabled);

  bool get directUploadEnabled => isEnabled(ConfigFlagKeys.uploadDirectEnabled);

  AppConfigManifest copyWithFlag(String key, bool value) {
    return AppConfigManifest._(<String, bool>{...flags, key: value});
  }
}
