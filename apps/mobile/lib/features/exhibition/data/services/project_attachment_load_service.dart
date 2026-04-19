part of '../exhibition_consumer_layer.dart';

extension _ProjectAttachmentLoadService on _ExhibitionLoadService {
  Future<ExhibitionLoadResult> loadProjectAttachments({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.myProjectAttachmentsPattern,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.myProjectAttachments(normalized),
      forceRefresh: forceRefresh,
    );
  }

  void invalidateProjectAttachments({required String? projectId}) {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return;
    }

    _invalidateCachedGet(ExhibitionCanonicalPaths.myProjectAttachments(normalized));
  }
}
