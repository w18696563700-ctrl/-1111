import 'package:flutter/widgets.dart';
import 'package:mobile/dev/visual_demo/forum_ia_visual_validation_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const sceneRaw = String.fromEnvironment(
    'FORUM_IA_SCENE',
    defaultValue: 'shell',
  );
  final scene = switch (sceneRaw) {
    'forum_feed' => ForumIaVisualScene.forumFeed,
    'post_detail' => ForumIaVisualScene.postDetail,
    'comment_interaction' => ForumIaVisualScene.commentInteraction,
    'messages_replies' => ForumIaVisualScene.messagesReplies,
    'messages_likes' => ForumIaVisualScene.messagesLikes,
    'profile_assets' => ForumIaVisualScene.profileAssets,
    _ => ForumIaVisualScene.shell,
  };
  runApp(buildForumIaVisualValidationApp(scene: scene));
}
