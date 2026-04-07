part of '../exhibition_trade_pages.dart';

class MilestoneSubmitPage extends StatefulWidget {
  const MilestoneSubmitPage({super.key, this.milestoneId});

  final String? milestoneId;

  @override
  State<MilestoneSubmitPage> createState() => _MilestoneSubmitPageState();
}

class _MilestoneSubmitPageState extends State<MilestoneSubmitPage> {
  late final TextEditingController _milestoneIdController =
      TextEditingController(text: widget.milestoneId ?? '');
  final TextEditingController _submissionNoteController =
      TextEditingController();
  final TextEditingController _uploadPayloadController = TextEditingController(
    text: '现场照片、节点确认单、材料进场记录',
  );

  bool _submitting = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionStageDataOrigin? _lastResultOrigin;
  AppUploadState? _uploadState;
  String? _uploadMessage;
  String? _uploadErrorCode;
  String? _uploadPath;
  UploadDirective? _uploadDirective;

  @override
  void initState() {
    super.initState();
    if (_milestoneIdController.text.trim().isEmpty) {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.milestoneSubmit,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message:
            'milestoneId is required from route context or page context before milestone submit',
      );
      _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
    }
  }

  @override
  void dispose() {
    _milestoneIdController.dispose();
    _submissionNoteController.dispose();
    _uploadPayloadController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final milestoneId = _milestoneIdController.text.trim();
    if (milestoneId.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.milestoneSubmit,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          message: 'milestoneId is required from route context or page context',
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

    final result = await ExhibitionConsumerLayer.instance.submitMilestone(
      MilestoneSubmitCommand(
        milestoneId: milestoneId,
        submissionNote: _submissionNoteController.text.trim(),
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
    final milestoneId = _milestoneIdController.text.trim().isEmpty
        ? ExhibitionStageDemoCatalog.demoMilestoneId
        : _milestoneIdController.text.trim();

    setState(() {
      _lastResult = ExhibitionStageDemoCatalog.milestoneSubmit(
        milestoneId: milestoneId,
      );
      _lastResultOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  Future<void> _runUpload() async {
    final businessId = _milestoneIdController.text.trim();
    final payload = _uploadPayloadController.text.trim();
    final payloadBytes = utf8.encode(payload);

    setState(() {
      _uploadState = AppUploadState.localValidating;
      _uploadMessage = '正在准备当前补充凭证';
      _uploadErrorCode = null;
      _uploadPath = ExhibitionCanonicalPaths.uploadInit;
    });

    if (businessId.isEmpty || payload.isEmpty) {
      setState(() {
        _uploadState = AppUploadState.uploadFailedRetryable;
        _uploadMessage = '请先承接当前里程碑，并补充一段凭证摘要，再继续上传。';
      });
      return;
    }

    final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: 'milestone',
        businessId: businessId,
        fileKind: 'evidence',
        mimeType: 'text/plain',
        size: payloadBytes.length,
        checksum: _derivedChecksum(payload),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _uploadState = initResult.state;
      _uploadMessage = initResult.message;
      _uploadErrorCode = initResult.errorCode;
      _uploadPath = initResult.path;
      _uploadDirective = initResult.directive;
    });

    final directive = initResult.directive;
    if (initResult.state != AppUploadState.signedReady || directive == null) {
      return;
    }

    setState(() {
      _uploadState = AppUploadState.uploading;
      _uploadMessage = '正在发送当前补充凭证';
      _uploadErrorCode = null;
      _uploadPath = directive.directUploadUrl;
    });

    final uploadResult = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: payloadBytes,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _uploadState = uploadResult.state;
      _uploadMessage = uploadResult.message;
      _uploadErrorCode = uploadResult.errorCode;
      _uploadPath = uploadResult.path;
    });

    if (uploadResult.state != AppUploadState.uploadConfirming) {
      return;
    }

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _uploadState = confirmResult.state;
      _uploadMessage = confirmResult.message;
      _uploadErrorCode = confirmResult.errorCode;
      _uploadPath = confirmResult.path;
    });
  }

  String _derivedChecksum(String payload) {
    return 'demo-${payload.length}-${payload.hashCode.abs()}';
  }

  @override
  Widget build(BuildContext context) {
    final routeMilestoneId = _normalizeId(widget.milestoneId);

    return _SubmissionPageFrame(
      title: '里程碑提交',
      summary: '这里处理当前里程碑的提交动作。页面会把节点说明、提交结果和补充凭证整理成完整履约界面，不再像测试表单。',
      canonicalPath: ExhibitionCanonicalPaths.milestoneSubmit,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      submitButtonLabel: '提交里程碑',
      sourceLabel: '当前展示方式：优先显示已接通内容',
      sourceMessage: '默认优先展示已接通结果；如需不中断演示，也可以切换到演示内容继续讲解。',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildResultSections(context, result, routeMilestoneId),
      body: _buildBody(routeMilestoneId),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionActionResult result,
    String? routeMilestoneId,
  ) {
    final continuationMilestoneId =
        _normalizeId(_payloadMap(result.payload)?['milestoneId'] as String?) ??
        routeMilestoneId;
    if (!result.isSuccess || continuationMilestoneId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '里程碑已提交',
        summary: _lastResultOrigin == ExhibitionStageDataOrigin.demo
            ? '当前结果来自演示内容。后续仍可继续讲解验收详情和验收提交，但不代表真实提交链路已通。'
            : '当前里程碑已经进入下一步承接面，后续可以继续查看当前验收详情。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          if (_lastResultOrigin == ExhibitionStageDataOrigin.demo) ...<Widget>[
            const _EmptyNotice(
              title: '当前展示：演示内容',
              message: '当前提交结果只用于继续讲解前端界面，真实提交链路恢复后会自动切回已接通内容。',
            ),
            const SizedBox(height: 12),
          ],
          const _StateMessage(
            title: '提交后如何继续',
            body: '后续验收入口会继续沿用当前里程碑上下文，不需要重新承接实例。',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                ExhibitionRoutes.inspectionDetailWithMilestoneId(
                  continuationMilestoneId,
                ),
              );
            },
            child: const Text('去验收详情'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildBody(String? routeMilestoneId) {
    return <Widget>[
      _ActionCard(
        title: '提交前先确认',
        summary: '先确认当前里程碑上下文，再完成本次提交。里程碑提交成功后，这条链路会自然继续到验收详情。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          if (routeMilestoneId != null)
            _InstanceSummaryLine(title: '当前里程碑 ID', value: routeMilestoneId),
          if (routeMilestoneId != null) const SizedBox(height: 12),
          const _StateMessage(title: '当前目标', body: '完成当前里程碑提交，并在需要时补充上传凭证。'),
          if (routeMilestoneId == null) ...<Widget>[
            const SizedBox(height: 12),
            const _EmptyNotice(
              title: '当前不可继续',
              message: '当前没有承接到真实里程碑时，暂时不能继续真实提交；如需演示，可直接使用演示结果继续讲解。',
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '提交说明',
        summary: '可补充当前里程碑提交说明，帮助后续验收继续承接当前链路。',
        children: <Widget>[
          _InputField(
            controller: _submissionNoteController,
            label: '提交说明（选填）',
            maxLines: 3,
            hintText: '例如：当前节点材料已经到场，施工确认无误',
            helperText: '可补充本次里程碑提交的说明。',
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _submitting ? null : _applyDemoResult,
            child: const Text('使用演示里程碑结果继续讲解'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '补充凭证',
        summary: '如果客户想继续看“节点资料如何补齐”，这里可以直接演示真实上传链路，但页面不会暴露技术字段。',
        children: <Widget>[
          _InputField(
            controller: _uploadPayloadController,
            label: '凭证摘要',
            helperText: '可填写当前准备上传的照片、节点单据或现场说明。',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _runUpload,
            child: const Text('补充当前凭证'),
          ),
          const SizedBox(height: 12),
          _UploadStatePanel(
            state: _uploadState,
            path: _uploadPath,
            message: _uploadMessage,
            errorCode: _uploadErrorCode,
            uploadDirective: _uploadDirective,
          ),
        ],
      ),
    ];
  }
}
