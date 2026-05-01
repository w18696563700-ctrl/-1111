part of 'profile_detail_pages.dart';

Future<void> openProfilePaymentBillingStatusPage(BuildContext context) {
  return Navigator.of(context).push(
    _profilePaymentBillingRoute(
      title: '支付与账单状态',
      child: const ProfilePaymentBillingStatusPage(),
    ),
  );
}

Route<void> _profilePaymentBillingRoute({
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

class ProfilePaymentBillingStatusPage extends StatefulWidget {
  const ProfilePaymentBillingStatusPage({super.key});

  @override
  State<ProfilePaymentBillingStatusPage> createState() =>
      _ProfilePaymentBillingStatusPageState();
}

class _ProfilePaymentBillingStatusPageState
    extends State<ProfilePaymentBillingStatusPage> {
  bool _loading = true;
  ProfilePaymentBillingResult<ProfilePaymentBillingStatusView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfilePaymentBillingConsumerLayer.instance
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
        message: '当前没有可验证的会话，支付与账单状态页不展示伪造状态。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取支付与账单状态',
        message: '正在同步当前支付状态、账单引用与后续衔接。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      final unavailablePanel = _paymentBillingUnavailablePanel(
        context: context,
        state: result.state,
        errorCode: result.errorCode,
        rawMessage: result.message,
      );
      if (unavailablePanel != null) {
        return unavailablePanel;
      }

      return _ProfileScreenStatePanel(
        title: '支付与账单状态当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '支付与账单状态',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: _PaymentBillingStatusOverview(
        data: data,
        onOpenExplanation: () => Navigator.of(context).push(
          _profilePaymentBillingRoute(
            title: '规则说明',
            child: const ProfilePaymentBillingExplanationPage(),
          ),
        ),
        onOpenHandoff: () => Navigator.of(context).push(
          _profilePaymentBillingRoute(
            title: '处理与衔接',
            child: const ProfilePaymentBillingHandoffPage(),
          ),
        ),
      ),
    );
  }
}

Widget? _paymentBillingUnavailablePanel({
  required BuildContext context,
  required AppPageState state,
  String? errorCode,
  String? rawMessage,
}) {
  final copy = profilePaymentBillingUnavailableVisibleCopy(
    state: state,
    errorCode: errorCode,
    rawMessage: rawMessage,
  );
  if (copy == null) {
    return null;
  }

  return _ProfileScreenStatePanel(
    title: copy.title,
    message: copy.message,
    actionLabel: copy.actionLabel,
    onAction: () => Navigator.of(
      context,
    ).pushNamed(ProfileIdentityRoutes.organizationSwitch),
  );
}
