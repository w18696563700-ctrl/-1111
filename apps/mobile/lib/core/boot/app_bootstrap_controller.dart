import 'dart:async';

import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/shell/navigation/app_building.dart';

enum GlobalShellState {
  booting,
  unauthenticated,
  sessionRefreshing,
  noOrganization,
  forbidden,
  unavailable,
  hiddenBuildingUnavailable,
  offline,
  maintenance,
}

extension GlobalShellStateX on GlobalShellState {
  String get contractName => switch (this) {
    GlobalShellState.booting => 'booting',
    GlobalShellState.unauthenticated => 'unauthenticated',
    GlobalShellState.sessionRefreshing => 'session_refreshing',
    GlobalShellState.noOrganization => 'no_organization',
    GlobalShellState.forbidden => 'forbidden',
    GlobalShellState.unavailable => 'unavailable',
    GlobalShellState.hiddenBuildingUnavailable => 'hidden_building_unavailable',
    GlobalShellState.offline => 'offline',
    GlobalShellState.maintenance => 'maintenance',
  };
}

class AppShellContextSnapshot {
  const AppShellContextSnapshot({
    required this.manifest,
    required this.blockingState,
    required this.blockingMessage,
    required this.shellContext,
  });

  final AppConfigManifest manifest;
  final GlobalShellState? blockingState;
  final String? blockingMessage;
  final AppShellContextData shellContext;

  bool isBuildingVisible(AppBuilding building) =>
      manifest.isEnabled(building.visibilityFlagKey);
}

class AppBootstrapController extends ChangeNotifier {
  static const Duration _bootstrapShellContextTimeout = Duration(seconds: 5);

  AppBootstrapController({
    AppConfigManifest? bootstrapManifest,
    AppShellContextData? bootstrapShellContext,
    AppShellContextConsumer? shellContextConsumer,
  }) : _manifest = bootstrapManifest ?? AppConfigManifest.bootstrapDefaults(),
       _shellContext =
           bootstrapShellContext ??
           AppShellContextData.bootstrapDefaults(
             manifest:
                 bootstrapManifest ?? AppConfigManifest.bootstrapDefaults(),
           ),
       _shellContextConsumer = bootstrapShellContext == null
           ? shellContextConsumer
           : null;

  final AppConfigManifest _manifest;
  AppShellContextData _shellContext;
  final AppShellContextConsumer? _shellContextConsumer;
  GlobalShellState? _blockingState = GlobalShellState.booting;
  String? _blockingMessage;
  bool _disposed = false;
  bool _initialized = false;
  bool _hasLoadedShellContext = false;

  AppShellContextSnapshot get snapshot => AppShellContextSnapshot(
    manifest: _manifest,
    blockingState: _blockingState,
    blockingMessage: _blockingMessage,
    shellContext: _shellContext,
  );

  void initialize() {
    if (_initialized) {
      return;
    }

    _initialized = true;
    Future<void>.microtask(_bootstrapShell);
  }

  GlobalShellState? guardBuilding(AppBuilding building) {
    if (_blockingState case final GlobalShellState blockingState) {
      if ((blockingState == GlobalShellState.unauthenticated ||
              blockingState == GlobalShellState.noOrganization) &&
          building == AppBuilding.exhibition) {
        return null;
      }
      return blockingState;
    }

    if (!snapshot.isBuildingVisible(building)) {
      return GlobalShellState.hiddenBuildingUnavailable;
    }

    return null;
  }

  Future<void> reloadShellContext() async {
    final consumer = _shellContextConsumer;
    if (consumer == null) {
      _setBlockingState(null);
      notifyListeners();
      return;
    }

    await _loadShellContext(consumer);
  }

  Future<void> refreshSessionAndReloadShell() async {
    final consumer = _shellContextConsumer;
    if (consumer == null) {
      _setBlockingState(GlobalShellState.unauthenticated);
      notifyListeners();
      return;
    }

    _setBlockingState(GlobalShellState.sessionRefreshing);
    notifyListeners();
    await _refreshSessionThenLoadShell(consumer);
  }

  Future<void> bootstrapAfterLogin({
    required String shellBootstrapState,
  }) async {
    if (_shellContextConsumer == null) {
      _setBlockingState(
        shellBootstrapState == 'no_organization'
            ? GlobalShellState.noOrganization
            : null,
      );
      notifyListeners();
      return;
    }

    await reloadShellContext();
    if (_blockingState == GlobalShellState.offline &&
        shellBootstrapState == 'no_organization') {
      _setBlockingState(GlobalShellState.noOrganization);
      notifyListeners();
    }
  }

  void handleLoggedOut() {
    AppSessionStore.instance.clearSession();
    _shellContext = AppShellContextData.bootstrapDefaults(manifest: _manifest);
    _hasLoadedShellContext = false;
    _setBlockingState(GlobalShellState.unauthenticated);
    notifyListeners();
  }

  void applyShellContext(AppShellContextData data) {
    _shellContext = data;
    _hasLoadedShellContext = true;
    _setBlockingState(
      data.organizationId == null ? GlobalShellState.noOrganization : null,
    );
    notifyListeners();
  }

  void applyMessagesUnreadProjection(int unreadCount) {
    final normalized = unreadCount < 0 ? 0 : unreadCount;
    final nextSummary = Map<String, Object?>.of(
      _shellContext.unreadSummary ?? const <String, Object?>{},
    );
    if (nextSummary['messages'] == normalized) {
      return;
    }
    nextSummary['messages'] = normalized;
    _shellContext = _shellContext.copyWith(unreadSummary: nextSummary);
    notifyListeners();
  }

  Future<void> _bootstrapShell() async {
    final consumer = _shellContextConsumer;
    if (consumer == null) {
      _setBlockingState(null);
      notifyListeners();
      return;
    }

    if (!AppSessionStore.instance.hasAnySession) {
      _setBlockingState(GlobalShellState.unauthenticated);
      notifyListeners();
      return;
    }

    if (AppSessionStore.instance.shouldRefresh) {
      _setBlockingState(GlobalShellState.sessionRefreshing);
      notifyListeners();
      await _refreshSessionThenLoadShell(consumer);
      return;
    }

    await _loadShellContext(consumer);
  }

  Future<void> _refreshSessionThenLoadShell(
    AppShellContextConsumer consumer,
  ) async {
    final refreshResult = await AuthConsumerLayer.instance.refreshSession();
    if (_disposed) {
      return;
    }

    if (refreshResult.state == AppPageState.content) {
      await _loadShellContext(consumer);
      return;
    }

    if (refreshResult.state == AppPageState.unauthorized) {
      _hasLoadedShellContext = false;
    }
    if (_hasLoadedShellContext &&
        refreshResult.state == AppPageState.errorRetryable) {
      _setBlockingState(_stateForCurrentShellContext());
      notifyListeners();
      return;
    }

    _setBlockingState(
      refreshResult.state == AppPageState.unauthorized
          ? GlobalShellState.unauthenticated
          : GlobalShellState.offline,
      message: refreshResult.message,
    );
    notifyListeners();
  }

  Future<void> _loadShellContext(AppShellContextConsumer consumer) async {
    final result = await consumer.loadResult().timeout(
      _bootstrapShellContextTimeout,
      onTimeout: () => const AppShellContextResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message: 'shell context request timed out',
      ),
    );

    if (_disposed) {
      return;
    }

    if (result.state == AppPageState.content) {
      final data = result.data;
      if (data == null) {
        _setBlockingState(GlobalShellState.unavailable);
      } else {
        _shellContext = data;
        _hasLoadedShellContext = true;
        _setBlockingState(
          data.organizationId == null ? GlobalShellState.noOrganization : null,
        );
      }
      notifyListeners();
      return;
    }

    if (result.state == AppPageState.unauthorized) {
      if (AppSessionStore.instance.hasRefreshToken) {
        _setBlockingState(GlobalShellState.sessionRefreshing);
        notifyListeners();
        await _refreshSessionThenLoadShell(consumer);
        return;
      }

      AppSessionStore.instance.clearSession();
      _hasLoadedShellContext = false;
      _setBlockingState(GlobalShellState.unauthenticated);
      notifyListeners();
      return;
    }

    if (_hasLoadedShellContext && result.state == AppPageState.errorRetryable) {
      _setBlockingState(_stateForCurrentShellContext());
      notifyListeners();
      return;
    }

    _setBlockingState(switch (result.state) {
      AppPageState.forbidden => GlobalShellState.forbidden,
      AppPageState.notFound ||
      AppPageState.errorNonRetryable => GlobalShellState.unavailable,
      _ => GlobalShellState.offline,
    }, message: result.message);
    notifyListeners();
  }

  GlobalShellState? _stateForCurrentShellContext() {
    return _shellContext.organizationId == null
        ? GlobalShellState.noOrganization
        : null;
  }

  void _setBlockingState(GlobalShellState? state, {String? message}) {
    _blockingState = state;
    final value = message?.trim();
    _blockingMessage = value == null || value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
