import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_organization_capability_copy.dart';
import 'package:mobile/features/profile/presentation/profile_organization_scope_visibility.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class OrganizationSwitchPage extends StatefulWidget {
  const OrganizationSwitchPage({super.key});

  @override
  State<OrganizationSwitchPage> createState() => _OrganizationSwitchPageState();
}

class _OrganizationSwitchPageState extends State<OrganizationSwitchPage> {
  bool _loading = true;
  String? _switchingOrganizationId;
  ProfileIdentityResult<MyOrganizationsView>? _result;
  ProfileIdentityResult<AppShellContextData>? _switchResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .loadMyOrganizations();
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _switchOrganization(MyOrganizationItemView item) async {
    setState(() {
      _switchingOrganizationId = item.organizationId;
      _switchResult = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .switchOrganization(organizationId: item.organizationId);
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content && result.data != null) {
      final shell = AppShellScope.read(context);
      shell.applyShellContext(result.data!);
    }

    final verified =
        (result.state != AppPageState.unauthorized &&
            result.state != AppPageState.forbidden)
        ? await _verifySwitchApplied(item.organizationId)
        : false;
    if (!mounted) {
      return;
    }

    if (verified) {
      final successResult = ProfileIdentityResult<AppShellContextData>(
        state: AppPageState.content,
        method: result.method,
        path: result.path,
        data: AppShellScope.of(context).snapshot.shellContext,
        message: '当前主体已切换，当前页已按最新组织上下文完成回读确认。',
      );
      final canPop =
          ModalRoute.of(context)?.canPop ?? Navigator.of(context).canPop();
      if (canPop) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _switchingOrganizationId = null;
        _switchResult = successResult;
      });
      return;
    }

    setState(() {
      _switchingOrganizationId = null;
      _switchResult = result;
    });
  }

  Future<bool> _verifySwitchApplied(String targetOrganizationId) async {
    await AppShellScope.read(context).reloadShellContext();
    if (!mounted) {
      return false;
    }
    await _load();
    if (!mounted) {
      return false;
    }
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final current = _resolveCurrent(
      _result?.data?.items ?? const <MyOrganizationItemView>[],
      shellContext.organizationId,
    );
    final currentOrganizationId = shellContext.organizationId?.trim();
    return currentOrganizationId == targetOrganizationId ||
        current?.organizationId == targetOrganizationId;
  }

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final items = _result?.data?.items ?? const <MyOrganizationItemView>[];
    final current = _resolveCurrent(items, shellContext.organizationId);
    final switchable = items
        .where(
          (MyOrganizationItemView item) =>
              item.organizationId != current?.organizationId &&
              profileCanSwitchToOrganization(item),
        )
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        _OrganizationSwitchCurrentBanner(
          title: _currentTitle(current),
          subtitle: _currentSubtitle(current),
          supportingText: _currentSupportingText(current),
        ),
        const SizedBox(height: 16),
        if (_switchResult != null)
          _OrganizationSwitchCard(
            title: _switchResult!.state == AppPageState.content
                ? '切换成功'
                : '切换当前未完成',
            child: Text(_switchResultMessage(_switchResult!)),
          )
        else if (_loading)
          const _OrganizationSwitchCard(
            title: '正在读取组织列表',
            child: Text('正在同步当前主体与可切换列表。'),
          )
        else if (_result?.state == AppPageState.content &&
            switchable.isNotEmpty)
          _OrganizationSwitchCard(
            title: '可切换主体',
            child: _OrganizationSwitchList(
              items: switchable,
              switchingOrganizationId: _switchingOrganizationId,
              onSwitch: _switchOrganization,
            ),
          )
        else
          _OrganizationSwitchCard(
            title: '当前没有其他主体可切换',
            child: Text(
              _organizationSwitchMessage(_result?.state, _result?.message),
            ),
          ),
      ],
    );
  }

  String _currentTitle(MyOrganizationItemView? current) {
    if (_loading) {
      return '正在同步当前主体';
    }
    if (_result != null &&
        _result!.state != AppPageState.content &&
        _result!.state != AppPageState.empty) {
      return _organizationSwitchMessage(_result!.state, _result!.message);
    }
    if (current == null) {
      return '当前还没有主体';
    }
    return '当前主体：${profileDisplayOrganizationName(current.name)}';
  }

  String? _currentSubtitle(MyOrganizationItemView? current) {
    if (_loading ||
        (_result != null &&
            _result!.state != AppPageState.content &&
            _result!.state != AppPageState.empty)) {
      return null;
    }
    if (current == null) {
      return '先返回公司与组织建立主体，再回来切换。';
    }
    return '${profileDisplayOrganizationCapabilitySummary(current.organizationType)} · '
        '${profileBuildOrganizationCapabilityStatusBadges(certificationStatus: current.certificationStatus, membershipStatus: current.membershipStatus).join(' · ')}';
  }

  String _currentSupportingText(MyOrganizationItemView? current) {
    if (_loading) {
      return '正在读取当前组织上下文与可切换列表。';
    }
    if (_result != null &&
        _result!.state != AppPageState.content &&
        _result!.state != AppPageState.empty) {
      return '当前主体信息暂未读取成功，下面会按返回结果继续展示可切换状态。';
    }
    if (current == null) {
      return '建立组织主体后，这里会显示当前主体，并在下方列出可切换目标。';
    }
    return '从下方选择目标主体后，整个 App 的组织上下文，以及可发布 / 可竞标能力都会一起切换。';
  }

  static MyOrganizationItemView? _resolveCurrent(
    List<MyOrganizationItemView> items,
    String? currentOrganizationId,
  ) {
    if (currentOrganizationId != null &&
        currentOrganizationId.trim().isNotEmpty) {
      for (final item in items) {
        if (item.organizationId == currentOrganizationId.trim()) {
          return item;
        }
      }
    }
    for (final item in items) {
      if (item.current) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  static String _switchResultMessage(
    ProfileIdentityResult<AppShellContextData> result,
  ) {
    if (result.state == AppPageState.content) {
      return '当前主体已切换，后续读取会按新的组织上下文继续承接。';
    }
    return _organizationSwitchMessage(result.state, result.message);
  }
}

class _OrganizationSwitchCard extends StatelessWidget {
  const _OrganizationSwitchCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title?.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (resolvedTitle != null && resolvedTitle.isNotEmpty) ...<Widget>[
              Text(
                resolvedTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _OrganizationSwitchCurrentBanner extends StatelessWidget {
  const _OrganizationSwitchCurrentBanner({
    required this.title,
    required this.subtitle,
    required this.supportingText,
  });

  final String title;
  final String? subtitle;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              supportingText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationSwitchList extends StatelessWidget {
  const _OrganizationSwitchList({
    required this.items,
    required this.switchingOrganizationId,
    required this.onSwitch,
  });

  final List<MyOrganizationItemView> items;
  final String? switchingOrganizationId;
  final ValueChanged<MyOrganizationItemView> onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            _OrganizationSwitchRow(
              item: items[index],
              switching: switchingOrganizationId == items[index].organizationId,
              onTap: () => onSwitch(items[index]),
            ),
            if (index != items.length - 1)
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _OrganizationSwitchRow extends StatelessWidget {
  const _OrganizationSwitchRow({
    required this.item,
    required this.switching,
    required this.onTap,
  });

  final MyOrganizationItemView item;
  final bool switching;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.35,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: switching ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profileDisplayOrganizationName(item.name),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '能力：${profileDisplayOrganizationCapabilitySummary(item.organizationType)}；'
                    '企业认证：${profileDisplayCertificationStatus(item.certificationStatus)}；'
                    '成员：${profileDisplayMembershipStatus(item.membershipStatus)}',
                    style: subtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            switching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '切换',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

String _organizationSwitchMessage(AppPageState? state, String? fallback) {
  if (state != null) {
    return profileVisibleReadMessage(
      state: state,
      rawMessage: fallback,
      surfaceLabel: '当前主体切换',
    );
  }
  if (fallback != null && fallback.trim().isNotEmpty) {
    return fallback.trim();
  }

  return '当前内容正在准备中。';
}
