import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Map<String, Object?> _projectDetailPayload() {
  return const <String, Object?>{
    'projectId': 'project-1',
    'projectNo': 'PROJ-1',
    'title': '展览项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1888,
    'state': 'published',
    'viewerProjectRelation': 'public_viewer',
    'summary': <String, Object?>{'heading': '当前项目说明'},
  };
}

void main() {
  test(
    'consumer submits exhibition report through formal canonical path',
    () async {
      Map<String, Object?>? reportBody;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST ${ExhibitionCanonicalPaths.exhibitionReportSubmit}':
                  (AppApiRequest request) async {
                    reportBody = request.body as Map<String, Object?>?;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'reportCaseId': 'report-case-1',
                        'targetType': 'project',
                        'targetId': 'project-1',
                        'status': 'submitted',
                        'acceptMode': 'created',
                        'traceId': 'trace-1',
                      },
                    );
                  },
            },
      );
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresInSeconds: 3600,
        deviceId: 'device-1',
      );
      AppSessionStore.install(sessionStore);
      addTearDown(AppSessionStore.reset);

      final result = await ExhibitionConsumerLayer(
        client: _client(transport),
      ).submitExhibitionReport(projectId: 'project-1');

      expect(result.isSuccess, isTrue);
      expect(reportBody, <String, Object?>{
        'targetType': 'project',
        'targetId': 'project-1',
        'reasonCode': 'fabricated_project',
      });
      expect(
        transport.requests.single.headers['authorization'],
        'Bearer access-1',
      );
    },
  );

  testWidgets('project detail exposes minimum project report action', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Map<String, Object?>? reportBody;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.projectDetail}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectDetailPayload(),
              );
            },
        'GET ${ExhibitionCanonicalPaths.projectPricingSummary('project-1')}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'projectId': 'project-1',
                  'readOnly': true,
                  'updatedAt': '2026-05-15T00:00:00Z',
                },
              );
            },
        'POST ${ExhibitionCanonicalPaths.exhibitionReportSubmit}':
            (AppApiRequest request) async {
              reportBody = request.body as Map<String, Object?>?;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'reportCaseId': 'report-case-1',
                  'targetType': 'project',
                  'targetId': 'project-1',
                  'status': 'submitted',
                  'acceptMode': 'created',
                  'traceId': 'trace-1',
                },
              );
            },
      },
    );
    ExhibitionConsumerLayer.install(
      ExhibitionConsumerLayer(client: _client(transport)),
    );
    addTearDown(ExhibitionConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProjectDetailPage(projectId: 'project-1')),
      ),
    );
    await tester.pumpAndSettle();

    final reportButton = find.widgetWithText(OutlinedButton, '举报该项目');
    await tester.scrollUntilVisible(find.text('举报该项目'), 200);
    await tester.ensureVisible(reportButton);
    await tester.tap(reportButton);
    await tester.pumpAndSettle();

    expect(reportBody, <String, Object?>{
      'targetType': 'project',
      'targetId': 'project-1',
      'reasonCode': 'fabricated_project',
    });
    expect(find.text('举报已提交，平台将进入人工复核。'), findsOneWidget);
  });
}
