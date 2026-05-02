import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets('post detail can submit bounded report', (
    WidgetTester tester,
  ) async {
    Map<String, Object?>? reportBody;
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/report/submit':
                  (AppApiRequest request) async {
                    reportBody = request.body as Map<String, Object?>?;
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'submitted',
                        'message': '举报已提交',
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    _openPostReportSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('刷屏 / 灌水'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, '补充说明（可选）'),
      '重复刷屏影响阅读',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '提交举报'));
    await tester.pumpAndSettle();

    expect(reportBody, <String, Object?>{
      'targetType': 'post',
      'targetId': 'post-materials-1',
      'reasonCode': 'spam_or_flood',
      'reasonDetail': '重复刷屏影响阅读',
    });
    expect(find.text('举报已提交'), findsOneWidget);
    expect(find.textContaining('ForumReport'), findsNothing);
  });

  testWidgets('comment item can submit duplicate report with bounded result', (
    WidgetTester tester,
  ) async {
    Map<String, Object?>? reportBody;
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/report/submit':
                  (AppApiRequest request) async {
                    reportBody = request.body as Map<String, Object?>?;
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'accepted_existing',
                        'message': '已存在处理中举报',
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('评论区'), 200);
    await tester.pumpAndSettle();
    final reportFinder = find.byIcon(Icons.flag_outlined).last;
    await tester.ensureVisible(reportFinder);
    await tester.pumpAndSettle();
    await tester.tap(reportFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('辱骂 / 人身攻击'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, '补充说明（可选）'),
      '评论里出现人身攻击',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '提交举报'));
    await tester.pumpAndSettle();

    expect(reportBody, <String, Object?>{
      'targetType': 'comment',
      'targetId': 'comment-2',
      'reasonCode': 'abuse_or_insult',
      'reasonDetail': '评论里出现人身攻击',
    });
    expect(find.text('已存在处理中举报'), findsOneWidget);
    expect(find.textContaining('ReviewTask'), findsNothing);
  });

  test('invalid report reason does not submit request', () async {
    var submitCount = 0;
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/report/submit': (AppApiRequest request) async {
              submitCount += 1;
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'status': 'submitted',
                  'message': '举报已提交',
                },
              );
            },
          },
    );
    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    );

    final result = await consumer.submitReport(
      targetType: 'post',
      targetId: 'post-materials-1',
      reasonCode: 'not_allowed',
      reasonDetail: '无效原因',
    );

    expect(result.isSuccess, isFalse);
    expect(result.message, '请先选择举报原因后再提交');
    expect(submitCount, 0);
    expect(transport.requests, isEmpty);
  });

  testWidgets('malformed report keeps controlled Chinese error inline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/report/submit':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 400,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'FORUM_REPORT_INVALID',
                        'message': '举报目标类型无效，请重新选择后再试。',
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    _openPostReportSheet(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('其他'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '提交举报'));
    await tester.pumpAndSettle();

    expect(find.text('举报目标类型无效，请重新选择后再试。'), findsOneWidget);
    expect(find.text('举报已提交'), findsNothing);
    expect(find.textContaining('targetId'), findsNothing);
  });

  testWidgets('no-auth report keeps session-invalid prompt controlled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/report/submit':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 401,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'AUTH_SESSION_INVALID',
                        'message': '当前登录状态已失效，请重新登录后再试。',
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    _openPostReportSheet(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('广告 / 导流'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '提交举报'));
    await tester.pumpAndSettle();

    expect(find.text('当前登录状态已失效，请重新登录后再试。'), findsOneWidget);
    expect(find.text('举报已提交'), findsNothing);
    expect(find.textContaining('reportId'), findsNothing);
  });
}

void _openPostReportSheet(WidgetTester tester) {
  final reportAction = find
      .ancestor(of: find.text('举报'), matching: find.byType(InkWell))
      .last;
  tester.widget<InkWell>(reportAction).onTap?.call();
}
