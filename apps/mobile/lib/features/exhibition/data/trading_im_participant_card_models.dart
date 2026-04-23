class TradingImParticipantCardView {
  const TradingImParticipantCardView({
    required this.projectId,
    required this.bidId,
    required this.participantOrganizationId,
    required this.participantRole,
    required this.enterpriseSummary,
    required this.reviewSummary,
    required this.formalInfoSummary,
  });

  final String projectId;
  final String bidId;
  final String participantOrganizationId;
  final String participantRole;
  final TradingImParticipantEnterpriseSummaryView enterpriseSummary;
  final TradingImParticipantReviewSummaryView reviewSummary;
  final TradingImParticipantFormalInfoSummaryView formalInfoSummary;
}

class TradingImParticipantEnterpriseSummaryView {
  const TradingImParticipantEnterpriseSummaryView({
    required this.enterpriseId,
    required this.displayName,
    required this.logoUrl,
    required this.primaryBoardType,
    required this.provinceName,
    required this.cityName,
    required this.verificationStatus,
  });

  final String enterpriseId;
  final String displayName;
  final String? logoUrl;
  final String primaryBoardType;
  final String provinceName;
  final String cityName;
  final String verificationStatus;
}

class TradingImParticipantReviewSummaryView {
  const TradingImParticipantReviewSummaryView({
    required this.avgScore,
    required this.reviewCount,
    required this.keywordTags,
  });

  final num? avgScore;
  final num reviewCount;
  final List<String> keywordTags;
}

class TradingImParticipantFormalInfoSummaryView {
  const TradingImParticipantFormalInfoSummaryView({
    required this.legalName,
    required this.businessType,
    required this.registeredCapital,
    required this.establishedAt,
    required this.businessScope,
    required this.certificationStatus,
  });

  final String legalName;
  final String? businessType;
  final String? registeredCapital;
  final String? establishedAt;
  final String? businessScope;
  final String certificationStatus;
}

TradingImParticipantCardView parseTradingImParticipantCard(Object? payload) {
  final body = _readParticipantCardMap(payload, 'trading IM participant-card');
  return TradingImParticipantCardView(
    projectId: _requiredParticipantCardString(body, 'projectId'),
    bidId: _requiredParticipantCardString(body, 'bidId'),
    participantOrganizationId: _requiredParticipantCardString(
      body,
      'participantOrganizationId',
    ),
    participantRole: _participantCardEnum(
      _requiredParticipantCardString(body, 'participantRole'),
      const <String>{'project_owner', 'bidder'},
      'trading IM participant role',
    ),
    enterpriseSummary: _parseParticipantEnterpriseSummary(
      body['enterpriseSummary'],
    ),
    reviewSummary: _parseParticipantReviewSummary(body['reviewSummary']),
    formalInfoSummary: _parseParticipantFormalInfoSummary(
      body['formalInfoSummary'],
    ),
  );
}

TradingImParticipantEnterpriseSummaryView _parseParticipantEnterpriseSummary(
  Object? payload,
) {
  final body = _readParticipantCardMap(payload, 'participant enterprise summary');
  return TradingImParticipantEnterpriseSummaryView(
    enterpriseId: _requiredParticipantCardString(body, 'enterpriseId'),
    displayName: _requiredParticipantCardString(body, 'displayName'),
    logoUrl: _optionalParticipantCardString(body['logoUrl']),
    primaryBoardType: _requiredParticipantCardString(body, 'primaryBoardType'),
    provinceName: _requiredParticipantCardString(body, 'provinceName'),
    cityName: _requiredParticipantCardString(body, 'cityName'),
    verificationStatus: _requiredParticipantCardString(body, 'verificationStatus'),
  );
}

TradingImParticipantReviewSummaryView _parseParticipantReviewSummary(
  Object? payload,
) {
  final body = _readParticipantCardMap(payload, 'participant review summary');
  return TradingImParticipantReviewSummaryView(
    avgScore: _optionalParticipantCardNumber(body['avgScore']),
    reviewCount: _requiredParticipantCardNumber(body, 'reviewCount'),
    keywordTags: _participantCardStringList(body['keywordTags']),
  );
}

TradingImParticipantFormalInfoSummaryView _parseParticipantFormalInfoSummary(
  Object? payload,
) {
  final body = _readParticipantCardMap(payload, 'participant formal-info summary');
  return TradingImParticipantFormalInfoSummaryView(
    legalName: _requiredParticipantCardString(body, 'legalName'),
    businessType: _optionalParticipantCardString(body['businessType']),
    registeredCapital: _optionalParticipantCardString(body['registeredCapital']),
    establishedAt: _optionalParticipantCardString(body['establishedAt']),
    businessScope: _optionalParticipantCardString(body['businessScope']),
    certificationStatus: _requiredParticipantCardString(body, 'certificationStatus'),
  );
}

Map<String, Object?> _readParticipantCardMap(Object? payload, String context) {
  if (payload is! Map) {
    throw FormatException('$context response must be an object');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

String _requiredParticipantCardString(Map<String, Object?> body, String field) {
  final value = '${body[field] ?? ''}'.trim();
  if (value.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return value;
}

String? _optionalParticipantCardString(Object? value) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? null : text;
}

num _requiredParticipantCardNumber(Map<String, Object?> body, String field) {
  final value = _optionalParticipantCardNumber(body[field]);
  if (value == null) {
    throw FormatException('field "$field" must be numeric');
  }
  return value;
}

num? _optionalParticipantCardNumber(Object? value) {
  if (value is num) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return num.tryParse(normalized);
  }
  return null;
}

List<String> _participantCardStringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((Object? item) => '$item'.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

String _participantCardEnum(String value, Set<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context "$value" is outside frozen contract');
  }
  return value;
}
