import 'dart:async';

import 'package:flutter/foundation.dart';

class OtpSendCooldownController extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;

  int get remainingSeconds => _remainingSeconds;
  bool get isCoolingDown => _remainingSeconds > 0;

  void start(int seconds) {
    _timer?.cancel();
    _remainingSeconds = seconds < 0 ? 0 : seconds;
    notifyListeners();
    if (_remainingSeconds <= 0) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _remainingSeconds = 0;
        notifyListeners();
        return;
      }

      _remainingSeconds -= 1;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
