part of 'forum_pages.dart';

class _ForumMeConfig {
  const _ForumMeConfig({
    required this.title,
    required this.summary,
    required this.scopeLabel,
    required this.routeLabel,
    required this.listTitle,
    required this.listSummary,
    required this.primaryCardTitle,
    required this.primaryCardSummary,
    required this.primaryCardMeta,
    required this.secondaryCardTitle,
    required this.secondaryCardMeta,
  });

  final String title;
  final String summary;
  final String scopeLabel;
  final String routeLabel;
  final String listTitle;
  final String listSummary;
  final String primaryCardTitle;
  final String primaryCardSummary;
  final String primaryCardMeta;
  final String secondaryCardTitle;
  final String secondaryCardMeta;
}

_ForumMeConfig _meConfig(ForumMeScope scope) {
  return switch (scope) {
    ForumMeScope.posts => const _ForumMeConfig(
      title: '我的帖子',
      summary: '用于承接我自己的帖子 continuity hub，只处理本人帖子的继续编辑与受控删除。',
      scopeLabel: 'me/posts',
      routeLabel: ExhibitionRoutes.forumMePosts,
      listTitle: '帖子 continuity hub',
      listSummary: '集中查看我自己的帖子状态，并继续进入编辑草稿或受控删除。',
      primaryCardTitle: '我发的帖子 | 供应商进场核对单',
      primaryCardSummary: '展示当前账号最近发布内容的摘要与回看入口。',
      primaryCardMeta: '浏览 218 | 收藏 12',
      secondaryCardTitle: '我发的帖子 | 灯箱安装踩坑清单',
      secondaryCardMeta: '浏览 145 | 收藏 9',
    ),
    ForumMeScope.comments => const _ForumMeConfig(
      title: '我的评论',
      summary: '用于承接我参与过的评论和回复列表。',
      scopeLabel: 'me/comments',
      routeLabel: ExhibitionRoutes.forumMeComments,
      listTitle: '最近评论',
      listSummary: '围绕未读回复和最近参与内容继续查看评论上下文。',
      primaryCardTitle: '我的评论 | 针对材料报价的回复',
      primaryCardSummary: '展示评论关联的原帖上下文和继续查看入口。',
      primaryCardMeta: '评论时间：今天 10:12',
      secondaryCardTitle: '我的评论 | 进场排班经验补充',
      secondaryCardMeta: '评论时间：昨天 18:40',
    ),
    ForumMeScope.bookmarks => const _ForumMeConfig(
      title: '我的收藏',
      summary: '用于承接已收藏的帖子与话题条目。',
      scopeLabel: 'me/bookmarks',
      routeLabel: ExhibitionRoutes.forumMeBookmarks,
      listTitle: '收藏内容',
      listSummary: '在当前冻结边界里查看可回看的话题与帖子锚点。',
      primaryCardTitle: '我的收藏 | 展台材料性价比清单',
      primaryCardSummary: '展示当前可回看的收藏锚点与基础元信息。',
      primaryCardMeta: '收藏时间：本周一',
      secondaryCardTitle: '我的收藏 | 供应商交接模板',
      secondaryCardMeta: '收藏时间：上周五',
    ),
    ForumMeScope.likes => const _ForumMeConfig(
      title: '我的点赞',
      summary: '用于承接我点过赞的帖子，方便继续回看和取消点赞。',
      scopeLabel: 'me/likes',
      routeLabel: ExhibitionRoutes.forumMeLikes,
      listTitle: '点赞内容',
      listSummary: '集中查看当前账号已经点赞过的帖子锚点。',
      primaryCardTitle: '我的点赞 | 展台搭建经验',
      primaryCardSummary: '展示已点赞帖子的摘要与回看入口。',
      primaryCardMeta: '点赞时间：本周',
      secondaryCardTitle: '我的点赞 | 进场排班提醒',
      secondaryCardMeta: '点赞时间：上周',
    ),
    ForumMeScope.follows => const _ForumMeConfig(
      title: '我的关注',
      summary: '用于承接我关注的话题、作者和机构列表。',
      scopeLabel: 'me/follows',
      routeLabel: ExhibitionRoutes.forumMeFollows,
      listTitle: '关注对象',
      listSummary: '集中查看当前可继续追踪的话题锚点，并回到关注页。',
      primaryCardTitle: '我的关注 | # 上海布展进场窗口',
      primaryCardSummary: '展示当前可继续追踪的话题锚点和回流入口。',
      primaryCardMeta: '类型：话题',
      secondaryCardTitle: '我的关注 | 临展材料供应协作组',
      secondaryCardMeta: '类型：机构',
    ),
  };
}
