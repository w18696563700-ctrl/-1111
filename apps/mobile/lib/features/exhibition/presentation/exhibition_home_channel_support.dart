part of 'exhibition_home_page.dart';

enum _HomeProjectFilter { comprehensive, province, latest }

extension _HomeProjectFilterPresentation on _HomeProjectFilter {
  String get label => switch (this) {
    _HomeProjectFilter.comprehensive => '综合',
    _HomeProjectFilter.province => '本省',
    _HomeProjectFilter.latest => '最新',
  };
}

enum _HomeForumFilter { comprehensive }

enum _HomeEnterpriseFilter { comprehensive, province, featured }

extension _HomeEnterpriseFilterPresentation on _HomeEnterpriseFilter {
  String get label => switch (this) {
    _HomeEnterpriseFilter.comprehensive => '综合',
    _HomeEnterpriseFilter.province => '本省',
    _HomeEnterpriseFilter.featured => '优选',
  };
}

class _HomeEnterprisePanelSnapshot {
  const _HomeEnterprisePanelSnapshot({
    required this.state,
    required this.items,
    this.message,
  });

  final AppPageState state;
  final List<EnterpriseHubListItem> items;
  final String? message;

  factory _HomeEnterprisePanelSnapshot.fromListResult(
    EnterpriseHubLoadResult<EnterpriseHubListData> result,
  ) {
    return _HomeEnterprisePanelSnapshot(
      state: result.state,
      items:
          result.data?.items.take(3).toList(growable: false) ??
          const <EnterpriseHubListItem>[],
      message: result.message,
    );
  }

  factory _HomeEnterprisePanelSnapshot.fromRecommendationResult(
    EnterpriseHubLoadResult<EnterpriseHubRecommendationData> result,
  ) {
    return _HomeEnterprisePanelSnapshot(
      state: result.state,
      items:
          result.data?.items.take(3).toList(growable: false) ??
          const <EnterpriseHubListItem>[],
      message: result.message,
    );
  }
}

String _homeEnterpriseCardBadgeLabel(EnterpriseHubListItem item) {
  final boardLabel = item.primaryBoardLabel.trim();
  if (boardLabel.isNotEmpty) {
    return boardLabel;
  }

  final certification = item.certificationLabel.trim();
  if (certification.isNotEmpty) {
    return certification;
  }

  return switch (item.boardType) {
    EnterpriseBoardType.company => '公司展示',
    EnterpriseBoardType.factory => '工厂展示',
    EnterpriseBoardType.supplier => '供应商展示',
  };
}

String _homeEnterpriseCardSummary(EnterpriseHubListItem item) {
  final intro = item.shortIntro.trim();
  if (intro.isNotEmpty) {
    return intro;
  }

  final locationParts = <String>[
    item.provinceName.trim(),
    item.cityName.trim(),
  ].where((String value) => value.isNotEmpty).toList(growable: false);
  if (locationParts.isNotEmpty) {
    return '${locationParts.join(' / ')} 当前已接入公开展示。';
  }

  return '当前实体已接入公开展示，可继续查看详情。';
}

String _homeEnterpriseDetailActionLabel(EnterpriseBoardType boardType) {
  return switch (boardType) {
    EnterpriseBoardType.company => '查看公司详情',
    EnterpriseBoardType.factory => '查看工厂详情',
    EnterpriseBoardType.supplier => '查看供应商详情',
  };
}

String _homeEnterpriseChannelLabel(EnterpriseBoardType boardType) {
  return switch (boardType) {
    EnterpriseBoardType.company => '公司',
    EnterpriseBoardType.factory => '工厂',
    EnterpriseBoardType.supplier => '供应商',
  };
}
