import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

void main() {
  test('upload init rejects internal confirm endpoint drift', () async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'upload-session-project-1',
                  'directUpload': <String, Object?>{
                    'url': 'https://oss.example.com/upload/project-1',
                    'method': 'PUT',
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/server/uploads/confirm',
                  },
                },
              );
            },
          },
    );

    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    );

    final result = await consumer.uploadInit(
      const UploadInitCommand(
        businessType: 'project',
        businessId: 'project-1',
        fileKind: 'evidence',
        mimeType: 'application/pdf',
        size: 128,
        checksum: 'checksum-project-1',
      ),
    );

    expect(result.state, AppUploadState.uploadFailedRetryable);
    expect(result.path, ExhibitionCanonicalPaths.uploadInit);
    expect(result.directive, isNull);
    expect(
      result.message,
      'upload init response confirm endpoint drifted outside app-facing canonical path',
    );
  });
}
