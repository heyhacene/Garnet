import 'dart:async';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/foundation.dart';

class BatteryService extends ChangeNotifier {
  final FLauncherChannel _channel;
  StreamSubscription<dynamic>? _subscription;

  bool _present = false;
  int _level = -1;
  bool _isCharging = false;

  bool get isPresent => _present;
  int get level => _level;
  bool get isCharging => _isCharging;
  bool get hasBatteryData => _present && _level >= 0;

  BatteryService(this._channel) {
    _init();
  }

  Future<void> _init() async {
    final initial = await _channel.getBatteryInfo();
    _apply(initial);
    _subscription = _channel.addBatteryChangedListener(_apply);
  }

  void _apply(Map<String, dynamic> info) {
    if (info.isEmpty) return;
    final bool nextPresent = info['present'] == true;
    final int nextLevel = (info['level'] is num) ? (info['level'] as num).round().clamp(-1, 100) : -1;
    final bool nextCharging = info['charging'] == true;

    if (nextPresent != _present || nextLevel != _level || nextCharging != _isCharging) {
      _present = nextPresent;
      _level = nextLevel;
      _isCharging = nextCharging;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
