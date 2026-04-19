part of '../exhibition_consumer_layer.dart';

extension _ProjectPublicResourceLoadService on _ExhibitionLoadService {
  Future<ExhibitionLoadResult> loadProjectPublicResources({
    bool forceRefresh = false,
  }) async {
    return _loadGet(
      ExhibitionCanonicalPaths.projectPublicResources,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateProjectPublicResources() {
    _invalidateCachedGet(ExhibitionCanonicalPaths.projectPublicResources);
  }
}
