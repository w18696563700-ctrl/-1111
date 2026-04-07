import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_workbench_source.dart';

part 'exhibition_workbench_view_model_sections.dart';
part 'exhibition_workbench_view_model_text.dart';

enum ExhibitionWorkbenchNodeTone { primary, continuation, frozen, unavailable }

enum ExhibitionWorkbenchContainerState {
  loading,
  empty,
  content,
  controlledFailure,
}

class ExhibitionWorkbenchPageViewModel {
  const ExhibitionWorkbenchPageViewModel({
    required this.pageState,
    required this.title,
    required this.subtitle,
    required this.sourceLabel,
    required this.sourceMessage,
    required this.projectChain,
    required this.orderChain,
    required this.fulfillmentChain,
    required this.extensionBoundary,
    required this.sections,
    this.bannerTitle,
    this.bannerMessage,
  });

  final AppPageState pageState;
  final String title;
  final String subtitle;
  final String sourceLabel;
  final String sourceMessage;
  final ExhibitionWorkbenchProjectChainData projectChain;
  final ExhibitionWorkbenchOrderChainData orderChain;
  final ExhibitionWorkbenchFulfillmentChainData fulfillmentChain;
  final ExhibitionWorkbenchExtensionBoundaryData extensionBoundary;
  final List<ExhibitionWorkbenchSectionViewModel> sections;
  final String? bannerTitle;
  final String? bannerMessage;
}

class ExhibitionWorkbenchSectionViewModel {
  const ExhibitionWorkbenchSectionViewModel({
    required this.title,
    required this.state,
    required this.stateLabel,
    required this.summary,
    required this.nodes,
  });

  final String title;
  final ExhibitionWorkbenchContainerState state;
  final String stateLabel;
  final String summary;
  final List<ExhibitionWorkbenchNodeViewModel> nodes;
}

class ExhibitionWorkbenchNodeViewModel {
  const ExhibitionWorkbenchNodeViewModel({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.tone,
    this.actionLabel,
    this.routeName,
  });

  final String title;
  final String description;
  final String statusLabel;
  final ExhibitionWorkbenchNodeTone tone;
  final String? actionLabel;
  final String? routeName;
}

class ExhibitionWorkbenchViewModelAdapter {
  const ExhibitionWorkbenchViewModelAdapter._();

  static ExhibitionWorkbenchPageViewModel fromSourceResult(
    ExhibitionWorkbenchSourceResult result,
  ) {
    final summary = result.summary ?? ExhibitionWorkbenchSummaryData.empty;
    final isDemo = result.kind == ExhibitionWorkbenchSourceKind.demo;
    final usesConnectedCopy = _usesConnectedCopy(result.state, isDemo);
    final activeOrderId = summary.orderChain.activeOrderId;
    final activeMilestoneId = summary.fulfillmentChain.activeMilestoneId;

    return ExhibitionWorkbenchPageViewModel(
      pageState: result.state,
      title: '项目工作台',
      subtitle: _workbenchPageSubtitle(isDemo),
      sourceLabel: _sourceLabel(result.state, isDemo),
      sourceMessage: isDemo
          ? '当前工作台先由演示内容承接，方便连续讲解私域交易与履约入口；这不代表真实链路已经全部接通。'
          : usesConnectedCopy
          ? '当前工作台只承接私域交易与履约继续动作，不再和公域项目展示混在同一屏。'
          : '当前工作台仍在走真实链路，但这次摘要还没有稳定返回，页面会保留待重试或待承接提示，而不是伪装成已有内容。',
      projectChain: summary.projectChain,
      orderChain: summary.orderChain,
      fulfillmentChain: summary.fulfillmentChain,
      extensionBoundary: summary.extensionBoundary,
      bannerTitle: _bannerTitle(result, isDemo),
      bannerMessage: _bannerMessage(result, isDemo),
      sections: <ExhibitionWorkbenchSectionViewModel>[
        _projectChainSection(summary.projectChain, result.state),
        _orderChainSection(summary.orderChain, activeOrderId, result.state),
        _fulfillmentChainSection(
          summary.fulfillmentChain,
          activeOrderId,
          activeMilestoneId,
          result.state,
        ),
        _extensionBoundarySection(
          summary.extensionBoundary,
          activeOrderId,
          result.state,
        ),
      ],
    );
  }
}
