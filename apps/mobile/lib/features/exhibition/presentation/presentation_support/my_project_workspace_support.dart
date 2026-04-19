part of '../exhibition_trade_pages.dart';

Widget _buildMyProjectWorkspaceTabsCard({
  required _MyProjectWorkspaceBucket selectedWorkspace,
  required ValueChanged<_MyProjectWorkspaceBucket> onSelected,
}) {
  final current = _myProjectWorkspaceOption(selectedWorkspace);

  return _ActionCard(
    title: '项目分类',
    summary: '先区分自己发布的项目和自己参与竞标的项目。',
    tone: _ActionCardTone.emphasis,
    children: <Widget>[
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _myProjectWorkspaceOptions.map((
          _MyProjectWorkspaceOption option,
        ) {
          return ChoiceChip(
            label: Text(option.label),
            selected: option.value == selectedWorkspace,
            onSelected: (_) => onSelected(option.value),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      _StateMessage(title: current.label, body: current.description),
    ],
  );
}

Widget _buildMyProjectBidPlaceholderSection(BuildContext context) {
  return _ActionCard(
    title: '我的竞标',
    summary: '当前只保留清晰分类，不把发布项目误当成竞标记录。',
    children: <Widget>[
      const _EmptyNotice(
        title: '当前竞标列表暂未接通',
        message: '当前还没有开放我的竞标列表。竞标提交成功后，本页不会把它混入我的发布；可先从项目详情进入竞标结果读取入口。',
      ),
      const SizedBox(height: 12),
      FilledButton.tonal(
        onPressed: () =>
            Navigator.of(context).pushNamed(ExhibitionRoutes.showcase),
        child: const Text('去项目展示查看'),
      ),
    ],
  );
}
