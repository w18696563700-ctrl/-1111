part of '../exhibition_trade_pages.dart';

class BidSubmitPage extends StatefulWidget {
  const BidSubmitPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<BidSubmitPage> createState() => _BidSubmitPageState();
}

class _BidSubmitPageState extends State<BidSubmitPage> {
  late final TextEditingController _projectIdController = TextEditingController(
    text: widget.projectId ?? '',
  );
  final TextEditingController _quoteAmountController = TextEditingController();
  final TextEditingController _proposalSummaryController =
      TextEditingController();

  bool _guardLoading = true;
  _BidAccessGuard? _accessGuard;
  bool _guardInitialized = false;
  int _guardRetryCount = 0;
  bool _submitting = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionStageDataOrigin? _lastResultOrigin;

  @override
  void initState() {
    super.initState();
    if (_projectIdController.text.trim().isEmpty) {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.bidSubmit,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message:
            'projectId is required from route context or page context before bid submit',
      );
      _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guardInitialized) {
      return;
    }
    _guardInitialized = true;
    _loadAccessGuard();
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    _quoteAmountController.dispose();
    _proposalSummaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_guardLoading) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorRetryable,
          message: '当前正在核对竞标守卫，请稍候再试。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    final accessGuard = _accessGuard;
    if (accessGuard != null) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.forbidden,
          message: accessGuard.message,
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    final projectId = _projectIdController.text.trim();
    final quoteAmount = double.tryParse(_quoteAmountController.text.trim());
    final proposalSummary = _proposalSummaryController.text.trim();

    if (projectId.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '当前还没有承接到项目，暂时不能继续当前竞标。请先回到项目详情，再从当前项目继续进入。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    if (quoteAmount == null) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '请先填写有效的投标报价，再继续提交。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    if (proposalSummary.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '请先补充方案说明，再继续提交投标。',
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

    final result = await ExhibitionConsumerLayer.instance.submitBid(
      BidSubmitCommand(
        projectId: projectId,
        quoteAmount: quoteAmount,
        proposalSummary: proposalSummary,
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

  void _applyDemoBidResult() {
    if (_guardLoading || _accessGuard != null) {
      return;
    }

    final projectId = _projectIdController.text.trim().isEmpty
        ? ExhibitionStageDemoCatalog.demoProjectId
        : _projectIdController.text.trim();

    setState(() {
      _lastResult = ExhibitionStageDemoCatalog.bidSubmit(projectId: projectId);
      _lastResultOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeProjectId = _normalizeId(widget.projectId);
    final projectId = _normalizeId(_projectIdController.text);

    return _SubmissionPageFrame(
      title: '投标提交',
      summary: '这里是当前项目下的最小竞标继续面，只收口报价、方案说明和提交反馈，不扩到订单或后续链路。',
      canonicalPath: ExhibitionCanonicalPaths.bidSubmit,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      submitButtonLabel: '提交投标',
      showSubmitButton: !_guardLoading && _accessGuard == null,
      sourceLabel: '当前展示方式：优先显示已接通内容',
      sourceMessage: '默认优先展示已接通结果；这一步只保留最小竞标继续动作，如需不中断演示，也可以切换到演示内容继续讲解。',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildBidSubmitResultSections(
            context: context,
            result: result,
            projectId: projectId,
            lastResultOrigin: _lastResultOrigin,
          ),
      body: _buildBidSubmitBody(
        context: context,
        routeProjectId: routeProjectId,
        guardLoading: _guardLoading,
        accessGuard: _accessGuard,
        quoteAmountController: _quoteAmountController,
        proposalSummaryController: _proposalSummaryController,
        submitting: _submitting,
        onApplyDemoBidResult: _applyDemoBidResult,
      ),
    );
  }

  Future<void> _loadAccessGuard() async {
    if (!AppSessionStore.instance.hasAnySession) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _BidAccessGuard(
          title: '当前尚未登录',
          message: '继续竞标属于私域动作，当前需要先登录后再继续。',
          actionLabel: '进入登录入口',
          actionRouteName: ProfileIdentityRoutes.login,
        );
      });
      return;
    }

    final snapshot = AppShellScope.read(context).snapshot;
    final blockingState = snapshot.blockingState;
    if (blockingState == GlobalShellState.booting ||
        blockingState == GlobalShellState.sessionRefreshing) {
      if (_guardRetryCount >= 20) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _BidAccessGuard(
            title: '当前竞标守卫暂不可用',
            message: '当前壳层状态仍在准备中，请稍后重试。',
            actionLabel: '回到项目工作台',
            actionRouteName: ExhibitionRoutes.workbench,
          );
        });
        return;
      }

      _guardRetryCount += 1;
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) {
          return;
        }
        _loadAccessGuard();
      });
      return;
    }

    _guardRetryCount = 0;
    final accessGuard = _deriveBidAccessGuard(
      snapshot: snapshot,
      hasSession: AppSessionStore.instance.hasAnySession,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _guardLoading = false;
      _accessGuard = accessGuard;
    });
  }
}
