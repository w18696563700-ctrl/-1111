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

  IconData get icon => switch (this) {
    _HomeModuleTab.project => Icons.snippet_folder_outlined,
    _HomeModuleTab.forum => Icons.forum_outlined,
    _HomeModuleTab.company => Icons.apartment_rounded,
    _HomeModuleTab.factory => Icons.factory_outlined,
    _HomeModuleTab.supplier => Icons.business_center_outlined,
    _HomeModuleTab.team => Icons.groups_2_outlined,
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
    required this.onRelocateHome,
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
  final Future<void> Function() onRelocateHome;
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExhibitionHomeVisualTokens.cardBackground,
        borderRadius: BorderRadius.circular(
          ExhibitionHomeVisualTokens.radiusLarge,
        ),
        boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HomeModuleTabStrip(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
            const SizedBox(height: 8),
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
        onRelocateHome: onRelocateHome,
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
        onRelocateHome: onRelocateHome,
        onOpenEnterpriseItem: onOpenEnterpriseItem,
        onOpenBoard: onOpenCompanyBoard,
      ),
      _HomeModuleTab.factory => _HomeEnterpriseModulePanel(
        boardType: EnterpriseBoardType.factory,
        openBoardLabel: '进入工厂列表',
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onRelocateHome: onRelocateHome,
        onOpenEnterpriseItem: onOpenEnterpriseItem,
        onOpenBoard: onOpenFactoryBoard,
      ),
      _HomeModuleTab.supplier => _HomeSupplierModulePanel(
        provinceCode: locationSnapshot?.provinceCode,
        provinceName: locationSnapshot?.provinceName,
        onRelocateHome: onRelocateHome,
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
                padding: const EdgeInsets.only(right: 6),
                child: Builder(
                  builder: (BuildContext chipContext) {
                    return _HomeModuleTabChip(
                      key: ValueKey<String>('home-tab-${tab.name}'),
                      tab: tab,
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
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  final _HomeModuleTab tab;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? ExhibitionHomeVisualTokens.brandGoldDeep
        : ExhibitionHomeVisualTokens.textSecondary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? ExhibitionHomeVisualTokens.brandGoldLight
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? ExhibitionHomeVisualTokens.brandGold.withValues(alpha: 0.3)
                  : ExhibitionHomeVisualTokens.borderSoft,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(tab.icon, size: 16, color: foreground),
              const SizedBox(width: 5),
              Text(
                tab.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: foreground,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
