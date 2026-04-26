part of '../exhibition_trade_pages.dart';

class ProjectAlbumPage extends StatelessWidget {
  const ProjectAlbumPage({super.key, this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId == null || normalizedProjectId.isEmpty) {
      return const _ProjectAlbumPageFrame(
        child: _ActionCard(
          title: '项目相册',
          children: <Widget>[
            _StateMessage(title: '缺少项目边界', body: '项目相册必须从具体项目进入。'),
          ],
        ),
      );
    }
    return _ProjectAlbumPageFrame(
      child: _ProjectAlbumSection(projectId: normalizedProjectId),
    );
  }
}

class _ProjectAlbumPageFrame extends StatelessWidget {
  const _ProjectAlbumPageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[child],
      ),
    );
  }
}
