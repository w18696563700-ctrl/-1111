import 'package:flutter/material.dart';
import 'package:mobile/shell/navigation/app_building.dart';

class RouteUnavailablePage extends StatelessWidget {
  const RouteUnavailablePage({super.key, required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Icon(
                    Icons.route_outlined,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '路由不可用',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '当前页面暂时不可进入，应用已经把你带到受控承接页，不会静默跳回其他页面。',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppBuilding.exhibition.routePath);
                    },
                    child: const Text('回到展览'),
                  ),
                  if (routeName != null && routeName!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 8),
                      title: const Text('开发辅助（默认收起）'),
                      children: <Widget>[
                        SelectableText(
                          '未识别入口：$routeName',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
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
