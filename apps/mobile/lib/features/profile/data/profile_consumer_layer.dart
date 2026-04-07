import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';

final class ProfileCanonicalPaths {
  const ProfileCanonicalPaths._();

  static const String profileIndex = '/api/app/profile/index';
}

class ProfileOrganizationView {
  const ProfileOrganizationView({
    required this.organizationId,
    required this.roleKeys,
    required this.visibleBuildings,
  });

  final String? organizationId;
  final List<String> roleKeys;
  final List<String> visibleBuildings;
}

class ProfileCertificationView {
  const ProfileCertificationView({required this.status});

  final String? status;
}

class ProfileMembershipView {
  const ProfileMembershipView({required this.status});

  final String? status;
}

class ProfileSettingsEntryView {
  const ProfileSettingsEntryView({required this.state});

  final String state;
}

class ProfileIndexView {
  const ProfileIndexView({
    required this.organization,
    required this.certification,
    required this.membership,
    required this.myBuildingProjection,
    required this.settingsEntry,
  });

  final ProfileOrganizationView organization;
  final ProfileCertificationView certification;
  final ProfileMembershipView membership;
  final Map<String, Object?>? myBuildingProjection;
  final ProfileSettingsEntryView settingsEntry;
}

class ProfileIndexResult {
  const ProfileIndexResult({
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
  final ProfileIndexView? data;
  final String? message;
  final String? errorCode;
}

class ProfileConsumerLayer {
  ProfileConsumerLayer._(this._client);

  factory ProfileConsumerLayer({AppApiClient? client}) {
    return ProfileConsumerLayer._(client ?? AppApiClient());
  }

  static ProfileConsumerLayer _instance = ProfileConsumerLayer();

  static ProfileConsumerLayer get instance => _instance;

  static void install(ProfileConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileConsumerLayer();
  }

  final AppApiClient _client;

  String get configuredEnvironmentLabel =>
      _client.config.userFacingEnvironmentLabel;

  Future<ProfileIndexResult> loadIndex() async {
    try {
      final response = await _client.get(ProfileCanonicalPaths.profileIndex);
      return _mapResponse(response);
    } on SocketException {
      return const ProfileIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: 'network error while loading profile index',
      );
    } on HttpException {
      return const ProfileIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: 'http error while loading profile index',
      );
    } on FormatException {
      return const ProfileIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: 'response decoding failed for profile index',
      );
    }
  }

  ProfileIndexResult _mapResponse(AppApiResponse response) {
    if (response.statusCode == 401) {
      return ProfileIndexResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: _extractMessage(response.body) ?? 'profile index unauthorized',
        errorCode: _extractErrorCode(response.body),
      );
    }

    if (response.statusCode == 403) {
      return ProfileIndexResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: _extractMessage(response.body) ?? 'profile index forbidden',
        errorCode: _extractErrorCode(response.body),
      );
    }

    if (response.statusCode == 404) {
      return ProfileIndexResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: _extractMessage(response.body) ?? 'profile index not found',
        errorCode: _extractErrorCode(response.body),
      );
    }

    if (response.statusCode >= 500) {
      return ProfileIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: _extractMessage(response.body) ?? 'profile index failed',
        errorCode: _extractErrorCode(response.body),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message:
            _extractMessage(response.body) ??
            'profile index returned a controlled failure',
        errorCode: _extractErrorCode(response.body),
      );
    }

    final payload = response.body;
    if (payload is! Map) {
      return const ProfileIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: 'profile index response must be an object',
      );
    }

    final body = payload.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    final parsed = _parseProfileIndex(body);
    if (parsed is String) {
      return ProfileIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: ProfileCanonicalPaths.profileIndex,
        message: parsed,
      );
    }

    return ProfileIndexResult(
      state: AppPageState.content,
      method: 'GET',
      path: ProfileCanonicalPaths.profileIndex,
      data: parsed as ProfileIndexView,
    );
  }
}

Object _parseProfileIndex(Map<String, Object?> body) {
  final organization = _parseOrganization(body['organization']);
  if (organization is String) {
    return organization;
  }

  final certification = _parseCertification(body['certification']);
  if (certification is String) {
    return certification;
  }

  final membership = _parseMembership(body['membership']);
  if (membership is String) {
    return membership;
  }

  final settingsEntry = _parseSettingsEntry(body['settingsEntry']);
  if (settingsEntry is String) {
    return settingsEntry;
  }

  return ProfileIndexView(
    organization: organization as ProfileOrganizationView,
    certification: certification as ProfileCertificationView,
    membership: membership as ProfileMembershipView,
    myBuildingProjection: _readObjectMap(body['myBuildingProjection']),
    settingsEntry: settingsEntry as ProfileSettingsEntryView,
  );
}

Object _parseOrganization(Object? raw) {
  if (raw is! Map) {
    return 'profile index is missing required object "organization"';
  }

  final body = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  final roleKeys = _readStringList(body['roleKeys']);
  final visibleBuildings = _readStringList(body['visibleBuildings']);
  if (roleKeys == null) {
    return 'profile organization is missing required field "roleKeys"';
  }
  if (visibleBuildings == null) {
    return 'profile organization is missing required field "visibleBuildings"';
  }

  return ProfileOrganizationView(
    organizationId: _readNullableString(body['organizationId']),
    roleKeys: roleKeys,
    visibleBuildings: visibleBuildings,
  );
}

Object _parseCertification(Object? raw) {
  if (raw is! Map) {
    return 'profile index is missing required object "certification"';
  }

  final body = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  if (!body.containsKey('status')) {
    return 'profile certification is missing required field "status"';
  }

  return ProfileCertificationView(status: _readNullableString(body['status']));
}

Object _parseMembership(Object? raw) {
  if (raw is! Map) {
    return 'profile index is missing required object "membership"';
  }

  final body = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  if (!body.containsKey('status')) {
    return 'profile membership is missing required field "status"';
  }

  return ProfileMembershipView(status: _readNullableString(body['status']));
}

Object _parseSettingsEntry(Object? raw) {
  if (raw is! Map) {
    return 'profile index is missing required object "settingsEntry"';
  }

  final body = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  final state = _readRequiredString(body['state']);
  if (state == null) {
    return 'profile settingsEntry is missing required field "state"';
  }
  if (state != 'visible') {
    return 'profile settingsEntry state "$state" is outside the frozen profile boundary';
  }

  return ProfileSettingsEntryView(state: state);
}

String? _readRequiredString(Object? raw) {
  if (raw is! String) {
    return null;
  }

  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _readNullableString(Object? raw) {
  if (raw == null) {
    return null;
  }

  return _readRequiredString(raw);
}

List<String>? _readStringList(Object? raw) {
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

Map<String, Object?>? _readObjectMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }

  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _extractMessage(Object? body) {
  if (body is Map && body['message'] is String) {
    return _readRequiredString(body['message']);
  }
  return null;
}

String? _extractErrorCode(Object? body) {
  if (body is Map && body['code'] is String) {
    return _readRequiredString(body['code']);
  }
  return null;
}
