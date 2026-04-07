part of '../exhibition_trade_pages.dart';

class MyProjectListPage extends StatefulWidget {
  const MyProjectListPage({super.key});

  @override
  State<MyProjectListPage> createState() => _MyProjectListPageState();
}

class _MyProjectListPageState extends State<MyProjectListPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadMyProjectList(
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: ExhibitionStageDemoCatalog.myProjectList,
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final snapshot = await _source.load(forceRefresh: forceRefresh);
    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '我的项目',
      summary: '查看当前组织的项目。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: AppBuilding.profile.routePath,
      recoveryButtonLabelOverride: '回到我的楼',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      showSourceNotice: false,
      showFallbackNotice: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content &&
            result.state != AppPageState.empty) {
          return const <Widget>[];
        }

        final ongoingProjects = _myProjectGroupItemsFromPayload(
          result.payload,
          'ongoingProjects',
        );
        final historicalProjects = _myProjectGroupItemsFromPayload(
          result.payload,
          'historicalProjects',
        );

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '项目概览',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _DetailLine(
                label: '进行中',
                value: '${ongoingProjects.length} 个',
                highlight: ongoingProjects.isNotEmpty,
              ),
              _DetailLine(
                label: '历史项目',
                value: '${historicalProjects.length} 个',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '进行中',
            items: ongoingProjects,
            emptyTitle: '当前没有进行中项目',
            emptyMessage: '当前暂无进行中的项目。',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '历史项目',
            items: historicalProjects,
            emptyTitle: '当前没有历史项目',
            emptyMessage: '当前暂无历史项目。',
          ),
        ];
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? summary,
    required List<Map<String, Object?>> items,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    return _ActionCard(
      title: title,
      summary: summary,
      children: <Widget>[
        if (items.isEmpty)
          _EmptyNotice(title: emptyTitle, message: emptyMessage)
        else
          ...items.map((Map<String, Object?> item) {
            final publicProject = _myProjectPublicProjectMap(item);
            final privateSummary = _myProjectPrivateProgressMap(item);
            final projectId = _normalizeId(
              publicProject?['projectId'] as String?,
            );
            if (publicProject == null ||
                privateSummary == null ||
                projectId == null) {
              return const SizedBox.shrink();
            }

            final title =
                _normalizeId(publicProject['title'] as String?) ?? '未命名项目';
            final projectNo =
                _normalizeId(publicProject['projectNo'] as String?) ?? '未提供';
            final summaryHeading =
                _myProjectSummaryHeading(publicProject) ??
                _myProjectPrivateSummaryText(privateSummary);
            final state = _normalizeId(publicProject['state'] as String?);
            final buildingType = _buildingTypeLabel(
              publicProject['buildingType'] as String?,
            );
            final areaLabel = _myProjectAreaLabel(
              publicProject['areaSqm'] as num?,
            );
            final regionLabel = _myProjectRegionLabel(publicProject);
            final pills = <String>[
              ..._myProjectPrivateSummaryPills(privateSummary),
              ...?(regionLabel == null ? null : <String>[regionLabel]),
              buildingType,
              if (publicProject['areaSqm'] is num) areaLabel,
            ];

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _EntityCard(
                title: title,
                description: summaryHeading,
                statusLabel: state == null
                    ? null
                    : _frontStageStateLabel(state),
                detailLines: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pills.map((String item) {
                      return _StatusPill(
                        label: item,
                        tone: _ActionCardTone.muted,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  _DetailLine(label: '项目编号', value: projectNo),
                  _DetailLine(label: '建筑类型', value: buildingType),
                  _DetailLine(
                    label: '预算金额',
                    value: _currencyText(publicProject['budgetAmount']),
                    highlight: true,
                  ),
                  if (regionLabel != null)
                    _DetailLine(label: '项目地点', value: regionLabel),
                  if (publicProject['areaSqm'] is num)
                    _DetailLine(label: '项目面积', value: areaLabel),
                  _DetailLine(
                    label: '当前进度',
                    value: _myProjectPrivateSummaryText(privateSummary),
                  ),
                ],
                actionLabel: '查看项目',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
