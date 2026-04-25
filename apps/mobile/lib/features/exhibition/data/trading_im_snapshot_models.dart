class BidSubmissionSnapshotView {
  const BidSubmissionSnapshotView({
    required this.projectId,
    required this.bidId,
    required this.bidder,
    required this.submittedAt,
    required this.quoteAmount,
    required this.proposalSummary,
    required this.attachmentSummary,
    required this.attachments,
    required this.availability,
  });

  final String projectId;
  final String bidId;
  final BidSubmissionBidderView bidder;
  final String submittedAt;
  final num quoteAmount;
  final String proposalSummary;
  final Map<String, Object?> attachmentSummary;
  final List<BidSubmissionAttachmentView> attachments;
  final Map<String, Object?> availability;
}

class BidSubmissionBidderView {
  const BidSubmissionBidderView({
    required this.organizationId,
    required this.displayName,
    required this.avatarUrl,
  });

  final String organizationId;
  final String displayName;
  final String? avatarUrl;
}

class BidSubmissionAttachmentView {
  const BidSubmissionAttachmentView({
    required this.slotKey,
    required this.slotLabel,
    required this.fileAssetId,
    required this.fileKind,
    required this.mimeType,
  });

  final String slotKey;
  final String slotLabel;
  final String fileAssetId;
  final String fileKind;
  final String mimeType;
}

BidSubmissionSnapshotView parseBidSubmissionSnapshot(Object? payload) {
  final body = _readSnapshotMap(payload, 'bid submission snapshot');
  return BidSubmissionSnapshotView(
    projectId: _requiredSnapshotString(body, 'projectId'),
    bidId: _requiredSnapshotString(body, 'bidId'),
    bidder: _parseBidSubmissionBidder(body['bidder']),
    submittedAt: _requiredSnapshotString(body, 'submittedAt'),
    quoteAmount: _requiredSnapshotNumber(body, 'quoteAmount'),
    proposalSummary: _requiredSnapshotString(body, 'proposalSummary'),
    attachmentSummary: _primitiveSnapshotMap(body['attachmentSummary']),
    attachments: _attachmentList(body['attachments']),
    availability: _primitiveSnapshotMap(body['availability']),
  );
}

BidSubmissionBidderView _parseBidSubmissionBidder(Object? payload) {
  final body = _readSnapshotMap(payload, 'bid submission snapshot bidder');
  return BidSubmissionBidderView(
    organizationId: _requiredSnapshotString(body, 'organizationId'),
    displayName: _requiredSnapshotString(body, 'displayName'),
    avatarUrl: _optionalSnapshotString(body['avatarUrl']),
  );
}

Map<String, Object?> _readSnapshotMap(Object? payload, String context) {
  if (payload is! Map) {
    throw FormatException('$context response must be an object');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

String _requiredSnapshotString(Map<String, Object?> body, String field) {
  final value = '${body[field] ?? ''}'.trim();
  if (value.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return value;
}

String? _optionalSnapshotString(Object? value) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? null : text;
}

num _requiredSnapshotNumber(Map<String, Object?> body, String field) {
  final value = body[field];
  if (value is! num) {
    throw FormatException('field "$field" must be numeric');
  }
  return value;
}

Map<String, Object?> _primitiveSnapshotMap(Object? payload) {
  final body = _readSnapshotMap(payload, 'primitive map');
  return body.map((String key, Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return MapEntry<String, Object?>(key, value);
    }
    throw FormatException('field "$key" must be primitive');
  });
}

List<BidSubmissionAttachmentView> _attachmentList(Object? payload) {
  if (payload is! List<Object?>) {
    throw FormatException('field "attachments" must be a list');
  }
  return payload.map(_parseAttachment).toList(growable: false);
}

BidSubmissionAttachmentView _parseAttachment(Object? payload) {
  final body = _readSnapshotMap(payload, 'bid submission attachment');
  return BidSubmissionAttachmentView(
    slotKey: _requiredSnapshotString(body, 'slotKey'),
    slotLabel: _requiredSnapshotString(body, 'slotLabel'),
    fileAssetId: _requiredSnapshotString(body, 'fileAssetId'),
    fileKind: _requiredSnapshotString(body, 'fileKind'),
    mimeType: _requiredSnapshotString(body, 'mimeType'),
  );
}
