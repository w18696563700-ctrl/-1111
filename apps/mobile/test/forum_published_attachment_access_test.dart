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
    'attachmentRefs': <Object?>[
      <String, Object?>{
        'fileAssetId': fileAssetId,
        'fileName': fileName,
        'mimeType': mimeType,
      },
    ],
    'publishedAt': '2026-03-31T12:00:00Z',
    'viewerHasLiked': false,
    'viewerHasBookmarked': false,
    'viewerFollowsTopic': false,
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

    await tester.tap(find.text('现场照片.jpg'));
    await tester.pumpAndSettle();

    expect(requested, isTrue);
    expect(find.text('图片预览'), findsOneWidget);
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

    await tester.tap(find.text('进场演示.mp4'));
    await tester.pumpAndSettle();

    expect(openedUri?.toString(), 'https://files.example.com/video.mp4?sig=2');
    expect(find.text('已打开视频预览'), findsOneWidget);
    expect(find.text('视频预览链接'), findsNothing);
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

    await tester.tap(find.text('交付清单.pdf'));
    await tester.pumpAndSettle();

    expect(openedUri?.toString(), 'https://files.example.com/brief.pdf?sig=3');
    expect(find.text('已交给系统处理下载'), findsOneWidget);
    expect(find.text('文件下载链接'), findsNothing);
  });

  testWidgets('published file attachment shows fallback sheet when external open fails', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.text('报价单.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('文件下载链接'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
  });

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

    await tester.tap(find.text('已解绑文件.pdf'));
    await tester.pump();

    expect(find.text('当前附件暂时不能读取'), findsOneWidget);
  });
}
