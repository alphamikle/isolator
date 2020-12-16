import 'dart:math';

import 'package:flutter/scheduler.dart';

class FpsMonitor {
  static FpsMonitor _instance;
  static FpsMonitor get instance {
    return _instance ??= FpsMonitor();
  }

  /// Frames per second of your screen
  double _refreshRate = 60;

  set refreshRate(double refreshRate) {
    _refreshRate = refreshRate;
    _msPerFrame = 1000 / refreshRate;
  }

  double get refreshRate => _refreshRate;

  Ticker _ticker;

  /// Time in ms for render one frame
  double _msPerFrame;

  double _refreshDiff = 0;

  double _prevRefreshTime;

  final List<FrameInfo> _metrics = [];

  void start() {
    _metrics.clear();
    _ticker = Ticker(_onTick);
    _ticker.start();
  }

  List<double> stop() {
    _ticker.stop(canceled: true);
    _ticker = null;
    _refreshDiff = 0;
    _prevRefreshTime = null;
    return [..._metrics].map((FrameInfo frameInfo) => frameInfo.renderTime).toList();
  }

  void _onTick(Duration d) {
    final double ms = d.inMicroseconds / 1000;
    if (_prevRefreshTime == null) {
      _prevRefreshTime = ms;
      _refreshDiff = _msPerFrame;
      return;
    }
    _refreshDiff = (ms - _prevRefreshTime).toDouble();
    final double fps = min((_msPerFrame / _refreshDiff) * _refreshRate, _refreshRate);
    _metrics.add(FrameInfo(_refreshDiff, fps));
    _prevRefreshTime = ms;
  }
}

class FrameInfo {
  const FrameInfo(this.renderTime, this.fpsAtNow);

  final double renderTime;
  final double fpsAtNow;
}
