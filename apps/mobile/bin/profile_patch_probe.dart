import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(() async {
    await for (final request in server) {
      print('method=${request.method} path=${request.uri.path}');
      final raw = await utf8.decoder.bind(request).join();
      print('body=$raw');
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'ok': true, 'traceId': 'trace-1'}));
      await request.response.close();
    }
  }());
  final consumer = ProfileIdentityConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://${server.address.host}:${server.port}/api/app'),
    ),
  );
  final result = await consumer.patchOrganizationMemberRole(memberId: 'member-2', roleKey: 'supplier_admin');
  print('state=${result.state} message=${result.message} path=${result.path}');
  print('data=${result.data?.traceId}');
  await server.close(force: true);
}
