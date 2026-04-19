import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:mobile/features/profile/presentation/profile_avatar_picker.dart';

Future<ProfileAvatarPickedFile?> openProfileAvatarEditConfirmationPage(
  BuildContext context, {
  required ProfileAvatarPickedFile file,
  String title = '调整头像',
  String imageLabel = '图片',
  String defaultStem = 'avatar',
}) {
  return Navigator.of(context).push<ProfileAvatarPickedFile?>(
    MaterialPageRoute<ProfileAvatarPickedFile?>(
      builder: (_) => ProfileAvatarEditConfirmationPage(
        file: file,
        title: title,
        imageLabel: imageLabel,
        defaultStem: defaultStem,
      ),
    ),
  );
}

class ProfileAvatarEditConfirmationPage extends StatefulWidget {
  const ProfileAvatarEditConfirmationPage({
    required this.file,
    this.title = '调整头像',
    this.imageLabel = '图片',
    this.defaultStem = 'avatar',
    super.key,
  });

  final ProfileAvatarPickedFile file;
  final String title;
  final String imageLabel;
  final String defaultStem;

  @override
  State<ProfileAvatarEditConfirmationPage> createState() =>
      _ProfileAvatarEditConfirmationPageState();
}

class _ProfileAvatarEditConfirmationPageState
    extends State<ProfileAvatarEditConfirmationPage> {
  late CropController _cropController;
  late Uint8List _imageBytes;
  bool _cropping = false;
  bool _editorReady = false;
  bool _finishPending = false;
  bool _modified = false;
  String? _errorMessage;
  int _editorVersion = 0;

  @override
  void initState() {
    super.initState();
    _cropController = CropController();
    _imageBytes = Uint8List.fromList(widget.file.bytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: <Widget>[
          TextButton(
            onPressed: _cropping ? null : _finish,
            child: Text(
              _cropping ? '处理中' : '完成',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Crop(
                    key: ValueKey<int>(_editorVersion),
                    controller: _cropController,
                    image: _imageBytes,
                    aspectRatio: 1,
                    initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                      size: 0.82,
                      aspectRatio: 1,
                    ),
                    interactive: true,
                    baseColor: Colors.black,
                    maskColor: Colors.black54,
                    radius: 0,
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    onCropped: _handleCropped,
                    onStatusChanged: _handleStatusChanged,
                    overlayBuilder: (context, rect) =>
                        CustomPaint(painter: _AvatarCropGridPainter()),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: _cropping ? null : _rotateRight,
                    icon: const Icon(Icons.rotate_right),
                    label: const Text('旋转'),
                  ),
                  TextButton.icon(
                    onPressed: _cropping ? null : _flipHorizontal,
                    icon: const Icon(Icons.flip),
                    label: const Text('左右翻转'),
                  ),
                  TextButton.icon(
                    onPressed: _cropping ? null : _flipVertical,
                    icon: const Icon(Icons.flip_camera_android_outlined),
                    label: const Text('上下翻转'),
                  ),
                  TextButton.icon(
                    onPressed: _cropping || !_modified ? null : _restore,
                    icon: const Icon(Icons.restore),
                    label: const Text('还原'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: _cropping
                        ? null
                        : () => Navigator.of(context).pop(null),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: _cropping ? null : _finish,
                    child: Text(_cropping ? '处理中' : '完成'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rotateRight() {
    final decoded = image_lib.decodeImage(_imageBytes);
    if (decoded == null) {
      setState(() => _errorMessage = '当前${widget.imageLabel}无法旋转，请重新选择后再试。');
      return;
    }

    setState(() {
      _cropController = CropController();
      _imageBytes = Uint8List.fromList(
        image_lib.encodePng(image_lib.copyRotate(decoded, angle: 90)),
      );
      _editorReady = false;
      _modified = true;
      _errorMessage = null;
      _editorVersion += 1;
    });
  }

  void _flipHorizontal() {
    final decoded = image_lib.decodeImage(_imageBytes);
    if (decoded == null) {
      setState(() => _errorMessage = '当前${widget.imageLabel}无法翻转，请重新选择后再试。');
      return;
    }

    setState(() {
      _cropController = CropController();
      _imageBytes = Uint8List.fromList(
        image_lib.encodePng(image_lib.flipHorizontal(decoded)),
      );
      _editorReady = false;
      _modified = true;
      _errorMessage = null;
      _editorVersion += 1;
    });
  }

  void _flipVertical() {
    final decoded = image_lib.decodeImage(_imageBytes);
    if (decoded == null) {
      setState(() => _errorMessage = '当前${widget.imageLabel}无法翻转，请重新选择后再试。');
      return;
    }

    setState(() {
      _cropController = CropController();
      _imageBytes = Uint8List.fromList(
        image_lib.encodePng(image_lib.flipVertical(decoded)),
      );
      _editorReady = false;
      _modified = true;
      _errorMessage = null;
      _editorVersion += 1;
    });
  }

  void _restore() {
    setState(() {
      _cropController = CropController();
      _imageBytes = Uint8List.fromList(widget.file.bytes);
      _editorReady = false;
      _finishPending = false;
      _modified = false;
      _errorMessage = null;
      _editorVersion += 1;
    });
  }

  void _finish() {
    if (!_editorReady) {
      setState(() {
        _cropping = true;
        _finishPending = true;
        _errorMessage = '当前${widget.imageLabel}正在准备中，准备完成后会继续裁切。';
      });
      return;
    }
    setState(() {
      _cropping = true;
      _finishPending = false;
      _errorMessage = null;
    });
    _cropController.crop();
  }

  void _handleStatusChanged(CropStatus status) {
    if (!mounted) {
      return;
    }
    final ready = status == CropStatus.ready;
    setState(() => _editorReady = ready);
    if (ready && _finishPending) {
      _finishPending = false;
      Future<void>.microtask(() {
        if (mounted && _cropping) {
          _cropController.crop();
        }
      });
    }
  }

  void _handleCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(
          ProfileAvatarPickedFile(
            fileName: _editedFileName(croppedImage),
            mimeType: _mimeTypeFor(croppedImage),
            bytes: croppedImage,
          ),
        );
      case CropFailure():
        if (!mounted) {
          return;
        }
        setState(() {
          _cropping = false;
          _errorMessage = '当前${widget.imageLabel}裁切失败，请调整裁切区域后重试。';
        });
    }
  }

  String _editedFileName(Uint8List bytes) {
    final extension = _mimeTypeFor(bytes) == 'image/jpeg' ? 'jpg' : 'png';
    final baseName = widget.file.fileName.trim();
    final dotIndex = baseName.lastIndexOf('.');
    final stem = dotIndex > 0 ? baseName.substring(0, dotIndex) : widget.defaultStem;
    final normalizedStem = stem.trim().isEmpty ? widget.defaultStem : stem.trim();
    return '${normalizedStem}_edited.$extension';
  }

  String _mimeTypeFor(Uint8List bytes) {
    if (bytes.length > 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    return 'image/png';
  }
}

class _AvatarCropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;
    for (var index = 1; index <= 2; index += 1) {
      canvas.drawLine(
        Offset(thirdWidth * index, 0),
        Offset(thirdWidth * index, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, thirdHeight * index),
        Offset(size.width, thirdHeight * index),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarCropGridPainter oldDelegate) => false;
}
