part of '../exhibition_consumer_layer.dart';

class OrderCreateCommand {
  const OrderCreateCommand({required this.bidId});

  final String bidId;

  Map<String, Object?> toJson() => <String, Object?>{'bidId': bidId};
}
