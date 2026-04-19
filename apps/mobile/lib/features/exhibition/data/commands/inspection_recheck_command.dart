part of '../exhibition_consumer_layer.dart';

class InspectionRecheckCommand {
  const InspectionRecheckCommand({required this.inspectionId});

  final String inspectionId;

  Map<String, Object?> toJson() => <String, Object?>{
    'inspectionId': inspectionId,
  };
}
