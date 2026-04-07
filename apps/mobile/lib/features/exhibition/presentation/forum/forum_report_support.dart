part of 'forum_pages.dart';

class _ForumReportReasonOption {
  const _ForumReportReasonOption({required this.code, required this.label});

  final String code;
  final String label;
}

const List<_ForumReportReasonOption> _forumReportReasonOptions =
    <_ForumReportReasonOption>[
      _ForumReportReasonOption(code: 'ad_or_solicitation', label: '广告 / 导流'),
      _ForumReportReasonOption(code: 'abuse_or_insult', label: '辱骂 / 人身攻击'),
      _ForumReportReasonOption(
        code: 'flamebait_or_conflict',
        label: '引战 / 煽动冲突',
      ),
      _ForumReportReasonOption(code: 'spam_or_flood', label: '刷屏 / 灌水'),
      _ForumReportReasonOption(code: 'plagiarism_or_repost', label: '搬运 / 抄袭'),
      _ForumReportReasonOption(code: 'other', label: '其他'),
    ];

class _ForumReportTarget {
  const _ForumReportTarget({
    required this.targetType,
    required this.targetId,
    required this.sheetTitle,
  });

  final String targetType;
  final String targetId;
  final String sheetTitle;
}

Future<void> _showForumReportSheet(
  BuildContext context, {
  required _ForumReportTarget target,
}) async {
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => _ForumReportBottomSheet(target: target),
  );
  if (!context.mounted || message == null || message.trim().isEmpty) {
    return;
  }
  ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text(message)));
}

class _ForumReportBottomSheet extends StatefulWidget {
  const _ForumReportBottomSheet({required this.target});

  final _ForumReportTarget target;

  @override
  State<_ForumReportBottomSheet> createState() =>
      _ForumReportBottomSheetState();
}

class _ForumReportBottomSheetState extends State<_ForumReportBottomSheet> {
  final TextEditingController _detailController = TextEditingController();
  String? _selectedReasonCode;
  String? _errorMessage;
  bool _submitting = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final reasonCode = _selectedReasonCode;
    if (reasonCode == null) {
      setState(() => _errorMessage = '请先选择举报原因');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ForumConsumerLayer.instance.submitReport(
      targetType: widget.target.targetType,
      targetId: widget.target.targetId,
      reasonCode: reasonCode,
      reasonDetail: _detailController.text,
    );
    if (!mounted) {
      return;
    }
    if (!result.isSuccess) {
      setState(() {
        _submitting = false;
        _errorMessage = result.message;
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(result.data?.message ?? result.message ?? '举报已提交');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.target.sheetTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '选择原因后提交，平台会按受控流程继续处理。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _forumReportReasonOptions
                  .map((_ForumReportReasonOption item) {
                    return ChoiceChip(
                      label: Text(item.label),
                      selected: _selectedReasonCode == item.code,
                      onSelected: (_) {
                        setState(() {
                          _selectedReasonCode = item.code;
                          _errorMessage = null;
                        });
                      },
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '补充说明（可选）',
                hintText: '可补充更具体的上下文，帮助平台更快确认问题',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? '提交中' : '提交举报'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
