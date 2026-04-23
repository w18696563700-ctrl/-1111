import 'dart:async';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';

Future<void> main() async {
  final client = AppApiClient(
    config: AppApiConfig(baseUrl: AppApiEntryTarget.sshTunnelBaseUrl),
  );

  Future<void> probe(String label, Future<AppApiResponse> Function() run) async {
    try {
      final res = await run();
      // Keep output short and deterministic for agent receipts.
      print('[$label] status=${res.statusCode} path=${res.uri.path}');
      if (res.body != null) {
        print('[$label] body=${res.body}');
      }
    } on TimeoutException catch (e) {
      print('[$label] timeout $e');
    } catch (e) {
      print('[$label] exception $e');
      rethrow;
    }
  }

  await probe('draft_save_cn', () {
    return client.post(
      '/api/app/forum/draft/save',
      body: <String, Object?>{
        'draftId': null,
        'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
        'title': '中文草稿标题（UTF-8探针）',
        'body': '中文正文：测试 transport JSON 编码，不应因中文直接崩溃。',
        'attachmentFileAssetIds': <String>[],
      },
    );
  });

  await probe('comment_submit_cn', () {
    return client.post(
      '/api/app/forum/post/comment',
      body: <String, Object?>{
        'postId': 'post-probe',
        'body': '中文评论：这是一条 UTF-8 提交探针。',
      },
    );
  });
}
