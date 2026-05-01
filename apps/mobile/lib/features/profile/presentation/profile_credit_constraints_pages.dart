part of 'profile_detail_pages.dart';

Future<void> openProfileCreditConstraintsStatusPage(BuildContext context) {
  return Navigator.of(context).push(
    _profileCreditConstraintsRoute(
      title: '我的信用与约束',
      child: const ProfileCreditConstraintsStatusPage(),
    ),
  );
}

Route<void> _profileCreditConstraintsRoute({
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

class ProfileCreditConstraintsStatusPage extends StatefulWidget {
  const ProfileCreditConstraintsStatusPage({super.key});

  @override
  State<ProfileCreditConstraintsStatusPage> createState() =>
      _ProfileCreditConstraintsStatusPageState();
}

class _ProfileCreditConstraintsStatusPageState
    extends State<ProfileCreditConstraintsStatusPage> {
  bool _loading = true;
  ProfileCreditConstraintsResult<ProfileCreditConstraintsStatusView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileCreditConstraintsConsumerLayer.instance
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
        message: '当前没有可验证的会话，我的信用与约束页不展示伪造状态。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取信用与约束',
        message: '正在同步当前信用、保证金与交易保障姿态。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '我的信用与约束当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '我的信用与约束',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: _ProfileCreditConstraintsStatusContent(data: data),
    );
  }
}

class ProfileCreditConstraintsExplanationPage extends StatefulWidget {
  const ProfileCreditConstraintsExplanationPage({super.key});

  @override
  State<ProfileCreditConstraintsExplanationPage> createState() =>
      _ProfileCreditConstraintsExplanationPageState();
}

class _ProfileCreditConstraintsExplanationPageState
    extends State<ProfileCreditConstraintsExplanationPage> {
  bool _loading = true;
  ProfileCreditConstraintsResult<ProfileCreditConstraintsExplanationView>?
  _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileCreditConstraintsConsumerLayer.instance
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
        title: '正在读取规则说明',
        message: '正在同步当前信用、保证金与交易保障规则说明。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '规则说明当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '规则说明页',
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
          _ProfileListSection(
            title: data.creditExplanation.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: data.creditExplanation.body,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.depositExplanation.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: data.depositExplanation.body,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.transactionGuaranteeExplanation.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: data.transactionGuaranteeExplanation.body,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '后续依赖',
            children: <Widget>[
              _ProfileValueRow(
                title: data.dependencyExplanation?.title ?? '当前依赖',
                value: data.dependencyExplanation?.body ?? '当前暂不要求额外依赖。',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前说明',
            children: <Widget>[
              _ProfileValueRow(title: '说明', value: data.disclaimer),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileCreditConstraintsHandoffPage extends StatefulWidget {
  const ProfileCreditConstraintsHandoffPage({super.key});

  @override
  State<ProfileCreditConstraintsHandoffPage> createState() =>
      _ProfileCreditConstraintsHandoffPageState();
}

class _ProfileCreditConstraintsHandoffPageState
    extends State<ProfileCreditConstraintsHandoffPage> {
  bool _loading = true;
  ProfileCreditConstraintsResult<ProfileCreditConstraintsHandoffView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileCreditConstraintsConsumerLayer.instance
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
        title: '正在读取处理与衔接',
        message: '正在同步当前处理方向与后续依赖说明。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '处理与衔接当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '处理与衔接页',
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
          _ProfileListSection(
            title: data.creditHandoff.title,
            children: <Widget>[
              _ProfileValueRow(title: '当前方向', value: data.creditHandoff.body),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.depositHandoff.title,
            children: <Widget>[
              _ProfileValueRow(title: '当前方向', value: data.depositHandoff.body),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.transactionGuaranteeHandoff.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前方向',
                value: data.transactionGuaranteeHandoff.body,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '后续依赖',
            children: <Widget>[
              _ProfileValueRow(
                title: data.dependencyHandoff?.title ?? '当前依赖',
                value: data.dependencyHandoff?.body ?? '当前暂不需要额外衔接。',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
