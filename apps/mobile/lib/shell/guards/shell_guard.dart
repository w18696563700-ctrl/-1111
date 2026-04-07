import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/shell/navigation/app_building.dart';

class AppShellGuard {
  const AppShellGuard(this.controller);

  final AppBootstrapController controller;

  GlobalShellState? resolve(AppBuilding building) {
    return controller.guardBuilding(building);
  }
}
