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
          description: '先看本省项目推荐，再进入详情判断是否继续竞标。',
          statusLabel: '已接通',
          actionLabel: '进入模块',
          onPressed: onShowcasePressed,
          highlighted: true,
        ),
        _HomeModuleCard(
          title: companyModule.title,
          description: companyModule.summary,
          statusLabel: companyModule.statusLabel,
          actionLabel: companyModule.actionLabel,
          onPressed: onCompanyPressed,
        ),
        _HomeModuleCard(
          title: factoryModule.title,
          description: factoryModule.summary,
          statusLabel: factoryModule.statusLabel,
          actionLabel: factoryModule.actionLabel,
          onPressed: onFactoryPressed,
        ),
        _HomeModuleCard(
          title: supplierModule.title,
          description: supplierModule.summary,
          statusLabel: supplierModule.statusLabel,
          actionLabel: supplierModule.actionLabel,
          onPressed: onSupplierPressed,
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

class _HomePrivateEntryCard extends StatelessWidget {
  const _HomePrivateEntryCard({
    required this.onWorkbenchPressed,
    required this.onPublishPressed,
  });

  static const ValueKey<String> workbenchButtonKey = ValueKey<String>(
    'home-private-entry-workbench',
  );
  static const ValueKey<String> publishButtonKey = ValueKey<String>(
    'home-private-entry-publish',
  );

  final VoidCallback onWorkbenchPressed;
  final VoidCallback onPublishPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HomePill(
              label: '私域入口',
              backgroundColor: colorScheme.onSecondaryContainer.withValues(
                alpha: 0.12,
              ),
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              '项目工作台',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '查看当前项目摘要与下一步入口；需要新发项目时，直接进入创建项目。',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final viewport = MediaQuery.sizeOf(context);
                final useCompactLayout =
                    viewport.width < 880 || viewport.height < 760;
                final workbenchButton = FilledButton(
                  key: workbenchButtonKey,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: onWorkbenchPressed,
                  child: const Text('项目工作台'),
                );
                final publishButton = FilledButton.tonal(
                  key: publishButtonKey,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: onPublishPressed,
                  child: const Text('创建项目'),
                );

                if (useCompactLayout) {
                  final compactButtonMaxWidth = constraints.maxWidth < 320
                      ? constraints.maxWidth
                      : 320.0;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compactButtonMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          workbenchButton,
                          const SizedBox(height: 12),
                          publishButton,
                        ],
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[workbenchButton, publishButton],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
