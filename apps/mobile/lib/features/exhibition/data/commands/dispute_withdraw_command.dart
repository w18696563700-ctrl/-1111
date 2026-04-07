part of '../exhibition_consumer_layer.dart';

class DisputeWithdrawCommand {
  const DisputeWithdrawCommand({required this.disputeId});

  final String disputeId;

  Map<String, Object?> toJson() {
    return <String, Object?>{'disputeId': disputeId};
  }
}
