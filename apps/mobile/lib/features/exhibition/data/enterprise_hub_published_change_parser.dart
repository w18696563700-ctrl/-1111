part of 'enterprise_hub_published_change_consumer_layer.dart';

EnterpriseHubPublishedChangeWorkbenchData
parseEnterpriseHubPublishedChangeWorkbench(Map<String, Object?> payload) {
  final boardType = EnterpriseBoardType.fromRaw(
    _requiredString(payload, 'boardType'),
  );
  if (boardType == null) {
    throw const FormatException('published-change workbench 缺少合法 boardType。');
  }
  return EnterpriseHubPublishedChangeWorkbenchData(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    boardType: boardType,
    liveSnapshot: _parseLiveSnapshot(payload['liveSnapshot']),
    currentChangeRequest: _parseCurrentChangeRequest(
      payload['currentChangeRequest'],
    ),
    basic: _parseBasic(payload['basic']),
    boardProfile: _asMap(payload['boardProfile']),
    primaryContact: _parsePrimaryContact(payload['primaryContact']),
    cases: _parseCases(payload['cases']),
    changeReadiness: _parseReadiness(payload['changeReadiness']),
  );
}

EnterpriseHubPublishedChangeStatusData parseEnterpriseHubPublishedChangeStatus(
  Map<String, Object?> payload,
) {
  return EnterpriseHubPublishedChangeStatusData(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    changeRequestId: _requiredString(payload, 'changeRequestId'),
    changeStatus: _requiredString(payload, 'changeStatus'),
    submittedAt: _readString(payload['submittedAt']),
    reviewedAt: _readString(payload['reviewedAt']),
    rejectionReason: _readString(payload['rejectionReason']),
  );
}

EnterpriseHubCaseCreateData parseEnterpriseHubCaseCreateData(
  Map<String, Object?> payload,
) {
  return EnterpriseHubCaseCreateData(
    caseId: _requiredString(payload, 'caseId'),
    caseStatus: _requiredString(payload, 'caseStatus'),
  );
}

EnterpriseHubPublishedLiveSnapshot _parseLiveSnapshot(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    throw const FormatException('published-change workbench 缺少 liveSnapshot。');
  }
  return EnterpriseHubPublishedLiveSnapshot(
    enterpriseStatus: _requiredString(payload, 'enterpriseStatus'),
    displayStatus: _requiredString(payload, 'displayStatus'),
    publishedAt: _requiredString(payload, 'publishedAt'),
  );
}

EnterpriseHubCurrentChangeRequestSnapshot? _parseCurrentChangeRequest(
  Object? raw,
) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubCurrentChangeRequestSnapshot(
    changeRequestId: _requiredString(payload, 'changeRequestId'),
    changeStatus: _requiredString(payload, 'changeStatus'),
    submittedAt: _readString(payload['submittedAt']),
    reviewedAt: _readString(payload['reviewedAt']),
    rejectionReason: _readString(payload['rejectionReason']),
  );
}

EnterpriseHubPublishedChangeReadiness _parseReadiness(Object? raw) {
  final payload = _asMap(raw) ?? const <String, Object?>{};
  return EnterpriseHubPublishedChangeReadiness(
    draftEditable: payload['draftEditable'] == true,
    submitReady: payload['submitReady'] == true,
    blockers: _readStringList(payload['blockers']),
  );
}

EnterpriseHubWorkbenchBasic? _parseBasic(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchBasic(
    name: _readString(payload['name']),
    logoFileAssetId: _readString(payload['logoFileAssetId']),
    logoUrl: _readString(payload['logoUrl']),
    albumImageFileAssetIds: _readStringList(payload['albumImageFileAssetIds']),
    albumImageUrlMap: _readStringMap(payload['albumImageUrlMap']),
    shortIntro: _readString(payload['shortIntro']),
    fullIntro: _readString(payload['fullIntro']),
    provinceCode: _readString(payload['provinceCode']),
    provinceName: _readString(payload['provinceName']),
    cityCode: _readString(payload['cityCode']),
    cityName: _readString(payload['cityName']),
    address: _readString(payload['address']),
    location: _asMap(payload['location']) == null
        ? null
        : EnterpriseHubLocationData(
            addressText: _readString(
              _asMap(payload['location'])?['addressText'],
              _asMap(payload['location'])?['address'],
            ),
            publicDisplayAddress: _readString(
              _asMap(payload['location'])?['publicDisplayAddress'],
            ),
            provinceCode: _readString(_asMap(payload['location'])?['provinceCode']),
            provinceName: _readString(_asMap(payload['location'])?['provinceName']),
            cityCode: _readString(_asMap(payload['location'])?['cityCode']),
            cityName: _readString(_asMap(payload['location'])?['cityName']),
            districtCode: _readString(_asMap(payload['location'])?['districtCode']),
            districtName: _readString(_asMap(payload['location'])?['districtName']),
            latitude: _readDouble(_asMap(payload['location'])?['latitude']),
            longitude: _readDouble(_asMap(payload['location'])?['longitude']),
            geoSource: _readString(_asMap(payload['location'])?['geoSource']),
            geoStatus:
                _readString(_asMap(payload['location'])?['geoStatus']) ??
                'not_provided',
            lastGeocodedAt: _readString(
              _asMap(payload['location'])?['lastGeocodedAt'],
            ),
            mapProvider: _readString(_asMap(payload['location'])?['mapProvider']),
            mapPreviewUrl: _readString(
              _asMap(payload['location'])?['mapPreviewUrl'],
            ),
            mapLinkUrl: _readString(
              _asMap(payload['location'])?['mapLinkUrl'],
            ),
          ),
    foundedAt: _readString(payload['foundedAt']),
    teamSizeRange: _readString(payload['teamSizeRange']),
    cooperationModes: _readStringList(payload['cooperationModes']),
    contactVisible: payload['contactVisible'] == true,
  );
}

EnterpriseHubWorkbenchContact? _parsePrimaryContact(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchContact(
    contactName: _requiredString(payload, 'contactName'),
    mobile: _readString(payload['mobile']),
    wechat: _readString(payload['wechat']),
    phone: _readString(payload['phone']),
    email: _readString(payload['email']),
    position: _readString(payload['position']),
    isPrimary: payload['isPrimary'] == true,
    visibleToPublic: payload['visibleToPublic'] == true,
  );
}

List<EnterpriseHubWorkbenchCaseItem> _parseCases(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubWorkbenchCaseItem>[];
  }
  return raw
      .whereType<Map>()
      .map(
        (Map item) => item.map(
          (Object? key, Object? value) => MapEntry('$key', value),
        ),
      )
      .map((Map<String, Object?> payload) {
        final boardType =
            EnterpriseBoardType.fromRaw(_readString(payload['boardType'])) ??
            EnterpriseBoardType.company;
        return EnterpriseHubWorkbenchCaseItem(
          caseId: _requiredString(payload, 'caseId'),
          boardType: boardType,
          title: _requiredString(payload, 'title'),
          exhibitionType: _readString(payload['exhibitionType']),
          city: _readString(payload['city']),
          eventTime: _readString(payload['eventTime']),
          summary: _requiredString(payload, 'summary'),
          caseCoverFileAssetId: _requiredString(payload, 'caseCoverFileAssetId'),
          caseMediaFileAssetIds: _readStringList(payload['caseMediaFileAssetIds']),
          caseImageUrlMap: _readStringMap(payload['caseImageUrlMap']),
          isFeatured: payload['isFeatured'] == true,
          caseStatus: _requiredString(payload, 'caseStatus'),
        );
      })
      .toList(growable: false);
}

Map<String, Object?>? _asMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

String _requiredString(Map<String, Object?> payload, String field) {
  final value = _readString(payload[field]);
  if (value == null) {
    throw FormatException('响应缺少必填字段 $field。');
  }
  return value;
}

String? _readString(Object? raw, [Object? fallback]) {
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  if (fallback is String) {
    final trimmed = fallback.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

List<String> _readStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, String> _readStringMap(Object? raw) {
  if (raw is! Map) {
    return const <String, String>{};
  }
  final result = <String, String>{};
  raw.forEach((Object? key, Object? value) {
    final normalizedKey = _normalized('$key');
    final normalizedValue = _readString(value);
    if (normalizedKey != null && normalizedValue != null) {
      result[normalizedKey] = normalizedValue;
    }
  });
  return result;
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

double? _readDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw.trim());
  }
  return null;
}
