import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';

class EnterpriseWorkbenchOverviewCard extends StatelessWidget {
  const EnterpriseWorkbenchOverviewCard({super.key, required this.boardType});

  final EnterpriseBoardType boardType;

  @override
  Widget build(BuildContext context) {
    final profileFields = switch (boardType) {
      EnterpriseBoardType.company => '展会类型、服务项目、服务城市',
      EnterpriseBoardType.factory => '工艺类型、核心产品',
      EnterpriseBoardType.supplier => '供应品类、供应模式、核心产品/服务',
    };

    return EnterpriseSectionCard(
      title: '工作台能力总览',
      subtitle: '当前页不是展示入口，只用于审核现有写链路能力和技术承接范围。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _WorkbenchCapabilityGroup(
            title: '当前已接通',
            items: <String>[
              '创建入驻草稿',
              '保存基础资料',
              '保存板块画像',
              '保存案例',
              '提交入驻申请',
              '查看申请状态',
            ],
          ),
          const SizedBox(height: 14),
          _WorkbenchCapabilityGroup(
            title: '当前写入字段',
            items: <String>[
              '基础资料：企业名称、一句话简介、完整介绍、省份、城市',
              '板块画像：$profileFields',
              '案例资料：标题、摘要、封面 FileAssetId',
            ],
          ),
          const SizedBox(height: 14),
          const _WorkbenchCapabilityGroup(
            title: '当前未接通',
            items: <String>[
              'Logo 上传编排',
              '图集 / 视频素材管理',
              '已发布展示编辑与上下线',
              '案例继续编辑 / 版本回溯',
              '个人/团队专区写链路',
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkbenchCapabilityGroup extends StatelessWidget {
  const _WorkbenchCapabilityGroup({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (String item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
