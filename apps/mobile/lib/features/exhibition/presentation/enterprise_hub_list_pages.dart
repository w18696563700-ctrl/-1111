import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

class EnterpriseBoardListPage extends StatefulWidget {
  const EnterpriseBoardListPage({
    super.key,
    required this.boardType,
  });

  final EnterpriseBoardType boardType;

  @override
  State<EnterpriseBoardListPage> createState() => _EnterpriseBoardListPageState();
}

class _EnterpriseBoardListPageState extends State<EnterpriseBoardListPage> {
  late final TextEditingController _searchController;
  late final TextEditingController _filterOneController;
  late final TextEditingController _filterTwoController;
  late EnterpriseHubListQuery _query;
  EnterpriseHubLoadResult<EnterpriseHubListData>? _listResult;
  EnterpriseHubLoadResult<EnterpriseHubRecommendationData>? _recommendationResult;
  bool _loading = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterOneController = TextEditingController();
    _filterTwoController = TextEditingController();
    _query = EnterpriseHubListQuery(boardType: widget.boardType);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterOneController.dispose();
    _filterTwoController.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });

    final results = await Future.wait<Object>(<Future<Object>>[
      EnterpriseHubConsumerLayer.instance.loadEnterprises(_query),
      EnterpriseHubConsumerLayer.instance.loadRecommendations(widget.boardType),
    ]);
    if (!mounted) {
      return;
    }

    final listResult = results[0] as EnterpriseHubLoadResult<EnterpriseHubListData>;
    final recommendationResult =
        results[1] as EnterpriseHubLoadResult<EnterpriseHubRecommendationData>;

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
            items: <EnterpriseHubListItem>[
              ...previous.items,
              ...next.items,
            ],
            pagination: next.pagination,
          ),
        );
      } else {
        _listResult = listResult;
      }
      _recommendationResult = recommendationResult;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _applySearchAndFilters() async {
    setState(() {
      _query = _query.copyWith(
        keyword: _searchController.text,
        exhibitionType: widget.boardType == EnterpriseBoardType.company
            ? _filterOneController.text
            : null,
        serviceCity: widget.boardType == EnterpriseBoardType.company
            ? _filterTwoController.text
            : null,
        processType: widget.boardType == EnterpriseBoardType.factory
            ? _filterOneController.text
            : null,
        urgentCapability: widget.boardType == EnterpriseBoardType.factory
            ? _filterTwoController.text
            : null,
        supplyCategory: widget.boardType == EnterpriseBoardType.supplier
            ? _filterOneController.text
            : null,
        supplyMode: widget.boardType == EnterpriseBoardType.supplier
            ? _filterTwoController.text
            : null,
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
      _query = _query.copyWith(page: pagination.page + 1);
    });
    await _load(append: true);
  }

  @override
  Widget build(BuildContext context) {
    final listData = _listResult?.data;
    final items = listData?.items ?? const <EnterpriseHubListItem>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        EnterpriseSectionCard(
          title: widget.boardType.title,
          subtitle: '列表页只承接搜索、筛选、排序、推荐位和卡片列表，不在这里展开 hub 首页。',
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ExhibitionRoutes.enterpriseApplyWithBoardType(
                    widget.boardType.contractName,
                  ),
                );
              },
              child: const Text('企业入驻'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '搜索框',
                  hintText: '按企业名称或关键词搜索',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _applySearchAndFilters,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
                onSubmitted: (_) => _applySearchAndFilters(),
              ),
              const SizedBox(height: 12),
              Text(
                '当前按 `${widget.boardType.contractName}` 读取 `/api/app/exhibition/enterprise-hub/enterprises`。',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BoardFilterBar(
          boardType: widget.boardType,
          certifiedOnly: _query.certifiedOnly,
          onCertifiedOnlyChanged: (bool value) {
            setState(() {
              _query = _query.copyWith(certifiedOnly: value, page: 1);
            });
            _load();
          },
          boardSpecificFilters: _buildBoardSpecificFilters(),
        ),
        const SizedBox(height: 16),
        BoardSortBar(
          currentSortBy: _query.sortBy,
          onChanged: (String value) {
            setState(() {
              _query = _query.copyWith(sortBy: value, page: 1);
            });
            _load();
          },
        ),
        const SizedBox(height: 16),
        RecommendationSlotBanner(
          boardType: widget.boardType,
          result: _recommendationResult,
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: '企业卡片列表',
          subtitle: _listSubtitle(),
          actions: <Widget>[
            FilledButton.tonal(
              onPressed: _loading ? null : _load,
              child: Text(_loading ? '加载中' : '刷新列表'),
            ),
          ],
          child: _buildListBody(items),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: '加载更多或分页',
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  listData == null
                      ? '当前还没有分页结果。'
                      : '第 ${listData.pagination.page} 页 / 共 ${listData.pagination.total} 条',
                ),
              ),
              FilledButton.tonal(
                onPressed: listData?.pagination.hasMore == true && !_loadingMore
                    ? _loadMore
                    : null,
                child: Text(_loadingMore ? '加载中' : '加载更多'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBoardSpecificFilters() {
    return <Widget>[
      SizedBox(
        width: 220,
        child: TextField(
          controller: _filterOneController,
          decoration: InputDecoration(
            labelText: switch (widget.boardType) {
              EnterpriseBoardType.company => '展会类型',
              EnterpriseBoardType.factory => '工艺类型',
              EnterpriseBoardType.supplier => '供应品类',
            },
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      SizedBox(
        width: 220,
        child: TextField(
          controller: _filterTwoController,
          decoration: InputDecoration(
            labelText: switch (widget.boardType) {
              EnterpriseBoardType.company => '服务城市',
              EnterpriseBoardType.factory => '加急能力',
              EnterpriseBoardType.supplier => '供应模式',
            },
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      FilledButton.tonal(
        onPressed: _applySearchAndFilters,
        child: const Text('应用筛选'),
      ),
    ];
  }

  String _listSubtitle() {
    final result = _listResult;
    if (_loading && result == null) {
      return '正在读取列表。';
    }
    if (result == null) {
      return '列表尚未开始读取。';
    }

    return switch (result.state) {
      AppPageState.content => '当前已接通真实列表数据。',
      AppPageState.empty => '当前返回为空列表。',
      AppPageState.notFound => '当前板块在边界内未返回内容。',
      AppPageState.unauthorized => '当前需要先恢复登录。',
      AppPageState.forbidden => '当前 actor 范围未开放该列表。',
      AppPageState.errorRetryable => result.message ?? '当前列表暂时不可用，可稍后重试。',
      AppPageState.errorNonRetryable =>
        result.message ?? '当前列表返回了受控失败。',
      AppPageState.loading => '正在读取列表。',
    };
  }

  Widget _buildListBody(List<EnterpriseHubListItem> items) {
    final result = _listResult;
    if (_loading && result == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Text(result?.message ?? '当前条件下没有企业卡片。');
    }

    return Column(
      children: items
          .map(
            (EnterpriseHubListItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnterpriseCard(
                item: item,
                onPressed: () {
                  Navigator.of(context).pushNamed(enterpriseDetailRouteForItem(item));
                },
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
