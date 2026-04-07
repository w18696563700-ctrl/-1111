import 'package:flutter/material.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';

class ShellStatePage extends StatelessWidget {
  const ShellStatePage({
    super.key,
    required this.state,
    required this.building,
  });

  final GlobalShellState state;
  final AppBuilding building;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blockingMessage = _visibleBlockingMessage(
      AppShellScope.of(context).snapshot.blockingMessage,
    );
    final title = switch (state) {
      GlobalShellState.booting => 'Shell 启动中',
      GlobalShellState.unauthenticated => '尚未登录',
      GlobalShellState.sessionRefreshing => '会话刷新中',
      GlobalShellState.noOrganization => '尚未加入组织',
      GlobalShellState.forbidden => '当前上下文未开放',
      GlobalShellState.unavailable => '当前上下文暂不可用',
      GlobalShellState.hiddenBuildingUnavailable => '${building.label}入口当前不可见',
      GlobalShellState.offline => '当前离线',
      GlobalShellState.maintenance => '平台维护中',
    };
    final description = switch (state) {
      GlobalShellState.booting => '正在准备首发演示面和当前可见楼层，请稍候。',
      GlobalShellState.unauthenticated => '当前还没有登录态，页面先停留在受控承接面。',
      GlobalShellState.sessionRefreshing => '当前正在刷新会话，请稍候再继续进入楼层。',
      GlobalShellState.noOrganization => '当前还没有组织归属，楼层入口会先停留在受控承接面。',
      GlobalShellState.forbidden =>
        '当前 /api/app/shell/context 未向本端开放可用上下文，页面先停留在受控不可用态。',
      GlobalShellState.unavailable =>
        '当前 /api/app/shell/context 还没有返回可消费上下文，页面先停留在受控不可用态。',
      GlobalShellState.hiddenBuildingUnavailable =>
        '该楼层已经预埋在应用里，但首发阶段暂未开放到当前主路径。你可以先回到展览、消息或我的继续演示。',
      GlobalShellState.offline => '当前网络不可用，页面先停留在离线承接面。',
      GlobalShellState.maintenance => '平台当前处于维护中，页面先停留在受控维护态。',
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (state == GlobalShellState.booting) ...<Widget>[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                  ] else ...<Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  if (state == GlobalShellState.unauthenticated) ...<Widget>[
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(ProfileIdentityRoutes.login);
                      },
                      child: const Text('进入登录入口'),
                    ),
                  ],
                  if (state == GlobalShellState.sessionRefreshing) ...<Widget>[
                    const SizedBox(height: 18),
                    FilledButton.tonal(
                      onPressed: () {
                        AppShellScope.read(
                          context,
                        ).refreshSessionAndReloadShell();
                      },
                      child: const Text('重试刷新会话'),
                    ),
                  ],
                  if (state == GlobalShellState.noOrganization) ...<Widget>[
                    const SizedBox(height: 18),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(ProfileIdentityRoutes.organizationHandoff);
                      },
                      child: const Text('查看组织状态'),
                    ),
                  ],
                  if (blockingMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      blockingMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (state == GlobalShellState.forbidden ||
                      state == GlobalShellState.unavailable ||
                      state == GlobalShellState.offline ||
                      state == GlobalShellState.maintenance) ...<Widget>[
                    const SizedBox(height: 18),
                    FilledButton.tonal(
                      onPressed: () {
                        AppShellScope.read(context).reloadShellContext();
                      },
                      child: const Text('重试承接'),
                    ),
                  ],
                  if (state ==
                      GlobalShellState.hiddenBuildingUnavailable) ...<Widget>[
                    const SizedBox(height: 18),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppBuilding.exhibition.routePath,
                        );
                      },
                      child: const Text('回到展览'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _visibleBlockingMessage(String? rawMessage) {
  final value = rawMessage?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(value)) {
    return null;
  }

  final lower = value.toLowerCase();
  if (lower.contains('/api/app/') ||
      lower.contains('socketexception') ||
      lower.contains('formatexception') ||
      lower.contains('stateerror') ||
      lower.contains('network error') ||
      lower.contains('http error') ||
      lower.contains('missing required') ||
      lower.contains('exception')) {
    return null;
  }

  return value;
}
