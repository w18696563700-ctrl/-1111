import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mobile/dev/visual_demo/visual_demo_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const compileTimeRoute = String.fromEnvironment('APP_INITIAL_ROUTE');
  final runtimeRoute = Platform.environment['APP_INITIAL_ROUTE']?.trim();
  final initialRoute = compileTimeRoute.isNotEmpty
      ? compileTimeRoute
      : runtimeRoute != null && runtimeRoute.isNotEmpty
      ? runtimeRoute
      : '/';
  runApp(buildVisualDemoApp(initialRoute: initialRoute));
}
