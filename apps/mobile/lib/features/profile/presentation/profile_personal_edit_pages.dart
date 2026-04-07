part of 'profile_detail_pages.dart';

Future<void> openProfilePersonalAvatarPage(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: ProfileRoutes.personalAvatar),
      builder: (_) => const ProfilePersonalAvatarRoutePage(),
    ),
  );
}

Future<void> openProfilePersonalNicknamePage(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: ProfileRoutes.personalNickname),
      builder: (_) => const ProfilePersonalNicknameRoutePage(),
    ),
  );
}
