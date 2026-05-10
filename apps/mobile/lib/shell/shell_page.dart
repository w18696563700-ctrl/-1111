import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/features/custom_furniture/presentation/custom_furniture_page.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_hub_page.dart';
import 'package:mobile/features/messages/presentation/messages_page.dart';
import 'package:mobile/features/profile/presentation/profile_page.dart';
import 'package:mobile/features/renovation/presentation/renovation_page.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/guards/shell_guard.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/presentation/app_shell_scaffold.dart';
import 'package:mobile/shell/presentation/shell_state_page.dart';

const double _rootBuildingSwipeEdgeGuardWidth = 24;
const double _rootBuildingSwipeTriggerDistance = 80;
const double _rootBuildingSwipeDominanceRatio = 1.35;
const Duration _rootBuildingTransitionDuration = Duration(milliseconds: 180);
const Curve _rootBuildingTransitionCurve = Curves.easeOutCubic;

class AppShellPage extends StatelessWidget {
  const AppShellPage({
    super.key,
    required this.currentBuilding,
    this.initialRouteQueryParameters = const <String, String>{},
  });

  final AppBuilding currentBuilding;
  final Map<String, String> initialRouteQueryParameters;

  @override
  Widget build(BuildContext context) {
    return _PersistentShellPage(
      initialBuilding: currentBuilding,
      initialRouteQueryParameters: initialRouteQueryParameters,
    );
  }
}

class _PersistentShellPage extends StatefulWidget {
  const _PersistentShellPage({
    required this.initialBuilding,
    required this.initialRouteQueryParameters,
  });

  final AppBuilding initialBuilding;
  final Map<String, String> initialRouteQueryParameters;

  @override
  State<_PersistentShellPage> createState() => _PersistentShellPageState();
}

class _PersistentShellPageState extends State<_PersistentShellPage>
    with SingleTickerProviderStateMixin {
  static const Duration _messagesAutoRefreshInterval = Duration(seconds: 3);
  static const Duration _shellContextAutoRefreshInterval = Duration(
    seconds: 20,
  );
  final Map<AppBuilding, Widget> _cachedPages = <AppBuilding, Widget>{};
  final Set<AppBuilding> _activatedBottomBuildings = <AppBuilding>{};
  final ValueNotifier<int> _messagesRefreshSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> _messagesEntrySignal = ValueNotifier<int>(0);
  late final AnimationController _rootBuildingTransitionController;
  Timer? _messagesRefreshTimer;
  Timer? _shellContextRefreshTimer;
  late AppBuilding _currentBuilding = widget.initialBuilding;
  int _rootBuildingTransitionDirection = 0;
  bool _shellContextRefreshing = false;

  @override
  void initState() {
    super.initState();
    _rootBuildingTransitionController = AnimationController(
      vsync: this,
      duration: _rootBuildingTransitionDuration,
      value: 1,
    );
    _activateBuilding(_currentBuilding);
    _syncMessagesRefreshTimer();
    _startShellContextRefreshTimer();
  }

  @override
  void dispose() {
    _messagesRefreshTimer?.cancel();
    _shellContextRefreshTimer?.cancel();
    _rootBuildingTransitionController.dispose();
    _messagesRefreshSignal.dispose();
    _messagesEntrySignal.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PersistentShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBuilding != widget.initialBuilding) {
      _currentBuilding = widget.initialBuilding;
      _activateBuilding(_currentBuilding);
      _syncMessagesRefreshTimer();
    }
  }

  void _activateBuilding(AppBuilding building) {
    if (building.showsInBottomNavigation) {
      _activatedBottomBuildings.add(building);
    }
    if (building == AppBuilding.messages) {
      _messagesEntrySignal.value += 1;
      _messagesRefreshSignal.value += 1;
    }
  }

  void _selectBuilding(AppBuilding building) {
    if (_currentBuilding == building) {
      return;
    }

    final transitionDirection = _transitionDirectionTo(building);
    _rootBuildingTransitionController.value = 0;
    setState(() {
      _currentBuilding = building;
      _rootBuildingTransitionDirection = transitionDirection;
      _activateBuilding(building);
      _syncMessagesRefreshTimer();
    });
    _rootBuildingTransitionController.forward();
  }

  int _transitionDirectionTo(AppBuilding target) {
    final currentIndex = bottomNavigationBuildings.indexOf(_currentBuilding);
    final targetIndex = bottomNavigationBuildings.indexOf(target);
    if (currentIndex < 0 || targetIndex < 0 || currentIndex == targetIndex) {
      return 0;
    }
    return targetIndex > currentIndex ? 1 : -1;
  }

  void _syncMessagesRefreshTimer() {
    final shouldPoll = _currentBuilding == AppBuilding.messages;
    if (!shouldPoll) {
      _messagesRefreshTimer?.cancel();
      _messagesRefreshTimer = null;
      return;
    }
    if (_messagesRefreshTimer != null) {
      return;
    }
    _messagesRefreshTimer = Timer.periodic(_messagesAutoRefreshInterval, (_) {
      if (!mounted || _currentBuilding != AppBuilding.messages) {
        return;
      }
      _messagesRefreshSignal.value += 1;
    });
  }

  void _startShellContextRefreshTimer() {
    _shellContextRefreshTimer ??= Timer.periodic(
      _shellContextAutoRefreshInterval,
      (_) => _refreshShellContextForUnreadBadge(),
    );
  }

  Future<void> _refreshShellContextForUnreadBadge() async {
    if (!mounted || _shellContextRefreshing) {
      return;
    }
    _shellContextRefreshing = true;
    try {
      await AppShellScope.read(context).reloadShellContext();
    } finally {
      _shellContextRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppShellScope.of(context);
    final visibleBottomBuildings = bottomNavigationBuildings
        .where(controller.snapshot.isBuildingVisible)
        .toList();

    final body =
        _currentBuilding.showsInBottomNavigation &&
            controller.snapshot.isBuildingVisible(_currentBuilding)
        ? _persistentBody(visibleBottomBuildings)
        : _buildingBody(context, _currentBuilding);
    final canSwitchRootBuilding =
        _currentBuilding.showsInBottomNavigation &&
        controller.snapshot.isBuildingVisible(_currentBuilding) &&
        _currentBuilding != AppBuilding.messages &&
        !Navigator.of(context).canPop();
    final shellBody = canSwitchRootBuilding
        ? _RootBuildingSwipeRegion(
            currentBuilding: _currentBuilding,
            visibleBuildings: visibleBottomBuildings,
            onBuildingSelected: _selectBuilding,
            child: body,
          )
        : body;

    return AppShellScaffold(
      currentBuilding: _currentBuilding,
      onBuildingSelected: _selectBuilding,
      showStageBanner: _currentBuilding != AppBuilding.exhibition,
      child: shellBody,
    );
  }

  Widget _persistentBody(List<AppBuilding> visibleBottomBuildings) {
    final selectedIndex = visibleBottomBuildings.indexOf(_currentBuilding);
    if (selectedIndex < 0) {
      return Builder(
        builder: (BuildContext context) =>
            _buildingBody(context, _currentBuilding),
      );
    }

    return _RootBuildingTransition(
      controller: _rootBuildingTransitionController,
      direction: _rootBuildingTransitionDirection,
      child: IndexedStack(
        index: selectedIndex,
        children: visibleBottomBuildings.map(_persistentChild).toList(),
      ),
    );
  }

  Widget _persistentChild(AppBuilding building) {
    if (!_activatedBottomBuildings.contains(building)) {
      return const SizedBox.shrink();
    }

    final active = _currentBuilding == building;
    return ExcludeSemantics(
      excluding: !active,
      child: TickerMode(
        enabled: active,
        child: KeyedSubtree(
          key: ValueKey<String>('shell-root-${building.code}'),
          child: _cachedPages.putIfAbsent(
            building,
            () => Builder(
              builder: (BuildContext context) =>
                  _buildingBody(context, building),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildingBody(BuildContext context, AppBuilding building) {
    final controller = AppShellScope.of(context);
    final guard = AppShellGuard(controller);
    final blockingState = guard.resolve(building);

    return blockingState == null
        ? _pageForBuilding(building)
        : ShellStatePage(state: blockingState, building: building);
  }

  Widget _pageForBuilding(AppBuilding building) {
    return switch (building) {
      AppBuilding.exhibition => const ExhibitionHubPage(),
      AppBuilding.renovation => const RenovationPage(),
      AppBuilding.customFurniture => const CustomFurniturePage(),
      AppBuilding.messages => MessagesPage(
        refreshSignal: _messagesRefreshSignal,
        entrySignal: _messagesEntrySignal,
        initialPrimaryTabKey: widget.initialRouteQueryParameters['tab'],
        initialForumInteractionTabKey:
            widget.initialRouteQueryParameters['interactionTab'],
      ),
      AppBuilding.profile => const ProfilePage(),
    };
  }
}

class _RootBuildingTransition extends StatelessWidget {
  const _RootBuildingTransition({
    required this.controller,
    required this.direction,
    required this.child,
  });

  final Animation<double> controller;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final curved = _rootBuildingTransitionCurve.transform(controller.value);
        final travel = direction == 0 ? 0.0 : direction * (1 - curved) * 0.045;
        return Opacity(
          opacity: 0.92 + curved * 0.08,
          child: FractionalTranslation(
            translation: Offset(travel, 0),
            child: child,
          ),
        );
      },
    );
  }
}

class _RootBuildingSwipeRegion extends StatefulWidget {
  const _RootBuildingSwipeRegion({
    required this.currentBuilding,
    required this.visibleBuildings,
    required this.onBuildingSelected,
    required this.child,
  });

  final AppBuilding currentBuilding;
  final List<AppBuilding> visibleBuildings;
  final ValueChanged<AppBuilding> onBuildingSelected;
  final Widget child;

  @override
  State<_RootBuildingSwipeRegion> createState() =>
      _RootBuildingSwipeRegionState();
}

class _RootBuildingSwipeRegionState extends State<_RootBuildingSwipeRegion> {
  int? _pointer;
  bool _tracking = false;
  Offset _totalDelta = Offset.zero;

  void _reset() {
    _pointer = null;
    _tracking = false;
    _totalDelta = Offset.zero;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null) {
      return;
    }
    _pointer = event.pointer;
    _tracking = event.position.dx > _rootBuildingSwipeEdgeGuardWidth;
    _totalDelta = Offset.zero;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || !_tracking) {
      return;
    }
    _totalDelta += event.delta;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    if (_tracking) {
      _selectAdjacentBuilding();
    }
    _reset();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer == _pointer) {
      _reset();
    }
  }

  void _selectAdjacentBuilding() {
    final horizontal = _totalDelta.dx;
    final vertical = _totalDelta.dy.abs();
    if (horizontal.abs() < _rootBuildingSwipeTriggerDistance ||
        horizontal.abs() <= vertical * _rootBuildingSwipeDominanceRatio) {
      return;
    }

    final currentIndex = widget.visibleBuildings.indexOf(
      widget.currentBuilding,
    );
    if (currentIndex < 0) {
      return;
    }
    final targetIndex = currentIndex + (horizontal < 0 ? 1 : -1);
    if (targetIndex < 0 || targetIndex >= widget.visibleBuildings.length) {
      return;
    }
    widget.onBuildingSelected(widget.visibleBuildings[targetIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.child,
    );
  }
}
