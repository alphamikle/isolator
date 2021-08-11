const int LOG_PADDING = 70;

class _Benchmark {
  final Map<String, int> _starts = <String, int>{};

  void start(dynamic id) {
    final String strId = id.toString();
    if (_starts.containsKey(strId)) {
      print('Benchmark already have comparing with id=$strId in time');
    } else {
      _starts[strId] = DateTime.now().microsecondsSinceEpoch;
    }
  }

  void end(dynamic id) {
    final String strId = id.toString();
    if (!_starts.containsKey(strId)) {
      print('In Benchmark not placed comparing with id=$strId');
    } else {
      print('$strId need ${(DateTime.now().microsecondsSinceEpoch - _starts[strId]!) / 1000}ms');
      _starts.remove(strId);
    }
  }

  void startService(dynamic id) {
    start('$id'.padLeft(LOG_PADDING, ':'));
  }

  void endService(dynamic id) {
    end('$id'.padLeft(LOG_PADDING, ':'));
  }

  void startTimer(dynamic id) {
    start(id);
  }

  double endTimer(dynamic id) {
    final String strId = id.toString();
    if (!_starts.containsKey(strId)) {
      print('In Benchmark not placed comparing with id=$strId');
    }
    final double diff = (DateTime.now().microsecondsSinceEpoch - _starts[strId]!) / 1000;
    _starts.remove(strId);
    return diff;
  }
}

final _Benchmark bench = _Benchmark();
