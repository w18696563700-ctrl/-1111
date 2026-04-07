import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'project list falls back to demo source when real content is unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(handlers: const {});

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectList,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前展示：演示内容'), findsOneWidget);
      expect(find.text('当前真实内容暂未返回'), findsOneWidget);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        contains(ExhibitionCanonicalPaths.projectList),
      );
    },
  );

  testWidgets(
    'inspection submit can continue with demo result when detail is unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(handlers: const {});

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionSubmitWithMilestoneId(
            'milestone-demo-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前展示：演示内容'), findsOneWidget);
      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, '使用演示结果继续讲解'),
      );

      expect(find.text('已提交验收结果'), findsOneWidget);
      expect(find.text('当前展示：演示内容'), findsWidgets);
      expect(find.text('当前状态：已提交'), findsOneWidget);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        contains(ExhibitionCanonicalPaths.inspectionDetail),
      );
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        isNot(contains(ExhibitionCanonicalPaths.inspectionSubmit)),
      );
    },
  );
}
