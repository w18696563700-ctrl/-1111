part of 'profile_detail_pages.dart';

class ProfileMembershipPaymentResultPage extends StatefulWidget {
  const ProfileMembershipPaymentResultPage({
    super.key,
    required this.order,
    required this.payInitResult,
  });

  final ProfileMembershipOrderCreateView order;
  final ProfileMembershipResult<ProfileMembershipPayInitView> payInitResult;

  @override
  State<ProfileMembershipPaymentResultPage> createState() =>
      _ProfileMembershipPaymentResultPageState();
}

class _ProfileMembershipPaymentResultPageState
    extends State<ProfileMembershipPaymentResultPage> {
  bool _loadingOrder = true;
  ProfileMembershipResult<ProfileMembershipOrderResultView>? _orderResult;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _loadingOrder = true);
    final result = await ProfileMembershipPurchaseConsumerLayer.instance
        .loadOrder(widget.order.membershipOrderId);
    if (!mounted) {
      return;
    }
    setState(() {
      _orderResult = result;
      _loadingOrder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final payInit = widget.payInitResult.data;
    final orderResult = _orderResult;
    final order = orderResult?.data;
    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '会员支付结果',
            subtitle: _membershipPaymentResultSubtitle(widget.payInitResult),
            detail:
                '订单 ${widget.order.membershipOrderId} · 订单状态只读展示，不在 Flutter 生成会员真相。',
            avatarLabel: '付',
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '支付初始化',
            children: <Widget>[
              _ProfileValueRow(
                title: '初始化状态',
                value: payInit == null
                    ? profileVisibleReadMessage(
                        state: widget.payInitResult.state,
                        rawMessage: widget.payInitResult.message,
                        surfaceLabel: '支付初始化',
                      )
                    : _membershipStatusLabel(payInit.paymentInitStatus),
              ),
              _ProfileValueRow(
                title: '支付引用',
                value: profileValueOrFallback(
                  payInit?.paymentReferenceId,
                  '当前暂未提供',
                ),
              ),
              _ProfileValueRow(
                title: '通道动作',
                value: profileValueOrFallback(
                  payInit?.channelActionType,
                  '当前暂未提供',
                ),
              ),
              _ProfileValueRow(
                title: '等待回调',
                value: payInit?.callbackAwaiting == true ? '是' : '否',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '订单状态只读',
            children: _membershipOrderRows(
              loading: _loadingOrder,
              orderResult: orderResult,
              order: order,
            ),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '后续动作',
            children: <Widget>[
              _ProfileActionRow(
                title: '刷新订单状态',
                subtitle: '只读查询 Server 返回的会员订单状态与权益状态。',
                onTap: _loadOrder,
              ),
              _ProfileActionRow(
                title: '返回我的会员',
                subtitle: '查看当前会员读态是否已由 Server 生效。',
                onTap: () => Navigator.of(context).pushReplacement(
                  _profileMembershipRoute(
                    title: '我的会员',
                    child: const ProfileMembershipCurrentPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<Widget> _membershipOrderRows({
  required bool loading,
  required ProfileMembershipResult<ProfileMembershipOrderResultView>?
  orderResult,
  required ProfileMembershipOrderResultView? order,
}) {
  if (loading || orderResult == null) {
    return const <Widget>[_ProfileValueRow(title: '订单状态', value: '正在读取订单状态')];
  }
  if (orderResult.state != AppPageState.content || order == null) {
    return <Widget>[
      _ProfileValueRow(
        title: '订单状态',
        value: profileVisibleReadMessage(
          state: orderResult.state,
          rawMessage: orderResult.message,
          surfaceLabel: '会员订单',
        ),
      ),
    ];
  }
  return <Widget>[
    _ProfileValueRow(
      title: '订单状态',
      value: _membershipStatusLabel(order.orderStatus),
    ),
    _ProfileValueRow(
      title: '支付状态',
      value: _membershipStatusLabel(order.paymentStatus),
    ),
    _ProfileValueRow(
      title: '权益状态',
      value: _membershipStatusLabel(order.entitlementStatus),
    ),
    _ProfileValueRow(
      title: '生效时间',
      value: profileValueOrFallback(order.effectiveAt, '尚未生效'),
    ),
    _ProfileValueRow(
      title: '到期时间',
      value: profileValueOrFallback(order.expiresAt, '当前暂未提供'),
    ),
  ];
}
