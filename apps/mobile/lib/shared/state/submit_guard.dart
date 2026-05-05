import 'package:flutter/foundation.dart';

class SubmitGuard extends ChangeNotifier {
  bool _submitting = false;

  bool get submitting => _submitting;

  Future<T?> run<T>(
    Future<T> Function() action, {
    bool canSubmit = true,
    VoidCallback? onBlocked,
  }) async {
    if (!canSubmit || _submitting) {
      onBlocked?.call();
      return null;
    }

    _submitting = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
