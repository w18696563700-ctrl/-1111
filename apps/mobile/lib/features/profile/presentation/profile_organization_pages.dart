import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/china_region_picker.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_certification_truth_support.dart';
import 'package:mobile/features/profile/presentation/profile_organization_capability_copy.dart';
import 'package:mobile/features/profile/presentation/profile_organization_scope_visibility.dart';
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
  ProfileIdentityResult<MyOrganizationsView>? _result;
  ProfileIdentityResult<ProfileCertificationCurrentView>? _certificationResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final results = await Future.wait<Object>(<Future<Object>>[
      ProfileIdentityConsumerLayer.instance.loadMyOrganizations(),
      ProfileIdentityConsumerLayer.instance.loadCertificationCurrent(),
    ]);
    final result = results[0] as ProfileIdentityResult<MyOrganizationsView>;
    final certificationResult =
        results[1] as ProfileIdentityResult<ProfileCertificationCurrentView>;
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _certificationResult = certificationResult;
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

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final items = _result?.data?.items ?? const <MyOrganizationItemView>[];
    final current = _resolveCurrent(items, shellContext.organizationId);
    final currentCertification = _resolveCurrentCertification(current);
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
        const _OrganizationCard(
          child: Text(
            '先在这里确认当前主体，再继续创建组织、加入组织或切换当前主体；项目归属、认证主体与可发布 / 可竞标能力都会跟随这里。',
          ),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '当前主体',
          child: _buildCurrentOrganization(current, currentCertification),
        ),
        const SizedBox(height: 16),
        _OrganizationCard(
          title: '可进行的操作',
          child: _buildActionBlocks(
            current: current,
            canSwitch: switchable.isNotEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBlocks({
    required MyOrganizationItemView? current,
    required bool canSwitch,
  }) {
    final actions = <_OrganizationActionSpec>[
      if (current == null)
        _OrganizationActionSpec(
          key: const ValueKey<String>('organization-action-create'),
          label: '创建组织',
          description: '新建当前主体',
          onPressed: () => _openRoute(ProfileIdentityRoutes.organizationCreate),
        ),
      if (current != null)
        _OrganizationActionSpec(
          key: const ValueKey<String>('organization-action-edit'),
          label: '编辑当前组织',
          description: '维护当前主体资料',
          onPressed: () => _openRoute(ProfileIdentityRoutes.organizationCreate),
        ),
      if (current != null)
        _OrganizationActionSpec(
          key: const ValueKey<String>('organization-action-create-another'),
          label: '再创建一个组织',
          description: '承接新的公司主体',
          onPressed: () => _openRoute(
            ProfileIdentityRoutes.organizationCreateWithMode(
              _OrganizationCreatePageState.createAnotherMode,
            ),
          ),
          tonal: true,
        ),
      _OrganizationActionSpec(
        key: const ValueKey<String>('organization-action-join'),
        label: '加入组织',
        description: '通过邀请码加入',
        onPressed: () => _openRoute(ProfileIdentityRoutes.organizationJoin),
        tonal: true,
      ),
      if (canSwitch)
        _OrganizationActionSpec(
          key: const ValueKey<String>('organization-action-switch'),
          label: '切换当前主体',
          description: '切换当前生效主体',
          onPressed: () => _openRoute(ProfileIdentityRoutes.organizationSwitch),
          tonal: true,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '先确定你当前以哪个主体在 App 内工作。项目归属、成员权限、认证主体，以及可发布 / 可竞标能力都跟随这里。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final columnCount = constraints.maxWidth < 340 ? 2 : 3;
            final tileWidth =
                (constraints.maxWidth - (columnCount - 1) * 12) / columnCount;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions
                  .map(
                    (_OrganizationActionSpec action) => SizedBox(
                      width: tileWidth,
                      child: _OrganizationActionTile(
                        key: action.key,
                        label: action.label,
                        description: action.description,
                        onPressed: action.onPressed,
                        tonal: action.tonal,
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrentOrganization(
    MyOrganizationItemView? current,
    ProfileCertificationCurrentView? certification,
  ) {
    if (_loading) {
      return const Text('正在同步当前组织信息。');
    }
    if (_result != null &&
        _result!.state != AppPageState.content &&
        _result!.state != AppPageState.empty) {
      return Text(_organizationMessage(_result!.state, _result!.message));
    }
    if (current == null) {
      return const _OrganizationCurrentSummaryPanel(
        title: '当前还没有主体',
        subtitle: '先创建组织或加入已有组织',
        statusText: '组织上下文未建立',
        statusBadges: <String>[],
        message: '完成创建或加入后，这里会同步当前主体摘要，并继续承接后续组织动作。',
        avatarLabel: '组',
        truthFields: <ProfileCertificationTruthField>[],
      );
    }

    final truthFields = buildProfileCertificationTruthFields(certification);
    final resolvedCertificationStatus =
        certification?.certificationStatus ?? current.certificationStatus;
    return _OrganizationCurrentSummaryPanel(
      title: profileDisplayOrganizationName(current.name),
      subtitle: profileDisplayOrganizationCapabilitySummary(
        current.organizationType,
        roleKeys: current.roleKeys,
      ),
      statusText: '',
      statusBadges: profileBuildOrganizationCapabilityStatusBadges(
        certificationStatus: resolvedCertificationStatus,
        membershipStatus: current.membershipStatus,
      ),
      message: truthFields.isEmpty
          ? '当前主体已建立，可继续编辑基础资料、再创建一个组织、加入组织或切换当前主体。正式认证资料会在通过认证后同步到这里。'
          : '当前主体已建立，下面显示的是当前生效的正式认证资料，用于确认主体真值、企业认证与后续能力上下文。',
      avatarLabel: '组',
      truthFields: truthFields,
    );
  }

  ProfileCertificationCurrentView? _resolveCurrentCertification(
    MyOrganizationItemView? current,
  ) {
    final result = _certificationResult;
    final certification = result?.state == AppPageState.content
        ? result?.data
        : null;
    if (certification == null) {
      return null;
    }
    final certificationOrganizationId = certification.organizationId?.trim();
    if (current == null ||
        certificationOrganizationId == null ||
        certificationOrganizationId.isEmpty ||
        certificationOrganizationId == current.organizationId) {
      return certification;
    }
    return null;
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
}

class OrganizationCreatePage extends StatefulWidget {
  const OrganizationCreatePage({super.key});

  @override
  State<OrganizationCreatePage> createState() => _OrganizationCreatePageState();
}

class _OrganizationCreatePageState extends State<OrganizationCreatePage> {
  static const String createAnotherMode = 'create_another';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _provinceCodeController = TextEditingController();
  final TextEditingController _cityCodeController = TextEditingController();
  final TextEditingController _provinceDisplayController =
      TextEditingController();
  final TextEditingController _cityDisplayController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController =
      TextEditingController();
  String _organizationType = 'demand';
  bool _loadingContext = true;
  bool _submitting = false;
  bool _routeResolved = false;
  bool _createAnother = false;
  MyOrganizationItemView? _currentOrganization;
  ProfileIdentityResult<ProfileCertificationCurrentView>? _certificationResult;
  ChinaRegionCatalog? _regionCatalog;
  String? _resultTitle;
  String? _resultMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeResolved) {
      return;
    }
    final route = ModalRoute.of(context);
    final routeName = route?.settings.name;
    if (route == null || routeName == null || routeName.trim().isEmpty) {
      return;
    }
    _routeResolved = true;
    final routeUri = Uri.tryParse(routeName);
    _createAnother = routeUri?.queryParameters['mode'] == createAnotherMode;
    _loadContext();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _provinceCodeController.dispose();
    _cityCodeController.dispose();
    _provinceDisplayController.dispose();
    _cityDisplayController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    super.dispose();
  }

  bool get _isEditMode => _currentOrganization != null && !_createAnother;

  ProfileCertificationCurrentView? get _currentCertification {
    final result = _certificationResult;
    if (result == null || result.state != AppPageState.content) {
      return null;
    }
    return result.data;
  }

  Future<void> _loadContext() async {
    setState(() {
      _loadingContext = true;
    });

    final results = await Future.wait<Object>(<Future<Object>>[
      ProfileIdentityConsumerLayer.instance.loadMyOrganizations(),
      ProfileIdentityConsumerLayer.instance.loadCertificationCurrent(),
    ]);
    final result = results[0] as ProfileIdentityResult<MyOrganizationsView>;
    final certificationResult =
        results[1] as ProfileIdentityResult<ProfileCertificationCurrentView>;
    if (!mounted) {
      return;
    }

    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final currentOrganization = _OrganizationHandoffPageState._resolveCurrent(
      result.data?.items ?? const <MyOrganizationItemView>[],
      shellContext.organizationId,
    );
    if (currentOrganization != null && !_createAnother) {
      _applyOrganizationToForm(currentOrganization);
      _applyCertificationToForm(certificationResult.data);
    } else if (_createAnother) {
      _clearCreateForm();
    }

    setState(() {
      _currentOrganization = currentOrganization;
      _certificationResult = certificationResult;
      _loadingContext = false;
    });

    final regionCatalog = await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _regionCatalog = regionCatalog;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _resultTitle = null;
      _resultMessage = null;
    });

    final result = _isEditMode
        ? await ProfileIdentityConsumerLayer.instance.updateCurrentOrganization(
            name: _resolvedOrganizationName,
            provinceCode: _provinceCodeController.text,
            cityCode: _cityCodeController.text,
            contactName: _contactNameController.text,
            contactMobile: _contactMobileController.text,
          )
        : await ProfileIdentityConsumerLayer.instance.createOrganization(
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
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
      return;
    }

    setState(() {
      _submitting = false;
      _resultTitle = _isEditMode ? '当前组织保存未完成' : '创建当前未完成';
      _resultMessage = _organizationMessage(result.state, result.message);
    });
  }

  void _applyOrganizationToForm(MyOrganizationItemView organization) {
    _nameController.text = organization.name;
    _applyLocationCodes(
      provinceCode: organization.provinceCode,
      cityCode: organization.cityCode,
    );
    _contactNameController.text = organization.contactName ?? '';
    _contactMobileController.text = organization.contactMobile ?? '';
    _organizationType = organization.organizationType;
  }

  void _applyCertificationToForm(
    ProfileCertificationCurrentView? certification,
  ) {
    final legalName = profileCertificationFormalSubjectName(certification);
    if (legalName != null) {
      _nameController.text = legalName;
    }
  }

  void _clearCreateForm() {
    _nameController.clear();
    _provinceCodeController.clear();
    _cityCodeController.clear();
    _provinceDisplayController.clear();
    _cityDisplayController.clear();
    _contactNameController.clear();
    _contactMobileController.clear();
    _organizationType = 'demand';
  }

  void _applyLocationCodes({String? provinceCode, String? cityCode}) {
    _provinceCodeController.text = provinceCode?.trim() ?? '';
    _cityCodeController.text = cityCode?.trim() ?? '';
    final catalog = _regionCatalog;
    final province = catalog?.provinceByCode(provinceCode);
    final city = catalog?.cityByCode(cityCode);
    _provinceDisplayController.text =
        city?.provinceName ?? province?.provinceName ?? '';
    _cityDisplayController.text = city?.cityName ?? '';
  }

  Future<void> _pickOrganizationCity() async {
    final catalog = _regionCatalog ?? await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    final picked = await showChinaCityPicker(
      context: context,
      catalog: catalog,
      title: '选择城市',
      initialProvinceCode: _provinceCodeController.text,
      initialCityCode: _cityCodeController.text,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _regionCatalog = catalog;
      _applyLocationCodes(
        provinceCode: picked.provinceCode,
        cityCode: picked.cityCode,
      );
    });
  }

  Future<void> _openCreateAnother() async {
    await Navigator.of(context).pushReplacementNamed(
      ProfileIdentityRoutes.organizationCreateWithMode(createAnotherMode),
    );
  }

  Future<void> _openEditCurrent() async {
    await Navigator.of(
      context,
    ).pushReplacementNamed(ProfileIdentityRoutes.organizationCreate);
  }

  String get _resolvedOrganizationName {
    return profileCertificationFormalSubjectName(_currentCertification) ??
        _nameController.text;
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentOrganization = _currentOrganization != null;
    final isEditMode = _isEditMode;
    final certificationTruthItems = buildProfileCertificationTruthFields(
      _currentCertification,
    );
    final hasLockedCertificationSubject =
        isEditMode && certificationTruthItems.isNotEmpty;
    final title = isEditMode
        ? '已创建当前组织'
        : _createAnother && hasCurrentOrganization
        ? '再创建一个组织'
        : '创建组织';
    final summary = isEditMode
        ? hasLockedCertificationSubject
              ? '当前组织主体已经创建。正式认证资料会在本页只读显示；这里仅编辑组织运营信息。'
              : '当前组织主体已经创建。这里编辑当前组织的基础资料；组织类型与认证字段已锁定，不在这里修改。'
        : _createAnother && hasCurrentOrganization
        ? '当前账号已经有组织主体。你现在进入的是“再创建一个组织”模式，填写后会新增一个组织主体。'
        : '当前只承接最小 organization create command，不扩成组织治理后台。';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        _OrganizationCard(title: title, child: Text(summary)),
        const SizedBox(height: 16),
        if (_loadingContext)
          const _OrganizationCard(
            title: '正在同步当前组织',
            child: Text('正在判断当前应进入创建模式还是编辑当前组织模式。'),
          )
        else if (hasCurrentOrganization && isEditMode)
          _OrganizationCard(
            title: '当前模式',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _OrganizationValueLine(
                  label: '当前组织',
                  value: profileDisplayOrganizationName(
                    _currentOrganization!.name,
                  ),
                ),
                _OrganizationValueLine(
                  label: '组织类型',
                  value: profileDisplayOrganizationType(
                    _currentOrganization!.organizationType,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _openCreateAnother,
                  child: const Text('再创建一个组织'),
                ),
              ],
            ),
          )
        else if (hasCurrentOrganization && _createAnother)
          _OrganizationCard(
            title: '已存在当前组织',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前组织 ${profileDisplayOrganizationName(_currentOrganization!.name)} 仍然保留。现在填写的是新的组织主体，不会修改当前组织的已认证字段。',
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _openEditCurrent,
                  child: const Text('返回编辑当前组织'),
                ),
              ],
            ),
          ),
        if (!_loadingContext && hasLockedCertificationSubject) ...<Widget>[
          const SizedBox(height: 16),
          _OrganizationCard(
            title: '认证主体信息',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('以下字段直接来自当前正式认证资料，和营业执照主体保持一致；如需修改，请走“更正认证资料”。'),
                const SizedBox(height: 12),
                for (final item in certificationTruthItems)
                  _OrganizationValueLine(label: item.label, value: item.value),
              ],
            ),
          ),
        ],
        if (_loadingContext) const SizedBox(height: 16),
        if (!_loadingContext) const SizedBox(height: 16),
        _OrganizationCard(
          title: isEditMode && hasLockedCertificationSubject
              ? '组织运营信息'
              : isEditMode
              ? '编辑当前组织'
              : '组织信息',
          child: Column(
            children: <Widget>[
              if (!(isEditMode && hasLockedCertificationSubject)) ...<Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '组织名称'),
                ),
                const SizedBox(height: 12),
              ],
              if (isEditMode)
                _OrganizationValueLine(
                  label: '组织类型',
                  value:
                      '${profileDisplayOrganizationType(_organizationType)}（已锁定，需新主体请再创建一个组织）',
                )
              else
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
              SelectLikeField(
                label: '所在省',
                value: _provinceDisplayController.text,
                placeholder: '点击选择所在地区',
                helperText: '组织所在省市必须点选，不再手填编码。',
                onTap: _loadingContext ? null : _pickOrganizationCity,
              ),
              const SizedBox(height: 12),
              SelectLikeField(
                label: '所在市',
                value: _cityDisplayController.text,
                placeholder: '点击选择所在地区',
                helperText: '组织所在省市必须按全国标准省市列表点选。',
                onTap: _loadingContext ? null : _pickOrganizationCity,
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
                onPressed: _loadingContext || _submitting ? null : _submit,
                child: Text(
                  _submitting ? '提交中' : (isEditMode ? '保存修改' : '创建组织'),
                ),
              ),
            ],
          ),
        ),
        if (_resultTitle != null && _resultMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          _OrganizationCard(title: _resultTitle!, child: Text(_resultMessage!)),
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
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
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
  const _OrganizationCard({this.title, required this.child});

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

class _OrganizationActionSpec {
  const _OrganizationActionSpec({
    required this.key,
    required this.label,
    required this.description,
    required this.onPressed,
    this.tonal = false,
  });

  final Key key;
  final String label;
  final String description;
  final VoidCallback? onPressed;
  final bool tonal;
}

class _OrganizationActionTile extends StatelessWidget {
  const _OrganizationActionTile({
    super.key,
    required this.label,
    required this.description,
    required this.onPressed,
    this.tonal = false,
  });

  final String label;
  final String description;
  final VoidCallback? onPressed;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = tonal
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: tonal
              ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.35)
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Icon(Icons.arrow_outward_rounded, size: 18, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationCurrentSummaryPanel extends StatelessWidget {
  const _OrganizationCurrentSummaryPanel({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusBadges,
    required this.message,
    required this.avatarLabel,
    required this.truthFields,
  });

  final String title;
  final String subtitle;
  final String statusText;
  final List<String> statusBadges;
  final String message;
  final String avatarLabel;
  final List<ProfileCertificationTruthField> truthFields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Text(
                        avatarLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (statusBadges.any(
                        (String item) => item.trim().isNotEmpty,
                      )) ...<Widget>[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: statusBadges
                              .where((String item) => item.trim().isNotEmpty)
                              .map(
                                (String item) => DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      item,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                      if (statusText.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
            if (truthFields.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Divider(color: theme.colorScheme.outlineVariant, height: 1),
              const SizedBox(height: 14),
              Text(
                '正式认证资料',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...truthFields.map(
                (ProfileCertificationTruthField field) =>
                    _OrganizationValueLine(
                      label: field.label,
                      value: field.value,
                    ),
              ),
            ],
          ],
        ),
      ),
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
