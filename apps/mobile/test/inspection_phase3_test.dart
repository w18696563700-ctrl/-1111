import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'inspection']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _inspectionPayload({
  required String inspectionId,
  required String milestoneId,
  String state = 'draft',
  String summaryHeading = 'inspection',
}) {
  return <String, Object?>{
    'inspectionId': inspectionId,
    'milestoneId': milestoneId,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

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

void main() {
  testWidgets(
    'inspection detail success stays minimal and exposes submit entry',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'draft',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionDetailWithMilestoneId(
            'milestone-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('验收详情'), findsWidgets);
      expect(
        find.textContaining('当前里程碑 ID：milestone-1'),
        findsAtLeastNWidgets(1),
      );
      await tester.scrollUntilVisible(
        find.text('当前状态：草稿'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('当前验收 ID：inspection-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('当前状态：草稿'), findsOneWidget);
      expect(
        find.text('当前说明：先看清当前验收状态，再判断这一页现在是可提交、只读承接，还是保持冻结边界。'),
        findsOneWidget,
      );
      final handoffButton = find.text('继续验收提交');
      await tester.scrollUntilVisible(
        handoffButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(handoffButton, findsOneWidget);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        contains(ExhibitionCanonicalPaths.inspectionDetail),
      );
      expect(
        find.textContaining('当前里程碑 ID：milestone-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('inspection/recheck'), findsNothing);
      expect(find.textContaining('history'), findsNothing);
      expect(find.textContaining('governance'), findsNothing);
      expect(find.text('查看合同详情'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
    },
  );

  testWidgets(
    'inspection detail submitted state stays read-only and keeps recheck frozen',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'submitted',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionDetailWithMilestoneId(
            'milestone-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('当前冻结'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('继续验收提交'), findsNothing);
      expect(find.text('继续复检提交'), findsNothing);
      expect(find.text('当前冻结'), findsOneWidget);
      expect(find.text('当前状态：已提交'), findsOneWidget);
    },
  );

  testWidgets(
    'inspection submit success posts inspectionId only and keeps milestone handoff',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'draft',
                  ),
                );
              },
              'POST /api/app/inspection/submit': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'inspectionId': 'inspection-1',
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'submitted',
                    summaryHeading: 'inspection submitted',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionSubmitWithMilestoneId(
            'milestone-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('inspection_submit_button'),
      );
      await tester.scrollUntilVisible(
        find.text('页面摘要已就位，可继续讲解这次验收提交。'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('页面摘要已就位，可继续讲解这次验收提交。'), findsOneWidget);
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(submitButton, findsOneWidget);
      expect(find.widgetWithText(FilledButton, '提交验收'), findsOneWidget);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        containsAll(<String>[
          ExhibitionCanonicalPaths.inspectionDetail,
          ExhibitionCanonicalPaths.inspectionSubmit,
        ]),
      );
      expect(
        find.textContaining('当前验收 ID：inspection-1'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.textContaining('当前里程碑 ID：milestone-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('当前状态：已提交'), findsOneWidget);
      expect(find.text('页面摘要已就位，可继续讲解这次验收提交。'), findsWidgets);
      expect(find.textContaining('业务状态：已提交'), findsOneWidget);
      expect(find.text('继续复检提交'), findsNothing);
      expect(find.text('inspection/recheck'), findsNothing);
      expect(find.textContaining('history'), findsNothing);
      expect(find.textContaining('governance'), findsNothing);
      expect(find.textContaining('decision'), findsNothing);
      expect(find.text('查看合同详情'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
    },
  );

  testWidgets(
    'inspection recheck success posts inspectionId and optional recheckNote only and stays minimal',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'submitted',
                  ),
                );
              },
              'POST /api/app/inspection/recheck':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'inspectionId': 'inspection-1',
                      'recheckNote': '补充现场照片',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: _inspectionPayload(
                        inspectionId: 'inspection-1',
                        milestoneId: 'milestone-1',
                        state: 'rechecked',
                        summaryHeading: 'inspection rechecked',
                      ),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionRecheckWithMilestoneId(
            'milestone-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'recheckNote'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'recheckNote'),
        '补充现场照片',
      );

      final submitButton = find.byKey(
        const ValueKey<String>('inspection_recheck_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(FilledButton, '提交复检'), findsOneWidget);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        containsAll(<String>[
          ExhibitionCanonicalPaths.inspectionDetail,
          ExhibitionCanonicalPaths.inspectionRecheck,
        ]),
      );
      expect(
        find.textContaining('当前验收 ID：inspection-1'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.textContaining('当前里程碑 ID：milestone-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('当前状态：已复检'), findsOneWidget);
      expect(find.text('摘要承接：已承接最小 summary'), findsWidgets);
      expect(find.text('inspection/recheck'), findsNothing);
      expect(find.textContaining('history'), findsNothing);
      expect(find.textContaining('governance'), findsNothing);
      expect(find.textContaining('decision'), findsNothing);
      expect(find.text('查看合同详情'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
    },
  );

  testWidgets('draft inspection recheck stays read-only and does not post', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['milestoneId'], 'milestone-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _inspectionPayload(
                  inspectionId: 'inspection-1',
                  milestoneId: 'milestone-1',
                  state: 'draft',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.inspectionRecheckWithMilestoneId(
          'milestone-1',
        ),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('inspection_recheck_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.scrollUntilVisible(
      find.textContaining('当前业务状态：草稿'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('当前业务状态：草稿'), findsOneWidget);
    expect(find.textContaining('暂时不能继续提交复检'), findsOneWidget);
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNull);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.inspectionRecheck,
      ),
      isEmpty,
    );
  });

  testWidgets(
    'rechecked inspection recheck stays read-only and does not post',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'rechecked',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.inspectionRecheckWithMilestoneId(
            'milestone-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('inspection_recheck_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.scrollUntilVisible(
        find.textContaining('当前业务状态：已复检'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('当前业务状态：已复检'), findsOneWidget);
      expect(find.textContaining('复检已经完成'), findsWidgets);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNull);
      expect(
        transport.requests.where(
          (AppApiRequest request) =>
              request.canonicalPath ==
              ExhibitionCanonicalPaths.inspectionRecheck,
        ),
        isEmpty,
      );
    },
  );

  testWidgets('inspection detail 409 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'INSPECTION_ENTRY_UNAVAILABLE',
                  'message':
                      'inspection truth is unavailable for this milestone',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.inspectionDetailWithMilestoneId(
          'milestone-1',
        ),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final backButton = find.widgetWithText(
      FilledButton,
      '回到展览',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      backButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('error code'), findsNothing);
    expect(backButton, findsOneWidget);
  });

  testWidgets('inspection submit 400 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _inspectionPayload(
                  inspectionId: 'inspection-1',
                  milestoneId: 'milestone-1',
                ),
              );
            },
            'POST /api/app/inspection/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'INSPECTION_SUBMIT_INVALID',
                  'message': 'inspectionId is required',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.inspectionSubmitWithMilestoneId(
          'milestone-1',
        ),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('inspection_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.widgetWithText(FilledButton, '提交验收'), findsOneWidget);
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('inspectionId is required'), findsOneWidget);
    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('inspection recheck 400 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _inspectionPayload(
                  inspectionId: 'inspection-1',
                  milestoneId: 'milestone-1',
                  state: 'submitted',
                ),
              );
            },
            'POST /api/app/inspection/recheck': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'INSPECTION_RECHECK_INVALID',
                  'message': 'recheck note is invalid',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.inspectionRecheckWithMilestoneId(
          'milestone-1',
        ),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('inspection_recheck_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.widgetWithText(FilledButton, '提交复检'), findsOneWidget);
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('recheck note is invalid'), findsOneWidget);
    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  test(
    'inspection submit 409 stays controlled and does not invent truth or eligibility',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/inspection/submit':
                      (AppApiRequest request) async {
                        expect(request.body, <String, Object?>{
                          'inspectionId': 'inspection-1',
                        });
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: <String, Object?>{
                            'code': 'INSPECTION_INVALID_STATE',
                            'message': 'inspection is already submitted',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.submitInspection(
        const InspectionSubmitCommand(inspectionId: 'inspection-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'INSPECTION_INVALID_STATE');
      expect(result.message, 'inspection is already submitted');
    },
  );

  test(
    'inspection recheck 409 stays controlled and does not invent truth or eligibility',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/inspection/recheck':
                      (AppApiRequest request) async {
                        expect(request.body, <String, Object?>{
                          'inspectionId': 'inspection-1',
                          'recheckNote': '补充现场照片',
                        });
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: <String, Object?>{
                            'code': 'INSPECTION_RECHECK_LIMIT_REACHED',
                            'message': 'inspection recheck limit reached',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.recheckInspection(
        const InspectionRecheckCommand(
          inspectionId: 'inspection-1',
          recheckNote: '补充现场照片',
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'INSPECTION_RECHECK_LIMIT_REACHED');
      expect(result.message, 'inspection recheck limit reached');
    },
  );

  testWidgets('inspection detail without milestoneId enters controlled state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.inspectionDetail,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final recoveryMessage = find.textContaining(
      '当前入口还没有承接到所需里程碑或验收实例',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      recoveryMessage.first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final backButton = find.text('回到展览', skipOffstage: false);
    await tester.scrollUntilVisible(
      backButton.first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前入口还没有承接到所需里程碑或验收实例'), findsOneWidget);
    expect(find.text('回到展览'), findsWidgets);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.inspectionDetail,
      ),
      isEmpty,
    );
  });
}
