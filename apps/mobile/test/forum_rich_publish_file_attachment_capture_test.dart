import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_rich_publish_file_attachment_frontend/20260330';

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_uploadHandlers({
  required String uploadSessionId,
  required String mimeType,
  required String fileAssetId,
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'POST /api/app/file/upload/init': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'uploadSessionId': uploadSessionId,
          'directUpload': <String, Object?>{
            'url': 'https://upload.example.com/$fileAssetId',
            'method': 'PUT',
            'headers': <String, Object?>{'content-type': mimeType},
          },
          'confirm': const <String, Object?>{
            'endpoint': '/api/app/file/upload/confirm',
          },
        },
      );
    },
    'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{'fileAssetId': fileAssetId},
      );
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumFileHandlers({
  String draftId = 'draft-file-1',
  String postId = 'post-file-1',
  List<String> attachmentFileAssetIds = const <String>['asset-file-1'],
  String attachmentMimeType = 'application/pdf',
  String attachmentFileName = '现场交付清单.pdf',
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'POST /api/app/forum/draft/save': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'draftId': draftId,
          'state': 'ready_to_publish',
          'updatedAt': '2026-03-30T19:40:00Z',
        },
      );
    },
    'POST /api/app/forum/publish': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'draftId': draftId,
          'topicId': 'expo-materials',
          'postId': postId,
          'state': 'published',
          'summary': const <String, Object?>{
            'title': '文件附件帖子',
            'publishedAt': '2026-03-30T20:00:00Z',
          },
          'decision': 'clear',
          'message': '发布成功',
        },
      );
    },
    'GET /api/app/forum/post/detail': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'postId': postId,
          'topicId': 'expo-materials',
          'topicTitle': '布展进场',
          'state': 'published',
          'author': const <String, Object?>{
            'authorId': 'member-1',
            'displayName': '赵工',
          },
          'content': '正式帖子正文',
          'attachmentRefs': attachmentFileAssetIds
              .map(
                (String item) => <String, Object?>{
                  'fileAssetId': item,
                  'fileName': attachmentFileName,
                  'mimeType': attachmentMimeType,
                },
              )
              .toList(growable: false),
          'publishedAt': '2026-03-30T18:30:00Z',
          'viewerHasLiked': false,
          'viewerHasBookmarked': false,
          'viewerFollowsTopic': true,
        },
      );
    },
  };
}

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      exhibitionHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Future<AppApiResponse> Function(AppApiUploadRequest request)?
  exhibitionUploadHandler,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  String initialRoute = ExhibitionRoutes.forumPublish,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: initialRoute,
          exhibitionHandlerOverrides: exhibitionHandlerOverrides,
          exhibitionUploadHandler: exhibitionUploadHandler,
          forumHandlerOverrides: forumHandlerOverrides,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillComposer(
  WidgetTester tester, {
  required String title,
  required String body,
}) async {
  await tester.enterText(find.byType(TextField).at(0), title);
  await tester.enterText(find.byType(TextField).at(1), body);
  await tester.pump();
  await tester.drag(find.byType(ListView).first, const Offset(0, -320));
  await tester.pumpAndSettle();
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ForumPublishMediaDebugOverrides.reset();
  });

  testWidgets('capture file selected pending surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场交付清单.pdf',
          bytes: <int>[37, 80, 68, 70, 45, 49, 46, 55],
        ),
      ],
    );
    await _pumpCaptureApp(tester, boundaryKey);
    await _fillComposer(tester, title: '文件待上传', body: '这是文件待上传状态。');
    await tester.tap(find.text('添加文件'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '01_file_selected_pending.png');
  });

  testWidgets('capture file confirm success surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场交付清单.pdf',
          bytes: <int>[37, 80, 68, 70, 45, 49, 46, 55],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-file-confirmed',
        mimeType: 'application/pdf',
        fileAssetId: 'asset-file-1',
      ),
    );
    await _fillComposer(tester, title: '文件确认完成', body: '这是文件确认完成状态。');
    await tester.tap(find.text('添加文件'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '02_file_confirm_success.png');
  });

  testWidgets('capture file draft saved surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场交付清单.pdf',
          bytes: <int>[37, 80, 68, 70, 45, 49, 46, 55],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-file-saved',
        mimeType: 'application/pdf',
        fileAssetId: 'asset-file-1',
      ),
      forumHandlerOverrides: _forumFileHandlers(),
    );
    await _fillComposer(tester, title: '文件草稿已承接', body: '文件确认后保存草稿。');
    await tester.tap(find.text('添加文件'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '03_file_draft_saved.png');
  });

  testWidgets('capture file upload failure surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场交付清单.pdf',
          bytes: <int>[37, 80, 68, 70, 45, 49, 46, 55],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-file-failure',
        mimeType: 'application/pdf',
        fileAssetId: 'asset-file-failure',
      ),
      exhibitionUploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 503, uri: Uri.parse(request.url));
      },
    );
    await _fillComposer(tester, title: '文件上传失败', body: '文件上传失败时应给中文反馈。');
    await tester.tap(find.text('添加文件'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '04_file_upload_failure.png');
  });

  testWidgets('capture post detail file attachment surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-file-1'),
      forumHandlerOverrides: _forumFileHandlers(),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '05_post_detail_file_attachment.png');
  });
}
