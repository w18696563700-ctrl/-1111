import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_published_attachment_access_frontend/20260331';

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: initialRoute,
          forumHandlerOverrides: forumHandlerOverrides,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

Map<String, Object?> _detailWithSingleAttachment({
  required String fileAssetId,
  required String fileName,
  required String mimeType,
}) {
  return <String, Object?>{
    'postId': 'post-access-capture',
    'topicId': 'expo-materials',
    'topicTitle': '布展进场',
    'state': 'published',
    'author': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
      'organizationName': '展览协作组',
    },
    'content': 'capture detail attachment access',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ForumPublishMediaDebugOverrides.reset();
    ForumDetailAttachmentDebugOverrides.reset();
  });

  testWidgets('capture published attachment access frontend screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      ForumPublishMediaDebugOverrides.reset();
      ForumDetailAttachmentDebugOverrides.reset();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-capture'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'postId': 'post-access-capture',
                  'topicId': 'expo-materials',
                  'topicTitle': '布展进场',
                  'state': 'published',
                  'author': <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                    'organizationName': '展览协作组',
                  },
                  'content': 'attachment overview',
                  'attachmentRefs': <Object?>[
                    <String, Object?>{
                      'fileAssetId': 'asset-image-overview',
                      'fileName': '现场照片.jpg',
                      'mimeType': 'image/jpeg',
                    },
                    <String, Object?>{
                      'fileAssetId': 'asset-video-overview',
                      'fileName': '进场演示.mp4',
                      'mimeType': 'video/mp4',
                    },
                    <String, Object?>{
                      'fileAssetId': 'asset-file-overview',
                      'fileName': '交付清单.pdf',
                      'mimeType': 'application/pdf',
                    },
                  ],
                  'publishedAt': '2026-03-31T12:00:00Z',
                  'viewerHasLiked': false,
                  'viewerHasBookmarked': false,
                  'viewerFollowsTopic': false,
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '05_post_detail_attachment_overview.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-capture'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _detailWithSingleAttachment(
                  fileAssetId: 'asset-image-1',
                  fileName: '现场照片.jpg',
                  mimeType: 'image/jpeg',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-image-1',
                  'mode': 'preview',
                  'accessUrl':
                      'https://files.example.com/capture-image.jpg?sig=1',
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
    await _capture(boundaryKey, '01_published_image_preview.png');

    ForumDetailAttachmentDebugOverrides.installExternalUrlOpener((
      Uri uri,
    ) async {
      return true;
    });
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-capture'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _detailWithSingleAttachment(
                  fileAssetId: 'asset-video-1',
                  fileName: '进场演示.mp4',
                  mimeType: 'video/mp4',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-video-1',
                  'mode': 'preview',
                  'accessUrl':
                      'https://files.example.com/capture-video.mp4?sig=2',
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
    await tester.pump();
    await _capture(boundaryKey, '02_published_video_preview.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-capture'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _detailWithSingleAttachment(
                  fileAssetId: 'asset-file-1',
                  fileName: '交付清单.pdf',
                  mimeType: 'application/pdf',
                ),
              );
            },
            'GET /api/app/file/access': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'asset-file-1',
                  'mode': 'download',
                  'accessUrl':
                      'https://files.example.com/capture-brief.pdf?sig=3',
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
    await tester.pump();
    await _capture(boundaryKey, '03_published_file_download.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-access-capture'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _detailWithSingleAttachment(
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
    await _capture(boundaryKey, '04_file_access_controlled_error.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublish,
    );
    await _capture(boundaryKey, '06_publish_attachment_entry_still_normal.png');
  });
}
