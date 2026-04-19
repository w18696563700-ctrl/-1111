import 'package:mobile/features/profile/data/profile_governance_appeal_models.dart';

final class ProfileGovernanceAppealPayloadParser {
  const ProfileGovernanceAppealPayloadParser._();

  static ProfileGovernanceAppealListView? parseListView(Object? payload) {
    final body = _map(payload);
    final items = _parseListItems(body?['items']);
    final pagination = _parsePagination(body?['pagination']);
    if (items == null || pagination == null) {
      return null;
    }
    return ProfileGovernanceAppealListView(
      items: items,
      pagination: pagination,
    );
  }

  static ProfileGovernanceAppealDetailView? parseDetailView(Object? payload) {
    final body = _map(payload);
    final appealCaseId = _readRequiredString(body?['appealCaseId']);
    final status = _readRequiredString(body?['status']);
    final appealReason =
        _readRequiredString(body?['appealReason']) ??
        _readRequiredString(body?['reason']);
    final penalty = _parsePenaltySummary(body);
    final evidenceFileAssetIds = _readStringList(body?['evidenceFileAssetIds']);
    if (body == null ||
        appealCaseId == null ||
        status == null ||
        appealReason == null ||
        penalty == null ||
        evidenceFileAssetIds == null ||
        !_containsAny(body, const <String>['submittedAt'])) {
      return null;
    }
    return ProfileGovernanceAppealDetailView(
      appealCaseId: appealCaseId,
      status: status,
      statusLabel: _readNullableString(body['statusLabel']),
      appealReason: appealReason,
      decision: _readNullableString(body['decision']),
      decisionLabel: _readNullableString(body['decisionLabel']),
      decisionNote: _readNullableString(body['decisionNote']),
      evidenceFileAssetIds: evidenceFileAssetIds,
      submittedAt: _readNullableString(body['submittedAt']),
      decidedAt: _readNullableString(body['decidedAt']),
      penalty: penalty,
    );
  }

  static String? extractMessage(Object? body) {
    return _readRequiredString(_map(body)?['message']);
  }

  static String? extractErrorCode(Object? body) {
    return _readRequiredString(_map(body)?['code']);
  }

  static List<ProfileGovernanceAppealListItemView>? _parseListItems(
    Object? raw,
  ) {
    if (raw is! List) {
      return null;
    }
    final items = <ProfileGovernanceAppealListItemView>[];
    for (final item in raw) {
      final body = _map(item);
      final appealCaseId = _readRequiredString(body?['appealCaseId']);
      final status = _readRequiredString(body?['status']);
      final penalty = _parsePenaltySummary(body);
      if (body == null ||
          appealCaseId == null ||
          status == null ||
          penalty == null ||
          !_containsAny(body, const <String>['submittedAt']) ||
          !_containsAny(body, const <String>['reasonSummary'], nested: 'penalty')) {
        return null;
      }
      items.add(
        ProfileGovernanceAppealListItemView(
          appealCaseId: appealCaseId,
          status: status,
          statusLabel: _readNullableString(body['statusLabel']),
          submittedAt: _readNullableString(body['submittedAt']),
          decidedAt: _readNullableString(body['decidedAt']),
          penalty: penalty,
        ),
      );
    }
    return List<ProfileGovernanceAppealListItemView>.unmodifiable(items);
  }

  static ProfileGovernanceAppealPaginationView? _parsePagination(Object? raw) {
    final body = _map(raw);
    final page = _readRequiredInt(body?['page']);
    final pageSize = _readRequiredInt(body?['pageSize']);
    final total = _readRequiredInt(body?['total']);
    final hasMore = _readRequiredBool(body?['hasMore']);
    if (body == null ||
        page == null ||
        pageSize == null ||
        total == null ||
        hasMore == null) {
      return null;
    }
    return ProfileGovernanceAppealPaginationView(
      page: page,
      pageSize: pageSize,
      total: total,
      hasMore: hasMore,
    );
  }

  static ProfileGovernanceAppealPenaltyView? _parsePenaltySummary(
    Map<String, Object?>? body,
  ) {
    final penaltyBody = _map(body?['penalty']);
    final penaltyId =
        _readRequiredString(body?['penaltyId']) ??
        _readRequiredString(penaltyBody?['penaltyId']);
    final penaltyType =
        _readRequiredString(body?['penaltyType']) ??
        _readRequiredString(penaltyBody?['penaltyType']);
    final penaltyStatus =
        _readRequiredString(body?['penaltyStatus']) ??
        _readRequiredString(penaltyBody?['penaltyStatus']);
    final reasonSummary =
        _readNullableString(body?['reasonSummary']) ??
        _readNullableString(penaltyBody?['reasonSummary']);
    if (penaltyId == null ||
        penaltyType == null ||
        penaltyStatus == null ||
        (!_containsAny(body, const <String>['reasonSummary'], nested: 'penalty'))) {
      return null;
    }
    return ProfileGovernanceAppealPenaltyView(
      penaltyId: penaltyId,
      penaltyType: penaltyType,
      penaltyTypeLabel:
          _readNullableString(body?['penaltyTypeLabel']) ??
          _readNullableString(penaltyBody?['penaltyTypeLabel']),
      penaltyStatus: penaltyStatus,
      penaltyStatusLabel:
          _readNullableString(body?['penaltyStatusLabel']) ??
          _readNullableString(penaltyBody?['penaltyStatusLabel']),
      reasonSummary: reasonSummary,
      effectiveFrom:
          _readNullableString(body?['effectiveFrom']) ??
          _readNullableString(penaltyBody?['effectiveFrom']),
      effectiveUntil:
          _readNullableString(body?['effectiveUntil']) ??
          _readNullableString(penaltyBody?['effectiveUntil']),
    );
  }

  static Map<String, Object?>? _map(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static bool _containsAny(
    Map<String, Object?>? body,
    List<String> keys, {
    String? nested,
  }) {
    if (body == null) {
      return false;
    }
    if (keys.any(body.containsKey)) {
      return true;
    }
    if (nested == null) {
      return false;
    }
    final nestedBody = _map(body[nested]);
    return nestedBody != null && keys.any(nestedBody.containsKey);
  }

  static String? _readRequiredString(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static String? _readNullableString(Object? raw) {
    if (raw == null) {
      return null;
    }
    return _readRequiredString(raw);
  }

  static int? _readRequiredInt(Object? raw) {
    return raw is int ? raw : null;
  }

  static bool? _readRequiredBool(Object? raw) {
    return raw is bool ? raw : null;
  }

  static List<String>? _readStringList(Object? raw) {
    if (raw == null) {
      return const <String>[];
    }
    if (raw is! List) {
      return null;
    }
    final values = <String>[];
    for (final item in raw) {
      final value = _readRequiredString(item);
      if (value == null) {
        return null;
      }
      values.add(value);
    }
    return List<String>.unmodifiable(values);
  }
}
