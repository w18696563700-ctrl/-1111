part of '../exhibition_trade_pages.dart';

class ProjectClarificationPage extends StatefulWidget {
  const ProjectClarificationPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<ProjectClarificationPage> createState() =>
      _ProjectClarificationPageState();
}

class _ProjectClarificationPageState extends State<ProjectClarificationPage> {
  final TextEditingController _bodyController = TextEditingController();
  final List<String> _attachmentFileAssetIds = <String>[];
  TradingImResult<ProjectClarificationListView>? _result;
  TradingImResult<ProjectClarificationItemView>? _lastSubmit;
  bool _loading = true;
  bool _submitting = false;
  bool _uploading = false;
  String? _uploadMessage;

  String? get _projectId => _normalizeId(widget.projectId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await TradingImConsumerLayer.instance.loadClarifications(
      projectId: widget.projectId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _uploadAttachment() async {
    final projectId = _projectId;
    if (projectId == null || _uploading) {
      return;
    }
    setState(() {
      _uploading = true;
      _uploadMessage = '正在准备沟通附件。';
    });
    final outcome = await _uploadTradingImAttachment(
      projectId: projectId,
      onProgress: (String message) {
        if (mounted) {
          setState(() => _uploadMessage = message);
        }
      },
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _uploading = false;
      _uploadMessage = outcome.message;
      if (outcome.fileAssetId case final String fileAssetId) {
        if (!_attachmentFileAssetIds.contains(fileAssetId)) {
          _attachmentFileAssetIds.add(fileAssetId);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _lastSubmit = null;
    });
    final result = await TradingImConsumerLayer.instance.createClarification(
      projectId: widget.projectId,
      body: _bodyController.text,
      attachmentFileAssetIds: _attachmentFileAssetIds,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _lastSubmit = result;
      if (result.isSuccess) {
        _bodyController.clear();
        _attachmentFileAssetIds.clear();
      }
    });
    if (result.isSuccess) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    final projectId = _projectId;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          const SizedBox(height: 8),
          _ActionCard(
            title: '项目澄清',
            summary: '公开澄清只绑定当前项目；附件只提交已确认的 FileAsset ID。',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _DetailLine(label: '项目 ID', value: projectId ?? '未承接'),
              if (data != null)
                _DetailLine(
                  label: '提交状态',
                  value: data.canCreate ? '可提交' : data.reason ?? '只读',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const _StateMessage(title: '正在加载', body: '请稍候片刻。')
          else if (result == null || result.state != AppPageState.content)
            _ActionCard(
              title: result?.message ?? '当前项目澄清暂不可用',
              children: <Widget>[
                _StateMessage(
                  title: '受控状态',
                  body:
                      result?.errorCode ??
                      result?.state.contractName ??
                      'unknown',
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(onPressed: _load, child: const Text('重试')),
              ],
            )
          else ...<Widget>[
            _buildComposer(data!),
            const SizedBox(height: 16),
            if (data.items.isEmpty)
              const _EmptyNotice(
                title: '当前还没有项目澄清',
                message: '有新的项目问题时，可以从上方提交。',
              )
            else
              ...data.items.map(_buildClarificationItem),
          ],
        ],
      ),
    );
  }

  Widget _buildComposer(ProjectClarificationListView data) {
    final canSubmit =
        data.canCreate && !_submitting && !_uploading && _projectId != null;
    return _ActionCard(
      title: '新增澄清',
      children: <Widget>[
        TextField(
          controller: _bodyController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '澄清内容',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _DetailLine(
          label: '已确认附件',
          value: _tradingImAttachmentText(_attachmentFileAssetIds),
        ),
        if (_uploadMessage != null) ...<Widget>[
          const SizedBox(height: 8),
          _StateMessage(title: '附件状态', body: _uploadMessage!),
        ],
        if (_lastSubmit != null && !_lastSubmit!.isSuccess) ...<Widget>[
          const SizedBox(height: 8),
          _StateMessage(
            title: '提交未完成',
            body: _lastSubmit!.message ?? _lastSubmit!.state.contractName,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: canSubmit ? _uploadAttachment : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(_uploading ? '上传中...' : '上传附件'),
            ),
            FilledButton.icon(
              onPressed: canSubmit ? _submit : null,
              icon: const Icon(Icons.send_rounded),
              label: Text(_submitting ? '提交中...' : '提交澄清'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClarificationItem(ProjectClarificationItemView item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _ActionCard(
        title: _tradingImRoleLabel(item.authorRole),
        children: <Widget>[
          _DetailLine(label: '内容', value: item.body),
          _DetailLine(
            label: '附件',
            value: _tradingImAttachmentText(item.attachmentFileAssetIds),
          ),
          _DetailLine(label: '状态', value: item.state),
          _DetailLine(label: '时间', value: item.createdAt),
        ],
      ),
    );
  }
}
