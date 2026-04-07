part of '../exhibition_consumer_layer.dart';

class InspectionSubmitCommand {
  const InspectionSubmitCommand({required this.inspectionId});

  final String inspectionId;

  Map<String, Object?> toJson() => <String, Object?>{
    'inspectionId': inspectionId,
  };
}
