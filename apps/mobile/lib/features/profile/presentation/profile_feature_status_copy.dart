import 'package:flutter/material.dart';

const bool profileFeatureStatusVisible = false;

class ProfileFeatureStatusSnapshot {
  const ProfileFeatureStatusSnapshot({
    required this.featureName,
    required this.statusLabel,
    required this.completedSummary,
    required this.incompleteSummary,
    required this.dependencySummary,
    required this.unlockConditionSummary,
  });

  final String featureName;
  final String statusLabel;
  final String completedSummary;
  final String incompleteSummary;
  final String dependencySummary;
  final String unlockConditionSummary;
}

class ProfileFeatureStatusCard extends StatelessWidget {
  const ProfileFeatureStatusCard({
    super.key,
    required this.snapshot,
    this.showFeatureName = true,
    this.forceVisible = false,
  });

  final ProfileFeatureStatusSnapshot snapshot;
  final bool showFeatureName;
  final bool forceVisible;

  @override
  Widget build(BuildContext context) {
    if (!profileFeatureStatusVisible && !forceVisible) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final rows = <_ProfileFeatureStatusRow>[
      if (showFeatureName)
        _ProfileFeatureStatusRow(label: '功能名称', value: snapshot.featureName),
      _ProfileFeatureStatusRow(label: '当前功能状态', value: snapshot.statusLabel),
      _ProfileFeatureStatusRow(
        label: '当前已完成',
        value: snapshot.completedSummary,
      ),
      _ProfileFeatureStatusRow(
        label: '当前未完成',
        value: snapshot.incompleteSummary,
      ),
      _ProfileFeatureStatusRow(
        label: '当前依赖项',
        value: snapshot.dependencySummary,
      ),
      _ProfileFeatureStatusRow(
        label: '后续开启条件',
        value: snapshot.unlockConditionSummary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            '功能状态',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              for (var index = 0; index < rows.length; index += 1) ...<Widget>[
                if (index > 0)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        rows[index].label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rows[index].value,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileFeatureStatusRow {
  const _ProfileFeatureStatusRow({required this.label, required this.value});

  final String label;
  final String value;
}

const ProfileFeatureStatusSnapshot profileCompanyFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '我的公司',
      statusLabel: '部分可用',
      completedSummary: '已完成当前公司摘要、当前组织现状、认证资料摘要，以及进入公司与组织、公司认证与我的身份的后续入口。',
      incompleteSummary: '这里不重复铺设完整组织办理后台；创建、加入、切换组织与认证办理继续在下游入口承接。',
      dependencySummary: '当前会话、当前组织上下文、认证当前态读取。',
      unlockConditionSummary: '更大范围公司工作台或跨组织治理后台正式解锁。',
    );

const ProfileFeatureStatusSnapshot profileOrganizationFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '公司与组织',
      statusLabel: '部分可用',
      completedSummary: '已完成当前组织读取、编辑当前组织、再创建一个组织、加入组织与切换当前公司/组织。',
      incompleteSummary: '当前不扩成综合治理后台；不承接认证审核、项目治理或跨组织风控。',
      dependencySummary: '当前会话、组织真值、壳层当前组织切换。',
      unlockConditionSummary: '更大范围公司操作台与跨组织治理主线解锁。',
    );

const ProfileFeatureStatusSnapshot profileCertificationIdentityFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '公司认证与我的身份',
      statusLabel: '部分可用',
      completedSummary: '已完成公司与组织入口、认证办理入口、当前公司/组织、当前成员身份与当前认证状态回显。',
      incompleteSummary: '当前不承接统一企业后台，不扩成全量资质中心或多轮审核工作台。',
      dependencySummary: '当前组织上下文、认证真值、营业执照上传与最小审核链。',
      unlockConditionSummary: '认证治理后台或更大范围企业主体管理主线解锁。',
    );

const ProfileFeatureStatusSnapshot profileMemberManagementFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '成员管理',
      statusLabel: '部分可用',
      completedSummary: '已完成当前组织成员列表、最小角色调整与禁用处理。',
      incompleteSummary: '当前不承接邀请审批、批量操作、审计台或复杂权限编排。',
      dependencySummary: '当前组织上下文、成员真值、角色变更与禁用写链路。',
      unlockConditionSummary: '成员治理与审计主线解锁。',
    );

const ProfileFeatureStatusSnapshot profileMembershipFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '我的会员',
      statusLabel: '部分可用',
      completedSummary: '已完成会员当前态、权益摘要、配额摘要、说明页、配额说明页、升级引导页与直购最小入口。',
      incompleteSummary: '当前不承接续费、取消、退款、发票、KA/旗舰或复杂账单闭环。',
      dependencySummary: '会员真值、组织 scope、Server 订单与支付回调。',
      unlockConditionSummary: 'Admin 查询、支付治理与发布门禁解锁。',
    );

const ProfileFeatureStatusSnapshot profileCreditConstraintsFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '我的信用与约束',
      statusLabel: '部分可用',
      completedSummary: '已完成信用、保证金与交易保障姿态的状态、说明、衔接与依赖读取。',
      incompleteSummary: '当前不承接真实保证金缴纳、资金冻结、支付执行或结算。',
      dependencySummary: '信用/保证金/交易保障真值，以及 V2.2 支付与账单依赖。',
      unlockConditionSummary: '支付/账单执行闭环解锁。',
    );

const ProfileFeatureStatusSnapshot profilePaymentBillingFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '支付与账单状态',
      statusLabel: '部分可用',
      completedSummary: '已完成支付状态、账单引用、规则说明、处理与衔接、后续依赖读取。',
      incompleteSummary: '当前不承接下单、支付 provider、回调、结算、发票、税务与财务后台。',
      dependencySummary: '支付/账单真值、支付 provider、后续财务依赖。',
      unlockConditionSummary: '支付 MVP 主线解锁。',
    );

const ProfileFeatureStatusSnapshot profileGovernanceAppealsFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '我的申诉记录',
      statusLabel: '部分可用',
      completedSummary: '已完成当前账号申诉列表与最小详情只读回显。',
      incompleteSummary: '当前不承接新建申诉、补充材料、多轮沟通或治理处理台。',
      dependencySummary: '当前 actor scope、申诉真值、治理详情读取。',
      unlockConditionSummary: '申诉写链路或治理处理台主线解锁。',
    );

const ProfileFeatureStatusSnapshot profilePersonalFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '个人资料',
      statusLabel: '部分可用',
      completedSummary: '已完成个人资料摘要、头像与昵称单独入口、我的公司 handoff，以及会话与设备入口。',
      incompleteSummary: '简介入口当前未开放；实名身份与更大范围资料治理仍未开放。',
      dependencySummary: '当前会话、shell 资料摘要、头像与昵称审核链。',
      unlockConditionSummary: '更丰富资料编辑或实名主线正式解锁。',
    );

ProfileFeatureStatusSnapshot profileForumFeatureStatus({
  required bool runtimeReady,
}) {
  return ProfileFeatureStatusSnapshot(
    featureName: '我的论坛',
    statusLabel: runtimeReady ? '部分可用' : '处理中',
    completedSummary: '已完成我的论坛一层 handoff、二层论坛资产页，以及帖子、评论、收藏、关注、草稿的受控读取入口。',
    incompleteSummary: runtimeReady
        ? '我的论坛页不承接公域作者主页，也不扩成第二论坛首页或额外状态机。'
        : '当前 me-assets 或草稿读取仍未全部稳定返回，论坛资产页先保持受控整理状态。',
    dependencySummary: '论坛 me-assets 读取、草稿读取、当前会话 carrier。',
    unlockConditionSummary: runtimeReady
        ? '更深层论坛资产治理或互动工作台主线解锁。'
        : 'forum me-assets 与 draft list live smoke 全部通过。',
  );
}

const ProfileFeatureStatusSnapshot profileSettingsFeatureStatus =
    ProfileFeatureStatusSnapshot(
      featureName: '设置',
      statusLabel: '部分可用',
      completedSummary: '已完成账号与安全、通知、隐私与权限、界面与显示、通用、存储空间、关于我们等 app-native 分组。',
      incompleteSummary: '当前不提供独立通知开关、隐私写链路、缓存管理或系统级显示设置接管。',
      dependencySummary: '当前会话、当前账号摘要、app-native 设置分组边界。',
      unlockConditionSummary: '真实设置写链路与系统联动能力正式解锁。',
    );
