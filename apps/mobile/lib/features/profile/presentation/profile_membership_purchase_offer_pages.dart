part of 'profile_detail_pages.dart';

class ProfileMembershipPurchaseOffersPage extends StatefulWidget {
  const ProfileMembershipPurchaseOffersPage({super.key});

  @override
  State<ProfileMembershipPurchaseOffersPage> createState() =>
      _ProfileMembershipPurchaseOffersPageState();
}

class _ProfileMembershipPurchaseOffersPageState
    extends State<ProfileMembershipPurchaseOffersPage> {
  bool _loading = true;
  ProfileMembershipResult<ProfileMembershipPurchaseOffersView>? _result;

  @override
  void initState() {
    super.initState();
    if (RcReleaseFlags.membershipPurchaseEnabled) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileMembershipPurchaseConsumerLayer.instance
        .loadPurchaseOffers();
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
    if (!RcReleaseFlags.membershipPurchaseEnabled) {
      return const _ProfileScreenStatePanel(
        title: rcFeatureUnavailableTitle,
        message: '当前 RC 版本只保留会员当前态、权益与配额只读展示，会员真实购买暂未开放。',
      );
    }
    if (!AppSessionStore.instance.hasAnySession) {
      return _ProfileScreenStatePanel(
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，会员直购页不展示伪造购买能力。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取会员套餐',
        message: '正在同步标准会员、专业会员与首轮支付通道。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '会员直购当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '会员直购',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    final contextView = data.currentOrganizationMembershipContext;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '会员直购最小闭环',
            subtitle: '标准会员 2599 元/年，专业会员 4599 元/年',
            detail: '支付宝为首轮优先通道；微信支付仅保留/灰度，不作为默认购买入口。',
            avatarLabel: '购',
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前购买边界',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前组织',
                value: profileValueOrFallback(
                  contextView.organizationId,
                  '当前暂未提供',
                ),
              ),
              _ProfileValueRow(
                title: '当前付费档位',
                value: profileDisplayPaidMembershipTier(
                  contextView.paidMembershipTier,
                ),
              ),
              _ProfileValueRow(
                title: '购买资格',
                value: contextView.purchaseEligible ? '允许创建新购订单' : '当前不可购买',
              ),
              if (!contextView.purchaseEligible)
                _ProfileValueRow(
                  title: '不可购买原因',
                  value: profileValueOrFallback(
                    contextView.ineligibleReasonCode,
                    '当前暂未提供',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '可购买套餐',
            children: data.offers
                .map(
                  (ProfileMembershipPurchaseOfferView offer) =>
                      _ProfileActionRow(
                        title: _membershipPurchaseOfferTitle(offer),
                        subtitle: _membershipPurchaseOfferSubtitle(offer),
                        emphasized:
                            offer.membershipTier == 'standard' &&
                            contextView.purchaseEligible,
                        onTap: contextView.purchaseEligible && offer.available
                            ? () => Navigator.of(context).push(
                                _profileMembershipRoute(
                                  title: '套餐确认',
                                  child: ProfileMembershipPackageConfirmPage(
                                    offer: offer,
                                    channelCandidates: data.channelCandidates,
                                    commercialDisclosure:
                                        data.commercialDisclosure,
                                  ),
                                ),
                              )
                            : null,
                      ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '支付通道',
            children: <Widget>[
              _ProfileValueRow(
                title: '支付宝',
                value: data.channelCandidates.contains('alipay_candidate')
                    ? '首轮优先通道'
                    : '当前暂未提供',
              ),
              _ProfileValueRow(
                title: '微信支付',
                value: data.channelCandidates.contains('wechat_candidate')
                    ? '保留/灰度通道，当前不作为默认入口'
                    : '当前暂未提供',
              ),
              _ProfileValueRow(title: '商业说明', value: data.commercialDisclosure),
            ],
          ),
        ],
      ),
    );
  }
}
