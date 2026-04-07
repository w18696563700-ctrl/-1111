import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/features/profile/presentation/profile_avatar_picker.dart';
import 'package:mobile/features/profile/presentation/profile_personal_edit_support.dart';
import 'package:mobile/shell/shell_app.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _PassthroughHttpOverrides();
    AppSessionStore.reset();
    ProfilePersonalEditConsumerLayer.reset();
    ProfileAvatarPicker.reset();
    ProfileCreditConstraintsConsumerLayer.install(
      ProfileCreditConstraintsConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/credit-and-constraints/status':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 404,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前信用与约束入口暂不可用，请稍后再试。',
                          'code':
                              'PROFILE_CREDIT_CONSTRAINTS_STATUS_UNAVAILABLE',
                        },
                      ),
                },
          ),
        ),
      ),
    );
    ProfilePaymentBillingConsumerLayer.install(
      ProfilePaymentBillingConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/payment-and-billing-status/status':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 404,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前支付与账单入口暂不可用，请稍后再试。',
                          'code':
                              'PAYMENT_AND_BILLING_STATUS_ROUTE_UNAVAILABLE',
                        },
                      ),
                },
          ),
        ),
      ),
    );
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    AppSessionStore.reset();
    ProfilePersonalEditConsumerLayer.reset();
    ProfileAvatarPicker.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
  });

  testWidgets('personal page shows avatar and nickname rows', (
    WidgetTester tester,
  ) async {
    final shellState = _MutableShellContextHarness(displayName: '张三');

    await tester.pumpWidget(
      _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
    );
    await tester.pumpAndSettle();

    expect(find.text('头像'), findsOneWidget);
    expect(find.text('昵称'), findsOneWidget);
    expect(find.text('张三'), findsWidgets);
    expect(find.text('当前只展示资料摘要；头像和昵称请通过下方两项单独设置。'), findsOneWidget);
    expect(find.text('资料审核提示'), findsOneWidget);
    expect(find.text('简介规则提示'), findsOneWidget);
    expect(find.textContaining('简介编辑入口当前未开放'), findsOneWidget);
    expect(find.textContaining('Forum Report'), findsNothing);
    expect(find.textContaining('Block'), findsNothing);
    expect(find.textContaining('Admin Review'), findsNothing);
  });

  testWidgets('tapping avatar opens personal avatar page', (
    WidgetTester tester,
  ) async {
    final shellState = _MutableShellContextHarness(displayName: '张三');

    await tester.pumpWidget(
      _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('头像'));
    await tester.pumpAndSettle();

    expect(find.text('个人头像'), findsWidgets);
    expect(find.widgetWithText(TextButton, '更换头像'), findsOneWidget);
    expect(find.text('合规提示'), findsOneWidget);
    expect(find.textContaining('新提交头像审核通过后才会替换当前公开头像'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '更换头像'));
    await tester.pumpAndSettle();

    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('tapping nickname opens nickname page', (
    WidgetTester tester,
  ) async {
    final shellState = _MutableShellContextHarness(displayName: '张三');

    await tester.pumpWidget(
      _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('昵称'));
    await tester.pumpAndSettle();

    expect(find.text('设置昵称'), findsWidgets);
    expect(find.widgetWithText(TextField, '昵称'), findsOneWidget);
    expect(find.text('规则提示'), findsOneWidget);
  });

  testWidgets('nickname page keeps submit disabled for invalid nickname', (
    WidgetTester tester,
  ) async {
    final shellState = _MutableShellContextHarness(displayName: '张三');

    await tester.pumpWidget(
      _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('昵称'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '张A');
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '完成'),
    );
    expect(button.onPressed, isNull);
    expect(find.text('昵称仅支持 1~10 个中文汉字，不支持空格、字母、数字、标点和 emoji'), findsOneWidget);
  });

  testWidgets(
    'nickname pending review keeps old value visible and shows pending hint',
    (WidgetTester tester) async {
      final shellState = _MutableShellContextHarness(displayName: '张三');
      final personalTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/profile/personal/nickname':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'nickname': '李四',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'nickname-pending-trace',
                        'safetySubmission': <String, Object?>{
                          'submissionId': 'nickname-submission-1',
                          'fieldKey': 'nickname',
                          'auditStatus': 'pending_review',
                          'pendingNickname': '李四',
                        },
                      },
                    );
                  },
            },
      );
      _installLivePersonalEditConsumer(transport: personalTransport);

      await tester.pumpWidget(
        _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
      );
      await tester.pumpAndSettle();
      final initialShellRequestCount = shellState.requestCount;

      await tester.tap(find.text('昵称'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '李四');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '完成'));
      await tester.pumpAndSettle();

      expect(shellState.displayName, '张三');
      expect(shellState.requestCount, initialShellRequestCount + 1);
      expect(find.text('设置昵称'), findsWidgets);
      expect(find.text('昵称审核中'), findsOneWidget);
      expect(find.textContaining('状态：pendingReview'), findsOneWidget);
      expect(find.textContaining('当前公开显示仍为已通过资料：张三'), findsWidgets);
      expect(find.textContaining('新提交内容审核中：李四'), findsOneWidget);
      expect(find.textContaining('审核通过后才会替换当前公开资料'), findsOneWidget);
      expect(find.textContaining('Forum Report'), findsNothing);
      expect(find.textContaining('Block'), findsNothing);
      expect(find.textContaining('Admin Review'), findsNothing);
    },
  );

  testWidgets('nickname rejected reason is shown and user can resubmit', (
    WidgetTester tester,
  ) async {
    final shellState = _MutableShellContextHarness(displayName: '张三');
    var postCount = 0;
    final personalTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/profile/personal/nickname':
                (AppApiRequest request) async {
                  postCount += 1;
                  if (postCount == 1) {
                    expect(request.body, const <String, Object?>{
                      'nickname': '李四',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'nickname-rejected-trace',
                        'safetySubmission': <String, Object?>{
                          'submissionId': 'nickname-submission-2',
                          'fieldKey': 'nickname',
                          'auditStatus': 'rejected',
                          'pendingNickname': '李四',
                          'rejectReason': '包含联系方式，请调整后重新提交。',
                        },
                      },
                    );
                  }

                  expect(request.body, const <String, Object?>{
                    'nickname': '王五',
                  });
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'ok': true,
                      'traceId': 'nickname-resubmit-trace',
                      'safetySubmission': <String, Object?>{
                        'submissionId': 'nickname-submission-3',
                        'fieldKey': 'nickname',
                        'auditStatus': 'pendingReview',
                        'pendingNickname': '王五',
                      },
                    },
                  );
                },
          },
    );
    _installLivePersonalEditConsumer(transport: personalTransport);

    await tester.pumpWidget(
      _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('昵称'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '李四');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '完成'));
    await tester.pumpAndSettle();

    expect(shellState.displayName, '张三');
    expect(find.text('昵称审核未通过'), findsOneWidget);
    expect(find.textContaining('状态：rejected'), findsOneWidget);
    expect(find.textContaining('当前公开显示仍为已通过资料：张三'), findsWidgets);
    expect(find.textContaining('拒绝原因：包含联系方式，请调整后重新提交。'), findsOneWidget);
    expect(find.textContaining('可重新提交'), findsOneWidget);
    expect(find.textContaining('保存失败'), findsNothing);

    await tester.enterText(find.byType(TextField), '王五');
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '完成'));
    await tester.pumpAndSettle();

    expect(postCount, 2);
    expect(shellState.displayName, '张三');
    expect(find.text('昵称审核中'), findsOneWidget);
    expect(find.textContaining('状态：pendingReview'), findsOneWidget);
    expect(find.textContaining('新提交内容审核中：王五'), findsOneWidget);
    expect(find.textContaining('当前公开显示仍为已通过资料：张三'), findsWidgets);
    expect(find.textContaining('Forum Report'), findsNothing);
    expect(find.textContaining('Block'), findsNothing);
    expect(find.textContaining('Admin Review'), findsNothing);
  });

  testWidgets(
    'nickname save reloads shell context and updates hub plus summary',
    (WidgetTester tester) async {
      final shellState = _MutableShellContextHarness(displayName: '张三');
      final personalTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/profile/personal/nickname':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'nickname': '李四',
                    });
                    shellState.displayName = '李四';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'nickname-trace-1',
                        'displayName': '李四',
                        'avatarUrl': null,
                      },
                    );
                  },
            },
      );
      _installLivePersonalEditConsumer(transport: personalTransport);

      await tester.pumpWidget(
        _buildApp(initialRoute: '/profile', shellState: shellState),
      );
      await tester.pumpAndSettle();
      final initialShellRequestCount = shellState.requestCount;

      expect(find.text('张三'), findsWidgets);

      await tester.tap(find.text('张三').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('昵称'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '李四');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '完成'));
      await tester.pumpAndSettle();

      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.nickname,
            )
            .length,
        1,
      );
      expect(shellState.requestCount, initialShellRequestCount + 1);
      expect(find.text('李四'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('李四'), findsWidgets);
    },
  );

  testWidgets(
    'avatar save reloads shell context and updates hub plus summary',
    (WidgetTester tester) async {
      const avatarUrl = 'http://127.0.0.1:1/avatar.png';
      final shellState = _MutableShellContextHarness(displayName: '张三')
        ..avatarUrl = avatarUrl;
      final avatarBytes = _avatarPngBytes();
      Map<String, Object?>? uploadInitBody;
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'avatar.png',
              mimeType: 'image/png',
              bytes: avatarBytes,
            ),
          ),
        ),
      );
      final personalTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                uploadInitBody = request.body as Map<String, Object?>;
                expect(uploadInitBody?['businessType'], 'profile');
                expect(uploadInitBody?['businessId'], '13812345678');
                expect(uploadInitBody?['fileKind'], 'avatar');
                expect(uploadInitBody?['mimeType'], 'image/png');
                expect(uploadInitBody?['size'], greaterThan(0));
                expect(uploadInitBody?['checksum'], isA<String>());
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'uploadSessionId': 'avatar-session-1',
                    'directUpload': <String, Object?>{
                      'url': 'https://upload.example/avatar.png',
                      'method': 'PUT',
                      'headers': <String, Object?>{'content-type': 'image/png'},
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'uploadSessionId': 'avatar-session-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'fileAssetId': 'file-asset-1',
                      },
                    );
                  },
              'POST /api/app/profile/personal/avatar':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'fileAssetId': 'file-asset-1',
                    });
                    shellState.avatarUrl = avatarUrl;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'avatar-trace-1',
                        'displayName': '张三',
                        'avatarUrl': avatarUrl,
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          expect(request.method, 'PUT');
          expect(request.url, 'https://upload.example/avatar.png');
          expect(request.headers, const <String, String>{
            'content-type': 'image/png',
          });
          expect(request.bodyBytes.length, uploadInitBody?['size']);
          expect(
            sha256.convert(request.bodyBytes).toString(),
            uploadInitBody?['checksum'],
          );
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );
      _installLivePersonalEditConsumer(transport: personalTransport);

      await tester.pumpWidget(
        _buildApp(initialRoute: '/profile', shellState: shellState),
      );
      await tester.pumpAndSettle();
      final initialShellRequestCount = shellState.requestCount;

      expect(_findAvatarBadge(avatarUrl: avatarUrl), findsOneWidget);

      await tester.tap(find.text('张三').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('头像'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, '更换头像'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, '从相册选择'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('调整头像'), findsOneWidget);
      expect(find.text('旋转'), findsOneWidget);
      expect(find.text('还原'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '完成'), findsOneWidget);
      await _pumpUntilAvatarDoneEnabled(tester);
      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.uploadInit,
            )
            .length,
        0,
      );

      await tester.tap(find.widgetWithText(FilledButton, '完成'));
      for (var index = 0; index < 40; index += 1) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
        if (shellState.requestCount > initialShellRequestCount) {
          break;
        }
      }

      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.uploadInit,
            )
            .length,
        1,
      );
      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.uploadConfirm,
            )
            .length,
        1,
      );
      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.avatar,
            )
            .length,
        1,
      );
      expect(personalTransport.uploads.length, 1);
      expect(shellState.requestCount, initialShellRequestCount + 1);
      expect(_findAvatarBadge(avatarUrl: avatarUrl), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'nickname write stays fail-closed when readback does not change',
    (WidgetTester tester) async {
      final shellState = _MutableShellContextHarness(displayName: '张三');
      final personalTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/profile/personal/nickname':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'nickname': '李四',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ok': true,
                        'traceId': 'nickname-trace-stale',
                        'displayName': '李四',
                        'avatarUrl': null,
                      },
                    );
                  },
            },
      );
      _installLivePersonalEditConsumer(transport: personalTransport);

      await tester.pumpWidget(
        _buildApp(initialRoute: ProfileRoutes.personal, shellState: shellState),
      );
      await tester.pumpAndSettle();
      final initialShellRequestCount = shellState.requestCount;

      await tester.tap(find.text('昵称'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '李四');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '完成'));
      await tester.pumpAndSettle();

      expect(
        personalTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ProfilePersonalEditCanonicalPaths.nickname,
            )
            .length,
        1,
      );
      expect(shellState.requestCount, initialShellRequestCount + 1);
      expect(find.text('设置昵称'), findsWidgets);
      expect(find.text('昵称回读当前未更新'), findsOneWidget);
      expect(find.text('当前昵称写入虽已返回，但正式回读仍未更新，页面保持受控失败。'), findsOneWidget);
    },
  );
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required _MutableShellContextHarness shellState,
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'personal-edit-access-token',
      refreshToken: 'personal-edit-refresh-token',
      expiresInSeconds: 3600,
      deviceId: 'personal-edit-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    shellContextConsumer: shellState.consumer,
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/index': (AppApiRequest request) async =>
                    AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organization': <String, Object?>{
                          'organizationId': 'org-1',
                          'roleKeys': <String>['buyer_admin'],
                          'visibleBuildings': <String>[
                            'exhibition',
                            'messages',
                            'profile',
                          ],
                        },
                        'certification': <String, Object?>{
                          'status': 'approved',
                        },
                        'membership': <String, Object?>{'status': 'active'},
                        'settingsEntry': <String, Object?>{'state': 'visible'},
                      },
                    ),
              },
        ),
      ),
    ),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/my/projects': (AppApiRequest request) async =>
                    AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ongoingProjects': <Object?>[],
                        'historicalProjects': <Object?>[],
                      },
                    ),
              },
        ),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: _forumHandlers()),
      ),
    ),
    sessionStore: sessionStore,
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        _pagedEmptyResponse(request),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        _pagedEmptyResponse(request),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        _pagedEmptyResponse(request),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        _pagedEmptyResponse(request),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        _pagedEmptyResponse(request),
  };
}

AppApiResponse _pagedEmptyResponse(AppApiRequest request) {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: const <String, Object?>{
      'items': <Object?>[],
      'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
    },
  );
}

Finder _findAvatarBadge({required String? avatarUrl}) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is ProfileAvatarBadge && widget.avatarUrl == avatarUrl,
    description: 'ProfileAvatarBadge avatarUrl=$avatarUrl',
  );
}

List<int> _avatarPngBytes() {
  final image = image_lib.Image(width: 64, height: 64);
  for (final pixel in image) {
    pixel.setRgb(160, 118, 72);
  }
  return image_lib.encodePng(image);
}

Future<void> _pumpUntilAvatarDoneEnabled(WidgetTester tester) async {
  for (var index = 0; index < 40; index += 1) {
    final doneButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '完成'),
    );
    if (doneButton.onPressed != null) {
      return;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
}

class _MutableShellContextHarness {
  _MutableShellContextHarness({required this.displayName});

  String? displayName;
  String? avatarUrl;
  late final FakeAppApiTransport transport = FakeAppApiTransport(
    handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
      'GET /api/app/shell/context': (AppApiRequest request) async =>
          AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'userId': '13812345678',
              'displayName': displayName,
              'avatarUrl': avatarUrl,
              'organizationId': 'org-1',
              'roleKeys': <String>['buyer_admin'],
              'certificationStatus': 'approved',
              'membershipStatus': 'active',
              'visibleBuildings': <String>['exhibition', 'messages', 'profile'],
              'featureFlagsVersion': '0.1.0',
              'unreadSummary': <String, Object?>{
                'total': 0,
                'system': 0,
                'business': 0,
              },
            },
          ),
    },
  );
  late final AppShellContextConsumer consumer = AppShellContextConsumer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: transport,
    ),
  );

  int get requestCount => transport.requests
      .where(
        (AppApiRequest request) =>
            request.canonicalPath == '/api/app/shell/context',
      )
      .length;
}

void _installLivePersonalEditConsumer({
  required FakeAppApiTransport transport,
}) {
  ProfilePersonalEditConsumerLayer.install(
    ProfilePersonalEditConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
  );
}

class _FakeProfileAvatarPicker implements ProfileAvatarPicker {
  _FakeProfileAvatarPicker({required this.result});

  final ProfileAvatarPickResult result;

  @override
  Future<ProfileAvatarPickResult> pick({
    required ProfileAvatarPickSource source,
  }) async {
    return result;
  }
}

class _PassthroughHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.userAgent = 'flutter-test';
    return client;
  }
}
