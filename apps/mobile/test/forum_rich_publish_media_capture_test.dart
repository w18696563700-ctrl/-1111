import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_rich_publish_media_frontend_hotfix/20260330';

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
_forumMediaHandlers({
  String draftId = 'draft-saved-1',
  String postId = 'post-with-asset-1',
  List<String> attachmentFileAssetIds = const <String>['asset-image-1'],
  String attachmentMimeType = 'image/jpeg',
  String attachmentFileName = '现场照片.jpg',
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'POST /api/app/forum/draft/save': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'draftId': draftId,
          'state': 'ready_to_publish',
          'updatedAt': '2026-03-27T10:40:00Z',
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
            'title': '附件帖子',
            'publishedAt': '2026-03-27T11:00:00Z',
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
          'publishedAt': '2026-03-27T09:30:00Z',
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
  await tester.drag(find.byType(ListView).first, const Offset(0, -300));
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

  testWidgets('capture publish initial surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(tester, boundaryKey);
    await _fillComposer(tester, title: '附件发帖', body: '这是发帖页初始态截图。');
    await _capture(tester, boundaryKey, '01_publish_initial.png');
  });

  testWidgets('capture image selected pending surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(tester, boundaryKey);
    await _fillComposer(tester, title: '图片待上传', body: '这是图片待上传状态。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    expect(find.text('现场照片.jpg'), findsOneWidget);
    await _capture(tester, boundaryKey, '02_image_selected_pending.png');
  });

  testWidgets('capture uploading surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    final uploadCompleter = Completer<AppApiResponse>();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-capture',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-1',
      ),
      exhibitionUploadHandler: (AppApiUploadRequest request) =>
          uploadCompleter.future,
    );
    await _fillComposer(tester, title: '上传中截图', body: '这是上传中状态。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pump();
    await _capture(tester, boundaryKey, '03_uploading.png');
    uploadCompleter.complete(
      AppApiResponse(
        statusCode: 200,
        uri: Uri.parse('https://upload.example.com/asset-image-1'),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('capture confirm success surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-confirmed',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-1',
      ),
    );
    await _fillComposer(tester, title: '上传确认完成', body: '这是上传确认完成状态。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '04_confirm_success.png');
  });

  testWidgets('capture video selected pending surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场视频.mp4',
          bytes: <int>[6, 5, 4, 3, 2, 1],
        ),
      ],
    );
    await _pumpCaptureApp(tester, boundaryKey);
    await _fillComposer(tester, title: '视频待上传', body: '这是视频入口状态。');
    await tester.tap(find.text('添加视频'));
    await tester.pumpAndSettle();
    expect(find.text('现场视频.mp4'), findsOneWidget);
    await _capture(tester, boundaryKey, '05_video_selected_pending.png');
  });

  testWidgets('capture draft saved with attachment surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-saved',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-1',
      ),
      forumHandlerOverrides: _forumMediaHandlers(),
    );
    await _fillComposer(tester, title: '保存草稿态', body: '附件确认后保存草稿。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '06_draft_saved_with_attachment.png');
  });

  testWidgets('capture publish success surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-publish',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-1',
      ),
      forumHandlerOverrides: _forumMediaHandlers(),
    );
    await _fillComposer(tester, title: '发布成功态', body: '附件确认后发布。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('发布'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '07_publish_success.png');
  });

  testWidgets('capture attachment removed surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-remove',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-1',
      ),
      forumHandlerOverrides: _forumMediaHandlers(),
    );
    await _fillComposer(tester, title: '移除附件态', body: '附件移除后重新保存。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('移除').last);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '08_attachment_removed.png');
  });

  testWidgets('capture upload failure surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '失败图片.jpg',
          bytes: <int>[6, 5, 4, 3, 2, 1],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-failure',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-image-failure',
      ),
      exhibitionUploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 503, uri: Uri.parse(request.url));
      },
    );
    await _fillComposer(tester, title: '上传失败态', body: '附件上传失败时给中文反馈。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始上传').last);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '09_upload_failure.png');
  });

  testWidgets('capture post detail attachment surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-with-asset-1'),
      forumHandlerOverrides: _forumMediaHandlers(),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '10_post_detail_attachment.png');
  });
}
