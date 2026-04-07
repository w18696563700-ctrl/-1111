import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

part 'exhibition_stage_demo_catalog.dart';

enum ExhibitionStageDataOrigin { futureReal, demo }

typedef ExhibitionStageFutureRealLoader =
    Future<ExhibitionLoadResult> Function({bool forceRefresh});

typedef ExhibitionStageDemoLoadBuilder = ExhibitionLoadResult Function();

class ExhibitionStageLoadSnapshot {
  const ExhibitionStageLoadSnapshot({
    required this.result,
    required this.origin,
    this.futureRealResult,
  });

  final ExhibitionLoadResult result;
  final ExhibitionStageDataOrigin origin;
  final ExhibitionLoadResult? futureRealResult;

  bool get isDemo => origin == ExhibitionStageDataOrigin.demo;

  bool get showsFallbackNotice => isDemo && futureRealResult != null;

  String get sourceLabel => switch (origin) {
    ExhibitionStageDataOrigin.futureReal => '当前展示：已接通内容',
    ExhibitionStageDataOrigin.demo => '当前展示：演示内容',
  };

  String get sourceMessage {
    if (origin == ExhibitionStageDataOrigin.futureReal) {
      return '当前页面直接展示已接通内容；后续动作仍以后端实际承接状态为准。';
    }

    if (futureRealResult == null) {
      return '当前页面正在用演示内容继续讲解，方便连续展示；这不代表真实链路已经全部接通。';
    }

    return '当前真实内容还没有稳定承接到这一页，页面先切到演示内容保持讲解连续，不会伪装成真实链路已通。';
  }

  String? get fallbackTitle {
    if (!showsFallbackNotice) {
      return null;
    }

    return switch (futureRealResult!.state) {
      AppPageState.notFound => '当前先看演示内容',
      AppPageState.errorRetryable => '当前真实内容暂未返回',
      AppPageState.errorNonRetryable => '当前真实内容暂不能继续',
      _ => '当前切换为演示内容',
    };
  }

  String? get fallbackMessage {
    if (!showsFallbackNotice) {
      return null;
    }

    return switch (futureRealResult!.state) {
      AppPageState.notFound => '当前实例还没有稳定承接到这一页，所以先用演示内容继续讲解当前页面。',
      AppPageState.errorRetryable => '真实链路这次没有稳定返回，页面先切到演示内容保持可展示。',
      AppPageState.errorNonRetryable => '真实链路暂时不能继续，页面先保留演示内容帮助客户看完整体界面。',
      _ => '页面先以演示内容继续展示，等真实链路稳定后会直接切回已接通内容。',
    };
  }
}

class ExhibitionStageLoadAutoSource {
  const ExhibitionStageLoadAutoSource({
    required ExhibitionStageFutureRealLoader futureRealLoader,
    required ExhibitionStageDemoLoadBuilder demoBuilder,
  }) : _futureRealLoader = futureRealLoader,
       _demoBuilder = demoBuilder;

  final ExhibitionStageFutureRealLoader _futureRealLoader;
  final ExhibitionStageDemoLoadBuilder _demoBuilder;

  Future<ExhibitionStageLoadSnapshot> load({bool forceRefresh = false}) async {
    final futureReal = await _futureRealLoader(forceRefresh: forceRefresh);
    if (_acceptFutureReal(futureReal)) {
      return ExhibitionStageLoadSnapshot(
        result: futureReal,
        origin: ExhibitionStageDataOrigin.futureReal,
      );
    }

    if (!_shouldUseDemoFallback(futureReal)) {
      return ExhibitionStageLoadSnapshot(
        result: futureReal,
        origin: ExhibitionStageDataOrigin.futureReal,
      );
    }

    return ExhibitionStageLoadSnapshot(
      result: _demoBuilder(),
      origin: ExhibitionStageDataOrigin.demo,
      futureRealResult: futureReal,
    );
  }

  bool _acceptFutureReal(ExhibitionLoadResult result) {
    return switch (result.state) {
      AppPageState.content ||
      AppPageState.empty ||
      AppPageState.unauthorized ||
      AppPageState.forbidden => true,
      _ => false,
    };
  }

  bool _shouldUseDemoFallback(ExhibitionLoadResult result) {
    return result.state == AppPageState.errorRetryable &&
        result.message ==
            'current fake transport did not provide this canonical path';
  }
}
