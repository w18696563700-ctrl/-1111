import 'package:flutter/material.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';

enum StatusBadgePolicyTone {
  success,
  warning,
  danger,
  neutral,
  info,
  pending,
  disabled,
  unknown,
}

class StatusBadgePolicy {
  const StatusBadgePolicy._();

  static AppStatusTone appTone(StatusBadgePolicyTone tone) {
    return switch (tone) {
      StatusBadgePolicyTone.success => AppStatusTone.success,
      StatusBadgePolicyTone.warning => AppStatusTone.warning,
      StatusBadgePolicyTone.danger => AppStatusTone.danger,
      StatusBadgePolicyTone.neutral => AppStatusTone.neutral,
      StatusBadgePolicyTone.info => AppStatusTone.info,
      StatusBadgePolicyTone.pending => AppStatusTone.pending,
      StatusBadgePolicyTone.disabled => AppStatusTone.disabled,
      StatusBadgePolicyTone.unknown => AppStatusTone.unknown,
    };
  }

  static String displayLabel(
    String? rawStatus, {
    String unknownLabel = '未知状态',
  }) {
    final normalized = rawStatus?.trim();
    if (normalized == null || normalized.isEmpty) {
      return unknownLabel;
    }
    return normalized;
  }

  static Widget badge({
    required String? label,
    StatusBadgePolicyTone tone = StatusBadgePolicyTone.unknown,
  }) {
    return AppStatusBadge(label: displayLabel(label), tone: appTone(tone));
  }
}
