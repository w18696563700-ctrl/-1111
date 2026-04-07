part of 'forum_consumer_layer.dart';

Object _parseBlockRelationStatus(Map<String, Object?> body) {
  final targetUserId =
      _readRequiredString(body['targetUserId']) ??
      _readRequiredString(body['targetMemberId']) ??
      _readRequiredString(body['blockedUserId']) ??
      _readRequiredString(body['targetId']);
  final state =
      _readRequiredString(body['state']) ?? _readRequiredString(body['status']);
  final isBlocked =
      _readBool(body['isBlocked']) ??
      _readBool(body['blocked']) ??
      _readBool(body['viewerHasBlocked']) ??
      _readBool(body['blockedByMe']) ??
      _blockedValueForState(state);

  if (targetUserId == null || isBlocked == null) {
    return 'forum block relation status is missing required fields';
  }

  return ForumBlockRelationStatusView(
    targetUserId: targetUserId,
    isBlocked: isBlocked,
    state: _normalizedBlockState(state, isBlocked: isBlocked),
    message: _readOptionalString(body['message']),
    traceId: _readOptionalString(body['traceId']),
    updatedAt: _readOptionalString(body['updatedAt']),
  );
}

bool? _blockedValueForState(String? state) {
  return switch (state?.trim()) {
    'blocked' || 'active' => true,
    'unblocked' || 'not_blocked' || 'none' || 'inactive' => false,
    _ => null,
  };
}

String _normalizedBlockState(String? state, {required bool isBlocked}) {
  final value = state?.trim();
  return switch (value) {
    'blocked' || 'active' => 'blocked',
    'unblocked' || 'not_blocked' || 'none' || 'inactive' => 'unblocked',
    _ => isBlocked ? 'blocked' : 'unblocked',
  };
}
