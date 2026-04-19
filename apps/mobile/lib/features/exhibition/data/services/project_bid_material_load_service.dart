part of '../exhibition_consumer_layer.dart';

extension _ProjectBidMaterialLoadService on _ExhibitionLoadService {
  Future<ExhibitionLoadResult> loadProjectBidMaterials({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectBidMaterials,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.projectBidMaterials,
      queryParameters: <String, String>{'projectId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  void invalidateProjectBidMaterials({required String? projectId}) {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return;
    }

    _invalidateCachedGet(
      ExhibitionCanonicalPaths.projectBidMaterials,
      queryParameters: <String, String>{'projectId': normalized},
    );
  }
}
