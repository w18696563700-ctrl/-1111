import 'package:mobile/features/profile/data/profile_governance_status_models.dart';

final class ProfileGovernanceStatusPayloadParser {
  const ProfileGovernanceStatusPayloadParser._();

  static ProfileGovernanceStatusView? parseStatusView(Object? payload) {
    final body = _map(payload);
    final violationScoreSnapshot = _readRequiredInt(
      body?['violationScoreSnapshot'],
    );
    final violationScoreUpdatedAt = _readRequiredString(
      body?['violationScoreUpdatedAt'],
    );
    if (body == null ||
        violationScoreSnapshot == null ||
        violationScoreUpdatedAt == null) {
      return null;
    }
    return ProfileGovernanceStatusView(
      violationScoreSnapshot: violationScoreSnapshot,
      violationScoreUpdatedAt: violationScoreUpdatedAt,
    );
  }

  static String? extractMessage(Object? body) {
    return _readRequiredString(_map(body)?['message']);
  }

  static String? extractErrorCode(Object? body) {
    return _readRequiredString(_map(body)?['code']);
  }

  static Map<String, Object?>? _map(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static String? _readRequiredString(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static int? _readRequiredInt(Object? raw) {
    return raw is int ? raw : null;
  }
}
