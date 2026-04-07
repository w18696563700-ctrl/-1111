part of 'forum_consumer_layer.dart';

ForumReadResult<T> _readTransportFailure<T>(String path, String message) {
  return ForumReadResult<T>(
    state: AppPageState.errorRetryable,
    method: 'GET',
    path: path,
    message: forumVisibleReadMessage(
      path: path,
      state: AppPageState.errorRetryable,
      rawMessage: message,
    ),
  );
}

ForumReadResult<void>? _mapFailure(
  AppApiResponse response, {
  required String method,
}) {
  final statusCode = response.statusCode;
  if (statusCode >= 200 && statusCode < 300) {
    return null;
  }

  final state = switch (statusCode) {
    401 => AppPageState.unauthorized,
    403 => AppPageState.forbidden,
    404 => AppPageState.notFound,
    _ when statusCode >= 500 => AppPageState.errorRetryable,
    _ => AppPageState.errorNonRetryable,
  };

  return ForumReadResult<void>(
    state: state,
    method: method,
    path: response.uri.path,
    message: forumVisibleReadMessage(
      path: response.uri.path,
      state: state,
      rawMessage: _extractMessage(response.body),
      errorCode: _extractErrorCode(response.body),
    ),
    errorCode: _extractErrorCode(response.body),
  );
}

Object _parseAttachmentList(Object? raw) {
  if (raw is! List) {
    return 'forum attachmentRefs must be an array';
  }

  final items = <ForumAttachmentRefView>[];
  for (final item in raw) {
    final body = _readBodyMap(item);
    final fileAssetId = _readRequiredString(body?['fileAssetId']);
    final fileName = _readRequiredString(body?['fileName']);
    final mimeType = _readRequiredString(body?['mimeType']);
    if (body == null ||
        fileAssetId == null ||
        fileName == null ||
        mimeType == null) {
      return 'forum attachment ref is missing required fields';
    }
    items.add(
      ForumAttachmentRefView(
        fileAssetId: fileAssetId,
        fileName: fileName,
        mimeType: mimeType,
      ),
    );
  }
  return List<ForumAttachmentRefView>.unmodifiable(items);
}

Map<String, Object?>? _readBodyMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _requiredRouteValue(String? raw) {
  final value = raw?.trim();
  return value == null || value.isEmpty ? null : value;
}

String? _readRequiredString(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

String? _readOptionalString(Object? raw) {
  if (raw == null) {
    return null;
  }
  return _readRequiredString(raw);
}

int? _readInt(Object? raw) {
  return raw is int ? raw : null;
}

bool? _readBool(Object? raw) {
  return raw is bool ? raw : null;
}

String? _extractMessage(Object? body) {
  final map = _readBodyMap(body);
  return _readRequiredString(map?['message']);
}

String? _extractErrorCode(Object? body) {
  final map = _readBodyMap(body);
  return _readRequiredString(map?['code']);
}
