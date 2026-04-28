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

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.currentBuilding});

  final AppBuilding currentBuilding;

  @override
  Widget build(BuildContext context) {
    return _PersistentShellPage(initialBuilding: currentBuilding);
  }
}

class _PersistentShellPage extends StatefulWidget {
  const _PersistentShellPage({required this.initialBuilding});

  final AppBuilding initialBuilding;

  @override
  State<_PersistentShellPage> createState() => _PersistentShellPageState();
}

class _PersistentShellPageState extends State<_PersistentShellPage> {
  static const Duration _messagesAutoRefreshInterval = Duration(seconds: 3);
  final Map<AppBuilding, Widget> _cachedPages = <AppBuilding, Widget>{};
  final Set<AppBuilding> _activatedBottomBuildings = <AppBuilding>{};
  final ValueNotifier<int> _messagesRefreshSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> _messagesEntrySignal = ValueNotifier<int>(0);
  Timer? _messagesRefreshTimer;
  late AppBuilding _currentBuilding = widget.initialBuilding;

  @override
  void initState() {
    super.initState();
    _activateBuilding(_currentBuilding);
    _syncMessagesRefreshTimer();
  }

  @override
  void dispose() {
    _messagesRefreshTimer?.cancel();
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

    setState(() {
      _currentBuilding = building;
      _activateBuilding(building);
      _syncMessagesRefreshTimer();
    });
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
    _messagesRefreshTimer = Timer.periodic(
      _messagesAutoRefreshInterval,
      (_) {
        if (!mounted || _currentBuilding != AppBuilding.messages) {
          return;
        }
        _messagesRefreshSignal.value += 1;
      },
    );
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

    return AppShellScaffold(
      currentBuilding: _currentBuilding,
      titleOverride: _currentBuilding == AppBuilding.messages ? '互动中心' : null,
      onBuildingSelected: _selectBuilding,
      showStageBanner: _currentBuilding != AppBuilding.exhibition,
      child: body,
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

    return IndexedStack(
      index: selectedIndex,
      children: visibleBottomBuildings.map(_persistentChild).toList(),
    );
  }

  Widget _persistentChild(AppBuilding building) {
    if (!_activatedBottomBuildings.contains(building)) {
      return const SizedBox.shrink();
    }

    return KeyedSubtree(
      key: ValueKey<String>('shell-root-${building.code}'),
      child: _cachedPages.putIfAbsent(
        building,
        () => Builder(
          builder: (BuildContext context) => _buildingBody(context, building),
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
      AppBuilding.messages =>
        MessagesPage(
          refreshSignal: _messagesRefreshSignal,
          entrySignal: _messagesEntrySignal,
        ),
      AppBuilding.profile => const ProfilePage(),
    };
  }
}
