import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher_string.dart';

typedef FileOpenInvoker =
    Future<OpenResult> Function(String path, {String? mimeType});
typedef ExternalUriInvoker = Future<bool> Function(Uri uri);
typedef FileOpenProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);
typedef FileOpenPlatformResolver = FileOpenPlatformSnapshot Function();

class FileOpenPlatformSnapshot {
  const FileOpenPlatformSnapshot({
    required this.isMacOS,
    required this.isLinux,
    required this.isWindows,
  });

  factory FileOpenPlatformSnapshot.current() {
    return FileOpenPlatformSnapshot(
      isMacOS: Platform.isMacOS,
      isLinux: Platform.isLinux,
      isWindows: Platform.isWindows,
    );
  }

  final bool isMacOS;
  final bool isLinux;
  final bool isWindows;
}

enum FileOpenOutcome { opened, failed }

class FileOpenCoordinatorResult {
  const FileOpenCoordinatorResult._({
    required this.outcome,
    required this.message,
  });

  const FileOpenCoordinatorResult.opened()
    : this._(outcome: FileOpenOutcome.opened, message: null);

  const FileOpenCoordinatorResult.failed(String message)
    : this._(outcome: FileOpenOutcome.failed, message: message);

  final FileOpenOutcome outcome;
  final String? message;

  bool get opened => outcome == FileOpenOutcome.opened;
}

class FileOpenCoordinator {
  FileOpenCoordinator({
    FileOpenInvoker? openFile,
    ExternalUriInvoker? openExternalUri,
    FileOpenProcessRunner? runProcess,
    FileOpenPlatformResolver? platformResolver,
  }) : _openFile = openFile ?? _defaultOpenFile,
       _openExternalUri = openExternalUri ?? _defaultOpenExternalUri,
       _runProcess = runProcess ?? Process.run,
       _platformResolver = platformResolver ?? FileOpenPlatformSnapshot.current;

  static final FileOpenCoordinator instance = FileOpenCoordinator();

  final FileOpenInvoker _openFile;
  final ExternalUriInvoker _openExternalUri;
  final FileOpenProcessRunner _runProcess;
  final FileOpenPlatformResolver _platformResolver;

  Future<FileOpenCoordinatorResult> openPath({
    required String path,
    String? mimeType,
  }) async {
    final resolvedPath = path.trim();
    if (resolvedPath.isEmpty) {
      return const FileOpenCoordinatorResult.failed('文件路径为空。');
    }

    try {
      final result = await _openFile(resolvedPath, mimeType: mimeType);
      if (result.type == ResultType.done) {
        return const FileOpenCoordinatorResult.opened();
      }
    } on PlatformException {
      // Fall through to desktop process open.
    } on IOException {
      // Fall through to desktop process open.
    }

    return _openPathByPlatformProcess(resolvedPath);
  }

  Future<FileOpenCoordinatorResult> openExternalUri(Uri uri) async {
    if (uri.scheme.isEmpty) {
      return const FileOpenCoordinatorResult.failed('外部链接无效。');
    }

    try {
      final opened = await _openExternalUri(uri);
      if (opened) {
        return const FileOpenCoordinatorResult.opened();
      }
    } on PlatformException {
      // Fall through to desktop process open.
    } on IOException {
      // Fall through to desktop process open.
    }

    return _openUriByPlatformProcess(uri);
  }

  Future<FileOpenCoordinatorResult> _openPathByPlatformProcess(
    String path,
  ) async {
    final process = await _runPlatformOpen(<String>[path]);
    if (process?.exitCode == 0) {
      return const FileOpenCoordinatorResult.opened();
    }
    return const FileOpenCoordinatorResult.failed('当前设备未能打开该文件。');
  }

  Future<FileOpenCoordinatorResult> _openUriByPlatformProcess(Uri uri) async {
    final process = await _runPlatformOpen(<String>[uri.toString()]);
    if (process?.exitCode == 0) {
      return const FileOpenCoordinatorResult.opened();
    }
    return const FileOpenCoordinatorResult.failed('当前设备未能打开该链接。');
  }

  Future<ProcessResult?> _runPlatformOpen(List<String> target) async {
    final platform = _platformResolver();
    try {
      if (platform.isMacOS) {
        return _runProcess('open', target);
      }
      if (platform.isLinux) {
        return _runProcess('xdg-open', target);
      }
      if (platform.isWindows) {
        return _runProcess('cmd', <String>['/c', 'start', '', ...target]);
      }
    } on ProcessException {
      return null;
    } on IOException {
      return null;
    }
    return null;
  }
}

Future<OpenResult> _defaultOpenFile(String path, {String? mimeType}) {
  return OpenFilex.open(path, type: mimeType);
}

Future<bool> _defaultOpenExternalUri(Uri uri) {
  return launchUrlString(uri.toString(), mode: LaunchMode.externalApplication);
}
