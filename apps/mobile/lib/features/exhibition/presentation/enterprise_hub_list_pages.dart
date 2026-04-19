import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/china_region_picker.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_filter_options.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_list_controls.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_list_state_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

class EnterpriseBoardListPage extends StatefulWidget {
  const EnterpriseBoardListPage({
    super.key,
    required this.boardType,
    this.actionController,
  });

  final EnterpriseBoardType boardType;
  final EnterpriseBoardListActionController? actionController;

  @override
  State<EnterpriseBoardListPage> createState() =>
      _EnterpriseBoardListPageState();
}

class _EnterpriseBoardListPageState extends State<EnterpriseBoardListPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late EnterpriseHubListQuery _query;
  EnterpriseHubLoadResult<EnterpriseHubListData>? _listResult;
  ChinaRegionCatalog? _regionCatalog;
  String? _cityFilterNotice;
  bool _loading = false;
  bool _loadingMore = false;
  bool _searchFieldVisible = false;

  EnterpriseBoardSurfaceSpec get _surfaceSpec =>
      enterpriseBoardSurfaceSpec(widget.boardType);

  List<EnterpriseHubCityOption> get _fallbackCityOptions =>
      enterpriseHubCityOptionsFromListItems(
        _listResult?.data?.items ?? const <EnterpriseHubListItem>[],
      );

  EnterpriseHubCityOption? get _selectedCity =>
      enterpriseHubCityOptionByCode(_regionCatalog, _query.cityCode) ??
      enterpriseHubCityOptionByCodeFromOptions(
        _fallbackCityOptions,
        _query.cityCode,
      );

  bool get _cityFilterEnabled =>
      _regionCatalog != null || _fallbackCityOptions.isNotEmpty;

  String? get _effectiveCityFilterNotice =>
      _cityFilterEnabled ? null : _cityFilterNotice;

  String? get _selectedCityLabel => _selectedCity?.displayName;

  String? get _selectedAreaLabel => enterpriseBoardOptionLabelForValue(
    enterpriseHubFactoryAreaOptions,
    _query.plantAreaRange,
  );

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _query = EnterpriseHubListQuery(boardType: widget.boardType);
    _bindActionController();
    _loadRegionCatalog();
    _load();
  }

  @override
  void didUpdateWidget(covariant EnterpriseBoardListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionController != widget.actionController) {
      oldWidget.actionController?.onSearchPressed = null;
      _bindActionController();
    }
  }

  @override
  void dispose() {
    widget.actionController?.onSearchPressed = null;
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _bindActionController() {
    widget.actionController?.onSearchPressed = _toggleSearchField;
  }

  Future<void> _loadRegionCatalog() async {
    try {
      final catalog = await ChinaRegionCatalogLoader.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _regionCatalog = catalog;
        _cityFilterNotice = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _regionCatalog = null;
        _cityFilterNotice = '城市筛选当前不可用，请稍后重试。';
      });
    }
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });

    final listResult = await EnterpriseHubConsumerLayer.instance
        .loadEnterprises(_query);
    if (!mounted) {
      return;
    }

    setState(() {
      if (append &&
          _listResult?.data != null &&
          listResult.state == AppPageState.content &&
          listResult.data != null) {
        final previous = _listResult!.data!;
        final next = listResult.data!;
        _listResult = EnterpriseHubLoadResult<EnterpriseHubListData>(
          state: AppPageState.content,
          method: listResult.method,
          path: listResult.path,
          payload: listResult.payload,
          data: EnterpriseHubListData(
            recommended: next.recommended,
            items: <EnterpriseHubListItem>[...previous.items, ...next.items],
            pagination: next.pagination,
          ),
        );
      } else {
        _listResult = listResult;
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  void _toggleSearchField() {
    setState(() {
      if (_searchFieldVisible &&
          _searchController.text.trim().isEmpty &&
          (_query.keyword?.trim().isEmpty ?? true)) {
        _searchFieldVisible = false;
      } else {
        _searchFieldVisible = true;
        _searchController.text = _query.keyword ?? '';
      }
    });
    if (_searchFieldVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _searchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _applySearch() async {
    final normalized = _searchController.text.trim();
    setState(() {
      _query = buildEnterpriseBoardListQuery(
        boardType: widget.boardType,
        current: _query,
        keyword: normalized.isEmpty ? null : normalized,
        clearKeyword: normalized.isEmpty,
        page: 1,
      );
      _searchFieldVisible = normalized.isNotEmpty;
    });
    await _load();
  }

  Future<void> _clearSearch() async {
    _searchController.clear();
    setState(() {
      _query = buildEnterpriseBoardListQuery(
        boardType: widget.boardType,
        current: _query,
        clearKeyword: true,
        page: 1,
      );
    });
    await _load();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _searchFieldVisible = false;
      _searchController.text = _query.keyword ?? '';
    });
  }

  Future<void> _selectCity(String cityCode) async {
    final cityOption = enterpriseHubCityOptionByCode(_regionCatalog, cityCode);
    setState(() {
      _query = buildEnterpriseBoardListQuery(
        boardType: widget.boardType,
        current: _query,
        cityCode: cityOption?.cityCode,
        provinceCode: cityOption?.provinceCode,
        clearCity: cityCode.isEmpty,
        page: 1,
      );
    });
    await _load();
  }

  Future<void> _openCityPicker() async {
    final fallbackOptions = _fallbackCityOptions;
    if (_regionCatalog == null && fallbackOptions.isNotEmpty) {
      final picked = await _showFallbackCityPicker(fallbackOptions);
      if (!mounted) {
        return;
      }
      await _selectCity(picked?.cityCode ?? '');
      return;
    }
    try {
      final catalog = _regionCatalog ?? await ChinaRegionCatalogLoader.load();
      if (!mounted) {
        return;
      }
      if (_regionCatalog == null) {
        setState(() {
          _regionCatalog = catalog;
          _cityFilterNotice = null;
        });
      }
      final picked = await showChinaCityPicker(
        context: context,
        catalog: catalog,
        title: '选择城市',
        initialCityCode: _query.cityCode,
        initialProvinceCode: _query.provinceCode,
        allowClear: true,
        clearLabel: '不限',
      );
      if (!mounted) {
        return;
      }
      await _selectCity(picked?.cityCode ?? '');
    } catch (_) {
      final fallbackOptions = _fallbackCityOptions;
      if (fallbackOptions.isNotEmpty) {
        final picked = await _showFallbackCityPicker(fallbackOptions);
        if (!mounted) {
          return;
        }
        setState(() {
          _cityFilterNotice = null;
        });
        await _selectCity(picked?.cityCode ?? '');
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _cityFilterNotice = '城市筛选当前不可用，请稍后重试。';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '当前城市筛选暂不可用，请稍后重试。',
          ),
        ),
      );
    }
  }

  Future<void> _selectPlantArea(String value) async {
    setState(() {
      _query = buildEnterpriseBoardListQuery(
        boardType: widget.boardType,
        current: _query,
        plantAreaRange: value.isEmpty ? null : value,
        clearPlantAreaRange: value.isEmpty,
        page: 1,
      );
    });
    await _load();
  }

  Future<void> _loadMore() async {
    final pagination = _listResult?.data?.pagination;
    if (pagination == null || !pagination.hasMore || _loadingMore) {
      return;
    }

    setState(() {
      _query = buildEnterpriseBoardListQuery(
        boardType: widget.boardType,
        current: _query,
        page: pagination.page + 1,
      );
    });
    await _load(append: true);
  }

  Future<EnterpriseHubCityOption?> _showFallbackCityPicker(
    List<EnterpriseHubCityOption> options,
  ) {
    return showModalBottomSheet<EnterpriseHubCityOption?>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              const ListTile(title: Text('选择城市')),
              ListTile(
                title: const Text('不限'),
                onTap: () => Navigator.of(context).pop(null),
              ),
              ...options.map(
                (EnterpriseHubCityOption option) => ListTile(
                  title: Text(option.displayName),
                  subtitle: Text('${option.provinceName} / ${option.cityName}'),
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listData = _listResult?.data;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          EnterpriseListToolbarCard(
            searchFieldVisible:
                _searchFieldVisible ||
                (_query.keyword?.trim().isNotEmpty ?? false),
            searchField: EnterpriseInlineSearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: _surfaceSpec.searchHint,
              onSubmitted: _applySearch,
              onClear: _clearSearch,
              onClose: _closeSearch,
            ),
            filterButtons: buildEnterpriseBoardFilterButtons(
              boardType: widget.boardType,
              surfaceSpec: _surfaceSpec,
              selectedCityLabel: _selectedCityLabel,
              selectedAreaLabel: _selectedAreaLabel,
              cityFilterEnabled: _cityFilterEnabled,
              onCityPressed: _openCityPicker,
              onAreaSelected: _selectPlantArea,
            ),
            toolbarNoticeText: _effectiveCityFilterNotice,
            resultSummaryText: enterpriseBoardListResultSummaryText(
              boardType: widget.boardType,
              result: _listResult,
              loading: _loading,
            ),
          ),
          if (_loading) ...<Widget>[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: 16),
          _buildListBody(listData?.items ?? const <EnterpriseHubListItem>[]),
          if (listData != null) ...<Widget>[
            const SizedBox(height: 16),
            Center(
              child: FilledButton.tonal(
                onPressed: listData.pagination.hasMore && !_loadingMore
                    ? _loadMore
                    : null,
                child: Text(
                  _loadingMore
                      ? '加载中'
                      : listData.pagination.hasMore
                      ? '加载更多'
                      : '没有更多了',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListBody(List<EnterpriseHubListItem> items) {
    final result = _listResult;
    if (_loading && result == null) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (result != null &&
        result.state != AppPageState.content &&
        result.state != AppPageState.empty) {
      return EnterpriseListMessageCard(
        message: '当前展示：受控状态。${result.message ?? '当前列表暂不可用。'}',
        actionLabel: '刷新',
        onPressed: _load,
      );
    }

    if (items.isEmpty) {
      return const EnterpriseListMessageCard(
        message: '当前展示：真实空结果。当前条件下没有企业卡片。',
      );
    }

    return Column(
      children: items
          .map(
            (EnterpriseHubListItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnterpriseCard(
                item: item,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(enterpriseDetailRouteForItem(item));
                },
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
