import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

Map<String, Object?> _postDetailWithAttachment({
  required String fileAssetId,
  required String fileName,
  required String mimeType,
}) {
  return _postDetailWithAttachments(
    attachments: <Map<String, Object?>>[
      _attachmentRef(
        fileAssetId: fileAssetId,
        fileName: fileName,
        mimeType: mimeType,
      ),
    ],
  );
}

Map<String, Object?> _postDetailWithAttachments({
  required List<Map<String, Object?>> attachments,
}) {
  return <String, Object?>{
    'postId': 'post-access-1',
    'topicId': 'expo-materials',
    'topicTitle': '布展进场',
    'state': 'published',
    'author': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
      'organizationName': '展览协作组',
    },
    'content': '已发布附件读取测试正文',
    'attachmentRefs': attachments,
    'engagement': <String, Object?>{
      'replyCount': 0,
      'likeCount': 0,
      'viewCount': 0,
    },
    'publishedAt': '2026-03-31T12:00:00Z',
    'viewerHasLiked': false,
    'viewerHasBookmarked': false,
    'viewerFollowsTopic': false,
  };
}

Map<String, Object?> _attachmentRef({
  required String fileAssetId,
  required String fileName,
  required String mimeType,
}) {
  return <String, Object?>{
    'fileAssetId': fileAssetId,
    'fileName': fileName,
    'mimeType': mimeType,
  };
}

Future<void> _pumpPostDetail(
  WidgetTester tester, {
  required Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  forumHandlerOverrides,
}) async {
  await tester.pumpWidget(
    buildForumTestAppWithOverrides(
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-1'),
      forumHandlerOverrides: forumHandlerOverrides,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToAttachment(WidgetTester tester, String fileName) async {
  final target = find.text(fileName);
  final viewportHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  for (var i = 0; i < 7; i += 1) {
    if (tester.any(target)) {
      final center = tester.getCenter(target);
      if (center.dy > 20 && center.dy < viewportHeight - 20) {
        break;
      }
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
}

Future<void> _ensureVisibleAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ForumDetailAttachmentDebugOverrides.reset();
  });

  tearDown(() {
    ForumDetailAttachmentDebugOverrides.reset();
  });

  testWidgets('published image attachment previews via file access', (
    WidgetTester tester,
  ) async {
    var requested = false;

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachment(
                  fileAssetId: 'asset-image-1',
                  fileName: '现场照片.jpg',
                  mimeType: 'image/jpeg',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              requested = true;
              expect(
                request.uri.queryParameters['fileAssetId'],
                'asset-image-1',
              );
              expect(request.uri.queryParameters['mode'], 'preview');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-image-1',
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/image.jpg?sig=1',
                  'fileName': '现场照片.jpg',
                  'mimeType': 'image/jpeg',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 1024,
                },
              );
            },
          },
    );

    expect(requested, isTrue);
    expect(
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-1')),
      findsOneWidget,
    );

    await _ensureVisibleAndTap(
      tester,
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-1')),
    );

    expect(find.text('图片预览'), findsOneWidget);
  });

  testWidgets('published image attachments render as two-column image grid', (
    WidgetTester tester,
  ) async {
    final requestedIds = <String>[];

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachments(
                  attachments: <Map<String, Object?>>[
                    _attachmentRef(
                      fileAssetId: 'asset-image-a',
                      fileName: '现场照片A.jpg',
                      mimeType: 'image/jpeg',
                    ),
                    _attachmentRef(
                      fileAssetId: 'asset-image-b',
                      fileName: '现场照片B.png',
                      mimeType: 'image/png',
                    ),
                  ],
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              final fileAssetId = request.uri.queryParameters['fileAssetId']!;
              requestedIds.add(fileAssetId);
              expect(request.uri.queryParameters['mode'], 'preview');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'fileAssetId': fileAssetId,
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/$fileAssetId.jpg',
                  'fileName': '$fileAssetId.jpg',
                  'mimeType': 'image/jpeg',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 1024,
                },
              );
            },
          },
    );

    expect(find.text('正文图片'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-b')),
      findsOneWidget,
    );
    expect(find.text('现场照片A.jpg'), findsNothing);
    expect(find.text('现场照片B.png'), findsNothing);
    expect(
      requestedIds,
      containsAll(<String>['asset-image-a', 'asset-image-b']),
    );
  });

  testWidgets('published image grid caps at nine and shows overflow count', (
    WidgetTester tester,
  ) async {
    final requestedIds = <String>[];

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachments(
                  attachments: List<Map<String, Object?>>.generate(10, (
                    int index,
                  ) {
                    final ordinal = index + 1;
                    return _attachmentRef(
                      fileAssetId: 'asset-image-$ordinal',
                      fileName: '现场照片$ordinal.jpg',
                      mimeType: 'image/jpeg',
                    );
                  }),
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              final fileAssetId = request.uri.queryParameters['fileAssetId']!;
              requestedIds.add(fileAssetId);
              expect(request.uri.queryParameters['mode'], 'preview');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'fileAssetId': fileAssetId,
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/$fileAssetId.jpg',
                  'fileName': '$fileAssetId.jpg',
                  'mimeType': 'image/jpeg',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 1024,
                },
              );
            },
          },
    );

    for (var ordinal = 1; ordinal <= 9; ordinal += 1) {
      expect(
        find.byKey(ValueKey('forum-detail-image-tile-asset-image-$ordinal')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-10')),
      findsNothing,
    );
    expect(find.text('+1'), findsOneWidget);
    expect(requestedIds, isNot(contains('asset-image-10')));
  });

  testWidgets('image grid keeps non-image attachments in attachment list', (
    WidgetTester tester,
  ) async {
    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachments(
                  attachments: <Map<String, Object?>>[
                    _attachmentRef(
                      fileAssetId: 'asset-image-mixed',
                      fileName: '现场照片.jpg',
                      mimeType: 'image/jpeg',
                    ),
                    _attachmentRef(
                      fileAssetId: 'asset-file-mixed',
                      fileName: '交付清单.pdf',
                      mimeType: 'application/pdf',
                    ),
                  ],
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              expect(
                request.uri.queryParameters['fileAssetId'],
                'asset-image-mixed',
              );
              expect(request.uri.queryParameters['mode'], 'preview');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-image-mixed',
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/mixed.jpg',
                  'fileName': '现场照片.jpg',
                  'mimeType': 'image/jpeg',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 1024,
                },
              );
            },
          },
    );

    expect(find.text('正文图片'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-mixed')),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('附件'), findsOneWidget);
    expect(find.text('交付清单.pdf'), findsOneWidget);
    expect(find.text('现场照片.jpg'), findsNothing);
  });

  testWidgets('image grid failed access can retry without raw error', (
    WidgetTester tester,
  ) async {
    var attempts = 0;

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachment(
                  fileAssetId: 'asset-image-retry',
                  fileName: '重试照片.jpg',
                  mimeType: 'image/jpeg',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              attempts += 1;
              expect(
                request.uri.queryParameters['fileAssetId'],
                'asset-image-retry',
              );
              expect(request.uri.queryParameters['mode'], 'preview');
              if (attempts == 1) {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FILE_ACCESS_UNAVAILABLE',
                    'message': 'FILE_ACCESS_UNAVAILABLE from upstream',
                  },
                );
              }
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-image-retry',
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/retry.jpg',
                  'fileName': '重试照片.jpg',
                  'mimeType': 'image/jpeg',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 1024,
                },
              );
            },
          },
    );

    expect(find.text('点击重试'), findsOneWidget);
    expect(find.text('FILE_ACCESS_UNAVAILABLE from upstream'), findsNothing);

    await _ensureVisibleAndTap(
      tester,
      find.byKey(const ValueKey('forum-detail-image-tile-asset-image-retry')),
    );

    expect(attempts, 2);
  });

  testWidgets('published video attachment opens external preview url', (
    WidgetTester tester,
  ) async {
    Uri? openedUri;
    ForumDetailAttachmentDebugOverrides.installExternalUrlOpener((
      Uri uri,
    ) async {
      openedUri = uri;
      return true;
    });

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachment(
                  fileAssetId: 'asset-video-1',
                  fileName: '进场演示.mp4',
                  mimeType: 'video/mp4',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              expect(
                request.uri.queryParameters['fileAssetId'],
                'asset-video-1',
              );
              expect(request.uri.queryParameters['mode'], 'preview');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-video-1',
                  'mode': 'preview',
                  'accessUrl': 'https://files.example.com/video.mp4?sig=2',
                  'fileName': '进场演示.mp4',
                  'mimeType': 'video/mp4',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 2048,
                },
              );
            },
          },
    );

    await _scrollToAttachment(tester, '进场演示.mp4');
    await tester.tap(find.text('进场演示.mp4'));
    await tester.pumpAndSettle();

    expect(find.text('视频预览'), findsOneWidget);
    expect(find.text('调用设备播放器'), findsOneWidget);
    expect(openedUri, isNull);

    await tester.tap(find.text('调用设备播放器'));
    await tester.pumpAndSettle();

    expect(openedUri?.toString(), 'https://files.example.com/video.mp4?sig=2');
    expect(find.text('已调用设备播放器'), findsOneWidget);
  });

  testWidgets('published file attachment opens external download url', (
    WidgetTester tester,
  ) async {
    Uri? openedUri;
    ForumDetailAttachmentDebugOverrides.installExternalUrlOpener((
      Uri uri,
    ) async {
      openedUri = uri;
      return true;
    });

    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachment(
                  fileAssetId: 'asset-file-1',
                  fileName: '交付清单.pdf',
                  mimeType: 'application/pdf',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              expect(
                request.uri.queryParameters['fileAssetId'],
                'asset-file-1',
              );
              expect(request.uri.queryParameters['mode'], 'download');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-file-1',
                  'mode': 'download',
                  'accessUrl': 'https://files.example.com/brief.pdf?sig=3',
                  'fileName': '交付清单.pdf',
                  'mimeType': 'application/pdf',
                  'expiresAt': '2026-03-31T13:00:00Z',
                  'contentLengthBytes': 4096,
                },
              );
            },
          },
    );

    await _scrollToAttachment(tester, '交付清单.pdf');
    await tester.tap(find.text('交付清单.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('文件预览'), findsOneWidget);
    expect(find.text('调用设备打开'), findsOneWidget);
    expect(openedUri, isNull);

    await tester.tap(find.text('调用设备打开'));
    await tester.pumpAndSettle();

    expect(openedUri?.toString(), 'https://files.example.com/brief.pdf?sig=3');
    expect(find.text('已调用设备打开附件'), findsOneWidget);
  });

  testWidgets(
    'published file attachment shows fallback sheet when external open fails',
    (WidgetTester tester) async {
      ForumDetailAttachmentDebugOverrides.installExternalUrlOpener((
        Uri uri,
      ) async {
        return false;
      });

      await _pumpPostDetail(
        tester,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/post/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _postDetailWithAttachment(
                    fileAssetId: 'asset-file-2',
                    fileName: '报价单.pdf',
                    mimeType: 'application/pdf',
                  ),
                );
              },
              'GET /api/app/file/access': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'fileAssetId': 'asset-file-2',
                    'mode': 'download',
                    'accessUrl': 'https://files.example.com/quote.pdf?sig=4',
                    'fileName': '报价单.pdf',
                    'mimeType': 'application/pdf',
                    'expiresAt': '2026-03-31T13:00:00Z',
                    'contentLengthBytes': 4096,
                  },
                );
              },
            },
      );

      await _scrollToAttachment(tester, '报价单.pdf');
      await tester.tap(find.text('报价单.pdf'));
      await tester.pumpAndSettle();

      expect(find.text('文件预览'), findsOneWidget);
      expect(find.text('调用设备打开'), findsOneWidget);
      expect(find.text('复制链接'), findsOneWidget);
    },
  );

  testWidgets('file access 409 is shown in controlled Chinese message', (
    WidgetTester tester,
  ) async {
    await _pumpPostDetail(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _postDetailWithAttachment(
                  fileAssetId: 'asset-unavailable-1',
                  fileName: '已解绑文件.pdf',
                  mimeType: 'application/pdf',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FILE_ACCESS_UNAVAILABLE',
                  'message': 'FILE_ACCESS_UNAVAILABLE from upstream',
                },
              );
            },
          },
    );

    await _scrollToAttachment(tester, '已解绑文件.pdf');
    await tester.tap(find.text('已解绑文件.pdf'));
    await tester.pump();

    expect(find.text('当前附件暂时不能读取'), findsOneWidget);
  });
}
