import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/p0_pay_read_only_summary.dart';

final class MessagesCanonicalPaths {
  const MessagesCanonicalPaths._();

  static const String messageInteractions = '/api/app/message/interactions';
  static const String counterpartConversationDetail =
      '/api/app/message/counterpart-conversation/detail';
  static const String projectCommunicationThread =
      '/api/app/message/project-communication/thread';
  static const String projectCommunicationMessages =
      '/api/app/message/project-communication/messages';
  static const String projectCommunicationReadCursor =
      '/api/app/message/project-communication/read-cursor';
  static const String projectCommunicationFilePreviewAccess =
      '/api/app/file/preview/access';
  static const String confirmationSoftLinkDetail =
      '/api/app/confirmation/softlink/detail';

  static String projectAlbumPhotos(String projectId) =>
      '/api/app/project/${Uri.encodeComponent(projectId)}/album/photos';

  static String projectAlbumPhoto(String projectId, String photoId) =>
      '${projectAlbumPhotos(projectId)}/${Uri.encodeComponent(photoId)}';

  static const String projectCounterpartyRatingEntry =
      '/api/app/project-counterparty-rating/entry';
  static const String projectCounterpartyRatingSubmit =
      '/api/app/project-counterparty-rating/submit';
}

final class MessageInteractionRouteTarget {
  const MessageInteractionRouteTarget({
    required this.objectType,
    required this.actionKey,
    required this.canonicalPath,
    required this.params,
    required this.routeLocation,
  });

  final String objectType;
  final String actionKey;
  final String canonicalPath;
  final Map<String, String> params;
  final String routeLocation;
}

final class MessageInteractionCounterpartView {
  const MessageInteractionCounterpartView({
    required this.organizationId,
    required this.displayName,
    required this.nickname,
    required this.companyName,
    required this.avatarUrl,
    required this.role,
    required this.certificationSummary,
  });

  final String organizationId;
  final String displayName;
  final String? nickname;
  final String companyName;
  final String? avatarUrl;
  final String role;
  final CounterpartCertificationSummaryView? certificationSummary;
}

final class CounterpartCertificationSummaryView {
  const CounterpartCertificationSummaryView({
    required this.certificationStatus,
    required this.legalName,
    required this.usccMasked,
    required this.businessType,
    required this.address,
    required this.establishedAt,
    required this.reviewedAt,
  });

  final String certificationStatus;
  final String legalName;
  final String? usccMasked;
  final String? businessType;
  final String? address;
  final String? establishedAt;
  final String? reviewedAt;
}

final class MessageInteractionSummaryView {
  const MessageInteractionSummaryView({
    required this.focusProjectId,
    required this.title,
    required this.text,
    required this.projectCount,
    required this.latestCardType,
  });

  final String focusProjectId;
  final String title;
  final String text;
  final int projectCount;
  final String latestCardType;
}

final class MessageInteractionItemView {
  const MessageInteractionItemView({
    required this.interactionId,
    required this.interactionType,
    required this.conversationId,
    required this.projectId,
    required this.counterpart,
    required this.summary,
    required this.p0PaySummary,
    required this.updatedAt,
    required this.routeTarget,
  });

  final String interactionId;
  final String interactionType;
  final String conversationId;
  final String projectId;
  final MessageInteractionCounterpartView counterpart;
  final MessageInteractionSummaryView summary;
  final P0PayReadOnlySummaryView? p0PaySummary;
  final String updatedAt;
  final MessageInteractionRouteTarget routeTarget;
}

final class MessageInteractionListResult {
  const MessageInteractionListResult({
    required this.state,
    required this.method,
    required this.path,
    required this.lane,
    this.items = const <MessageInteractionItemView>[],
    this.message,
  });

  final AppPageState state;
  final String method;
  final String path;
  final String lane;
  final List<MessageInteractionItemView> items;
  final String? message;
}

final class MessageInteractionPayloadParseResult {
  const MessageInteractionPayloadParseResult({
    required this.state,
    required this.lane,
    this.items = const <MessageInteractionItemView>[],
    this.message,
  });

  final AppPageState state;
  final String lane;
  final List<MessageInteractionItemView> items;
  final String? message;
}
