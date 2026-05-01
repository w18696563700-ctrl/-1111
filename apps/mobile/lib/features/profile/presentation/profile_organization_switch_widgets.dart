import 'package:flutter/material.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_organization_capability_copy.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

class OrganizationSwitchCard extends StatelessWidget {
  const OrganizationSwitchCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title?.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (resolvedTitle != null && resolvedTitle.isNotEmpty) ...<Widget>[
              Text(
                resolvedTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class OrganizationSwitchCurrentBanner extends StatelessWidget {
  const OrganizationSwitchCurrentBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.supportingText,
  });

  final String title;
  final String? subtitle;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              supportingText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoCurrentOrganizationAction extends StatelessWidget {
  const NoCurrentOrganizationAction({
    super.key,
    required this.onOpenOrganizationHub,
  });

  final VoidCallback onOpenOrganizationHub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('当前账号没有可用的公司/组织主体，请创建组织或通过邀请码加入组织后继续使用。'),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: onOpenOrganizationHub,
          child: const Text('去公司与组织'),
        ),
      ],
    );
  }
}

class OrganizationLeaveActionCard extends StatelessWidget {
  const OrganizationLeaveActionCard({
    super.key,
    required this.current,
    required this.leaving,
    required this.onLeave,
  });

  final MyOrganizationItemView current;
  final bool leaving;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return OrganizationSwitchCard(
      title: '退出当前组织',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '退出对象：${profileDisplayOrganizationName(current.name)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '退出后不能再以该组织身份管理项目、认证、竞标和消息；公司、认证资料和历史记录会保留。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: leaving ? null : onLeave,
            child: Text(leaving ? '退出中' : '退出当前组织'),
          ),
        ],
      ),
    );
  }
}

class OrganizationSwitchList extends StatelessWidget {
  const OrganizationSwitchList({
    super.key,
    required this.items,
    required this.currentOrganizationId,
    required this.switchingOrganizationId,
    required this.onSwitch,
  });

  final List<MyOrganizationItemView> items;
  final String? currentOrganizationId;
  final String? switchingOrganizationId;
  final ValueChanged<MyOrganizationItemView> onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            _OrganizationSwitchRow(
              item: items[index],
              current:
                  items[index].current ||
                  items[index].organizationId == currentOrganizationId,
              busy: switchingOrganizationId != null,
              switching: switchingOrganizationId == items[index].organizationId,
              onTap: () => onSwitch(items[index]),
            ),
            if (index != items.length - 1)
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _OrganizationSwitchRow extends StatelessWidget {
  const _OrganizationSwitchRow({
    required this.item,
    required this.current,
    required this.busy,
    required this.switching,
    required this.onTap,
  });

  final MyOrganizationItemView item;
  final bool current;
  final bool busy;
  final bool switching;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.35,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: current || busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profileDisplayOrganizationName(item.name),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '能力：${profileDisplayOrganizationCapabilitySummary(item.organizationType, roleKeys: item.roleKeys)}；'
                    '企业认证：${profileDisplayCertificationStatus(item.certificationStatus)}；'
                    '成员：${profileDisplayMembershipStatus(item.membershipStatus)}',
                    style: subtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (current)
              _OrganizationCurrentChip(colorScheme: theme.colorScheme)
            else if (switching)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '切换',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationCurrentChip extends StatelessWidget {
  const _OrganizationCurrentChip({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '当前',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
