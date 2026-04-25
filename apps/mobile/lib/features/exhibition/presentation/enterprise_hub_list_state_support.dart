import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';

EnterpriseHubListQuery buildEnterpriseBoardListQuery({
  required EnterpriseBoardType boardType,
  required EnterpriseHubListQuery current,
  String? keyword,
  bool clearKeyword = false,
  String? cityCode,
  String? provinceCode,
  bool clearCity = false,
  String? supplyCategory,
  bool clearSupplyCategory = false,
  String? plantAreaRange,
  bool clearPlantAreaRange = false,
  int? page,
}) {
  return EnterpriseHubListQuery(
    boardType: boardType,
    keyword: clearKeyword ? null : keyword ?? current.keyword,
    provinceCode: clearCity ? null : provinceCode ?? current.provinceCode,
    cityCode: clearCity ? null : cityCode ?? current.cityCode,
    supplyCategory: boardType == EnterpriseBoardType.supplier
        ? (clearSupplyCategory
              ? null
              : supplyCategory ?? current.supplyCategory)
        : null,
    plantAreaRange: boardType == EnterpriseBoardType.factory
        ? (clearPlantAreaRange
              ? null
              : plantAreaRange ?? current.plantAreaRange)
        : null,
    page: page ?? current.page,
    pageSize: current.pageSize,
  );
}

String enterpriseBoardListResultSummaryText({
  required EnterpriseBoardType boardType,
  required EnterpriseHubLoadResult<EnterpriseHubListData>? result,
  required bool loading,
}) {
  final total = result?.data?.pagination.total;
  if (loading && result == null) {
    return '正在读取${boardType.title}列表';
  }
  if (result?.state == AppPageState.content && total != null) {
    return '当前展示：已接通内容，共 $total 家，按当前筛选条件展示';
  }

  return switch (result?.state) {
    AppPageState.empty => '当前展示：真实空结果，当前条件下暂无匹配企业',
    AppPageState.notFound => '当前展示：受控阻断，当前板块未返回可展示内容',
    AppPageState.unauthorized => '当前展示：受控阻断，需要先恢复登录',
    AppPageState.forbidden => '当前展示：受控阻断，${result?.message ?? '当前账号暂未开放该列表'}',
    AppPageState.errorRetryable =>
      '当前展示：受控失败，${result?.message ?? '列表暂时不可用，可下拉刷新重试'}',
    AppPageState.errorNonRetryable =>
      '当前展示：受控失败，${result?.message ?? '当前列表返回受控失败'}',
    _ => '按筛选条件查看对应企业',
  };
}

bool enterpriseBoardListHasActiveFilters({
  required EnterpriseHubListQuery query,
}) {
  return (query.keyword?.trim().isNotEmpty ?? false) ||
      query.provinceCode != null ||
      query.cityCode != null ||
      query.supplyCategory != null ||
      query.plantAreaRange != null;
}
