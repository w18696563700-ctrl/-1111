part of '../exhibition_trade_pages.dart';

Future<void> showCounterpartConversationSubjectSheet(
  BuildContext context, {
  required CounterpartConversationDetailView data,
  required CounterpartConversationProjectGroupView? projectGroup,
  required String? bidId,
  Future<void> Function()? onRatingSubmitted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.86,
      child: _CounterpartConversationSubjectSheet(
        data: data,
        projectGroup: projectGroup,
        bidId: bidId,
        onRatingSubmitted: onRatingSubmitted,
      ),
    ),
  );
}

class _CounterpartConversationSubjectSheet extends StatefulWidget {
  const _CounterpartConversationSubjectSheet({
    required this.data,
    required this.projectGroup,
    required this.bidId,
    required this.onRatingSubmitted,
  });

  final CounterpartConversationDetailView data;
  final CounterpartConversationProjectGroupView? projectGroup;
  final String? bidId;
  final Future<void> Function()? onRatingSubmitted;

  @override
  State<_CounterpartConversationSubjectSheet> createState() =>
      _CounterpartConversationSubjectSheetState();
}

class _CounterpartConversationSubjectSheetState
    extends State<_CounterpartConversationSubjectSheet> {
  int _score = 5;
  final Set<String> _tags = <String>{'响应及时'};
  final TextEditingController _remarkController = TextEditingController();
  bool _submittedLocally = false;
  bool _submitting = false;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counterpart = widget.data.counterpart;
    final group = widget.projectGroup;
    final nickname = counterpart.nickname?.trim() ?? '';
    final companyName = counterpart.companyName.trim().isNotEmpty
        ? counterpart.companyName.trim()
        : counterpart.displayName.trim();
    final displayName = nickname.isNotEmpty
        ? nickname
        : (companyName.isNotEmpty ? companyName : '未命名对方');
    final certification = counterpart.certificationSummary;
    final ratingEntry = group?.ratingEntry;
    final projectEnded = _projectIsEnded(group?.projectState);
    final canShowSubmit = projectEnded && (ratingEntry?.canRate ?? false);
    final reason = _ratingUnavailableReason(projectEnded, ratingEntry);
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 10),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    '对方主体',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: '关闭',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: <Widget>[
                _ActionCard(
                  title: displayName,
                  summary: companyName.isNotEmpty
                      ? companyName
                      : '当前仅展示系统返回的对方主体摘要。',
                  tone: _ActionCardTone.emphasis,
                  children: <Widget>[
                    if (nickname.isNotEmpty)
                      _DetailLine(label: '昵称', value: nickname),
                    _DetailLine(
                      label: '公司名称',
                      value: companyName.isNotEmpty ? companyName : '当前未提供',
                    ),
                    _DetailLine(
                      label: '认证状态',
                      value: _certificationStatusLabel(
                        certification?.certificationStatus,
                      ),
                    ),
                    if (certification?.legalName.trim().isNotEmpty ?? false)
                      _DetailLine(
                        label: '认证主体',
                        value: certification!.legalName,
                      ),
                    if (certification?.usccMasked?.trim().isNotEmpty ?? false)
                      _DetailLine(
                        label: '统一社会信用代码',
                        value: certification!.usccMasked!,
                      ),
                    if (certification?.businessType?.trim().isNotEmpty ?? false)
                      _DetailLine(
                        label: '企业类型',
                        value: certification!.businessType!,
                      ),
                    if (certification?.address?.trim().isNotEmpty ?? false)
                      _DetailLine(label: '住所', value: certification!.address!),
                    _DetailLine(
                      label: '当前项目',
                      value:
                          group?.projectDisplayTitle ??
                          widget.data.focusProjectId,
                    ),
                    if (ratingEntry != null)
                      _DetailLine(label: '评价订单', value: ratingEntry.orderId),
                    _DetailLine(
                      label: '项目状态',
                      value: _subjectProjectStateLabel(group?.projectState),
                      highlight: projectEnded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: '评价对方',
                  summary: projectEnded
                      ? '项目已进入结束态时才允许评价；提交仍以后端评价真值为准。'
                      : '项目未结束前不允许评价，避免把沟通中状态误写成信用真值。',
                  children: <Widget>[
                    if (reason != null)
                      _StateMessage(title: '暂不可评价', body: reason)
                    else ...<Widget>[
                      _RatingScorePicker(
                        score: _score,
                        onChanged: (int value) =>
                            setState(() => _score = value),
                      ),
                      const SizedBox(height: 12),
                      _RatingTagPicker(
                        selectedTags: _tags,
                        onToggle: _toggleTag,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _remarkController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '文字备注',
                          hintText: '补充本次合作体验，仅支持文字。',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const ValueKey<String>(
                          'counterpart_rating_submit_button',
                        ),
                        onPressed:
                            canShowSubmit && !_submitting && !_submittedLocally
                            ? () => _submitControlledRating(ratingEntry!)
                            : null,
                        icon: const Icon(Icons.star_rate_rounded),
                        label: const Text('提交评价'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: '信用提示',
                  children: <Widget>[
                    _StateMessage(
                      title: _submittedLocally ? '评价已提交' : '以后端为准',
                      body: _submittedLocally
                          ? '当前评价已提交；真实信用联动继续以后端评价真值和信用聚合触发链为准。'
                          : '提交评价后可展示信用联动提示，但 Flutter 不计算信用分、不预测分值变化。',
                    ),
                  ],
                ),
                if (widget.bidId != null) ...<Widget>[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTradingImParticipantCardSheet(
                        context,
                        projectId:
                            group?.projectId ?? widget.data.focusProjectId,
                        bidId: widget.bidId,
                        participantOrganizationId: counterpart.organizationId,
                      ),
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('查看旧竞标主体卡'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _certificationStatusLabel(String? status) {
    return switch (status?.trim()) {
      'approved' || 'verified' => '认证已通过',
      null || '' => '当前未提供认证摘要',
      _ => '当前未提供认证摘要',
    };
  }

  String? _ratingUnavailableReason(
    bool projectEnded,
    CounterpartConversationRatingEntryView? ratingEntry,
  ) {
    if (!projectEnded) {
      return '当前项目尚未结束，评价入口不会开放。';
    }
    if (ratingEntry == null) {
      return '当前缺少 orderId/project-counterparty-rating 真值锚点，不能提交真实评价。';
    }
    if (!ratingEntry.canRate) {
      return ratingEntry.reason ?? '当前评价已提交或暂不可重复提交。';
    }
    return null;
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  Future<void> _submitControlledRating(
    CounterpartConversationRatingEntryView ratingEntry,
  ) async {
    if (_submitting || _submittedLocally || !ratingEntry.canRate) {
      return;
    }
    setState(() => _submitting = true);
    final result = await CounterpartConversationConsumerLayer.instance
        .submitProjectCounterpartyRating(
          orderId: ratingEntry.orderId,
          projectId: ratingEntry.projectId,
          rateeOrganizationId: ratingEntry.rateeOrganizationId,
          scoreLabel: _scoreLabel(_score),
          commentText: _ratingCommentText(),
        );
    if (!mounted) {
      return;
    }
    final submitted = result.state == AppPageState.content;
    setState(() {
      _submitting = false;
      _submittedLocally = submitted;
    });
    if (submitted) {
      await widget.onRatingSubmitted?.call();
      if (!mounted) {
        return;
      }
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          submitted ? '评价已提交，信用联动以后端为准。' : result.message ?? '评价提交失败，请刷新后重试。',
        ),
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 5) {
      return 'very_satisfied';
    }
    if (score == 4) {
      return 'satisfied';
    }
    if (score == 3) {
      return 'passable';
    }
    return 'negative';
  }

  String? _ratingCommentText() {
    final parts = <String>[
      if (_tags.isNotEmpty) '标签：${_tags.join('、')}',
      if (_remarkController.text.trim().isNotEmpty)
        _remarkController.text.trim(),
    ];
    return parts.isEmpty ? null : parts.join('\n');
  }
}

class _RatingScorePicker extends StatelessWidget {
  const _RatingScorePicker({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List<Widget>.generate(5, (int index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => onChanged(value),
          icon: Icon(
            value <= score ? Icons.star_rounded : Icons.star_border_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: '$value 分',
        );
      }),
    );
  }
}

class _RatingTagPicker extends StatelessWidget {
  const _RatingTagPicker({required this.selectedTags, required this.onToggle});

  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;

  static const List<String> _tags = <String>[
    '响应及时',
    '交付稳定',
    '沟通清楚',
    '现场规范',
    '需要改进',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags
          .map((String tag) {
            final selected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: selected,
              onSelected: (_) => onToggle(tag),
            );
          })
          .toList(growable: false),
    );
  }
}

bool _projectIsEnded(String? state) {
  final normalized = state?.trim().toLowerCase();
  return normalized == 'closed' ||
      normalized == 'completed' ||
      normalized == 'finished';
}

String _subjectProjectStateLabel(String? state) {
  return switch (state?.trim().toLowerCase()) {
    'published' => '已发布，暂不可评价',
    'open' => '进行中，暂不可评价',
    'closed' => '已结束',
    'completed' => '已完成',
    'finished' => '已完结',
    null || '' => '未提供',
    _ => state!,
  };
}
