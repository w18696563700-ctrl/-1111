import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_scaffold_widgets.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_shared_components.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_state_widgets.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'forum_feed_pages.dart';
part 'forum_feed_support.dart';
part 'forum_feed_filter_support.dart';
part 'forum_topics_page.dart';
part 'forum_detail_pages.dart';
part 'forum_detail_surface_widgets.dart';
part 'forum_composer_media_widgets.dart';
part 'forum_detail_media_widgets.dart';
part 'forum_media_presentation_widgets.dart';
part 'forum_comment_pages.dart';
part 'forum_creator_pages.dart';
part 'forum_creator_page_sections.dart';
part 'forum_publish_continuation_support.dart';
part 'forum_media_upload_support.dart';
part 'forum_asset_support.dart';
part 'forum_draft_search_pages.dart';
part 'forum_search_pages.dart';
part 'forum_me_pages.dart';
part 'forum_my_report_pages.dart';
part 'forum_own_post_support.dart';
part 'forum_report_support.dart';
part 'forum_author_profile_pages.dart';
part 'forum_author_profile_surface_widgets.dart';
part 'forum_page_configs.dart';

enum ForumFeedScope { square, local, following }

enum ForumMeScope { posts, comments, bookmarks, likes, follows }

typedef ForumExternalUrlOpener = Future<bool> Function(Uri uri);

final class ForumDetailAttachmentDebugOverrides {
  const ForumDetailAttachmentDebugOverrides._();

  static ForumExternalUrlOpener? _externalUrlOpener;

  static ForumExternalUrlOpener? get externalUrlOpener => _externalUrlOpener;

  static void installExternalUrlOpener(ForumExternalUrlOpener? opener) {
    _externalUrlOpener = opener;
  }

  static void reset() {
    _externalUrlOpener = null;
  }
}

String _resolvedId(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}
