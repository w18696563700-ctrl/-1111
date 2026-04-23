part of '../exhibition_consumer_layer.dart';

extension _ExhibitionMyBidLoadService on _ExhibitionLoadService {
  Future<ExhibitionLoadResult> loadMyBidList({
    bool forceRefresh = false,
  }) async {
    return _loadGet(
      ExhibitionCanonicalPaths.myBidList,
      forceRefresh: forceRefresh,
    );
  }
}
