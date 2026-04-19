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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: profileDisplayPaymentBillingSummaryStatus(
              data.privateSummary.summaryStatus,
            ),
            subtitle: '当前支付状态、账单引用与后续衔接摘要',
            detail: _paymentBillingHeaderDetail(data),
            avatarLabel: '账',
          ),
          if (profileFeatureStatusVisible) ...<Widget>[
            const SizedBox(height: 18),
            const ProfileFeatureStatusCard(
              snapshot: profilePaymentBillingFeatureStatus,
            ),
            const SizedBox(height: 14),
          ] else
            const SizedBox(height: 18),
          _ProfileListSection(
            title: '当前摘要',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前状态',
                value: profileDisplayPaymentBillingSummaryStatus(
                  data.privateSummary.summaryStatus,
                ),
              ),
              _ProfileValueRow(
                title: '当前支付状态',
                value: profileDisplayPaymentStatus(
                  data.privateSummary.paymentStatus,
                ),
              ),
              _ProfileValueRow(
                title: '当前账单引用',
                value: profileDisplayBillingReferenceStatus(
                  data.privateSummary.billingReferenceStatus,
                ),
              ),
              if (data.dependencyReference != null)
                _ProfileValueRow(
                  title: '后续依赖',
                  value: _paymentBillingDependencyReferenceHint(
                    data.dependencyReference,
                  ),
                ),
              _ProfileValueRow(
                title: '最近更新',
                value: data.privateSummary.updatedAt,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '支付状态',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前支付状态',
                value: profileDisplayPaymentStatus(
                  data.paymentStatus.paymentStatus,
                ),
              ),
              _ProfileValueRow(
                title: '当前可见性',
                value: profileDisplayPaymentAvailabilityStatus(
                  data.paymentStatus.paymentAvailabilityStatus,
                ),
              ),
              _ProfileValueRow(
                title: '处理提示',
                value: profileDisplayPaymentBillingHandoffHint(
                  data.paymentStatus.paymentHandoffKey,
                ),
              ),
              _ProfileValueRow(
                title: '说明提示',
                value: profileDisplayPaymentBillingExplanationHint(
                  data.paymentStatus.paymentExplanationKey,
                ),
              ),
              if (data.paymentStatus.paymentDependencyKey != null)
                _ProfileValueRow(
                  title: '后续依赖',
                  value: profileDisplayPaymentBillingDependencyHint(
                    data.paymentStatus.paymentDependencyKey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '账单引用',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前状态',
                value: profileDisplayBillingReferenceStatus(
                  data.billingReference.billingReferenceStatus,
                ),
              ),
              _ProfileValueRow(
                title: '显示状态',
                value: profileDisplayBillingReferenceVisibilityStatus(
                  data.billingReference.billingReferenceVisibilityStatus,
                ),
              ),
              _ProfileValueRow(
                title: '当前引用',
                value:
                    data.billingReference.billingReferenceCode ?? '当前账单引用暂未显示',
              ),
              _ProfileValueRow(
                title: '处理提示',
                value: profileDisplayPaymentBillingHandoffHint(
                  data.billingReference.billingHandoffKey,
                ),
              ),
              _ProfileValueRow(
                title: '说明提示',
                value: profileDisplayPaymentBillingExplanationHint(
                  data.billingReference.billingExplanationKey,
                ),
              ),
              if (data.billingReference.billingDependencyKey != null)
                _ProfileValueRow(
                  title: '后续依赖',
                  value: profileDisplayPaymentBillingDependencyHint(
                    data.billingReference.billingDependencyKey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '继续查看',
            children: <Widget>[
              _ProfileActionRow(
                title: '规则说明页',
                subtitle: '查看当前支付状态、账单引用与依赖说明',
                onTap: () => Navigator.of(context).push(
                  _profilePaymentBillingRoute(
                    title: '规则说明',
                    child: const ProfilePaymentBillingExplanationPage(),
                  ),
                ),
              ),
              _ProfileActionRow(
                title: '处理与衔接页',
                subtitle: '查看当前处理方向、后续依赖与衔接说明',
                onTap: () => Navigator.of(context).push(
                  _profilePaymentBillingRoute(
                    title: '处理与衔接',
                    child: const ProfilePaymentBillingHandoffPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _paymentBillingHeaderDetail(
    ProfilePaymentBillingStatusView data,
  ) {
    final pieces = <String>[
      profileDisplayPaymentStatus(data.privateSummary.paymentStatus),
      profileDisplayBillingReferenceStatus(
        data.privateSummary.billingReferenceStatus,
      ),
      if (data.dependencyReference?.dependencyRequired ?? false)
        _paymentBillingDependencyReferenceHint(data.dependencyReference),
    ];
    return pieces.join(' · ');
  }

  static String _paymentBillingDependencyReferenceHint(
    PaymentBillingDependencyReferenceView? dependencyReference,
  ) {
    if (dependencyReference == null ||
        !dependencyReference.dependencyRequired) {
      return '当前暂不需要额外依赖';
    }
    return '依赖 ${profileDisplayPaymentBillingDependencyFamily(dependencyReference.dependencyFamilyKey)}';
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
