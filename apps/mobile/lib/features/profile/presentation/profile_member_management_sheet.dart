import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

Future<void> showOrganizationMembersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => const _OrganizationMembersSheet(),
  );
}

class _OrganizationMembersSheet extends StatefulWidget {
  const _OrganizationMembersSheet();

  @override
  State<_OrganizationMembersSheet> createState() =>
      _OrganizationMembersSheetState();
}

class _OrganizationMembersSheetState extends State<_OrganizationMembersSheet> {
  bool _loading = true;
  String? _actingMemberId;
  String? _lastHandledMemberId;
  _MemberActionKind? _lastActionKind;
  ProfileIdentityResult<OrganizationMembersView>? _membersResult;
  ProfileIdentityResult<ProfileActionAckView>? _actionResult;

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
        .loadOrganizationMembers();
    if (!mounted) {
      return;
    }

    setState(() {
      _membersResult = result;
      _loading = false;
    });
  }

  Future<void> _changeRole(
    OrganizationMemberItemView item,
    String nextRoleKey,
  ) async {
    setState(() {
      _actingMemberId = item.memberId;
      _lastHandledMemberId = item.memberId;
      _lastActionKind = _MemberActionKind.role;
      _actionResult = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .patchOrganizationMemberRole(
          memberId: item.memberId,
          roleKey: nextRoleKey,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      setState(() {
        _actingMemberId = null;
        _actionResult = result;
      });
      await _load();
      return;
    }

    setState(() {
      _actingMemberId = null;
      _actionResult = result;
    });
  }

  Future<void> _disableMember(OrganizationMemberItemView item) async {
    setState(() {
      _actingMemberId = item.memberId;
      _lastHandledMemberId = item.memberId;
      _lastActionKind = _MemberActionKind.disable;
      _actionResult = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .disableOrganizationMember(memberId: item.memberId);
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      setState(() {
        _actingMemberId = null;
        _actionResult = result;
      });
      await _load();
      return;
    }

    setState(() {
      _actingMemberId = null;
      _actionResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersResult = _membersResult;
    final members =
        membersResult?.data?.items ?? const <OrganizationMemberItemView>[];

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          '成员管理',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '查看当前公司/组织成员，并处理最小角色调整与禁用。',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : membersResult == null ||
                        membersResult.state != AppPageState.content
                  ? _buildFailureBody(membersResult)
                  : _buildContentBody(members),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureBody(
    ProfileIdentityResult<OrganizationMembersView>? membersResult,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        _MembersCard(
          title: '成员列表暂不可用',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                profileVisibleReadMessage(
                  state: membersResult?.state ?? AppPageState.errorRetryable,
                  rawMessage: membersResult?.message,
                  surfaceLabel: '成员管理',
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonal(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentBody(List<OrganizationMemberItemView> members) {
    final activeCount = members
        .where(
          (OrganizationMemberItemView item) => item.memberStatus == 'active',
        )
        .length;
    final disabledCount = members
        .where((OrganizationMemberItemView item) => _isDisabled(item))
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        _MembersCard(
          title: '成员摘要',
          child: Text(
            '当前组织共 ${members.length} 位成员，启用中 $activeCount 位，已禁用 $disabledCount 位。',
          ),
        ),
        const SizedBox(height: 12),
        _MembersCard(
          title: '成员列表',
          child: members.isEmpty
              ? const Text('当前组织暂未返回可展示成员。')
              : Column(
                  children: members
                      .map(
                        (OrganizationMemberItemView item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMemberTile(item),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(OrganizationMemberItemView item) {
    final acting = _actingMemberId == item.memberId;
    final canOperate = item.memberStatus == 'active' && !_isDisabled(item);
    final isLastHandled = _lastHandledMemberId == item.memberId;
    final actionResult = isLastHandled ? _actionResult : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _memberTitle(item),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if ((item.mobileMasked?.trim().isNotEmpty ?? false) &&
                item.mobileMasked != item.displayName) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                item.mobileMasked!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 10),
            _MemberValueLine(
              label: '角色',
              value: profileDisplayRoleKey(item.roleKey),
            ),
            _MemberValueLine(
              label: '成员状态',
              value: profileDisplayOrganizationMemberStatus(item.memberStatus),
            ),
            _MemberValueLine(
              label: '加入时间',
              value: profileValueOrFallback(item.joinedAt, '暂未提供'),
            ),
            if ((item.disabledAt?.trim().isNotEmpty ?? false))
              _MemberValueLine(label: '禁用时间', value: item.disabledAt!),
            const SizedBox(height: 12),
            if (canOperate)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.roleKey,
                          borderRadius: BorderRadius.circular(16),
                          onChanged: acting
                              ? null
                              : (String? value) {
                                  if (value == null || value == item.roleKey) {
                                    return;
                                  }
                                  _changeRole(item, value);
                                },
                          items: _memberRoleOptions
                              .map(
                                (_MemberRoleOption option) =>
                                    DropdownMenuItem<String>(
                                      value: option.roleKey,
                                      child: Text(option.label),
                                    ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: acting ? null : () => _disableMember(item),
                    child: Text(acting ? '处理中' : '禁用成员'),
                  ),
                ],
              )
            else
              Text(
                _isDisabled(item)
                    ? '当前成员已禁用，页面只展示最新状态。'
                    : '当前成员状态下暂不开放角色调整与禁用。',
                style: const TextStyle(color: Colors.black54),
              ),
            if (actionResult != null) ...<Widget>[
              const SizedBox(height: 12),
              _MembersInlineFeedback(
                title: _actionResultTitle(actionResult),
                body: _actionResultMessage(actionResult),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _actionResultTitle(
    ProfileIdentityResult<ProfileActionAckView> result,
  ) {
    if (result.state == AppPageState.content) {
      return _lastActionKind == _MemberActionKind.role ? '角色已刷新' : '成员状态已刷新';
    }
    return _lastActionKind == _MemberActionKind.role
        ? '角色调整当前未完成'
        : '成员禁用当前未完成';
  }

  String _actionResultMessage(
    ProfileIdentityResult<ProfileActionAckView> result,
  ) {
    if (result.state == AppPageState.content && result.data != null) {
      return '最新成员列表已同步，traceId ${result.data!.traceId}。';
    }
    return profileVisibleReadMessage(
      state: result.state,
      rawMessage: result.message,
      surfaceLabel: _lastActionKind == _MemberActionKind.role ? '角色调整' : '成员禁用',
    );
  }

  static bool _isDisabled(OrganizationMemberItemView item) {
    return item.memberStatus == 'disabled' ||
        (item.disabledAt?.trim().isNotEmpty ?? false);
  }

  static String _memberTitle(OrganizationMemberItemView item) {
    final displayName = item.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final mobileMasked = item.mobileMasked?.trim();
    if (mobileMasked != null && mobileMasked.isNotEmpty) {
      return mobileMasked;
    }
    return '当前成员';
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MemberValueLine extends StatelessWidget {
  const _MemberValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label：$value'),
    );
  }
}

class _MembersInlineFeedback extends StatelessWidget {
  const _MembersInlineFeedback({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );
  }
}

enum _MemberActionKind { role, disable }

class _MemberRoleOption {
  const _MemberRoleOption(this.roleKey, this.label);

  final String roleKey;
  final String label;
}

const List<_MemberRoleOption> _memberRoleOptions = <_MemberRoleOption>[
  _MemberRoleOption('buyer_admin', '需求管理员'),
  _MemberRoleOption('buyer_member(scoped)', '需求成员'),
  _MemberRoleOption('supplier_admin', '供应商管理员'),
  _MemberRoleOption('supplier_member(scoped)', '供应成员'),
];
