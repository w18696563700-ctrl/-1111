import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';

class LoginLegalEntryStrip extends StatelessWidget {
  const LoginLegalEntryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '登录前请先查看',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(ProfileIdentityRoutes.userAgreement);
                  },
                  child: const Text('用户协议'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(ProfileIdentityRoutes.privacyPolicy);
                  },
                  child: const Text('隐私政策'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '当前仍只承接手机号 + 验证码登录，不扩到其他登录方式或第二条认证路径。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentPage(
      assetPath: 'assets/legal/user_agreement.md',
      title: '用户协议',
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentPage(
      assetPath: 'assets/legal/privacy_policy.md',
      title: '隐私政策',
    );
  }
}

class _LegalDocumentPage extends StatelessWidget {
  const _LegalDocumentPage({required this.assetPath, required this.title});

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: const <Widget>[
              _LegalNoticeCard(
                title: '正文加载失败',
                message: '当前法务正文资产未能成功载入，请稍后重试。若问题持续存在，请检查 App 内置法律文书资产是否已打包。',
              ),
            ],
          );
        }

        final content = <String>[
          '> 当前展示的是仓库内可直接使用的法务正文。',
          '> 正文内容以仓库同步到 App 资产的最新版本为准。',
          '',
          snapshot.data!,
        ].join('\n');

        return Markdown(
          data: content,
          selectable: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        );
      },
    );
  }
}

class _LegalNoticeCard extends StatelessWidget {
  const _LegalNoticeCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
