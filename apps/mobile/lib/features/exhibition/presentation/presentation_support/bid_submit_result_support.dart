part of '../exhibition_trade_pages.dart';

List<Widget> _buildBidSubmitResultSections({
  required BuildContext context,
  required ExhibitionActionResult result,
  required String? projectId,
}) {
  if (_isBidDuplicateSubmissionResult(result)) {
    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '已提交竞标',
        summary: '后端返回当前项目已有竞标记录，本页已锁定提交入口，避免重复提交；这不是本次新提交成功。',
        tone: _ActionCardTone.emphasis,
        children: <Widget>[
          const _StateMessage(
            title: '当前提交入口已锁定',
            body: '你可以回到项目详情或我的竞标查看最新状态，当前页面不会再发起重复提交。',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.myProjectListWithWorkspace('bids'),
                  );
                },
                child: const Text('查看我的竞标'),
              ),
              if (projectId != null)
                FilledButton.tonal(
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

  final bidId = _bidIdFromPayload(result.payload);
  if (!result.isSuccess || bidId == null) {
    return const <Widget>[];
  }

  return <Widget>[
    const SizedBox(height: 16),
    _ActionCard(
      title: '竞标已提交',
      summary: '当前竞标已经完成提交，页面保留最小结果回执，并允许直接进入沟通与投标或回到我的竞标。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '竞标 ID', value: bidId),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (projectId != null)
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.bidThreadWithIds(
                      projectId: projectId,
                      bidId: bidId,
                    ),
                  );
                },
                icon: const Icon(Icons.handshake_rounded),
                label: const Text('沟通与投标'),
              ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ExhibitionRoutes.myProjectListWithWorkspace('bids'),
                );
              },
              child: const Text('查看我的竞标'),
            ),
            if (projectId != null)
              FilledButton.tonal(
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

bool _isBidDuplicateSubmissionResult(ExhibitionActionResult? result) {
  return result?.path == ExhibitionCanonicalPaths.bidSubmit &&
      result?.errorCode?.trim() == 'BID_DUPLICATE_SUBMISSION';
}
