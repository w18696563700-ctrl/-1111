import 'package:flutter/widgets.dart';
import 'package:mobile/dev/visual_demo/forum_formal_nav_rollout_demo_app.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const initialRoute = String.fromEnvironment(
    'FORUM_FORMAL_ROUTE',
    defaultValue: ExhibitionRoutes.forum,
  );
  runApp(buildForumFormalNavRolloutDemoApp(initialRoute: initialRoute));
}
