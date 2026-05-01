import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';

Future<AppApiResponse> runProtectedAppRequest(
  Future<AppApiResponse> Function() send,
) async {
  if (AppSessionStore.instance.shouldRefresh) {
    await AuthConsumerLayer.instance.refreshSession();
  }

  final accessTokenBeforeSend = AppSessionStore.instance.snapshot.accessToken;
  final response = await send();
  if (response.statusCode != 401 || !AppSessionStore.instance.hasRefreshToken) {
    return response;
  }

  if (_accessTokenChangedSince(accessTokenBeforeSend)) {
    return send();
  }

  final refreshResult = await AuthConsumerLayer.instance.refreshSession();
  if (refreshResult.state != AppPageState.content) {
    return response;
  }

  return send();
}

bool _accessTokenChangedSince(String? previous) {
  final current = AppSessionStore.instance.snapshot.accessToken;
  return _normalizeToken(current) != _normalizeToken(previous);
}

String? _normalizeToken(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
