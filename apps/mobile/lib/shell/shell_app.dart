import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/core/notifications/app_notification_bootstrap.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/project_name_access_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/trading_im_consumer_layer.dart';
import 'package:mobile/features/messages/data/app_notification_parser.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_governance_appeal_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_governance_status_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shared/theme/app_theme.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_router.dart';

class ExhibitionMobileApp extends StatefulWidget {
  const ExhibitionMobileApp({
    super.key,
    this.initialRoute = '/',
    this.bootstrapManifest,
    this.bootstrapShellContext,
    this.shellContextConsumer,
    this.exhibitionConsumerLayer,
    this.exhibitionHomeAggregationClient,
    this.projectNameAccessConsumerLayer,
    this.forumConsumerLayer,
    this.tradingImConsumerLayer,
    this.authConsumerLayer,
    this.messagesConsumerLayer,
    this.counterpartConversationConsumerLayer,
    this.profileConsumerLayer,
    this.profileGovernanceAppealConsumerLayer,
    this.profileGovernanceStatusConsumerLayer,
    this.profileIdentityConsumerLayer,
    this.deviceLocationService,
    this.sessionStore,
  });

  final String initialRoute;
  final AppConfigManifest? bootstrapManifest;
  final AppShellContextData? bootstrapShellContext;
  final AppShellContextConsumer? shellContextConsumer;
  final ExhibitionConsumerLayer? exhibitionConsumerLayer;
  final ExhibitionHomeAggregationClient? exhibitionHomeAggregationClient;
  final ProjectNameAccessConsumerLayer? projectNameAccessConsumerLayer;
  final ForumConsumerLayer? forumConsumerLayer;
  final TradingImConsumerLayer? tradingImConsumerLayer;
  final AuthConsumerLayer? authConsumerLayer;
  final MessagesConsumerLayer? messagesConsumerLayer;
  final CounterpartConversationConsumerLayer?
  counterpartConversationConsumerLayer;
  final ProfileConsumerLayer? profileConsumerLayer;
  final ProfileGovernanceAppealConsumerLayer?
  profileGovernanceAppealConsumerLayer;
  final ProfileGovernanceStatusConsumerLayer?
  profileGovernanceStatusConsumerLayer;
  final ProfileIdentityConsumerLayer? profileIdentityConsumerLayer;
  final DeviceLocationService? deviceLocationService;
  final AppSessionStore? sessionStore;

  @override
  State<ExhibitionMobileApp> createState() => _ExhibitionMobileAppState();
}

class _ExhibitionMobileAppState extends State<ExhibitionMobileApp> {
  static const bool _enablePersistedSession = bool.fromEnvironment(
    'APP_ENABLE_PERSISTED_SESSION',
  );
  static const String _sessionStorageNamespace = String.fromEnvironment(
    'APP_SESSION_STORAGE_NAMESPACE',
    defaultValue: 'default',
  );

  late final AppBootstrapController _controller = AppBootstrapController(
    bootstrapManifest: widget.bootstrapManifest,
    bootstrapShellContext: widget.bootstrapShellContext,
    shellContextConsumer: widget.shellContextConsumer,
  );

  final AppRouter _router = const AppRouter();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _notificationBootstrapStarted = false;

  @override
  void initState() {
    super.initState();
    AppSessionStore.install(
      widget.sessionStore ??
          AppSessionStore(
            persistSession: _enablePersistedSession,
            storageNamespace: _sessionStorageNamespace,
          ),
    );
    final hasBootstrapSession = AppSessionStore.instance
        .establishBootstrapSessionFromEnvironment();
    AuthConsumerLayer.install(widget.authConsumerLayer ?? AuthConsumerLayer());
    ExhibitionConsumerLayer.install(
      widget.exhibitionConsumerLayer ?? ExhibitionConsumerLayer(),
    );
    ExhibitionHomeAggregationClient.install(
      widget.exhibitionHomeAggregationClient ??
          CanonicalExhibitionHomeAggregationClient(),
    );
    ProjectNameAccessConsumerLayer.install(
      widget.projectNameAccessConsumerLayer ?? ProjectNameAccessConsumerLayer(),
    );
    DeviceLocationService.install(
      widget.deviceLocationService ?? GeolocatorDeviceLocationService(),
    );
    ForumConsumerLayer.install(
      widget.forumConsumerLayer ?? ForumConsumerLayer(),
    );
    TradingImConsumerLayer.install(
      widget.tradingImConsumerLayer ?? TradingImConsumerLayer(),
    );
    MessagesConsumerLayer.install(
      widget.messagesConsumerLayer ?? MessagesConsumerLayer(),
    );
    CounterpartConversationConsumerLayer.install(
      widget.counterpartConversationConsumerLayer ??
          CounterpartConversationConsumerLayer(),
    );
    ProfileConsumerLayer.install(
      widget.profileConsumerLayer ?? ProfileConsumerLayer(),
    );
    ProfileGovernanceAppealConsumerLayer.install(
      widget.profileGovernanceAppealConsumerLayer ??
          ProfileGovernanceAppealConsumerLayer(),
    );
    ProfileGovernanceStatusConsumerLayer.install(
      widget.profileGovernanceStatusConsumerLayer ??
          ProfileGovernanceStatusConsumerLayer(),
    );
    ProfileIdentityConsumerLayer.install(
      widget.profileIdentityConsumerLayer ?? ProfileIdentityConsumerLayer(),
    );
    AppSessionStore.instance.addListener(_maybeBootstrapNotifications);
    if (AppSessionStore.instance.persistsSession && !hasBootstrapSession) {
      unawaited(_restorePersistedSessionAndInitializeShell());
    } else {
      _controller.initialize();
      _maybeBootstrapNotifications();
    }
  }

  Future<void> _restorePersistedSessionAndInitializeShell() async {
    await AppSessionStore.instance.restorePersistedSession();
    if (!mounted) {
      return;
    }
    _controller.initialize();
    _maybeBootstrapNotifications();
  }

  void _maybeBootstrapNotifications() {
    if (_notificationBootstrapStarted) {
      return;
    }
    if (!AppSessionStore.instance.snapshot.hasAccessToken) {
      return;
    }
    _notificationBootstrapStarted = true;
    unawaited(
      AppNotificationBootstrapService().initialize(
        onRouteTargetOpened: _openNotificationRouteTarget,
      ),
    );
  }

  Future<void> _openNotificationRouteTarget(
    Map<String, Object?> routeTargetPayload,
  ) async {
    final routeTarget = parseAppNotificationRouteTarget(routeTargetPayload);
    final routeLocation = routeTarget?.routeLocation?.trim();
    if (routeLocation == null || routeLocation.isEmpty) {
      return;
    }
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    try {
      await navigator.pushNamed(routeLocation);
    } catch (_) {
      // System notification taps must never mutate business state when routing
      // is unavailable. The in-app notification stays as the recoverable entry.
    }
  }

  @override
  void dispose() {
    AppSessionStore.instance.removeListener(_maybeBootstrapNotifications);
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
    ExhibitionConsumerLayer.reset();
    ExhibitionHomeAggregationClient.reset();
    ProjectNameAccessConsumerLayer.reset();
    DeviceLocationService.reset();
    ForumConsumerLayer.reset();
    TradingImConsumerLayer.reset();
    MessagesConsumerLayer.reset();
    CounterpartConversationConsumerLayer.reset();
    ProfileConsumerLayer.reset();
    ProfileGovernanceAppealConsumerLayer.reset();
    ProfileGovernanceStatusConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      controller: _controller,
      child: MaterialApp(
        title: '展览装修之家',
        debugShowCheckedModeBanner: false,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const <Locale>[Locale('zh', 'CN')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        navigatorKey: _navigatorKey,
        initialRoute: widget.initialRoute,
        onGenerateInitialRoutes: (String initialRoute) {
          final routeName = initialRoute.isEmpty ? '/' : initialRoute;
          return <Route<dynamic>>[
            _router.onGenerateRoute(RouteSettings(name: routeName)),
          ];
        },
        onGenerateRoute: _router.onGenerateRoute,
        onUnknownRoute: _router.onUnknownRoute,
      ),
    );
  }
}
