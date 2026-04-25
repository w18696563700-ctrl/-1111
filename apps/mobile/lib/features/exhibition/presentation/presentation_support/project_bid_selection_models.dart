part of '../exhibition_trade_pages.dart';

class _ProjectBidCandidate {
  const _ProjectBidCandidate({
    required this.bidId,
    this.bidNo,
    this.bidderOrganizationId,
    this.bidderOrganizationName,
    this.quoteAmount,
    this.proposalSummary,
    this.state,
    this.submittedAt,
  });

  final String bidId;
  final String? bidNo;
  final String? bidderOrganizationId;
  final String? bidderOrganizationName;
  final num? quoteAmount;
  final String? proposalSummary;
  final String? state;
  final String? submittedAt;

  String get bidderTitle {
    return bidderOrganizationName ?? bidderOrganizationId ?? '竞标方 $bidId';
  }

  String? get stateLabel {
    return state == null ? null : _frontStageStateLabel(state!);
  }

  static List<_ProjectBidCandidate> fromProjectMap(
    Map<String, Object?> projectMap,
  ) {
    final rawList = projectMap['bidCandidates'];
    if (rawList is! List) {
      return const <_ProjectBidCandidate>[];
    }

    return rawList
        .whereType<Map>()
        .map(
          (Map item) =>
              item.map((Object? key, Object? value) => MapEntry('$key', value)),
        )
        .map(_ProjectBidCandidate.tryParse)
        .whereType<_ProjectBidCandidate>()
        .toList(growable: false);
  }

  static _ProjectBidCandidate? tryParse(Map<String, Object?> map) {
    final bidId = _normalizeDynamicText(map['bidId']);
    if (bidId == null) {
      return null;
    }
    return _ProjectBidCandidate(
      bidId: bidId,
      bidNo: _normalizeDynamicText(map['bidNo']),
      bidderOrganizationId: _normalizeDynamicText(map['bidderOrganizationId']),
      bidderOrganizationName: _normalizeDynamicText(
        map['bidderOrganizationName'],
      ),
      quoteAmount: map['quoteAmount'] is num ? map['quoteAmount'] as num : null,
      proposalSummary: _normalizeDynamicText(map['proposalSummary']),
      state: _normalizeDynamicText(map['state']),
      submittedAt: _normalizeDynamicText(map['submittedAt']),
    );
  }
}

class _ProjectBidSelectionState {
  const _ProjectBidSelectionState({
    this.winningBidId,
    this.orderId,
    this.contractId,
  });

  final String? winningBidId;
  final String? orderId;
  final String? contractId;

  static _ProjectBidSelectionState? fromProjectMap(
    Map<String, Object?> projectMap,
  ) {
    final raw = projectMap['bidSelection'];
    if (raw is! Map) {
      return null;
    }
    final map = raw.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    return _ProjectBidSelectionState(
      winningBidId: _normalizeDynamicText(map['winningBidId']),
      orderId: _normalizeDynamicText(map['orderId']),
      contractId: _normalizeDynamicText(map['contractId']),
    );
  }
}
