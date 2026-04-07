part of '../exhibition_consumer_layer.dart';

class InspectionRecheckCommand {
  const InspectionRecheckCommand({
    required this.inspectionId,
    this.recheckNote,
  });

  final String inspectionId;
  final String? recheckNote;

  Map<String, Object?> toJson() => <String, Object?>{
    'inspectionId': inspectionId,
    if (_normalize(recheckNote) != null) 'recheckNote': _normalize(recheckNote),
  };
}
