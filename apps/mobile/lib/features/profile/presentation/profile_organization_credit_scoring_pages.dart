part of 'profile_detail_pages.dart';

Future<void> openProfileOrganizationCreditScoringStatusPage(
  BuildContext context,
) {
  return Navigator.of(context).push(
    _profileOrganizationCreditScoringRoute(
      title: '组织信用评分',
      child: const ProfileOrganizationCreditScoringStatusPage(),
    ),
  );
}

Route<void> _profileOrganizationCreditScoringRoute({
  required String title,
  required Widget child,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => AppShellScaffold(
      currentBuilding: AppBuilding.profile,
      titleOverride: title,
      showStageBanner: false,
      child: child,
    ),
  );
}

class ProfileOrganizationCreditScoringStatusPage extends StatefulWidget {
  const ProfileOrganizationCreditScoringStatusPage({super.key});

  @override
  State<ProfileOrganizationCreditScoringStatusPage> createState() =>
      _ProfileOrganizationCreditScoringStatusPageState();
}

class _ProfileOrganizationCreditScoringStatusPageState
    extends State<ProfileOrganizationCreditScoringStatusPage> {
  bool _loading = true;
  ProfileOrganizationCreditScoringResult<OrganizationCreditScoringStatusView>?
  _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileOrganizationCreditScoringConsumerLayer.instance
        .loadStatus();
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
    if (!AppSessionStore.instance.hasAnySession) {
      return _ProfileScreenStatePanel(
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，组织信用评分 reserve 不展示伪造状态。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取组织信用评分 reserve',
        message:
            '正在同步 future-mainline reserve 的 status / explanation / handoff。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '组织信用评分 reserve当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '组织信用评分 reserve',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: _ProfileOrganizationCreditScoringStatusContent(data: data),
    );
  }
}

class ProfileOrganizationCreditScoringExplanationPage extends StatefulWidget {
  const ProfileOrganizationCreditScoringExplanationPage({super.key});

  @override
  State<ProfileOrganizationCreditScoringExplanationPage> createState() =>
      _ProfileOrganizationCreditScoringExplanationPageState();
}

class _ProfileOrganizationCreditScoringExplanationPageState
    extends State<ProfileOrganizationCreditScoringExplanationPage> {
  bool _loading = true;
  ProfileOrganizationCreditScoringResult<
    OrganizationCreditScoringExplanationView
  >?
  _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileOrganizationCreditScoringConsumerLayer.instance
        .loadExplanation();
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
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取组织信用评分说明',
        message: '正在同步 future-mainline reserve 的 explanation read surface。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '组织信用评分说明当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '组织信用评分说明',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '组织信用评分说明',
            subtitle: _reserveSampleStatusLabel(data.sampleStatus),
            detail: _reserveRiskPostureLabel(data.riskPosture),
            avatarLabel: '说',
            badgeText: '未来主线 reserve',
            supportingText: '当前只展示 explanation 读取面，不写回 current V2.1。',
          ),
          const SizedBox(height: 18),
          _ProfileListSection(
            title: '原因摘要',
            children: <Widget>[
              _ProfileValueRow(title: '当前摘要', value: data.reasonSummary),
              _ProfileValueRow(
                title: '最近更新',
                value: profileDisplayTimeLabel(
                  data.updatedAt,
                  fallback: '时间未知',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '原因码',
            children: <Widget>[
              _ProfileValueRow(
                title: '原因码列表',
                value: data.reasonCodes.join('、'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前样本与风险',
            children: <Widget>[
              _ProfileValueRow(
                title: '样本状态',
                value: _reserveSampleStatusLabel(data.sampleStatus),
              ),
              _ProfileValueRow(
                title: '风险姿态',
                value: _reserveRiskPostureLabel(data.riskPosture),
              ),
              _ProfileValueRow(
                title: '已评分完成订单数',
                value: data.ratedCompletedOrderCount.toString(),
              ),
              _ProfileValueRow(
                title: '正向率',
                value: _reserveRateLabel(data.positiveRate),
              ),
              _ProfileValueRow(
                title: '负向率',
                value: _reserveRateLabel(data.negativeRate),
              ),
              _ProfileValueRow(
                title: '非常满意',
                value: data.verySatisfiedCount.toString(),
              ),
              _ProfileValueRow(
                title: '满意',
                value: data.satisfiedCount.toString(),
              ),
              _ProfileValueRow(
                title: '可接受',
                value: data.passableCount.toString(),
              ),
              _ProfileValueRow(
                title: '负向',
                value: data.negativeCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileOrganizationCreditScoringHandoffPage extends StatefulWidget {
  const ProfileOrganizationCreditScoringHandoffPage({super.key});

  @override
  State<ProfileOrganizationCreditScoringHandoffPage> createState() =>
      _ProfileOrganizationCreditScoringHandoffPageState();
}

class _ProfileOrganizationCreditScoringHandoffPageState
    extends State<ProfileOrganizationCreditScoringHandoffPage> {
  bool _loading = true;
  ProfileOrganizationCreditScoringResult<OrganizationCreditScoringHandoffView>?
  _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileOrganizationCreditScoringConsumerLayer.instance
        .loadHandoff();
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
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取组织信用评分衔接',
        message: '正在同步 future-mainline reserve 的 handoff read surface。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '组织信用评分衔接当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '组织信用评分衔接',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '组织信用评分衔接',
            subtitle: _reserveActionableStateLabel(data.actionableState),
            detail: _reserveRiskPostureLabel(data.riskPosture),
            avatarLabel: '接',
            badgeText: '未来主线 reserve',
            supportingText: '当前只展示 handoff 读取面，不写回 current V2.1。',
          ),
          const SizedBox(height: 18),
          _ProfileListSection(
            title: '当前建议',
            children: <Widget>[
              _ProfileValueRow(
                title: '可执行状态',
                value: _reserveActionableStateLabel(data.actionableState),
              ),
              _ProfileValueRow(
                title: '主动作编码',
                value: _reserveValueOrFallback(data.primaryActionCode),
              ),
              _ProfileValueRow(
                title: '主动作标签',
                value: _reserveValueOrFallback(
                  data.primaryActionLabel,
                  fallback: '当前暂无主动作标签',
                ),
              ),
              _ProfileValueRow(
                title: '样本状态',
                value: _reserveSampleStatusLabel(data.sampleStatus),
              ),
              _ProfileValueRow(
                title: '风险姿态',
                value: _reserveRiskPostureLabel(data.riskPosture),
              ),
              _ProfileValueRow(
                title: '最近更新',
                value: profileDisplayTimeLabel(
                  data.updatedAt,
                  fallback: '时间未知',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '衔接说明',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: _reserveValueOrFallback(
                  data.handoffMessage,
                  fallback: '当前暂无衔接说明',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
