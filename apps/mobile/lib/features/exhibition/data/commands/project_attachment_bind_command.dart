part of '../exhibition_consumer_layer.dart';

class ProjectAttachmentBindCommand {
  const ProjectAttachmentBindCommand({
    required this.fileAssetId,
    required this.fileName,
    required this.attachmentKind,
    required this.mimeType,
    required this.sortOrder,
  });

  final String fileAssetId;
  final String fileName;
  final String attachmentKind;
  final String mimeType;
  final int sortOrder;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'fileAssetId': fileAssetId,
      'fileName': fileName,
      'attachmentKind': attachmentKind,
      'mimeType': mimeType,
      'sortOrder': sortOrder,
    };
  }
}
