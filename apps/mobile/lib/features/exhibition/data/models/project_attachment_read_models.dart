part of '../exhibition_consumer_layer.dart';

class ProjectAttachmentReadModel {
  const ProjectAttachmentReadModel({
    required this.attachmentId,
    required this.projectId,
    required this.fileAssetId,
    required this.fileName,
    required this.attachmentKind,
    required this.mimeType,
    required this.visibility,
    required this.sortOrder,
    required this.createdAt,
    this.createdBy,
  });

  factory ProjectAttachmentReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException('project attachment payload must be an object');
    }

    return ProjectAttachmentReadModel(
      attachmentId: '${raw['attachmentId']!}',
      projectId: '${raw['projectId']!}',
      fileAssetId: '${raw['fileAssetId']!}',
      fileName: '${raw['fileName']!}',
      attachmentKind: '${raw['attachmentKind']!}',
      mimeType: '${raw['mimeType']!}',
      visibility: '${raw['visibility']!}',
      sortOrder: raw['sortOrder'] as int,
      createdAt: '${raw['createdAt']!}',
      createdBy: raw['createdBy'] is String ? '${raw['createdBy']}' : null,
    );
  }

  final String attachmentId;
  final String projectId;
  final String fileAssetId;
  final String fileName;
  final String attachmentKind;
  final String mimeType;
  final String visibility;
  final int sortOrder;
  final String createdAt;
  final String? createdBy;
}

class ProjectAttachmentListReadModel {
  const ProjectAttachmentListReadModel({
    required this.projectId,
    required this.attachments,
  });

  factory ProjectAttachmentListReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project attachment list payload must be an object',
      );
    }

    final rawAttachments = raw['attachments'];
    if (rawAttachments is! List) {
      throw const FormatException(
        'project attachment list payload must contain attachments',
      );
    }

    return ProjectAttachmentListReadModel(
      projectId: '${raw['projectId']!}',
      attachments: rawAttachments
          .map<ProjectAttachmentReadModel>(ProjectAttachmentReadModel.fromPayload)
          .toList(growable: false),
    );
  }

  final String projectId;
  final List<ProjectAttachmentReadModel> attachments;
}
