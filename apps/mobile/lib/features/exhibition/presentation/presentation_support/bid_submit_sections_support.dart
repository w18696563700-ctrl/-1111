part of '../exhibition_trade_pages.dart';

List<Widget> _buildBidSubmitResultSections({
  required BuildContext context,
  required ExhibitionActionResult result,
  required String? projectId,
  required ExhibitionStageDataOrigin? lastResultOrigin,
}) {
  final bidId = _bidIdFromPayload(result.payload);
  if (!result.isSuccess || bidId == null) {
    return const <Widget>[];
  }

  return <Widget>[
    const SizedBox(height: 16),
    _ActionCard(
      title: '竞标已提交',
      summary: lastResultOrigin == ExhibitionStageDataOrigin.demo
          ? '当前竞标结果来自演示内容，仅用于继续讲解当前页面，不代表真实链路已成功提交。'
          : '当前竞标已经完成最小提交。此轮成功走廊到 bidId 为止，不继续扩展订单或后续链路。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '投标 ID', value: bidId),
        if (lastResultOrigin == ExhibitionStageDataOrigin.demo) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前展示：演示内容',
            message: '当前提交结果来自演示内容，真实投标链路恢复后会自动切回已接通内容。',
          ),
        ],
        const SizedBox(height: 12),
        const _StateMessage(
          title: '当前结果',
          body: '竞标最小提交已经完成。当前页面只保留 bid 提交结果反馈。',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (projectId != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.projectDetailWithProjectId(projectId),
                  );
                },
                child: const Text('回到项目详情'),
              ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pushNamed(ExhibitionRoutes.showcase);
              },
              child: const Text('回到项目展示'),
            ),
          ],
        ),
      ],
    ),
  ];
}

List<Widget> _buildBidSubmitBody({
  required BuildContext context,
  required String? routeProjectId,
  required bool guardLoading,
  required _BidAccessGuard? accessGuard,
  required TextEditingController quoteAmountController,
  required TextEditingController proposalSummaryController,
  required bool submitting,
  required VoidCallback onApplyDemoBidResult,
}) {
  return <Widget>[
    if (guardLoading)
      const _ActionCard(
        title: '正在核对竞标守卫',
        summary: '正在检查当前登录、组织、认证与角色状态，请稍候。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _DetailLine(label: '当前状态', value: '守卫状态读取中，当前先不开放竞标提交。'),
        ],
      ),
    if (!guardLoading && accessGuard != null)
      _ActionCard(
        title: accessGuard.title,
        summary: accessGuard.message,
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          const _DetailLine(
            label: '守卫说明',
            value: '当前以登录态、组织态、认证状态和供应商角色作为前端导流守卫依据；最终业务权限仍以后端判定为准。',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(accessGuard.actionRouteName),
            child: Text(accessGuard.actionLabel),
          ),
        ],
      ),
    if (guardLoading || accessGuard != null) const SizedBox(height: 16),
    _ActionCard(
      title: '第一步 承接当前项目',
      summary: '最小竞标继续面会直接挂在当前项目下继续推进，所以这一步必须先承接到真实项目。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (routeProjectId != null)
          _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
        if (routeProjectId != null) const SizedBox(height: 12),
        const _StateMessage(title: '当前目标', body: '完成本次最小竞标提交并确认 bidId 结果。'),
        if (routeProjectId == null) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前不可继续',
            message: '当前没有承接到真实项目时，暂时不能继续真实竞标；如需演示，可直接使用演示结果继续讲解。',
          ),
        ],
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '第二步 补齐最小竞标信息',
      summary: '把本次报价和方案说明补充完整，当前最小竞标提交仅消费这两项输入。',
      children: <Widget>[
        _InputField(
          controller: quoteAmountController,
          label: '投标报价',
          keyboardType: TextInputType.number,
          hintText: '例如：1200',
          helperText: '填写当前投标报价。',
        ),
        _InputField(
          controller: proposalSummaryController,
          label: '方案说明',
          maxLines: 3,
          hintText: '例如：先完成展台结构、照明和基础安装',
          helperText: '简要说明当前投标方案的重点。',
        ),
      ],
    ),
    const SizedBox(height: 16),
    _ActionCard(
      title: '第三步 提交继续',
      summary: '当前页只保留现有提交动作和受控结果反馈，不扩成独立 BidWorkspace，也不提前放开后续链路。',
      children: <Widget>[
        const _DetailLine(label: '提交后承接', value: '成功后仅返回最小 bidId 结果。'),
        const _DetailLine(
          label: '当前边界',
          value: '本轮不扩比较台、结果披露、我的竞标、订单承接与后续履约链路。',
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: (submitting || guardLoading || accessGuard != null)
              ? null
              : onApplyDemoBidResult,
          child: const Text('使用演示投标继续讲解'),
        ),
      ],
    ),
  ];
}
