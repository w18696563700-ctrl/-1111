part of '../exhibition_consumer_layer.dart';

class BidAwardCommand {
  const BidAwardCommand({
    required this.projectId,
    required this.winningBidId,
    required this.reasonCode,
    required this.reasonText,
  });

  final String projectId;
  final String winningBidId;
  final String reasonCode;
  final String reasonText;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'winningBidId': winningBidId,
    'reasonCode': reasonCode,
    'reasonText': reasonText,
  };
}

class BidSelectAndCreateOrderCommand {
  const BidSelectAndCreateOrderCommand({
    required this.projectId,
    required this.winningBidId,
    required this.reasonCode,
    required this.reasonText,
  });

  final String projectId;
  final String winningBidId;
  final String reasonCode;
  final String reasonText;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'winningBidId': winningBidId,
    'reasonCode': reasonCode,
    'reasonText': reasonText,
  };
}
