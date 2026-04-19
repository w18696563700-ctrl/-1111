part of '../exhibition_trade_pages.dart';

class DisputeOpenPage extends StatefulWidget {
  const DisputeOpenPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<DisputeOpenPage> createState() => _DisputeOpenPageState();
}

class _DisputeOpenPageState extends State<DisputeOpenPage> {
  late final TextEditingController _orderIdController = TextEditingController(
    text: widget.orderId ?? '',
  );
  final TextEditingController _reasonController = TextEditingController();

  bool _submitting = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionStageDataOrigin? _lastResultOrigin;

  @override
  void initState() {
    super.initState();
    if (_orderIdController.text.trim().isEmpty) {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.disputeOpen,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message: 'orderId is required from route context before dispute open',
      );
      _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.disputeOpen,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          message: 'orderId is required from route context before dispute open',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
      _lastResultOrigin = null;
    });

    final result = await ExhibitionConsumerLayer.instance.openDispute(
      DisputeOpenCommand(
        orderId: orderId,
        reason: _reasonController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
      _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
    });
  }

  void _applyDemoResult() {
    final orderId = _orderIdController.text.trim().isEmpty
        ? ExhibitionStageDemoCatalog.demoOrderId
        : _orderIdController.text.trim();

    setState(() {
      _lastResult = ExhibitionStageDemoCatalog.disputeOpen(orderId: orderId);
      _lastResultOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final resultState = _stateFromPayload(_lastResult?.payload);
    final resultSummary = _payloadMap(_lastResult?.payload)?['summary'];
    final currentStateMessage = switch (resultState) {
      'accepted' => '当前状态：争议开启入口已经受理，这一页继续保留最小结果承接。',
      'opened' => '当前状态：当前结果来自演示已开启内容，这一页继续保留最小结果承接。',
      _ when routeOrderId != null && _lastResult == null =>
        '当前状态：已承接订单上下文，正在等待本次争议开启续接受理。',
      _ when routeOrderId != null => '当前状态：本次续接受理结果已返回，是否还能继续以后端结果为准。',
      _ => '当前状态：缺少 orderId，上下文不足以继续开启争议。',
    };
    final actionMessage = routeOrderId != null
        ? '当前动作：可以继续把当前订单上下文交给争议开启入口；页面不会本地补做资格、范围或治理判断。'
        : '当前动作：当前不可继续，请先恢复订单上下文。';

    return _SubmissionPageFrame(
      title: '争议开启入口',
      summary:
          '这里用于在当前订单下继续争议开启的 shell / handoff。页面只受理当前订单上下文和结果承接，不把本页写成 dispute truth 已创建。',
      canonicalPath: ExhibitionCanonicalPaths.disputeOpen,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      showSubmitButton: false,
      sourceLabel: '当前展示方式：优先显示已接通内容',
      sourceMessage: '默认优先展示已接通结果；如需不中断演示，也可以切换到演示内容继续讲解当前边界页。',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildResultSections(
            result,
            routeOrderId,
            resultState,
            resultSummary,
          ),
      body: _buildBody(routeOrderId, currentStateMessage, actionMessage),
    );
  }

  List<Widget> _buildResultSections(
    ExhibitionActionResult result,
    String? routeOrderId,
    String? resultState,
    Object? resultSummary,
  ) {
    final disputeId = _disputeIdFromPayload(result.payload);
    final orderId = _orderIdFromPayload(result.payload) ?? routeOrderId;
    if (!result.isSuccess || orderId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '争议开启入口已受理',
        summary: _lastResultOrigin == ExhibitionStageDataOrigin.demo
            ? '当前结果来自演示内容。页面会继续展示争议已开启后的样子，但不代表真实争议链路已经联通。'
            : '争议开启入口已经受理。当前页继续保留结果承接，只补最小撤回续接，不把争议 truth 写成完整工作流。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
          if (disputeId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前争议 ID', value: disputeId),
          ],
          if (_lastResultOrigin == ExhibitionStageDataOrigin.demo) ...<Widget>[
            const SizedBox(height: 12),
            const _EmptyNotice(
              title: '当前展示：演示内容',
              message: '当前结果只用于继续讲解边界页面，真实链路恢复后会自动切回已接通内容。',
            ),
          ],
          if (resultState != null) ...<Widget>[
            const SizedBox(height: 12),
            _DetailLine(
              label: '当前状态',
              value: _frontStageStateLabel(resultState),
              highlight: true,
            ),
          ],
          if (resultSummary is Map)
            const _DetailLine(
              label: '当前说明',
              value: '争议开启入口已经受理，当前页继续保留边界续接结果。',
            ),
          if (_lastResultOrigin == ExhibitionStageDataOrigin.futureReal &&
              _lastResult?.isSuccess == true) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ExhibitionRoutes.disputeWithdrawWithOrderId(orderId),
                );
              },
              child: const Text('去争议撤回'),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '提交后如何继续',
        summary: _lastResultOrigin == ExhibitionStageDataOrigin.futureReal &&
                _lastResult?.isSuccess == true
            ? '当前首发阶段只补最小撤回续接。撤回后仍停留在边界结果承接，不扩成争议工作台。'
            : '当前首发阶段先把争议开启做成 shell / handoff 入口，只有在真实受理后才开放最小撤回续接。',
        children: <Widget>[
          _StateMessage(
            title: '当前能做什么',
            body: _lastResultOrigin == ExhibitionStageDataOrigin.futureReal &&
                    _lastResult?.isSuccess == true
                ? '当前页会继续展示已受理结果，并允许进入最小争议撤回入口。'
                : '当前页会继续展示已受理结果，帮助客户确认争议开启已经进入受控承接面。',
          ),
          const SizedBox(height: 12),
          _EmptyNotice(
            title: '当前边界',
            message: _lastResultOrigin == ExhibitionStageDataOrigin.futureReal &&
                    _lastResult?.isSuccess == true
                ? '当前只开放最小争议撤回；协商、平台审理、升级和裁决仍不继续开放。'
                : '争议撤回、协商、平台审理、升级和裁决当前阶段都不继续开放动作。',
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildBody(
    String? routeOrderId,
    String currentStateMessage,
    String actionMessage,
  ) {
    return <Widget>[
      _ActionCard(
        title: '争议说明',
        summary: '如需补充原因，可在这里填写一段当前争议背景。未填写也不会扩成第二套判断逻辑。',
        eyebrow: '动作说明',
        children: <Widget>[
          _InputField(
            controller: _reasonController,
            label: '争议说明（选填）',
            maxLines: 3,
            hintText: 'reason (optional)',
            helperText: '用于补充当前为何需要开启争议。',
          ),
          FilledButton(
            key: const ValueKey<String>('dispute_open_submit_button'),
            onPressed: _submitting ? null : _submit,
            child: const Text('继续争议开启'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _submitting ? null : _applyDemoResult,
            child: const Text('使用演示争议结果继续讲解'),
          ),
          if (routeOrderId == null) ...<Widget>[
            const SizedBox(height: 12),
            const _EmptyNotice(
              title: '当前不可继续',
              message: '当前没有承接到真实订单时，暂时不能继续真实争议开启；如需演示，可直接使用演示结果继续讲解。',
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '开启前先确认',
        summary: '争议入口只依赖当前订单上下文，不会本地补做资格、范围或治理判断，也不在本页创建新的 dispute truth。',
        tone: _ActionCardTone.emphasis,
        eyebrow: '当前边界页',
        children: <Widget>[
          _StateMessage(title: '当前状态', body: currentStateMessage),
          const SizedBox(height: 12),
          _StateMessage(title: '当前动作', body: actionMessage),
          const SizedBox(height: 12),
          const _DetailLine(
            label: '为什么现在允许开',
            value: '当前订单已经承接到争议入口，所以这一页可以展示 shell / handoff 动作和结果承接。',
          ),
          if (routeOrderId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
          ],
        ],
      ),
      const SizedBox(height: 16),
      const _ActionCard(
        title: '这一步意味着什么',
        summary: '争议开启入口受理后，页面会保留结果承接；如有真实受理结果，可继续进入最小撤回入口，但不会继续扩成治理台。',
        eyebrow: '边界说明',
        children: <Widget>[
          _DetailLine(label: '受理后能看到什么', value: '可以看到争议开启入口已受理结果、当前状态和当前说明。'),
          _DetailLine(label: '当前不能做什么', value: '协商、升级、平台审理和历史列表仍保持冻结。'),
          _DetailLine(label: '下一步怎么继续', value: '真实受理后可以进入最小撤回入口；演示时继续停留在已受理结果页。'),
        ],
      ),
    ];
  }
}
