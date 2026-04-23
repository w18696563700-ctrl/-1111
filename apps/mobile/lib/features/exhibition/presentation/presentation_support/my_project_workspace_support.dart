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
