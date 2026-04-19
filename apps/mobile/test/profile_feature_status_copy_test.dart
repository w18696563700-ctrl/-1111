import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/presentation/profile_feature_status_copy.dart';

void main() {
  test(
    'profile personal feature status copy stays aligned with frozen source',
    () {
      expect(profilePersonalFeatureStatus.featureName, '个人资料');
      expect(
        profilePersonalFeatureStatus.incompleteSummary,
        '简介入口当前未开放；实名身份与更大范围资料治理仍未开放。',
      );
    },
  );

  test(
    'profile forum feature status copy stays aligned with frozen source',
    () {
      final snapshot = profileForumFeatureStatus(runtimeReady: true);

      expect(snapshot.featureName, '我的论坛');
      expect(snapshot.incompleteSummary, '我的论坛页不承接公域作者主页，也不扩成第二论坛首页或额外状态机。');
    },
  );
}
