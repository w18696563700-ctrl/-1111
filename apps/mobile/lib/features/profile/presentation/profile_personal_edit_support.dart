import 'package:flutter/material.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

String profileResolvedDisplayName({
  required String? displayName,
  required String? rawUserId,
}) {
  final visibleDisplayName = displayName?.trim();
  if (visibleDisplayName != null && visibleDisplayName.isNotEmpty) {
    return visibleDisplayName;
  }
  return profileDisplayName(rawUserId);
}

String profileResolvedNickname(String? displayName) {
  final visibleDisplayName = displayName?.trim();
  if (visibleDisplayName == null || visibleDisplayName.isEmpty) {
    return '未设置';
  }
  return visibleDisplayName;
}

String? profileResolvedAvatarUrl(String? avatarUrl) {
  final value = avatarUrl?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

String profileResolvedAvatarFallbackLabel({
  required String? displayName,
  required String? rawUserId,
}) {
  final visibleName = profileResolvedDisplayName(
    displayName: displayName,
    rawUserId: rawUserId,
  ).trim();
  if (visibleName.isEmpty ||
      visibleName == '未登录' ||
      visibleName == '当前用户') {
    return '我';
  }
  return visibleName.characters.first;
}

String? profileNicknameValidationError(String value) {
  if (value.isEmpty) {
    return '昵称不能为空';
  }
  if (value.trim() != value) {
    return '昵称不支持空格';
  }
  if (!RegExp(r'^[\u4e00-\u9fff]{1,10}$').hasMatch(value)) {
    return '昵称仅支持 1~10 个中文汉字，不支持空格、字母、数字、标点和 emoji';
  }
  return null;
}

bool profileNicknameSubmitEnabled({
  required String candidate,
  required String initialDisplayName,
}) {
  if (profileNicknameValidationError(candidate) != null) {
    return false;
  }
  return candidate.trim() != initialDisplayName.trim();
}

class ProfileAvatarBadge extends StatelessWidget {
  const ProfileAvatarBadge({
    super.key,
    required this.avatarUrl,
    required this.fallbackLabel,
    required this.semanticLabel,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String? avatarUrl;
  final String fallbackLabel;
  final String semanticLabel;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedAvatarUrl = profileResolvedAvatarUrl(avatarUrl);
    final resolvedBackgroundColor =
        backgroundColor ?? theme.colorScheme.primaryContainer;
    final resolvedForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            fallbackLabel,
            style:
                textStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: resolvedForegroundColor,
                ),
          ),
        ),
      ),
    );

    return Semantics(
      label: semanticLabel,
      image: resolvedAvatarUrl != null,
      child: SizedBox(
        width: size,
        height: size,
        child: resolvedAvatarUrl == null
            ? fallback
            : ClipOval(
                child: Image.network(
                  resolvedAvatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                  excludeFromSemantics: true,
                ),
              ),
      ),
    );
  }
}
