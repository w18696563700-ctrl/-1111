part of '../exhibition_trade_pages.dart';

extension _ProjectDetailReportSupport on _ProjectDetailPageState {
  Widget _buildProjectReportAction({required String projectId}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: _submittingReport
            ? null
            : () => _submitProjectReport(projectId: projectId),
        icon: const Icon(Icons.flag_outlined),
        label: Text(_submittingReport ? '提交中...' : '举报该项目'),
      ),
    );
  }

  Future<void> _submitProjectReport({required String projectId}) async {
    if (_submittingReport) {
      return;
    }
    setState(() => _submittingReport = true);
    final result = await ExhibitionConsumerLayer.instance
        .submitExhibitionReport(projectId: projectId);
    if (!mounted) {
      return;
    }
    setState(() => _submittingReport = false);
    final message = result.isSuccess
        ? _projectReportSuccessMessage(result.payload)
        : (result.message ?? '当前举报提交未完成，请稍后再试。');
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  String _projectReportSuccessMessage(Object? payload) {
    if (payload is Map && payload['acceptMode'] == 'existing_active') {
      return '已存在处理中举报，平台将继续人工复核。';
    }
    return '举报已提交，平台将进入人工复核。';
  }
}
