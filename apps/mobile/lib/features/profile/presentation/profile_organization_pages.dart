import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class OrganizationHandoffPage extends StatefulWidget {
  const OrganizationHandoffPage({super.key});

  @override
  State<OrganizationHandoffPage> createState() =>
      _OrganizationHandoffPageState();
}

class _OrganizationHandoffPageState extends State<OrganizationHandoffPage> {
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

  Future<void> _openRoute(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _load();
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
      await shell.reloadShellContext();
      if (!mounted) {
        return;
      }
      setState(() {
        _switchingOrganizationId = null;
        _switchResult = result;
      });
      await _load();
      return;
    }

    setState(() {
      _switchingOrganizationId = null;
      _switchResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final items = _result?.data?.items ?? const <MyOrganizationItemView>[];
    final current = _resolveCurrent(items, shellContext.organizationId);
    final switchable = items
        .where(
          (MyOrganizationItemView item) =>
              item.organizationId != current?.organizationId,
        )
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _OrganizationCard(
          title: '公司与组织',
          child: Text('在这里继续创建公司/组织、加入公司/组织或切换当前公司/组织，不扩成治理后台。'),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '当前公司/组织',
          child: _buildCurrentOrganization(current),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '可进行的操作',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () =>
                    _openRoute(ProfileIdentityRoutes.organizationCreate),
                child: const Text('创建组织'),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    _openRoute(ProfileIdentityRoutes.organizationJoin),
                child: const Text('加入组织'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_switchResult != null)
          _OrganizationCard(
            title: _switchResult!.state == AppPageState.content
                ? '切换成功'
                : '切换当前未完成',
            child: Text(_switchResultMessage(_switchResult!)),
          )
        else if (_loading)
          const _OrganizationCard(
            title: '正在读取组织列表',
            child: Text('正在同步当前公司/组织与可切换列表。'),
          )
        else if (_result?.state == AppPageState.content &&
            switchable.isNotEmpty)
          _OrganizationCard(
            title: '切换当前公司/组织',
            child: Column(
              children: switchable
                  .map((MyOrganizationItemView item) => _organizationTile(item))
                  .toList(growable: false),
            ),
          )
        else
          _OrganizationCard(
            title: '当前没有其他公司/组织可切换',
            child: Text(_organizationMessage(_result?.state, _result?.message)),
          ),
      ],
    );
  }

  Widget _buildCurrentOrganization(MyOrganizationItemView? current) {
    if (_loading) {
      return const Text('正在同步当前组织信息。');
    }
    if (current == null) {
      return const Text('当前还没有公司/组织，可先创建或通过邀请码加入。');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _OrganizationValueLine(
          label: '公司名称',
          value: profileDisplayOrganizationName(current.name),
        ),
        _OrganizationValueLine(
          label: '组织类型',
          value: profileDisplayOrganizationType(current.organizationType),
        ),
        _OrganizationValueLine(
          label: '成员身份',
          value: profileDisplayRoleSummary(current.roleKeys),
        ),
        _OrganizationValueLine(
          label: '成员状态',
          value: profileDisplayMembershipStatus(current.membershipStatus),
        ),
        _OrganizationValueLine(
          label: '认证状态',
          value: profileDisplayCertificationStatus(current.certificationStatus),
        ),
      ],
    );
  }

  Widget _organizationTile(MyOrganizationItemView item) {
    final switching = _switchingOrganizationId == item.organizationId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                profileDisplayOrganizationName(item.name),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '类型：${profileDisplayOrganizationType(item.organizationType)}；'
                '认证：${profileDisplayCertificationStatus(item.certificationStatus)}；'
                '成员：${profileDisplayMembershipStatus(item.membershipStatus)}',
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: switching ? null : () => _switchOrganization(item),
                child: Text(switching ? '切换中' : '切换为当前公司/组织'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static MyOrganizationItemView? _resolveCurrent(
    List<MyOrganizationItemView> items,
    String? currentOrganizationId,
  ) {
    for (final item in items) {
      if (item.current) {
        return item;
      }
    }
    if (currentOrganizationId == null || currentOrganizationId.trim().isEmpty) {
      return items.isEmpty ? null : items.first;
    }
    for (final item in items) {
      if (item.organizationId == currentOrganizationId.trim()) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  static String _switchResultMessage(
    ProfileIdentityResult<AppShellContextData> result,
  ) {
    if (result.state == AppPageState.content) {
      return '当前公司/组织已切换，后续读取会按新的组织上下文继续承接。';
    }
    return _organizationMessage(result.state, result.message);
  }
}

class OrganizationCreatePage extends StatefulWidget {
  const OrganizationCreatePage({super.key});

  @override
  State<OrganizationCreatePage> createState() => _OrganizationCreatePageState();
}

class _OrganizationCreatePageState extends State<OrganizationCreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _provinceCodeController = TextEditingController();
  final TextEditingController _cityCodeController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController =
      TextEditingController();
  String _organizationType = 'demand';
  bool _submitting = false;
  ProfileIdentityResult<ProfileOrganizationCreateView>? _result;

  @override
  void dispose() {
    _nameController.dispose();
    _provinceCodeController.dispose();
    _cityCodeController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _result = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .createOrganization(
          name: _nameController.text,
          organizationType: _organizationType,
          provinceCode: _provinceCodeController.text,
          cityCode: _cityCodeController.text,
          contactName: _contactNameController.text,
          contactMobile: _contactMobileController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      await AppShellScope.read(context).reloadShellContext();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    setState(() {
      _submitting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _OrganizationCard(
          title: '创建组织',
          child: Text('当前只承接最小 organization create command，不扩成组织治理后台。'),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '组织信息',
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '组织名称'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _organizationType,
                decoration: const InputDecoration(labelText: '组织类型'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'demand', child: Text('需求方')),
                  DropdownMenuItem(value: 'supplier', child: Text('供应商')),
                  DropdownMenuItem(value: 'both', child: Text('需求方 / 供应商')),
                ],
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _organizationType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _provinceCodeController,
                decoration: const InputDecoration(labelText: '所在省编码'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityCodeController,
                decoration: const InputDecoration(labelText: '所在市编码'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: '联系人'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactMobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '联系电话'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? '提交中' : '创建组织'),
              ),
            ],
          ),
        ),
        if (_result != null) ...<Widget>[
          const SizedBox(height: 16),
          _OrganizationCard(
            title: '创建当前未完成',
            child: Text(_organizationMessage(_result!.state, _result!.message)),
          ),
        ],
      ],
    );
  }
}

class OrganizationJoinPage extends StatefulWidget {
  const OrganizationJoinPage({super.key});

  @override
  State<OrganizationJoinPage> createState() => _OrganizationJoinPageState();
}

class _OrganizationJoinPageState extends State<OrganizationJoinPage> {
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _submitting = false;
  ProfileIdentityResult<ProfileOrganizationJoinAcceptedView>? _result;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _result = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance.joinByCode(
      inviteCode: _inviteCodeController.text,
    );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      await AppShellScope.read(context).reloadShellContext();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    setState(() {
      _submitting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _OrganizationCard(
          title: '加入组织',
          child: Text('当前只承接邀请码加入，不扩成完整成员治理系统。'),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '邀请码',
          child: Column(
            children: <Widget>[
              TextField(
                controller: _inviteCodeController,
                decoration: const InputDecoration(labelText: '邀请码'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? '提交中' : '加入组织'),
              ),
            ],
          ),
        ),
        if (_result != null) ...<Widget>[
          const SizedBox(height: 16),
          _OrganizationCard(
            title: '加入当前未完成',
            child: Text(_organizationMessage(_result!.state, _result!.message)),
          ),
        ],
      ],
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _OrganizationValueLine extends StatelessWidget {
  const _OrganizationValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$label：$value'),
    );
  }
}

String _organizationMessage(AppPageState? state, String? fallback) {
  if (fallback != null && fallback.trim().isNotEmpty) {
    return fallback;
  }

  return switch (state) {
    AppPageState.content => '当前组织信息已准备好。',
    AppPageState.unauthorized => '当前会话未授权，请先恢复登录态。',
    AppPageState.forbidden => '当前入口暂未开放。',
    AppPageState.notFound => '当前路径暂未承接。',
    AppPageState.errorRetryable => '当前请求暂时没有成功，可以稍后重试。',
    AppPageState.errorNonRetryable => '当前请求处于受控失败态。',
    _ => '当前内容正在准备中。',
  };
}
