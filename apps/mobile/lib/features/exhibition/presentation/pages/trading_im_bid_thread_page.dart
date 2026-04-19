part of '../exhibition_trade_pages.dart';

class BidThreadPage extends StatefulWidget {
  const BidThreadPage({super.key, this.projectId, this.bidId});

  final String? projectId;
  final String? bidId;

  @override
  State<BidThreadPage> createState() => _BidThreadPageState();
}

class _BidThreadPageState extends State<BidThreadPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _confirmationSummaryController =
      TextEditingController();
  final List<String> _attachmentFileAssetIds = <String>[];
  TradingImResult<BidThreadDetailView>? _result;
  TradingImResult<BidThreadMessageView>? _lastMessageResult;
  TradingImResult<ConfirmationCardView>? _lastConfirmationResult;
  String _confirmationType = 'quote';
  String? _sourceMessageId;
  bool _loading = true;
  bool _sending = false;
  bool _creatingConfirmation = false;
  bool _uploading = false;
  String? _uploadMessage;

  String? get _projectId => _normalizeId(widget.projectId);
  String? get _bidId => _normalizeId(widget.bidId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _confirmationSummaryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await TradingImConsumerLayer.instance.loadBidThread(
      projectId: widget.projectId,
      bidId: widget.bidId,
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

  Future<void> _sendMessage() async {
    if (_sending) {
      return;
    }
    setState(() {
      _sending = true;
      _lastMessageResult = null;
    });
    final result = await TradingImConsumerLayer.instance.sendBidThreadMessage(
      projectId: widget.projectId,
      bidId: widget.bidId,
      body: _messageController.text,
      attachmentFileAssetIds: _attachmentFileAssetIds,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _sending = false;
      _lastMessageResult = result;
      if (result.isSuccess) {
        _messageController.clear();
        _attachmentFileAssetIds.clear();
        _sourceMessageId = result.data?.messageId;
      }
    });
    if (result.isSuccess) {
      await _load();
    }
  }

  Future<void> _createConfirmation() async {
    if (_creatingConfirmation) {
      return;
    }
    setState(() {
      _creatingConfirmation = true;
      _lastConfirmationResult = null;
    });
    final result = await TradingImConsumerLayer.instance.createConfirmationCard(
      projectId: widget.projectId,
      bidId: widget.bidId,
      confirmationType: _confirmationType,
      summary: _confirmationSummaryController.text,
      sourceMessageId: _sourceMessageId ?? '',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _creatingConfirmation = false;
      _lastConfirmationResult = result;
      if (result.isSuccess) {
        _confirmationSummaryController.clear();
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
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          const SizedBox(height: 8),
          _ActionCard(
            title: '沟通与投标',
            summary: '当前页只承接一个项目与一个投标之间的私密沟通。',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _DetailLine(label: '项目 ID', value: _projectId ?? '未承接'),
              _DetailLine(label: '投标 ID', value: _bidId ?? '未承接'),
              if (data != null)
                _DetailLine(label: '线程状态', value: data.state, highlight: true),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const _StateMessage(title: '正在加载', body: '请稍候片刻。')
          else if (result == null || result.state != AppPageState.content)
            _ActionCard(
              title: result?.message ?? '当前沟通线程暂不可用',
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
            _buildParticipants(data!),
            const SizedBox(height: 16),
            _buildMessageComposer(data),
            const SizedBox(height: 16),
            _buildConfirmationComposer(data),
            const SizedBox(height: 16),
            _buildMessages(data),
            const SizedBox(height: 16),
            _buildConfirmationCards(data),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipants(BidThreadDetailView data) {
    return _ActionCard(
      title: '参与方',
      children: <Widget>[
        for (final participant in data.participants)
          _DetailLine(
            label: _tradingImRoleLabel(participant.participantRole),
            value: participant.organizationId,
          ),
        if (data.viewerParticipantRole != null)
          _DetailLine(
            label: '当前身份',
            value: _tradingImRoleLabel(data.viewerParticipantRole!),
            highlight: true,
          ),
      ],
    );
  }

  Widget _buildMessageComposer(BidThreadDetailView data) {
    final canSend =
        data.availability.canSendMessage && !_sending && !_uploading;
    return _ActionCard(
      title: '发送消息',
      children: <Widget>[
        TextField(
          controller: _messageController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '沟通内容',
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
        if (_lastMessageResult != null &&
            !_lastMessageResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 8),
          _StateMessage(
            title: '发送未完成',
            body:
                _lastMessageResult!.message ??
                _lastMessageResult!.state.contractName,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: canSend ? _uploadAttachment : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(_uploading ? '上传中...' : '上传附件'),
            ),
            FilledButton.icon(
              onPressed: canSend ? _sendMessage : null,
              icon: const Icon(Icons.send_rounded),
              label: Text(_sending ? '发送中...' : '发送消息'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationComposer(BidThreadDetailView data) {
    final canCreate =
        data.availability.canCreateConfirmation &&
        !_creatingConfirmation &&
        _sourceMessageId != null;
    return _ActionCard(
      title: '最小确认卡',
      children: <Widget>[
        DropdownButtonFormField<String>(
          initialValue: _confirmationType,
          decoration: const InputDecoration(
            labelText: '确认类型',
            border: OutlineInputBorder(),
          ),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: 'quote', child: Text('报价确认')),
            DropdownMenuItem<String>(
              value: 'craft_material',
              child: Text('工艺材料确认'),
            ),
            DropdownMenuItem<String>(value: 'schedule', child: Text('排期确认')),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _confirmationType = value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmationSummaryController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '确认摘要',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _DetailLine(label: '来源消息', value: _sourceMessageId ?? '请先选择消息'),
        if (_lastConfirmationResult != null &&
            !_lastConfirmationResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 8),
          _StateMessage(
            title: '确认未完成',
            body:
                _lastConfirmationResult!.message ??
                _lastConfirmationResult!.state.contractName,
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: canCreate ? _createConfirmation : null,
          icon: const Icon(Icons.fact_check_rounded),
          label: Text(_creatingConfirmation ? '创建中...' : '创建确认卡'),
        ),
      ],
    );
  }

  Widget _buildMessages(BidThreadDetailView data) {
    if (data.messages.isEmpty) {
      return const _EmptyNotice(title: '当前还没有沟通消息', message: '可以从上方发送第一条消息。');
    }
    return Column(
      children: data.messages
          .map((BidThreadMessageView message) {
            final selected = message.messageId == _sourceMessageId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActionCard(
                title: _tradingImRoleLabel(message.senderRole),
                tone: selected
                    ? _ActionCardTone.emphasis
                    : _ActionCardTone.standard,
                children: <Widget>[
                  _DetailLine(label: '内容', value: message.body),
                  _DetailLine(
                    label: '附件',
                    value: _tradingImAttachmentText(
                      message.attachmentFileAssetIds,
                    ),
                  ),
                  _DetailLine(label: '时间', value: message.createdAt),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _sourceMessageId = message.messageId),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(selected ? '已选为确认来源' : '用于确认卡'),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildConfirmationCards(BidThreadDetailView data) {
    if (data.confirmationCards.isEmpty) {
      return const _EmptyNotice(title: '当前还没有确认卡', message: '确认卡会绑定到所选来源消息。');
    }
    return Column(
      children: data.confirmationCards
          .map((ConfirmationCardView card) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActionCard(
                title: _confirmationTypeLabel(card.confirmationType),
                children: <Widget>[
                  _DetailLine(label: '摘要', value: card.summary),
                  _DetailLine(label: '来源消息', value: card.sourceMessageId),
                  _DetailLine(label: '时间', value: card.createdAt),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
