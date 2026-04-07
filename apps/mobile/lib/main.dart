import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/shell/shell_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const compileTimeRoute = String.fromEnvironment('APP_INITIAL_ROUTE');
  final runtimeRoute = Platform.environment['APP_INITIAL_ROUTE']?.trim();
  final initialRoute = compileTimeRoute.isNotEmpty
      ? compileTimeRoute
      : runtimeRoute != null && runtimeRoute.isNotEmpty
      ? runtimeRoute
      : '/';
  runApp(
    ExhibitionMobileApp(
      initialRoute: initialRoute,
      shellContextConsumer: AppShellContextConsumer(),
    ),
  );
}
