import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _projectPayload({
  required String projectId,
  String projectNo = 'PROJ-1',
  String title = '展览项目',
  String buildingType = 'exhibition',
  num budgetAmount = 1000,
  String viewerProjectRelation = 'non_owner',
  String state = 'published',
  String heading = '展览项目',
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': <String, Object?>{
      'heading': heading,
      'stateLabel': state,
      'budgetAmount': budgetAmount,
    },
  };
}

ExhibitionMobileApp _buildApp({
  required FakeAppApiTransport transport,
  required String initialRoute,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'showcase detail keeps public materials read-only while published projects can still continue bid',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    title: '公开展示项目',
                    heading: '公开展示项目',
                    state: 'published',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.widgetWithText(FilledButton, '立即参与竞标'));
      expect(find.text('公开资料边界'), findsNothing);
      expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
      expect(find.text('上传当前附件', skipOffstage: false), findsNothing);
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsOneWidget);
    },
  );

  testWidgets(
    'showcase keeps converted projects in read-only guidance instead of bid continuation',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _projectPayload(
                        projectId: 'project-closed',
                        projectNo: 'PROJ-CLOSED',
                        title: '已转订单项目',
                        heading: '已转订单项目',
                        state: 'converted_to_order',
                      ),
                    ],
                  },
                );
              },
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-closed',
                    projectNo: 'PROJ-CLOSED',
                    title: '已转订单项目',
                    heading: '已转订单项目',
                    state: 'converted_to_order',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          initialRoute: ExhibitionRoutes.showcase,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('已转订单项目'));
      expect(find.text('已转订单项目'), findsWidgets);
      expect(find.textContaining('当前项目已经转入订单链路'), findsNothing);

      await _tapVisible(tester, find.text('已转订单项目'));

      await _scrollTo(tester, find.textContaining('当前项目已被承接'));
      expect(find.text('公开资料边界'), findsNothing);
      expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsNothing);
      expect(find.textContaining('当前项目已被承接'), findsWidgets);
    },
  );
}
