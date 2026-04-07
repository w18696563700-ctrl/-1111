import 'package:flutter/widgets.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';

class AppShellScope extends InheritedNotifier<AppBootstrapController> {
  const AppShellScope({
    super.key,
    required AppBootstrapController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppBootstrapController of(BuildContext context) {
    final AppShellScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static AppBootstrapController read(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<AppShellScope>();
    final AppShellScope? scope = element?.widget as AppShellScope?;
    assert(scope != null, 'AppShellScope is missing in the widget tree.');
    return scope!.notifier!;
  }
}
