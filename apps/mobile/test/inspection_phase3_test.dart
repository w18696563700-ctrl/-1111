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
    'inspection detail success stays minimal and remains read-only in draft state',
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
      await tester.scrollUntilVisible(
        find.text('当前不在这里开放'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('继续验收提交'), findsNothing);
      expect(find.text('当前不在这里开放'), findsOneWidget);
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
    'inspection detail submitted state exposes the minimal recheck entry only',
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

      final recheckButton = find.byKey(
        const ValueKey<String>('inspection_recheck_button'),
      );
      await tester.scrollUntilVisible(
        recheckButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('继续验收提交'), findsNothing);
      expect(recheckButton, findsOneWidget);
      expect(
        find.text('当前验收已经提交完成；如果需要最小复检，可以直接在这里执行。复检成功后页面会刷新验收详情。'),
        findsOneWidget,
      );
      expect(find.text('inspection/recheck'), findsNothing);
    },
  );

  testWidgets(
    'inspection recheck success posts inspectionId and refreshes inspection detail only',
    (WidgetTester tester) async {
      var inspectionDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                inspectionDetailRequestCount += 1;
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
                    state: inspectionDetailRequestCount == 1
                        ? 'submitted'
                        : 'rechecked',
                  ),
                );
              },
              'POST /api/app/inspection/recheck': (
                AppApiRequest request,
              ) async {
                expect(request.body, <String, Object?>{
                  'inspectionId': 'inspection-1',
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _inspectionPayload(
                    inspectionId: 'inspection-1',
                    milestoneId: 'milestone-1',
                    state: 'rechecked',
                    summaryHeading: 'inspection recheck accepted',
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

      final recheckButton = find.byKey(
        const ValueKey<String>('inspection_recheck_button'),
      );
      await tester.scrollUntilVisible(
        recheckButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(recheckButton, findsOneWidget);
      await tester.ensureVisible(recheckButton);
      await tester.pumpAndSettle();
      await tester.tap(recheckButton);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('验收复检入口已受理'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsOneWidget);
      expect(find.text('验收复检入口已受理'), findsOneWidget);
      expect(
        find.text('当前验收已经完成复检，页面继续保留只读结果承接。'),
        findsOneWidget,
      );
      expect(recheckButton, findsNothing);
      expect(inspectionDetailRequestCount, 2);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.inspectionRecheck,
            )
            .length,
        1,
      );
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
                    state: 'draft',
                    summaryHeading: 'inspection handoff accepted',
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
      expect(find.widgetWithText(FilledButton, '继续验收提交'), findsOneWidget);
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
      expect(find.text('验收提交入口已受理'), findsOneWidget);
      expect(find.text('页面摘要已就位，可继续讲解这次验收提交。'), findsWidgets);
      expect(find.textContaining('业务状态：草稿'), findsAtLeastNWidgets(1));
      expect(find.text('当前说明：当前验收提交入口已经受理，后续仍以验收详情真值为准。'), findsOneWidget);
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
    expect(find.widgetWithText(FilledButton, '继续验收提交'), findsOneWidget);
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
