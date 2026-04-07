import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';

void main() {
  test('UTF-8 Chinese JSON body does not crash transport', () async {
    final client = AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    );

    // No auth is fine; we only care the transport accepts Chinese body bytes.
    final response = await client.post(
      '/api/app/forum/draft/save',
      body: <String, Object?>{
        'draftId': null,
        'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
        'title': '中文草稿标题（UTF-8探针）',
        'body': '中文正文：测试 transport JSON 编码，不应因中文直接崩溃。',
        'attachmentFileAssetIds': <String>[],
      },
    );

    expect(response.statusCode, greaterThanOrEqualTo(200));
  });
}

