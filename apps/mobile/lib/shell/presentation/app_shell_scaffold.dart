import 'package:flutter/material.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';

const double _shellEdgeBackGestureWidth = 24;
const double _shellEdgeBackTriggerDistance = 56;
const double _shellEdgeBackDominanceRatio = 1.5;

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
    this.showBottomNavigationBar = true,
  });

  final AppBuilding currentBuilding;
  final Widget child;
  final String? titleOverride;
  final Widget? titleContent;
  final List<Widget> appBarActions;
  final Widget? floatingActionButton;
  final ValueChanged<AppBuilding>? onBuildingSelected;
  final bool showStageBanner;
  final bool showBottomNavigationBar;

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
    final unreadBadgeLabel = shellContext.messagesUnreadBadgeLabel;
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
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                if (showStageBanner && !currentBuilding.showsInBottomNavigation)
                  _ShellStageBanner(currentBuilding: currentBuilding),
                Expanded(child: child),
              ],
            ),
          ),
          if (canPop)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _shellEdgeBackGestureWidth,
              child: _ShellEdgeBackGestureOverlay(
                onBack: () {
                  navigator.maybePop();
                },
              ),
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNavigationBar
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
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
                      height: 74,
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
            )
          : null,
    );
  }
}

class _ShellEdgeBackGestureOverlay extends StatefulWidget {
  const _ShellEdgeBackGestureOverlay({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_ShellEdgeBackGestureOverlay> createState() =>
      _ShellEdgeBackGestureOverlayState();
}

class _ShellEdgeBackGestureOverlayState
    extends State<_ShellEdgeBackGestureOverlay> {
  int? _pointer;
  Offset _totalDelta = Offset.zero;
  bool _triggered = false;

  void _reset() {
    _pointer = null;
    _totalDelta = Offset.zero;
    _triggered = false;
  }

  bool _shouldBack() {
    final horizontal = _totalDelta.dx;
    final vertical = _totalDelta.dy.abs();
    return horizontal >= _shellEdgeBackTriggerDistance &&
        horizontal > vertical * _shellEdgeBackDominanceRatio;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null) {
      return;
    }
    _pointer = event.pointer;
    _totalDelta = Offset.zero;
    _triggered = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _triggered) {
      return;
    }
    _totalDelta += event.delta;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    if (!_triggered && _shouldBack()) {
      _triggered = true;
      widget.onBack();
    }
    _reset();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer == _pointer) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: const SizedBox.expand(),
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
