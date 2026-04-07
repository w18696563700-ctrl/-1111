part of 'forum_ia_visual_validation_app.dart';

class _ForumFeedPrototypePage extends StatelessWidget {
  const _ForumFeedPrototypePage({required this.scopeTitle});

  final String scopeTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('论坛 / $scopeTitle'),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: () {
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('搜索仍是右上角工具位，本轮不展开真实搜索。')),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          _SectionLead(
            eyebrow: '论坛列表',
            title: '$scopeTitle 视角下的帖子流',
            body: '列表层继续只承接内容浏览，话题标签露出在标题前方，返回上一级直接回到论坛容器。',
          ),
          const SizedBox(height: 12),
          const _IaCard(
            title: '内部筛选',
            summary: '话题只在列表里做轻量筛选，不抢一级内容视角。',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _TopicChip(label: '# 布展进场', selected: true),
                _TopicChip(label: '# 搭建排班'),
                _TopicChip(label: '# 供应协同'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ForumPreviewTile(
            topic: '布展进场',
            title: '夜间进场窗口怎么排吊装和安检顺序？',
            excerpt: '夜班时间有限，想听听大家怎么处理吊装窗口、安检队列和材料堆放顺序。',
            meta: '李工 · 2 小时前 · 112 赞 · 28 回复',
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _PostDetailPrototypePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ForumPreviewTile(
            topic: scopeTitle == '关注' ? '关注话题' : '本地供应链',
            title: '本地班组交接时，材料签收要不要拆到小时级？',
            excerpt: '如果场馆切换频繁，把签收节点颗粒度做细一点，回头追问题会更省心。',
            meta: '王监理 · 5 小时前 · 68 赞 · 11 回复',
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _PostDetailPrototypePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostDetailPrototypePage extends StatelessWidget {
  const _PostDetailPrototypePage({this.commentOnly = false});

  final bool commentOnly;

  @override
  Widget build(BuildContext context) {
    if (commentOnly) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const <Widget>[
          _SectionLead(
            eyebrow: '评论互动区',
            title: '围绕单帖展开回复，不脱离帖子上下文',
            body: '这里是帖子详情的下游互动层。返回键先回帖子详情，再回论坛列表，不绕路也不重建首页。',
          ),
          SizedBox(height: 12),
          _IaCard(
            title: '当前回复对象',
            summary: '用户始终知道自己在围绕哪条帖子和哪条评论继续互动。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _TopicChip(label: '# 布展进场', selected: true),
                SizedBox(height: 10),
                Text('《夜间进场窗口怎么排吊装和安检顺序？》'),
                SizedBox(height: 10),
                _CommentComposerPlaceholder(),
              ],
            ),
          ),
          SizedBox(height: 12),
          _IaCard(
            title: '评论线程',
            summary: '评论流清楚呈现谁、回复谁、说了什么，并保留继续回复入口。',
            child: Column(
              children: <Widget>[
                _CommentTile(
                  author: '王监理',
                  target: '回复 楼主',
                  content: '先锁定吊装批次，再做进场二维码核验，现场秩序会稳很多。',
                ),
                SizedBox(height: 8),
                _CommentTile(
                  author: '张队长',
                  target: '回复 王监理',
                  content: '我们会把夜班拆成两段，前半段清材料，后半段专门处理吊装。',
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        const _SectionLead(
          eyebrow: '帖子详情',
          title: '单帖内容与互动集中在同一条阅读路径里',
          body: '详情页只承接话题、正文、主互动和评论预览。用户从列表进来后，不会被带去第二个论坛首页。',
        ),
        const SizedBox(height: 12),
        const _IaCard(
          title: '帖子正文',
          summary: '话题标签放在标题前，正文是单帖主内容本体。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TopicChip(label: '# 布展进场', selected: true),
              SizedBox(height: 10),
              Text(
                '夜间进场窗口怎么排吊装和安检顺序？',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('李工 · 昨天 21:40 · 来自广场'),
              SizedBox(height: 12),
              Text(
                '夜间进场时间很短，材料又分批到场。想请教大家怎么安排吊装顺序、安检队列和安全员排班，才能既稳又不拖第二天的搭建节奏。',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _IaCard(
          title: '主互动',
          summary: '点赞、关注、回复都围绕当前帖子发生，回复继续下钻到评论互动区。',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              const _ToolChip(label: '👍 点赞'),
              const _ToolChip(label: '⭐ 关注'),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const _PostDetailPrototypePage(commentOnly: true),
                    ),
                  );
                },
                icon: const Icon(Icons.reply_rounded),
                label: const Text('进入回复'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _IaCard(
          title: '评论预览',
          summary: '评论区先给出互动现场预览，再由用户决定是否继续深入回复。',
          child: Column(
            children: <Widget>[
              const _CommentTile(
                author: '王监理',
                target: '回复 楼主',
                content: '建议把吊装批次和安检闸口拆开排，不要让同一组人来回切换。',
              ),
              const SizedBox(height: 8),
              const _CommentTile(
                author: '陈设计',
                target: '回复 王监理',
                content: '我们会在材料外箱先贴区域码，现场找货会快很多。',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const _PostDetailPrototypePage(commentOnly: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('展开评论互动区'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InteractionCenterPage extends StatelessWidget {
  const _InteractionCenterPage({this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3,
      child: Column(
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _SectionLead(
              eyebrow: '消息楼',
              title: '只承接互动通知，不重建论坛首页',
              body: '消息楼只保留回复我的、收到的赞、新关注三类通知。每条都强调谁、对什么对象、如何回到源对象。',
            ),
          ),
          TabBar(
            tabs: <Tab>[
              Tab(text: '回复我的'),
              Tab(text: '收到的赞'),
              Tab(text: '新关注'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _NotificationList(typeLabel: '回复我的'),
                _NotificationList(typeLabel: '收到的赞'),
                _NotificationList(typeLabel: '新关注'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.typeLabel});

  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        _IaCard(
          title: '$typeLabel 通知流',
          summary: '这一层是通知流，不是内容流；点击后应该直接回到源对象，而不是绕回论坛首页。',
          child: Column(
            children: <Widget>[
              _NoticeTile(
                actor: '李工',
                objectText: switch (typeLabel) {
                  '回复我的' => '在《夜间进场窗口怎么排吊装和安检顺序？》下回复了你',
                  '收到的赞' => '赞了你在《搭建夜班排班》下的评论',
                  _ => '关注了你',
                },
                sourceHint: switch (typeLabel) {
                  '回复我的' => '源对象：帖子详情',
                  '收到的赞' => '源对象：评论详情',
                  _ => '源对象：个人主页',
                },
              ),
              const SizedBox(height: 8),
              _NoticeTile(
                actor: typeLabel == '新关注' ? '陈设计' : '王监理',
                objectText: switch (typeLabel) {
                  '回复我的' => '回复了你在《材料交接节点》里的问题',
                  '收到的赞' => '赞了你在《供应协同模板》下的建议',
                  _ => '关注了你的论坛动态',
                },
                sourceHint: switch (typeLabel) {
                  '回复我的' => '源对象：评论详情',
                  '收到的赞' => '源对象：帖子详情',
                  _ => '源对象：个人主页',
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ForumAssetEntrancePage extends StatelessWidget {
  const _ForumAssetEntrancePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: const <Widget>[
        _SectionLead(
          eyebrow: '我的楼',
          title: '论坛相关沉淀统一收进个人资产入口',
          body: '这里强调的是我的内容、我的关系和我的草稿，整体更像资产管理页，而不是再开一条内容浏览流。',
        ),
        SizedBox(height: 12),
        _IaCard(
          title: '资产概览',
          summary: '先看沉淀量和待处理，再决定进入哪个资产管理入口。',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MetricTile(label: '我的帖子', value: '12'),
              _MetricTile(label: '我的评论', value: '36'),
              _MetricTile(label: '我的收藏', value: '18'),
              _MetricTile(label: '草稿待整理', value: '4'),
            ],
          ),
        ),
        SizedBox(height: 12),
        _IaCard(
          title: '内容资产',
          summary: '围绕我发过、我评论过、我收藏过的内容进入单项管理。',
          child: Column(
            children: <Widget>[
              _AssetRow(title: '我的帖子', count: '12', note: '查看已发布内容'),
              _AssetRow(title: '我的评论', count: '36', note: '查看我的讨论痕迹'),
              _AssetRow(title: '我的收藏', count: '18', note: '查看稍后再读内容'),
            ],
          ),
        ),
        SizedBox(height: 12),
        _IaCard(
          title: '关系与草稿',
          summary: '关注关系和草稿箱留在个人资产语义里，不再回论坛主容器占一级入口。',
          child: Column(
            children: <Widget>[
              _AssetRow(title: '我的关注', count: '9', note: '查看关注对象'),
              _AssetRow(title: '草稿箱', count: '4', note: '继续整理未发布内容'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SceneBar extends StatelessWidget implements PreferredSizeWidget {
  const _SceneBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
