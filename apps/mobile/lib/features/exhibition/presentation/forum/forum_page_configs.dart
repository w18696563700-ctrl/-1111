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
      summary: '查看我发布过的帖子，继续编辑可修改内容，删除会按真实权限受控执行。',
      scopeLabel: 'me/posts',
      routeLabel: ExhibitionRoutes.forumMePosts,
      listTitle: '帖子资产',
      listSummary: '集中查看帖子状态、发布时间和可用操作。',
      primaryCardTitle: '我发的帖子 | 供应商进场核对单',
      primaryCardSummary: '展示当前账号最近发布内容的摘要与回看入口。',
      primaryCardMeta: '浏览 218 | 收藏 12',
      secondaryCardTitle: '我发的帖子 | 灯箱安装踩坑清单',
      secondaryCardMeta: '浏览 145 | 收藏 9',
    ),
    ForumMeScope.comments => const _ForumMeConfig(
      title: '我的评论',
      summary: '查看我参与过的评论，回到原帖继续阅读上下文。',
      scopeLabel: 'me/comments',
      routeLabel: ExhibitionRoutes.forumMeComments,
      listTitle: '最近评论',
      listSummary: '按当前返回结果展示评论内容、所属帖子和后续回复数。',
      primaryCardTitle: '我的评论 | 针对材料报价的回复',
      primaryCardSummary: '展示评论关联的原帖上下文和继续查看入口。',
      primaryCardMeta: '评论时间：今天 10:12',
      secondaryCardTitle: '我的评论 | 进场排班经验补充',
      secondaryCardMeta: '评论时间：昨天 18:40',
    ),
    ForumMeScope.bookmarks => const _ForumMeConfig(
      title: '我的收藏',
      summary: '查看我收藏过的帖子，方便稍后回看。',
      scopeLabel: 'me/bookmarks',
      routeLabel: ExhibitionRoutes.forumMeBookmarks,
      listTitle: '收藏内容',
      listSummary: '展示可回看的收藏帖子和话题入口。',
      primaryCardTitle: '我的收藏 | 展台材料性价比清单',
      primaryCardSummary: '展示当前可回看的收藏锚点与基础元信息。',
      primaryCardMeta: '收藏时间：本周一',
      secondaryCardTitle: '我的收藏 | 供应商交接模板',
      secondaryCardMeta: '收藏时间：上周五',
    ),
    ForumMeScope.likes => const _ForumMeConfig(
      title: '我的点赞',
      summary: '查看我点过赞的帖子，方便继续回看。',
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
      summary: '查看我关注的公开作者，继续进入作者主页。',
      scopeLabel: 'me/follows',
      routeLabel: ExhibitionRoutes.forumMeFollows,
      listTitle: '关注对象',
      listSummary: '当前仅展示已返回的作者关注关系，不新增关注类型。',
      primaryCardTitle: '我的关注 | # 上海布展进场窗口',
      primaryCardSummary: '展示当前可继续追踪的话题锚点和回流入口。',
      primaryCardMeta: '类型：话题',
      secondaryCardTitle: '我的关注 | 临展材料供应协作组',
      secondaryCardMeta: '类型：机构',
    ),
  };
}
