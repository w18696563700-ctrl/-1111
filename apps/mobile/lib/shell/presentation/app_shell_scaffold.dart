import 'package:flutter/material.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.currentBuilding,
    required this.child,
    this.titleOverride,
    this.titleContent,
    this.appBarActions = const <Widget>[],
    this.floatingActionButton,
    this.onBuildingSelected,
    this.showStageBanner = true,
  });

  final AppBuilding currentBuilding;
  final Widget child;
  final String? titleOverride;
  final Widget? titleContent;
  final List<Widget> appBarActions;
  final Widget? floatingActionButton;
  final ValueChanged<AppBuilding>? onBuildingSelected;
  final bool showStageBanner;

  @override
  Widget build(BuildContext context) {
    final controller = AppShellScope.of(context);
    final shellContext = controller.snapshot.shellContext;
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();
    final visibleBottomBuildings = bottomNavigationBuildings
        .where(controller.snapshot.isBuildingVisible)
        .toList();
    final selectedIndex = visibleBottomBuildings.indexOf(currentBuilding);
    final unreadBadgeLabel = shellContext.unreadSummaryBadgeLabel;
    final theme = Theme.of(context);
    final appBarActions = <Widget>[
      ...this.appBarActions,
      if (!currentBuilding.showsInBottomNavigation)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '预埋楼层',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
    ];
    final hideRootExhibitionAppBar =
        currentBuilding == AppBuilding.exhibition &&
        titleOverride == null &&
        !canPop;

    return Scaffold(
      appBar: hideRootExhibitionAppBar
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        navigator.maybePop();
                      },
                    )
                  : null,
              title:
                  titleContent ?? Text(titleOverride ?? currentBuilding.label),
              actions: appBarActions.isEmpty ? null : appBarActions,
            ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (showStageBanner && !currentBuilding.showsInBottomNavigation)
              _ShellStageBanner(currentBuilding: currentBuilding),
            Expanded(child: child),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: NavigationBar(
                height: 78,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                destinations: visibleBottomBuildings
                    .map(
                      (AppBuilding building) => NavigationDestination(
                        icon: _ShellNavigationIcon(
                          icon: building.icon,
                          badgeLabel: building == AppBuilding.messages
                              ? unreadBadgeLabel
                              : null,
                        ),
                        selectedIcon: _ShellNavigationIcon(
                          icon: building.selectedIcon,
                          badgeLabel: building == AppBuilding.messages
                              ? unreadBadgeLabel
                              : null,
                        ),
                        label: building.label,
                      ),
                    )
                    .toList(),
                onDestinationSelected: (int index) {
                  final targetBuilding = visibleBottomBuildings[index];
                  if (targetBuilding == currentBuilding) {
                    return;
                  }

                  final onBuildingSelected = this.onBuildingSelected;
                  if (onBuildingSelected != null) {
                    onBuildingSelected(targetBuilding);
                    return;
                  }

                  Navigator.of(
                    context,
                  ).pushReplacementNamed(targetBuilding.routePath);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellStageBanner extends StatelessWidget {
  const _ShellStageBanner({required this.currentBuilding});

  final AppBuilding currentBuilding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  '当前楼层暂未开放到首发主路径',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppBuilding.exhibition.routePath);
                  },
                  child: const Text('回到展览'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellNavigationIcon extends StatelessWidget {
  const _ShellNavigationIcon({required this.icon, this.badgeLabel});

  final IconData icon;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final label = badgeLabel;
    if (label == null) {
      return Icon(icon);
    }

    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon),
        Positioned(
          right: -10,
          top: -6,
          child: Semantics(
            label: '消息未处理摘要 $label',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
