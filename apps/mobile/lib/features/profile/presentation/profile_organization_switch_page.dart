import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_organization_capability_copy.dart';
import 'package:mobile/features/profile/presentation/profile_organization_scope_visibility.dart';
import 'package:mobile/features/profile/presentation/profile_organization_switch_widgets.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class OrganizationSwitchPage extends StatefulWidget {
  const OrganizationSwitchPage({super.key});

  @override
  State<OrganizationSwitchPage> createState() => _OrganizationSwitchPageState();
}

class _OrganizationSwitchPageState extends State<OrganizationSwitchPage> {
  bool _loading = true;
  bool _leavingCurrentOrganization = false;
  String? _switchingOrganizationId;
  ProfileIdentityResult<MyOrganizationsView>? _result;
  ProfileIdentityResult<AppShellContextData>? _switchResult;
  ProfileIdentityResult<OrganizationLeaveAcceptedView>? _leaveResult;

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
    final currentOrganizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId?.trim();
    if (_switchingOrganizationId != null ||
        item.current ||
        item.organizationId == currentOrganizationId) {
      return;
    }

    final confirmed = await _confirmSwitchOrganization(item);
    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _switchingOrganizationId = item.organizationId;
      _switchResult = null;
      _leaveResult = null;
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

  Future<bool> _confirmSwitchOrganization(MyOrganizationItemView item) async {
    final organizationName = profileDisplayOrganizationName(item.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认切换当前主体'),
          content: Text(
            '确认切换到“$organizationName”吗？切换后，项目、认证、竞标和消息都会按这个主体继续展示。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认切换'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _leaveCurrentOrganization(MyOrganizationItemView current) async {
    if (_leavingCurrentOrganization || _switchingOrganizationId != null) {
      return;
    }

    final confirmed = await _confirmLeaveCurrentOrganization(current);
    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _leavingCurrentOrganization = true;
      _leaveResult = null;
      _switchResult = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .leaveCurrentOrganization();
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content && result.data != null) {
      await AppShellScope.read(context).bootstrapAfterLogin(
        shellBootstrapState: result.data!.shellBootstrapState,
      );
      if (!mounted) {
        return;
      }
      await _load();
      if (!mounted) {
        return;
      }
    }

    setState(() {
      _leavingCurrentOrganization = false;
      _leaveResult = result;
    });
  }

  Future<bool> _confirmLeaveCurrentOrganization(
    MyOrganizationItemView current,
  ) async {
    final organizationName = profileDisplayOrganizationName(current.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认退出当前组织'),
          content: Text(
            '确认退出“$organizationName”吗？退出后不能再以该组织身份管理项目、认证、竞标和消息；公司、认证资料和历史记录不会被删除。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认退出'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final items = _result?.data?.items ?? const <MyOrganizationItemView>[];
    final current = _resolveCurrent(items, shellContext.organizationId);
    final currentOrganizationId = current?.organizationId;
    final visibleItems = items
        .where((MyOrganizationItemView item) {
          final isCurrent =
              item.current || item.organizationId == currentOrganizationId;
          return isCurrent || profileCanSwitchToOrganization(item);
        })
        .toList(growable: false);
    final hasSwitchTarget = visibleItems.any(
      (MyOrganizationItemView item) =>
          item.organizationId != currentOrganizationId &&
          !item.current &&
          profileCanSwitchToOrganization(item),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        OrganizationSwitchCurrentBanner(
          title: _currentTitle(current),
          subtitle: _currentSubtitle(current),
          supportingText: _currentSupportingText(current),
        ),
        const SizedBox(height: 16),
        if (_switchResult != null)
          OrganizationSwitchCard(
            title: _switchResult!.state == AppPageState.content
                ? '切换成功'
                : '切换当前未完成',
            child: Text(_switchResultMessage(_switchResult!)),
          )
        else if (_loading)
          const OrganizationSwitchCard(
            title: '正在读取组织列表',
            child: Text('正在同步当前主体与可切换列表。'),
          )
        else if (_result?.state == AppPageState.content &&
            visibleItems.isNotEmpty)
          OrganizationSwitchCard(
            title: hasSwitchTarget ? '我的主体列表' : '当前没有其他主体可切换',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OrganizationSwitchList(
                  items: visibleItems,
                  currentOrganizationId: currentOrganizationId,
                  switchingOrganizationId: _switchingOrganizationId,
                  onSwitch: _switchOrganization,
                ),
                if (!hasSwitchTarget) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    '当前账号没有其他可切换的公司/组织，或其他组织暂不具备 App 可用身份。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          )
        else if (_result?.state == AppPageState.content && current == null)
          OrganizationSwitchCard(
            title: '当前还没有公司/组织',
            child: NoCurrentOrganizationAction(
              onOpenOrganizationHub: () => Navigator.of(
                context,
              ).pushNamed(ProfileIdentityRoutes.organizationHandoff),
            ),
          )
        else
          OrganizationSwitchCard(
            title: '当前没有其他主体可切换',
            child: Text(
              _organizationSwitchMessage(_result?.state, _result?.message),
            ),
          ),
        if (_leaveResult != null) ...<Widget>[
          const SizedBox(height: 16),
          OrganizationSwitchCard(
            title: _leaveResult!.state == AppPageState.content
                ? '已退出当前组织'
                : '退出组织未完成',
            child: Text(_leaveResultMessage(_leaveResult!)),
          ),
        ],
        if (!_loading &&
            _result?.state == AppPageState.content &&
            current != null) ...<Widget>[
          const SizedBox(height: 16),
          OrganizationLeaveActionCard(
            current: current,
            leaving: _leavingCurrentOrganization,
            onLeave: () => _leaveCurrentOrganization(current),
          ),
        ],
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
    return '${profileDisplayOrganizationCapabilitySummary(current.organizationType, roleKeys: current.roleKeys)} · '
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

  static String _leaveResultMessage(
    ProfileIdentityResult<OrganizationLeaveAcceptedView> result,
  ) {
    if (result.state == AppPageState.content && result.data != null) {
      if (result.data!.nextOrganizationId != null) {
        return '已退出当前组织，并切换到下一个可用主体。页面已重新读取当前组织上下文。';
      }
      return '已退出当前组织。当前账号没有其他可用组织，可前往公司与组织创建或加入组织。';
    }
    return _organizationSwitchMessage(result.state, result.message);
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
