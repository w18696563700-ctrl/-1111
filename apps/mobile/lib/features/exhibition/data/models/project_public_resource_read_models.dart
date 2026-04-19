part of '../exhibition_consumer_layer.dart';

class ProjectPublicResourceReadModel {
  const ProjectPublicResourceReadModel({
    required this.resourceId,
    required this.resourceCategory,
    required this.title,
    required this.summary,
    required this.fileAssetId,
    required this.fileName,
    required this.mimeType,
    required this.visibility,
    required this.sortOrder,
    required this.publishedAt,
  });

  factory ProjectPublicResourceReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project public resource payload must be an object',
      );
    }

    return ProjectPublicResourceReadModel(
      resourceId: '${raw['resourceId']!}',
      resourceCategory: '${raw['resourceCategory']!}',
      title: '${raw['title']!}',
      summary: raw['summary'] as String?,
      fileAssetId: '${raw['fileAssetId']!}',
      fileName: '${raw['fileName']!}',
      mimeType: '${raw['mimeType']!}',
      visibility: '${raw['visibility']!}',
      sortOrder: raw['sortOrder'] as int,
      publishedAt: '${raw['publishedAt']!}',
    );
  }

  final String resourceId;
  final String resourceCategory;
  final String title;
  final String? summary;
  final String fileAssetId;
  final String fileName;
  final String mimeType;
  final String visibility;
  final int sortOrder;
  final String publishedAt;
}

class ProjectPublicResourceCatalogReadModel {
  const ProjectPublicResourceCatalogReadModel({required this.resources});

  factory ProjectPublicResourceCatalogReadModel.fromPayload(Object? payload) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project public resource catalog payload must be an object',
      );
    }

    final rawResources = raw['resources'];
    if (rawResources is! List) {
      throw const FormatException(
        'project public resource catalog payload must contain resources',
      );
    }

    return ProjectPublicResourceCatalogReadModel(
      resources: rawResources
          .map<ProjectPublicResourceReadModel>(
            ProjectPublicResourceReadModel.fromPayload,
          )
          .toList(growable: false),
    );
  }

  final List<ProjectPublicResourceReadModel> resources;
}

class ProjectPublicResourceFileAccessReadModel {
  const ProjectPublicResourceFileAccessReadModel({
    required this.accessUrl,
    this.fileAssetId,
    this.mode,
    this.fileName,
    this.mimeType,
    this.expiresAt,
    this.contentLengthBytes,
  });

  factory ProjectPublicResourceFileAccessReadModel.fromPayload(
    Object? payload,
  ) {
    final raw = _asMap(payload);
    if (raw == null) {
      throw const FormatException(
        'project public resource file access payload must be an object',
      );
    }

    final accessUrl = raw['accessUrl'];
    if (accessUrl is! String || accessUrl.trim().isEmpty) {
      throw const FormatException(
        'project public resource file access payload must contain accessUrl',
      );
    }

    return ProjectPublicResourceFileAccessReadModel(
      accessUrl: accessUrl,
      fileAssetId: raw['fileAssetId'] as String?,
      mode: raw['mode'] as String?,
      fileName: raw['fileName'] as String?,
      mimeType: raw['mimeType'] as String?,
      expiresAt: raw['expiresAt'] as String?,
      contentLengthBytes: raw['contentLengthBytes'] as int?,
    );
  }

  final String accessUrl;
  final String? fileAssetId;
  final String? mode;
  final String? fileName;
  final String? mimeType;
  final String? expiresAt;
  final int? contentLengthBytes;
}
