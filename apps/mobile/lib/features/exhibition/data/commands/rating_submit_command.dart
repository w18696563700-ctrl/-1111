part of '../exhibition_consumer_layer.dart';

class RatingSubmitCommand {
  const RatingSubmitCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}
