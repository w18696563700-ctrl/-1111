import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class EnterpriseApplicationPage extends StatefulWidget {
  const EnterpriseApplicationPage({
    super.key,
    this.initialBoardType,
  });

  final EnterpriseBoardType? initialBoardType;

  @override
  State<EnterpriseApplicationPage> createState() => _EnterpriseApplicationPageState();
}

class _EnterpriseApplicationPageState extends State<EnterpriseApplicationPage> {
  late EnterpriseBoardType _boardType;
  final TextEditingController _applicantNameController =
      TextEditingController();
  final TextEditingController _applicantMobileController =
      TextEditingController();
  final TextEditingController _enterpriseNameController =
      TextEditingController();
  final TextEditingController _shortIntroController = TextEditingController();
  final TextEditingController _fullIntroController = TextEditingController();
  final TextEditingController _provinceNameController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController = TextEditingController();
  final TextEditingController _profileOneController = TextEditingController();
  final TextEditingController _profileTwoController = TextEditingController();
  final TextEditingController _caseTitleController = TextEditingController();
  final TextEditingController _caseSummaryController = TextEditingController();
  final TextEditingController _caseCoverAssetIdController =
      TextEditingController();

  EnterpriseHubApplicationDraft? _draft;
  String? _lastCaseId;
  bool _creatingDraft = false;
  bool _savingBasic = false;
  bool _savingProfile = false;
  bool _creatingCase = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _boardType = widget.initialBoardType ?? EnterpriseBoardType.company;
  }

  @override
  void dispose() {
    _applicantNameController.dispose();
    _applicantMobileController.dispose();
    _enterpriseNameController.dispose();
    _shortIntroController.dispose();
    _fullIntroController.dispose();
    _provinceNameController.dispose();
    _cityNameController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    _profileOneController.dispose();
    _profileTwoController.dispose();
    _caseTitleController.dispose();
    _caseSummaryController.dispose();
    _caseCoverAssetIdController.dispose();
    super.dispose();
  }

  Future<void> _createDraft() async {
    setState(() {
      _creatingDraft = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.createApplication(
      boardType: _boardType,
      applicantName: _applicantNameController.text,
      applicantMobile: _applicantMobileController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _creatingDraft = false;
      _draft = result.data;
    });
    _showActionMessage(
      success: result.isSuccess,
      successMessage: '已创建入驻草稿，可继续补充企业资料。',
      failureMessage: result.message ?? '当前无法创建入驻草稿。',
    );
  }

  Future<void> _saveBasic() async {
    final enterpriseId = _draft?.enterpriseId;
    if (enterpriseId == null) {
      return;
    }

    setState(() {
      _savingBasic = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.updateBasic(
      enterpriseId: enterpriseId,
      body: <String, Object?>{
        'name': _emptyToNull(_enterpriseNameController.text),
        'shortIntro': _emptyToNull(_shortIntroController.text),
        'fullIntro': _emptyToNull(_fullIntroController.text),
        'provinceName': _emptyToNull(_provinceNameController.text),
        'cityName': _emptyToNull(_cityNameController.text),
        'contactVisible': true,
      },
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _savingBasic = false;
    });
    _showActionMessage(
      success: result.isSuccess,
      successMessage: '基础资料已提交到 enterprise-hub basic。',
      failureMessage: result.message ?? '当前无法保存基础资料。',
    );
  }

  Future<void> _saveBoardProfile() async {
    final enterpriseId = _draft?.enterpriseId;
    if (enterpriseId == null) {
      return;
    }

    setState(() {
      _savingProfile = true;
    });

    final Map<String, Object?> body = switch (_boardType) {
      EnterpriseBoardType.company => <String, Object?>{
        'exhibitionTypes': _csvList(_profileOneController.text),
        'serviceItems': _csvList(_profileTwoController.text),
        'serviceCities': _csvList(_cityNameController.text),
      },
      EnterpriseBoardType.factory => <String, Object?>{
        'processTypes': _csvList(_profileOneController.text),
        'coreProducts': _csvList(_profileTwoController.text),
      },
      EnterpriseBoardType.supplier => <String, Object?>{
        'supplyCategories': _csvList(_profileOneController.text),
        'supplyMode': _csvList(_profileTwoController.text),
        'coreProductsOrServices': _csvList(_shortIntroController.text),
      },
    };

    final result = await switch (_boardType) {
      EnterpriseBoardType.company =>
        EnterpriseHubConsumerLayer.instance.updateCompanyProfile(
          enterpriseId: enterpriseId,
          body: body,
        ),
      EnterpriseBoardType.factory =>
        EnterpriseHubConsumerLayer.instance.updateFactoryProfile(
          enterpriseId: enterpriseId,
          body: body,
        ),
      EnterpriseBoardType.supplier =>
        EnterpriseHubConsumerLayer.instance.updateSupplierProfile(
          enterpriseId: enterpriseId,
          body: body,
        ),
    };

    if (!mounted) {
      return;
    }

    setState(() {
      _savingProfile = false;
    });
    _showActionMessage(
      success: result.isSuccess,
      successMessage: '板块画像已提交到 ${_boardType.contractName} profile。',
      failureMessage: result.message ?? '当前无法保存板块画像。',
    );
  }

  Future<void> _createCase() async {
    final enterpriseId = _draft?.enterpriseId;
    if (enterpriseId == null) {
      return;
    }

    setState(() {
      _creatingCase = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.createCase(
      enterpriseId: enterpriseId,
      body: <String, Object?>{
        'boardType': _boardType.contractName,
        'title': _caseTitleController.text.trim(),
        'summary': _caseSummaryController.text.trim(),
        'caseCoverFileAssetId': _caseCoverAssetIdController.text.trim(),
      },
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _creatingCase = false;
      _lastCaseId = result.data?.caseId;
    });
    _showActionMessage(
      success: result.isSuccess,
      successMessage: '案例已提交，当前 caseId 为 ${result.data?.caseId ?? '未返回'}。',
      failureMessage: result.message ?? '当前无法创建案例。',
    );
  }

  Future<void> _submitApplication() async {
    final applicationId = _draft?.applicationId;
    if (applicationId == null) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.submitApplication(
      applicationId: applicationId,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });

    if (result.isSuccess) {
      Navigator.of(context).pushNamed(
        ExhibitionRoutes.enterpriseApplicationStatusWithId(
          applicationId,
          boardType: _boardType.contractName,
        ),
      );
      return;
    }

    _showActionMessage(
      success: false,
      successMessage: '',
      failureMessage: result.message ?? '当前无法提交申请。',
    );
  }

  void _showActionMessage({
    required bool success,
    required String successMessage,
    required String failureMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? successMessage : failureMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AppShellScope.read(context).snapshot;
    final guard = _buildGuard(snapshot);
    if (guard != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[guard],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        EnterpriseSectionCard(
          title: '企业入驻页',
          subtitle: '入驻页继续绑定现有 organization 上下文与认证状态，不独立成新 building。',
          actions: <Widget>[
            FilledButton(
              onPressed: _creatingDraft ? null : _createDraft,
              child: Text(_creatingDraft ? '创建中' : '创建入驻草稿'),
            ),
            if (_draft != null)
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterpriseApplicationStatusWithId(
                      _draft!.applicationId,
                      boardType: _boardType.contractName,
                    ),
                  );
                },
                child: const Text('查看当前状态'),
              ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SegmentedButton<EnterpriseBoardType>(
                segments: EnterpriseBoardType.values
                    .map(
                      (EnterpriseBoardType item) => ButtonSegment<EnterpriseBoardType>(
                        value: item,
                        label: Text(item.title),
                      ),
                    )
                    .toList(growable: false),
                selected: <EnterpriseBoardType>{_boardType},
                onSelectionChanged: (Set<EnterpriseBoardType> value) {
                  setState(() {
                    _boardType = value.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _applicantNameController,
                decoration: const InputDecoration(
                  labelText: '申请人姓名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _applicantMobileController,
                decoration: const InputDecoration(
                  labelText: '申请人手机号',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'basic',
          subtitle: '对应 PUT /enterprises/{enterpriseId}/basic',
          actions: <Widget>[
            FilledButton.tonal(
              onPressed: _draft == null || _savingBasic ? null : _saveBasic,
              child: Text(_savingBasic ? '保存中' : '保存基础资料'),
            ),
          ],
          child: Column(
            children: <Widget>[
              TextField(
                controller: _enterpriseNameController,
                decoration: const InputDecoration(
                  labelText: '企业名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shortIntroController,
                decoration: const InputDecoration(
                  labelText: '一句话简介',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fullIntroController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '完整介绍',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _provinceNameController,
                decoration: const InputDecoration(
                  labelText: '省份名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityNameController,
                decoration: const InputDecoration(
                  labelText: '城市名称',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'boardProfile',
          subtitle: '统一骨架下按公司 / 工厂 / 供应商切换对应 profile 接口。',
          actions: <Widget>[
            FilledButton.tonal(
              onPressed: _draft == null || _savingProfile ? null : _saveBoardProfile,
              child: Text(_savingProfile ? '保存中' : '保存板块画像'),
            ),
          ],
          child: Column(
            children: <Widget>[
              TextField(
                controller: _profileOneController,
                decoration: InputDecoration(
                  labelText: switch (_boardType) {
                    EnterpriseBoardType.company => '展会类型（逗号分隔）',
                    EnterpriseBoardType.factory => '工艺类型（逗号分隔）',
                    EnterpriseBoardType.supplier => '供应品类（逗号分隔）',
                  },
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _profileTwoController,
                decoration: InputDecoration(
                  labelText: switch (_boardType) {
                    EnterpriseBoardType.company => '服务项目（逗号分隔）',
                    EnterpriseBoardType.factory => '核心产品（逗号分隔）',
                    EnterpriseBoardType.supplier => '供应模式（逗号分隔）',
                  },
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: 'cases',
          subtitle: '案例创建仍走独立 canonical path，不写死 file_url。',
          actions: <Widget>[
            FilledButton.tonal(
              onPressed: _draft == null || _creatingCase ? null : _createCase,
              child: Text(_creatingCase ? '创建中' : '新增案例'),
            ),
          ],
          child: Column(
            children: <Widget>[
              TextField(
                controller: _caseTitleController,
                decoration: const InputDecoration(
                  labelText: '案例标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _caseSummaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '案例摘要',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _caseCoverAssetIdController,
                decoration: const InputDecoration(
                  labelText: '案例封面 FileAssetId',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_lastCaseId != null) ...<Widget>[
                const SizedBox(height: 12),
                Text('最近一次创建案例：$_lastCaseId'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnterpriseSectionCard(
          title: '提交申请',
          subtitle: '提交后进入 application-status 页面承接状态结果。',
          actions: <Widget>[
            FilledButton(
              onPressed: _draft == null || _submitting ? null : _submitApplication,
              child: Text(_submitting ? '提交中' : '提交入驻申请'),
            ),
          ],
          child: Text(
            _draft == null
                ? '请先创建入驻草稿。'
                : '当前 applicationId：${_draft!.applicationId}；enterpriseId：${_draft!.enterpriseId}；状态：${_draft!.applicationStatus}',
          ),
        ),
      ],
    );
  }

  Widget? _buildGuard(AppShellContextSnapshot snapshot) {
    final blockingState = snapshot.blockingState;
    if (blockingState == GlobalShellState.unauthenticated) {
      return const EnterpriseSectionCard(
        title: '当前尚未登录',
        subtitle: '企业入驻属于组织侧动作，需先登录。',
        child: _GuardAction(
          actionLabel: '进入登录入口',
          routeName: ProfileIdentityRoutes.login,
        ),
      );
    }
    if (blockingState == GlobalShellState.noOrganization ||
        snapshot.shellContext.organizationId == null) {
      return const EnterpriseSectionCard(
        title: '当前缺少 organization scope',
        subtitle: '入驻页必须绑定现有 organization 上下文。',
        child: _GuardAction(
          actionLabel: '前往组织承接',
          routeName: ProfileIdentityRoutes.organizationHandoff,
        ),
      );
    }

    final certification = snapshot.shellContext.certificationStatus?.toLowerCase();
    if (certification != 'verified' && certification != 'approved') {
      return const EnterpriseSectionCard(
        title: '当前认证状态不足',
        subtitle: '企业入驻需要先回到现有认证流程补齐，不在前端发明新角色。',
        child: _GuardAction(
          actionLabel: '查看认证状态',
          routeName: ProfileIdentityRoutes.certificationCurrent,
        ),
      );
    }

    return null;
  }
}

class EnterpriseApplicationStatusPage extends StatefulWidget {
  const EnterpriseApplicationStatusPage({
    super.key,
    required this.applicationId,
    this.boardType,
  });

  final String? applicationId;
  final EnterpriseBoardType? boardType;

  @override
  State<EnterpriseApplicationStatusPage> createState() =>
      _EnterpriseApplicationStatusPageState();
}

class _EnterpriseApplicationStatusPageState
    extends State<EnterpriseApplicationStatusPage> {
  EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final applicationId = widget.applicationId?.trim();
    if (applicationId == null || applicationId.isEmpty) {
      setState(() {
        _result = EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: '/api/app/exhibition/enterprise-hub/applications/{applicationId}',
          message: '缺少 applicationId，当前无法读取申请状态。',
        );
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    final result = await EnterpriseHubConsumerLayer.instance.loadApplicationStatus(
      applicationId: applicationId,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _result?.data;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        EnterpriseSectionCard(
          title: '入驻提交成功或状态页',
          subtitle: '当前承接 GET /applications/{applicationId}。',
          actions: <Widget>[
            FilledButton.tonal(
              onPressed: _loading ? null : _load,
              child: Text(_loading ? '读取中' : '刷新状态'),
            ),
            if (widget.boardType != null)
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterpriseApplyWithBoardType(
                      widget.boardType!.contractName,
                    ),
                  );
                },
                child: const Text('返回入驻页'),
              ),
          ],
          child: _loading && data == null
              ? const Center(child: CircularProgressIndicator())
              : data == null
              ? Text(_result?.message ?? '当前状态页暂不可用。')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('申请单：${data.applicationId}'),
                    const SizedBox(height: 8),
                    Text('企业：${data.enterpriseId}'),
                    const SizedBox(height: 8),
                    Text('板块：${data.applyBoardType.title}'),
                    const SizedBox(height: 8),
                    Text('状态：${data.applicationStatus}'),
                    if (data.submittedAt != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text('提交时间：${data.submittedAt}'),
                    ],
                    if (data.reviewedAt != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text('审核时间：${data.reviewedAt}'),
                    ],
                    if (data.rejectionReason != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text('驳回原因：${data.rejectionReason}'),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _GuardAction extends StatelessWidget {
  const _GuardAction({
    required this.actionLabel,
    required this.routeName,
  });

  final String actionLabel;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).pushNamed(routeName),
      child: Text(actionLabel),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _csvList(String raw) {
  return raw
      .split(',')
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}
