part of 'profile_detail_pages.dart';

class ProfilePaymentBillingExplanationPage extends StatefulWidget {
  const ProfilePaymentBillingExplanationPage({super.key});

  @override
  State<ProfilePaymentBillingExplanationPage> createState() =>
      _ProfilePaymentBillingExplanationPageState();
}

class _ProfilePaymentBillingExplanationPageState
    extends State<ProfilePaymentBillingExplanationPage> {
  bool _loading = true;
  ProfilePaymentBillingResult<ProfilePaymentBillingExplanationView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfilePaymentBillingConsumerLayer.instance
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
        message: '正在同步当前支付状态、账单引用与依赖说明。',
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
            title: data.paymentExplanation.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: data.paymentExplanation.body,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.billingExplanation.title,
            children: <Widget>[
              _ProfileValueRow(
                title: '当前说明',
                value: data.billingExplanation.body,
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

class ProfilePaymentBillingHandoffPage extends StatefulWidget {
  const ProfilePaymentBillingHandoffPage({super.key});

  @override
  State<ProfilePaymentBillingHandoffPage> createState() =>
      _ProfilePaymentBillingHandoffPageState();
}

class _ProfilePaymentBillingHandoffPageState
    extends State<ProfilePaymentBillingHandoffPage> {
  bool _loading = true;
  ProfilePaymentBillingResult<ProfilePaymentBillingHandoffView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfilePaymentBillingConsumerLayer.instance
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
            title: data.paymentHandoff.title,
            children: <Widget>[
              _ProfileValueRow(title: '当前方向', value: data.paymentHandoff.body),
              _ProfileValueRow(
                title: '当前衔接状态',
                value: profileDisplayPaymentBillingHandoffStatus(
                  data.paymentHandoff.handoffStatus,
                ),
              ),
              _ProfileValueRow(
                title: '当前目标',
                value: profileDisplayPaymentBillingHandoffTargetFamily(
                  data.paymentHandoff.handoffTargetFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: data.billingHandoff.title,
            children: <Widget>[
              _ProfileValueRow(title: '当前方向', value: data.billingHandoff.body),
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
