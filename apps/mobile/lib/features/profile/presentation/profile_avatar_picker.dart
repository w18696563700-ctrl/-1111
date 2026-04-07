import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum ProfileAvatarPickSource { camera, gallery }

class ProfileAvatarPickedFile {
  const ProfileAvatarPickedFile({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final List<int> bytes;
}

class ProfileAvatarPickResult {
  const ProfileAvatarPickResult._({
    required this.cancelled,
    this.file,
    this.message,
  });

  const ProfileAvatarPickResult.cancelled()
    : this._(cancelled: true, file: null, message: null);

  const ProfileAvatarPickResult.failure(String message)
    : this._(cancelled: false, file: null, message: message);

  const ProfileAvatarPickResult.selected(ProfileAvatarPickedFile file)
    : this._(cancelled: false, file: file, message: null);

  final bool cancelled;
  final ProfileAvatarPickedFile? file;
  final String? message;
}

abstract class ProfileAvatarPicker {
  static ProfileAvatarPicker _instance = ImagePickerProfileAvatarPicker();

  static ProfileAvatarPicker get instance => _instance;

  static void install(ProfileAvatarPicker picker) {
    _instance = picker;
  }

  static void reset() {
    _instance = ImagePickerProfileAvatarPicker();
  }

  Future<ProfileAvatarPickResult> pick({
    required ProfileAvatarPickSource source,
  });
}

class ImagePickerProfileAvatarPicker implements ProfileAvatarPicker {
  ImagePickerProfileAvatarPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ProfileAvatarPickResult> pick({
    required ProfileAvatarPickSource source,
  }) async {
    try {
      final file = await _picker.pickImage(
        source: source == ProfileAvatarPickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) {
        return const ProfileAvatarPickResult.cancelled();
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return const ProfileAvatarPickResult.failure('当前没有读取到可用头像图片。');
      }

      return ProfileAvatarPickResult.selected(
        ProfileAvatarPickedFile(
          fileName: file.name.trim().isEmpty ? 'avatar.jpg' : file.name.trim(),
          mimeType: _resolveMimeType(file.name),
          bytes: bytes,
        ),
      );
    } on PlatformException {
      return const ProfileAvatarPickResult.failure(
        '当前设备暂时无法完成头像选择，请稍后再试。',
      );
    } on UnsupportedError {
      return const ProfileAvatarPickResult.failure(
        '当前设备暂不支持头像选择，请稍后再试。',
      );
    }
  }

  String _resolveMimeType(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lowerName.endsWith('.heic') || lowerName.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }
}
