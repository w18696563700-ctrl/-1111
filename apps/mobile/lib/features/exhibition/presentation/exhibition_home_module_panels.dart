part of 'exhibition_home_page.dart';

class _HomeTeamModulePanel extends StatelessWidget {
  const _HomeTeamModulePanel({required this.onOpenTeamExplanation});

  final VoidCallback onOpenTeamExplanation;

  @override
  Widget build(BuildContext context) {
    return _HomeModulePanelShell(
      children: <Widget>[
        _HomeChannelActionRail(
          actions: <_HomeChannelAction>[
            _HomeChannelAction(
              label: '查看说明',
              onPressed: onOpenTeamExplanation,
              primary: true,
            ),
            const _HomeChannelAction(label: '敬请期待', onPressed: null),
          ],
        ),
        const SizedBox(height: 12),
        _HomeStateNotice(
          title: '团队频道保持受控建设态',
          message: '当前首页已经保留团队入口，但这条推荐链路还没接到真实公开内容。',
          actions: <Widget>[
            OutlinedButton(
              onPressed: onOpenTeamExplanation,
              child: const Text('查看当前说明'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeModulePanelShell extends StatelessWidget {
  const _HomeModulePanelShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
