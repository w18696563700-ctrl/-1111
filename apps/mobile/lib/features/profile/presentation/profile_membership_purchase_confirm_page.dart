part of 'profile_detail_pages.dart';

class ProfileMembershipPackageConfirmPage extends StatefulWidget {
  const ProfileMembershipPackageConfirmPage({
    super.key,
    required this.offer,
    required this.channelCandidates,
    required this.commercialDisclosure,
  });

  final ProfileMembershipPurchaseOfferView offer;
  final List<String> channelCandidates;
  final String commercialDisclosure;

  @override
  State<ProfileMembershipPackageConfirmPage> createState() =>
      _ProfileMembershipPackageConfirmPageState();
}

class _ProfileMembershipPackageConfirmPageState
    extends State<ProfileMembershipPackageConfirmPage> {
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _startAlipay() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final createResult = await ProfileMembershipPurchaseConsumerLayer.instance
        .createOrder(offer: widget.offer);
    if (!mounted) {
      return;
    }
    final created = createResult.data;
    if (createResult.state != AppPageState.content || created == null) {
      setState(() {
        _submitting = false;
        _errorMessage = profileVisibleReadMessage(
          state: createResult.state,
          rawMessage: createResult.message,
          surfaceLabel: '会员订单创建',
        );
      });
      return;
    }

    final payInitResult = await ProfileMembershipPurchaseConsumerLayer.instance
        .payInit(
          membershipOrderId: created.membershipOrderId,
          payChannel: 'alipay_candidate',
        );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    await Navigator.of(context).pushReplacement(
      _profileMembershipRoute(
        title: '支付结果',
        child: ProfileMembershipPaymentResultPage(
          order: created,
          payInitResult: payInitResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final alipayAvailable = widget.channelCandidates.contains(
      'alipay_candidate',
    );
    final wechatRetained = widget.channelCandidates.contains(
      'wechat_candidate',
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: profileDisplayPaidMembershipTier(offer.membershipTier),
          subtitle: _membershipPurchasePriceText(offer),
          detail: offer.serviceFeeDiscountSummary ?? '会员服务费优惠当前暂未提供，不展示旧固定费率。',
          avatarLabel: '套',
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '套餐确认',
          children: <Widget>[
            _ProfileValueRow(title: 'SKU', value: offer.skuName),
            _ProfileValueRow(
              title: '购买周期',
              value: '${offer.durationMonths} 个月',
            ),
            _ProfileValueRow(
              title: '应付金额',
              value: _membershipMoney(offer.priceAmount, offer.currency),
            ),
            _ProfileValueRow(
              title: '服务费优惠',
              value: offer.serviceFeeDiscountSummary ?? '当前暂未提供，不展示旧固定费率。',
            ),
            _ProfileValueRow(
              title: '续费/退款/发票',
              value: '本轮暂不开通；仅创建新购订单并等待支付回调生效。',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '支付入口',
          children: <Widget>[
            _ProfileActionRow(
              title: _submitting ? '正在初始化支付宝支付' : '支付宝支付',
              subtitle: alipayAvailable
                  ? '首轮优先通道；支付成功后等待 Server 回调写入会员权益。'
                  : '当前支付宝通道暂未提供。',
              emphasized: alipayAvailable,
              onTap: alipayAvailable && !_submitting ? _startAlipay : null,
              trailing: _submitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            _ProfileActionRow(
              title: '微信支付（保留/灰度）',
              subtitle: wechatRetained
                  ? '当前只展示为保留通道，不作为首轮默认支付入口。'
                  : '当前微信支付通道暂未提供。',
              onTap: null,
              trailing: const Text('保留'),
            ),
          ],
        ),
        if (_errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前错误',
            children: <Widget>[
              _ProfileValueRow(title: '处理结果', value: _errorMessage!),
            ],
          ),
        ],
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '购买说明',
          children: <Widget>[
            _ProfileValueRow(title: '说明', value: widget.commercialDisclosure),
            const _ProfileValueRow(
              title: '旧费率',
              value: '不展示旧固定费率，不按成交金额固定百分比计算。',
            ),
          ],
        ),
      ],
    );
  }
}
