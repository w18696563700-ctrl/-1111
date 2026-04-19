import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

final class ProfileMembershipCanonicalPaths {
  const ProfileMembershipCanonicalPaths._();

  static const String current = '/api/app/profile/membership/current';
  static const String explanation = '/api/app/profile/membership/explanation';
  static const String quota = '/api/app/profile/membership/quota';
  static const String upgradeGuide =
      '/api/app/profile/membership/upgrade-guide';
}

class ProfileMembershipCurrentView {
  const ProfileMembershipCurrentView({
    required this.organizationId,
    required this.paidMembershipTier,
    required this.rateBand,
    required this.entitlementsSummary,
    required this.quotaSummary,
    required this.effectiveAt,
    required this.expiresAt,
    required this.nextRefreshAt,
  });

  final String? organizationId;
  final String? paidMembershipTier;
  final String? rateBand;
  final List<String> entitlementsSummary;
  final List<String> quotaSummary;
  final String? effectiveAt;
  final String? expiresAt;
  final String? nextRefreshAt;
}

class MembershipExplanationTierItemView {
  const MembershipExplanationTierItemView({
    required this.tier,
    required this.title,
    required this.highlights,
  });

  final String tier;
  final String title;
  final List<String> highlights;
}

class ProfileMembershipExplanationView {
  const ProfileMembershipExplanationView({
    required this.tiers,
    required this.entitlementNotes,
    required this.quotaNotes,
    required this.disclaimer,
  });

  final List<MembershipExplanationTierItemView> tiers;
  final List<String> entitlementNotes;
  final List<String> quotaNotes;
  final String disclaimer;
}

class MembershipQuotaItemView {
  const MembershipQuotaItemView({
    required this.quotaType,
    required this.summary,
    required this.currentValue,
    required this.refreshRule,
  });

  final String quotaType;
  final String summary;
  final int? currentValue;
  final String? refreshRule;
}

class ProfileMembershipQuotaView {
  const ProfileMembershipQuotaView({
    required this.items,
    required this.nextRefreshAt,
  });

  final List<MembershipQuotaItemView> items;
  final String? nextRefreshAt;
}

class MembershipUpgradeGuideTierItemView {
  const MembershipUpgradeGuideTierItemView({
    required this.tier,
    required this.title,
    required this.candidateDisplayPrice,
    required this.candidateDisplayRateBand,
  });

  final String tier;
  final String title;
  final String? candidateDisplayPrice;
  final String? candidateDisplayRateBand;
}

class ProfileMembershipUpgradeGuideView {
  const ProfileMembershipUpgradeGuideView({
    required this.currentTier,
    required this.availableTiers,
    required this.upgradeHighlights,
    required this.commercialDisclosure,
  });

  final String? currentTier;
  final List<MembershipUpgradeGuideTierItemView> availableTiers;
  final List<String> upgradeHighlights;
  final String commercialDisclosure;
}

class ProfileMembershipResult<T> {
  const ProfileMembershipResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ProfileMembershipConsumerLayer {
  ProfileMembershipConsumerLayer._(this._client);

  factory ProfileMembershipConsumerLayer({AppApiClient? client}) {
    return ProfileMembershipConsumerLayer._(client ?? AppApiClient());
  }

  static ProfileMembershipConsumerLayer _instance =
      ProfileMembershipConsumerLayer();

  static ProfileMembershipConsumerLayer get instance => _instance;

  static void install(ProfileMembershipConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileMembershipConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileMembershipResult<ProfileMembershipCurrentView>> loadCurrent() {
    return _get(
      canonicalPath: ProfileMembershipCanonicalPaths.current,
      parser: _parseCurrentView,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipExplanationView>>
  loadExplanation() {
    return _get(
      canonicalPath: ProfileMembershipCanonicalPaths.explanation,
      parser: _parseExplanationView,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipQuotaView>> loadQuota() {
    return _get(
      canonicalPath: ProfileMembershipCanonicalPaths.quota,
      parser: _parseQuotaView,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipUpgradeGuideView>>
  loadUpgradeGuide() {
    return _get(
      canonicalPath: ProfileMembershipCanonicalPaths.upgradeGuide,
      parser: _parseUpgradeGuideView,
    );
  }

  Future<ProfileMembershipResult<T>> _get<T>({
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) async {
    const method = 'GET';
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath),
      );
      return _mapResponse(
        response,
        method: method,
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'network error while loading membership read model',
      );
    } on HttpException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'http error while loading membership read model',
      );
    } on FormatException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'response decoding failed for membership read model',
      );
    }
  }

  ProfileMembershipResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    if (response.statusCode == 401) {
      return ProfileMembershipResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ?? 'membership request unauthorized',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 403) {
      return ProfileMembershipResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ?? 'membership request forbidden',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 404) {
      return ProfileMembershipResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ?? 'membership route unavailable',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode >= 500) {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: _extractMessage(response.body) ?? 'membership request failed',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'membership request returned a controlled failure',
        errorCode: _extractErrorCode(response.body),
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'membership response is missing required fields',
      );
    }

    return ProfileMembershipResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  static ProfileMembershipCurrentView? _parseCurrentView(Object? payload) {
    if (payload is! Map) {
      return null;
    }
    final body = _map(payload);
    final entitlementsSummary = _readStringList(body['entitlementsSummary']);
    final quotaSummary = _readStringList(body['quotaSummary']);
    if (entitlementsSummary == null || quotaSummary == null) {
      return null;
    }
    return ProfileMembershipCurrentView(
      organizationId: _readNullableString(body['organizationId']),
      paidMembershipTier: _readNullableString(body['paidMembershipTier']),
      rateBand: _readNullableString(body['rateBand']),
      entitlementsSummary: entitlementsSummary,
      quotaSummary: quotaSummary,
      effectiveAt: _readNullableString(body['effectiveAt']),
      expiresAt: _readNullableString(body['expiresAt']),
      nextRefreshAt: _readNullableString(body['nextRefreshAt']),
    );
  }

  static ProfileMembershipExplanationView? _parseExplanationView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }
    final body = _map(payload);
    final rawTiers = body['tiers'];
    final entitlementNotes = _readStringList(body['entitlementNotes']);
    final quotaNotes = _readStringList(body['quotaNotes']);
    final disclaimer = _readString(body['disclaimer']);
    if (rawTiers is! List ||
        entitlementNotes == null ||
        quotaNotes == null ||
        disclaimer == null) {
      return null;
    }

    final tiers = <MembershipExplanationTierItemView>[];
    for (final rawItem in rawTiers) {
      if (rawItem is! Map) {
        return null;
      }
      final item = _map(rawItem);
      final tier = _readString(item['tier']);
      final title = _readString(item['title']);
      final highlights =
          _readStringList(item['highlights']) ?? const <String>[];
      if (tier == null || title == null) {
        return null;
      }
      tiers.add(
        MembershipExplanationTierItemView(
          tier: tier,
          title: title,
          highlights: highlights,
        ),
      );
    }

    return ProfileMembershipExplanationView(
      tiers: List<MembershipExplanationTierItemView>.unmodifiable(tiers),
      entitlementNotes: entitlementNotes,
      quotaNotes: quotaNotes,
      disclaimer: disclaimer,
    );
  }

  static ProfileMembershipQuotaView? _parseQuotaView(Object? payload) {
    if (payload is! Map) {
      return null;
    }
    final body = _map(payload);
    final rawItems = body['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = <MembershipQuotaItemView>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        return null;
      }
      final item = _map(rawItem);
      final quotaType = _readString(item['quotaType']);
      final summary = _readString(item['summary']);
      final currentValue = _readNullableInt(item['currentValue']);
      final refreshRule = _readNullableString(item['refreshRule']);
      if (quotaType == null || summary == null) {
        return null;
      }
      items.add(
        MembershipQuotaItemView(
          quotaType: quotaType,
          summary: summary,
          currentValue: currentValue,
          refreshRule: refreshRule,
        ),
      );
    }

    return ProfileMembershipQuotaView(
      items: List<MembershipQuotaItemView>.unmodifiable(items),
      nextRefreshAt: _readNullableString(body['nextRefreshAt']),
    );
  }

  static ProfileMembershipUpgradeGuideView? _parseUpgradeGuideView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }
    final body = _map(payload);
    final rawAvailableTiers = body['availableTiers'];
    final upgradeHighlights = _readStringList(body['upgradeHighlights']);
    final commercialDisclosure = _readString(body['commercialDisclosure']);
    if (rawAvailableTiers is! List ||
        upgradeHighlights == null ||
        commercialDisclosure == null) {
      return null;
    }

    final availableTiers = <MembershipUpgradeGuideTierItemView>[];
    for (final rawItem in rawAvailableTiers) {
      if (rawItem is! Map) {
        return null;
      }
      final item = _map(rawItem);
      final tier = _readString(item['tier']);
      final title = _readString(item['title']);
      if (tier == null || title == null) {
        return null;
      }
      availableTiers.add(
        MembershipUpgradeGuideTierItemView(
          tier: tier,
          title: title,
          candidateDisplayPrice: _readNullableString(
            item['candidateDisplayPrice'],
          ),
          candidateDisplayRateBand: _readNullableString(
            item['candidateDisplayRateBand'],
          ),
        ),
      );
    }

    return ProfileMembershipUpgradeGuideView(
      currentTier: _readNullableString(body['currentTier']),
      availableTiers: List<MembershipUpgradeGuideTierItemView>.unmodifiable(
        availableTiers,
      ),
      upgradeHighlights: upgradeHighlights,
      commercialDisclosure: commercialDisclosure,
    );
  }

  static Map<String, Object?> _map(Map raw) {
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static String? _readString(Object? raw) {
    final value = _readNullableString(raw);
    return value == null || value.isEmpty ? null : value;
  }

  static String? _readNullableString(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static List<String>? _readStringList(Object? raw) {
    if (raw is! List) {
      return null;
    }
    return raw
        .whereType<String>()
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static int? _readNullableInt(Object? raw) {
    if (raw is int) {
      return raw >= 0 ? raw : null;
    }
    if (raw is num && raw >= 0 && raw == raw.roundToDouble()) {
      return raw.toInt();
    }
    return null;
  }

  static String? _extractMessage(Object? payload) {
    if (payload is! Map) {
      return null;
    }
    return _readNullableString(payload['message']);
  }

  static String? _extractErrorCode(Object? payload) {
    if (payload is! Map) {
      return null;
    }
    return _readNullableString(payload['code']);
  }
}
