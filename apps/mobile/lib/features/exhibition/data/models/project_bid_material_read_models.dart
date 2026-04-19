part of '../exhibition_consumer_layer.dart';

class ProjectBidMaterialReadModel {
  const ProjectBidMaterialReadModel({
    required this.attachmentId,
    required this.projectId,
    required this.fileAssetId,
    required this.fileName,
    required this.attachmentKind,
    required this.mimeType,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ProjectBidMaterialReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project bid-material payload must be an object',
      );
    }

    return ProjectBidMaterialReadModel(
      attachmentId: '${raw['attachmentId']!}',
      projectId: '${raw['projectId']!}',
      fileAssetId: '${raw['fileAssetId']!}',
      fileName: '${raw['fileName']!}',
      attachmentKind: '${raw['attachmentKind']!}',
      mimeType: '${raw['mimeType']!}',
      sortOrder: raw['sortOrder'] as int,
      createdAt: '${raw['createdAt']!}',
    );
  }

  final String attachmentId;
  final String projectId;
  final String fileAssetId;
  final String fileName;
  final String attachmentKind;
  final String mimeType;
  final int sortOrder;
  final String createdAt;
}

class ProjectBidMaterialListReadModel {
  const ProjectBidMaterialListReadModel({
    required this.projectId,
    required this.attachments,
  });

  factory ProjectBidMaterialListReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project bid-material list payload must be an object',
      );
    }

    final rawAttachments = raw['attachments'];
    if (rawAttachments is! List) {
      throw const FormatException(
        'project bid-material list payload must contain attachments',
      );
    }

    return ProjectBidMaterialListReadModel(
      projectId: '${raw['projectId']!}',
      attachments: rawAttachments
          .map<ProjectBidMaterialReadModel>(
            ProjectBidMaterialReadModel.fromPayload,
          )
          .toList(growable: false),
    );
  }

  final String projectId;
  final List<ProjectBidMaterialReadModel> attachments;
}
