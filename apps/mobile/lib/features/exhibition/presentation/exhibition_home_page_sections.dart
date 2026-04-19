part of 'exhibition_home_page.dart';

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          summary,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _HomeModuleGrid extends StatelessWidget {
  const _HomeModuleGrid({
    required this.onShowcasePressed,
    required this.onForumPressed,
    required this.companyModule,
    required this.factoryModule,
    required this.supplierModule,
    required this.onCompanyPressed,
    required this.onFactoryPressed,
    required this.onSupplierPressed,
    required this.onTeamPlaceholderPressed,
  });

  final VoidCallback onShowcasePressed;
  final VoidCallback onForumPressed;
  final _HomeModuleProjection companyModule;
  final _HomeModuleProjection factoryModule;
  final _HomeModuleProjection supplierModule;
  final VoidCallback onCompanyPressed;
  final VoidCallback onFactoryPressed;
  final VoidCallback onSupplierPressed;
  final ValueChanged<String> onTeamPlaceholderPressed;

  @override
  Widget build(BuildContext context) {
    final enterpriseModules = <_HomeEnterpriseModuleCardConfig>[
      _HomeEnterpriseModuleCardConfig(
        moduleKey: 'excellent_company',
        projection: companyModule,
        onPressed: onCompanyPressed,
      ),
      _HomeEnterpriseModuleCardConfig(
        moduleKey: 'excellent_factory',
        projection: factoryModule,
        onPressed: onFactoryPressed,
      ),
      _HomeEnterpriseModuleCardConfig(
        moduleKey: 'excellent_supplier',
        projection: supplierModule,
        onPressed: onSupplierPressed,
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 0.76,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _HomeModuleCard(
          title: '项目展示',
          description: '先看本省项目推荐，再进入详情判断是否立即参与竞标。',
          statusLabel: '已接通',
          actionLabel: '进入模块',
          onPressed: onShowcasePressed,
          highlighted: true,
        ),
        ...enterpriseModules.map(
          (_HomeEnterpriseModuleCardConfig item) => _HomeModuleCard(
            key: ValueKey<String>('home-module-${item.moduleKey}'),
            title: item.projection.title,
            description: item.projection.summary,
            statusLabel: item.projection.statusLabel,
            actionLabel: item.projection.actionLabel,
            onPressed: item.onPressed,
          ),
        ),
        _HomeModuleCard(
          title: '展览论坛',
          description: '论坛继续承接热帖和主题讨论，作为首页推荐的辅助入口。',
          statusLabel: '已接通',
          actionLabel: '打开论坛',
          onPressed: onForumPressed,
        ),
        _HomeModuleCard(
          title: '优秀团队员工',
          description: '当前保留本省团队与工人推荐位，正式推荐接通后会直接替换。',
          statusLabel: '占位',
          actionLabel: '查看说明',
          onPressed: () => onTeamPlaceholderPressed('优秀团队员工'),
        ),
      ],
    );
  }
}

class _HomeEnterpriseModuleCardConfig {
  const _HomeEnterpriseModuleCardConfig({
    required this.moduleKey,
    required this.projection,
    required this.onPressed,
  });

  final String moduleKey;
  final _HomeModuleProjection projection;
  final VoidCallback onPressed;
}
