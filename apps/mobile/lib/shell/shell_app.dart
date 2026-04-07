import 'package:flutter/material.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
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
    this.forumConsumerLayer,
    this.authConsumerLayer,
    this.messagesConsumerLayer,
    this.profileConsumerLayer,
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
  final ForumConsumerLayer? forumConsumerLayer;
  final AuthConsumerLayer? authConsumerLayer;
  final MessagesConsumerLayer? messagesConsumerLayer;
  final ProfileConsumerLayer? profileConsumerLayer;
  final ProfileIdentityConsumerLayer? profileIdentityConsumerLayer;
  final DeviceLocationService? deviceLocationService;
  final AppSessionStore? sessionStore;

  @override
  State<ExhibitionMobileApp> createState() => _ExhibitionMobileAppState();
}

class _ExhibitionMobileAppState extends State<ExhibitionMobileApp> {
  late final AppBootstrapController _controller = AppBootstrapController(
    bootstrapManifest: widget.bootstrapManifest,
    bootstrapShellContext: widget.bootstrapShellContext,
    shellContextConsumer: widget.shellContextConsumer,
  )..initialize();

  final AppRouter _router = const AppRouter();

  @override
  void initState() {
    super.initState();
    AppSessionStore.install(widget.sessionStore ?? AppSessionStore());
    AuthConsumerLayer.install(widget.authConsumerLayer ?? AuthConsumerLayer());
    ExhibitionConsumerLayer.install(
      widget.exhibitionConsumerLayer ?? ExhibitionConsumerLayer(),
    );
    ExhibitionHomeAggregationClient.install(
      widget.exhibitionHomeAggregationClient ??
          CanonicalExhibitionHomeAggregationClient(),
    );
    DeviceLocationService.install(
      widget.deviceLocationService ?? GeolocatorDeviceLocationService(),
    );
    ForumConsumerLayer.install(
      widget.forumConsumerLayer ?? ForumConsumerLayer(),
    );
    MessagesConsumerLayer.install(
      widget.messagesConsumerLayer ?? MessagesConsumerLayer(),
    );
    ProfileConsumerLayer.install(
      widget.profileConsumerLayer ?? ProfileConsumerLayer(),
    );
    ProfileIdentityConsumerLayer.install(
      widget.profileIdentityConsumerLayer ?? ProfileIdentityConsumerLayer(),
    );
  }

  @override
  void dispose() {
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
    ExhibitionConsumerLayer.reset();
    ExhibitionHomeAggregationClient.reset();
    DeviceLocationService.reset();
    ForumConsumerLayer.reset();
    MessagesConsumerLayer.reset();
    ProfileConsumerLayer.reset();
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
        theme: AppTheme.light(),
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
