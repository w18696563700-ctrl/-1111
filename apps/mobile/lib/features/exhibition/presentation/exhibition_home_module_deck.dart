part of 'exhibition_home_page.dart';

enum _HomeModuleTab { project, forum, company, factory, supplier, team }

extension _HomeModuleTabPresentation on _HomeModuleTab {
  String get title => switch (this) {
    _HomeModuleTab.project => '项目',
    _HomeModuleTab.forum => '论坛',
    _HomeModuleTab.company => '公司',
    _HomeModuleTab.factory => '工厂',
    _HomeModuleTab.supplier => '供应商',
    _HomeModuleTab.team => '团队',
  };
}

class _HomeModuleDeck extends StatelessWidget {
  const _HomeModuleDeck({
    required this.selectedTab,
    required this.onTabSelected,
    required this.loading,
    required this.locationSnapshot,
    required this.projectResult,
    required this.projectItems,
    required this.onRefreshHome,
    required this.onOpenProjectList,
    required this.onOpenProjectCreate,
    required this.onOpenProjectDetail,
    required this.onOpenForum,
    required this.onOpenForumPublish,
    required this.onOpenForumPost,
    required this.onOpenCompanyBoard,
    required this.onOpenFactoryBoard,
    required this.onOpenSupplierBoard,
    required this.onOpenEnterpriseItem,
    required this.onOpenTeamExplanation,
  });

  final _HomeModuleTab selectedTab;
  final ValueChanged<_HomeModuleTab> onTabSelected;
  final bool loading;
  final DeviceLocationSnapshot? locationSnapshot;
  final ExhibitionLoadResult? projectResult;
  final List<Map<String, Object?>> projectItems;
  final Future<void> Function() onRefreshHome;
  final VoidCallback onOpenProjectList;
  final VoidCallback onOpenProjectCreate;
  final ValueChanged<String> onOpenProjectDetail;
  final VoidCallback onOpenForum;
  final VoidCallback onOpenForumPublish;
  final ValueChanged<String> onOpenForumPost;
  final VoidCallback onOpenCompanyBoard;
  final VoidCallback onOpenFactoryBoard;
  final VoidCallback onOpenSupplierBoard;
  final ValueChanged<EnterpriseHubListItem> onOpenEnterpriseItem;
  final VoidCallback onOpenTeamExplanation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HomeModuleTabStrip(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey<String>('home-panel-${selectedTab.name}'),
                child: _buildActivePanel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePanel(BuildContext context) {
    return switch (selectedTab) {
      _HomeModuleTab.project => _HomeProjectModulePanel(
        loading: loading,
        result: projectResult,
        projectItems: projectItems,
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onRefreshHome: onRefreshHome,
        onOpenProjectList: onOpenProjectList,
        onOpenProjectCreate: onOpenProjectCreate,
        onOpenProjectDetail: onOpenProjectDetail,
      ),
      _HomeModuleTab.forum => _HomeForumModulePanel(
        onOpenForum: onOpenForum,
        onOpenForumPublish: onOpenForumPublish,
        onOpenForumPost: onOpenForumPost,
      ),
      _HomeModuleTab.company => _HomeEnterpriseModulePanel(
        boardType: EnterpriseBoardType.company,
        openBoardLabel: '进入公司列表',
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onOpenEnterpriseItem: onOpenEnterpriseItem,
        onOpenBoard: onOpenCompanyBoard,
      ),
      _HomeModuleTab.factory => _HomeEnterpriseModulePanel(
        boardType: EnterpriseBoardType.factory,
        openBoardLabel: '进入工厂列表',
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onOpenEnterpriseItem: onOpenEnterpriseItem,
        onOpenBoard: onOpenFactoryBoard,
      ),
      _HomeModuleTab.supplier => _HomeSupplierModulePanel(
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onOpenSupplierBoard: onOpenSupplierBoard,
        onOpenEnterpriseItem: onOpenEnterpriseItem,
      ),
      _HomeModuleTab.team => _HomeTeamModulePanel(
        onOpenTeamExplanation: onOpenTeamExplanation,
      ),
    };
  }
}

class _HomeModuleTabStrip extends StatelessWidget {
  const _HomeModuleTabStrip({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final _HomeModuleTab selectedTab;
  final ValueChanged<_HomeModuleTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _HomeModuleTab.values
            .map((_HomeModuleTab tab) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Builder(
                  builder: (BuildContext chipContext) {
                    return _HomeModuleTabChip(
                      key: ValueKey<String>('home-tab-${tab.name}'),
                      title: tab.title,
                      selected: selectedTab == tab,
                      onPressed: () {
                        onTabSelected(tab);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!chipContext.mounted) {
                            return;
                          }
                          Scrollable.ensureVisible(
                            chipContext,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            alignment: 0.5,
                          );
                        });
                      },
                    );
                  },
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _HomeModuleTabChip extends StatelessWidget {
  const _HomeModuleTabChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
