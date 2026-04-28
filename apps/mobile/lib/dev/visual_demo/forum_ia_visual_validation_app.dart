import 'package:flutter/material.dart';

part 'forum_ia_visual_validation_pages.dart';
part 'forum_ia_visual_validation_widgets.dart';

enum _ForumIaBuilding { exhibition, messages, profile }

enum ForumIaVisualScene {
  shell,
  forumFeed,
  postDetail,
  commentInteraction,
  messagesReplies,
  messagesLikes,
  profileAssets,
}

MaterialApp buildForumIaVisualValidationApp({
  ForumIaVisualScene scene = ForumIaVisualScene.shell,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9E7148),
    brightness: Brightness.light,
  );
  return MaterialApp(
    title: '论坛信息架构可视化验证',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF3EEE7),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: const Color(0xFFE8D8C4),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: _ForumIaShellPage(scene: scene),
  );
}

class _ForumIaShellPage extends StatefulWidget {
  const _ForumIaShellPage({required this.scene});

  final ForumIaVisualScene scene;

  @override
  State<_ForumIaShellPage> createState() => _ForumIaShellPageState();
}

class _ForumIaShellPageState extends State<_ForumIaShellPage> {
  _ForumIaBuilding _building = _ForumIaBuilding.exhibition;

  @override
  Widget build(BuildContext context) {
    final quickScene = _quickSceneChild();
    if (quickScene != null) {
      return quickScene;
    }

    final body = switch (_building) {
      _ForumIaBuilding.exhibition => _ForumContainerHome(
        onOpenFeed: (String scopeTitle) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ForumFeedPrototypePage(scopeTitle: scopeTitle),
            ),
          );
        },
      ),
      _ForumIaBuilding.messages => const _InteractionCenterPage(),
      _ForumIaBuilding.profile => const _ForumAssetEntrancePage(),
    };
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: navigator.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: navigator.pop,
              )
            : null,
        title: Text(switch (_building) {
          _ForumIaBuilding.exhibition => '展览楼 / 论坛容器',
          _ForumIaBuilding.messages => '消息楼 / 互动中心',
          _ForumIaBuilding.profile => '我的 / 论坛资产',
        }),
        actions: _building == _ForumIaBuilding.exhibition
            ? <Widget>[
                IconButton(
                  tooltip: '搜索',
                  onPressed: _showSearchNotice,
                  icon: const Icon(Icons.search_rounded),
                ),
              ]
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: body,
      ),
      floatingActionButton: _building == _ForumIaBuilding.exhibition
          ? FloatingActionButton.small(
              tooltip: '发帖',
              onPressed: _showPublishNotice,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _building.index,
        onDestinationSelected: (int index) {
          setState(() {
            _building = _ForumIaBuilding.values[index];
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.storefront), label: '展览'),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: '消息',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }

  void _showSearchNotice() {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('搜索是论坛右上角工具入口，本轮只做信息架构样机。')));
  }

  void _showPublishNotice() {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('发帖主动作固定在右下角 +，本轮不接真实发帖流程。')));
  }

  Widget? _quickSceneChild() {
    return switch (widget.scene) {
      ForumIaVisualScene.shell => null,
      ForumIaVisualScene.forumFeed => const Scaffold(
        appBar: _SceneBar(title: '展览楼 / 论坛广场'),
        body: _ForumFeedPrototypePage(scopeTitle: '广场'),
      ),
      ForumIaVisualScene.postDetail => const Scaffold(
        appBar: _SceneBar(title: '展览楼 / 帖子详情'),
        body: _PostDetailPrototypePage(),
      ),
      ForumIaVisualScene.commentInteraction => const Scaffold(
        appBar: _SceneBar(title: '展览楼 / 评论互动区'),
        body: _PostDetailPrototypePage(commentOnly: true),
      ),
      ForumIaVisualScene.messagesReplies => const Scaffold(
        appBar: _SceneBar(title: '消息楼 / 互动中心'),
        body: _InteractionCenterPage(initialTabIndex: 0),
      ),
      ForumIaVisualScene.messagesLikes => const Scaffold(
        appBar: _SceneBar(title: '消息楼 / 互动中心'),
        body: _InteractionCenterPage(initialTabIndex: 1),
      ),
      ForumIaVisualScene.profileAssets => const Scaffold(
        appBar: _SceneBar(title: '我的 / 论坛资产入口'),
        body: _ForumAssetEntrancePage(),
      ),
    };
  }
}

class _ForumContainerHome extends StatelessWidget {
  const _ForumContainerHome({required this.onOpenFeed});

  final void Function(String scopeTitle) onOpenFeed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: <Widget>[
        const _SectionLead(
          eyebrow: '展览楼里的论坛',
          title: '先选内容视角，再决定工具动作',
          body: '论坛主容器只保留广场、本地、关注三段一级内容视角。话题只留作分类与筛选，搜索退到右上角，发帖退到右下角。',
        ),
        const SizedBox(height: 14),
        _IaCard(
          title: '一级内容视角',
          summary: '一级先看内容，不再把话题、草稿、我的论坛和工具动作并排成入口大超市。',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _PrimaryScopeButton(
                icon: Icons.public_rounded,
                label: '广场',
                caption: '公共讨论主入口',
                onPressed: () => onOpenFeed('广场'),
              ),
              _PrimaryScopeButton(
                icon: Icons.place_outlined,
                label: '本地',
                caption: '本地施工与供应动态',
                onPressed: () => onOpenFeed('本地'),
              ),
              _PrimaryScopeButton(
                icon: Icons.favorite_border_rounded,
                label: '关注',
                caption: '关注的人与话题更新',
                onPressed: () => onOpenFeed('关注'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _IaCard(
          title: '话题只做内部分类',
          summary: '话题仍然重要，但只用于发帖必选、标题标签和列表筛选，不再提升成一级导航。',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _TopicChip(label: '# 布展进场', selected: true),
              _TopicChip(label: '# 材料协同'),
              _TopicChip(label: '# 本地供应链'),
              _TopicChip(label: '# 施工夜班'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _IaCard(
          title: '主浏览链预览',
          summary: '从列表进入详情，再进入评论互动区，返回路径保持自然，不在消息楼或我的楼重建第二个论坛首页。',
          child: Column(
            children: <Widget>[
              _ForumPreviewTile(
                topic: '布展进场',
                title: '夜间进场窗口怎么排吊装和安检顺序？',
                excerpt: '先看现场批次、安检闸口和吊装节拍，再分配夜班岗位，避免一上来就混成全员待命。',
                meta: '李工 · 2 小时前 · 112 赞 · 28 回复',
                onOpen: () => onOpenFeed('广场'),
              ),
              const SizedBox(height: 10),
              _ForumPreviewTile(
                topic: '本地供应链',
                title: '成都本地搭建班组怎么压缩临展交接时间？',
                excerpt: '把供应商交付时间前移半天，现场交接会顺很多。',
                meta: '陈设计 · 4 小时前 · 74 赞 · 16 回复',
                onOpen: () => onOpenFeed('本地'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _IaCard(
          title: '楼层边界提示',
          summary: '论坛主浏览链留在展览楼；互动通知留在消息楼；个人沉淀和草稿留在我的楼。',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ToolChip(label: '消息：回复我的 / 收到的赞 / 新关注'),
              _ToolChip(label: '我的：帖子 / 评论 / 收藏 / 关注 / 草稿'),
            ],
          ),
        ),
      ],
    );
  }
}
