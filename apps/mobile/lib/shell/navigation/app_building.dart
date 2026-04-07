import 'package:flutter/material.dart';
import 'package:mobile/core/config/config_manifest.dart';

enum AppBuilding { exhibition, renovation, customFurniture, messages, profile }

extension AppBuildingX on AppBuilding {
  String get routePath => switch (this) {
    AppBuilding.exhibition => '/exhibition',
    AppBuilding.renovation => '/renovation',
    AppBuilding.customFurniture => '/custom-furniture',
    AppBuilding.messages => '/messages',
    AppBuilding.profile => '/profile',
  };

  String get code => switch (this) {
    AppBuilding.exhibition => 'exhibition',
    AppBuilding.renovation => 'renovation',
    AppBuilding.customFurniture => 'custom_furniture',
    AppBuilding.messages => 'messages',
    AppBuilding.profile => 'profile',
  };

  String get label => switch (this) {
    AppBuilding.exhibition => '展览',
    AppBuilding.renovation => '装修',
    AppBuilding.customFurniture => '全屋定制',
    AppBuilding.messages => '消息',
    AppBuilding.profile => '我的',
  };

  IconData get icon => switch (this) {
    AppBuilding.exhibition => Icons.storefront_outlined,
    AppBuilding.renovation => Icons.home_repair_service_outlined,
    AppBuilding.customFurniture => Icons.chair_outlined,
    AppBuilding.messages => Icons.chat_bubble_outline,
    AppBuilding.profile => Icons.person_outline,
  };

  IconData get selectedIcon => switch (this) {
    AppBuilding.exhibition => Icons.storefront,
    AppBuilding.renovation => Icons.home_repair_service,
    AppBuilding.customFurniture => Icons.chair,
    AppBuilding.messages => Icons.chat_bubble,
    AppBuilding.profile => Icons.person,
  };

  bool get showsInBottomNavigation => switch (this) {
    AppBuilding.exhibition ||
    AppBuilding.messages ||
    AppBuilding.profile => true,
    AppBuilding.renovation || AppBuilding.customFurniture => false,
  };

  String get visibilityFlagKey => switch (this) {
    AppBuilding.exhibition => ConfigFlagKeys.buildingExhibitionVisible,
    AppBuilding.messages => ConfigFlagKeys.buildingMessagesVisible,
    AppBuilding.profile => ConfigFlagKeys.buildingProfileVisible,
    AppBuilding.renovation => ConfigFlagKeys.buildingRenovationVisible,
    AppBuilding.customFurniture =>
      ConfigFlagKeys.buildingCustomFurnitureVisible,
  };
}

const List<AppBuilding> registeredBuildings = <AppBuilding>[
  AppBuilding.exhibition,
  AppBuilding.renovation,
  AppBuilding.customFurniture,
  AppBuilding.messages,
  AppBuilding.profile,
];

const List<AppBuilding> bottomNavigationBuildings = <AppBuilding>[
  AppBuilding.exhibition,
  AppBuilding.messages,
  AppBuilding.profile,
];

AppBuilding? appBuildingFromRoute(String? routeName) {
  if (routeName == null || routeName == '/') {
    return AppBuilding.exhibition;
  }

  for (final AppBuilding building in registeredBuildings) {
    if (building.routePath == routeName) {
      return building;
    }
  }

  return null;
}
