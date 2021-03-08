const int LOG_PADDING = 70;

class _Benchmark {
  final Map<String, int> _starts = <String, int>{};

  void start(dynamic id) {
    id = id.toString();
    if (_starts.containsKey(id)) {
      print('Benchmark already have comparing with id=$id in time');
    } else {
      _starts[id] = DateTime.now().microsecondsSinceEpoch;
    }
  }

  void end(dynamic id) {
    id = id.toString();
    if (!_starts.containsKey(id)) {
      print('In Benchmark not placed comparing with id=$id');
    } else {
      print('$id need ${(DateTime.now().microsecondsSinceEpoch - _starts[id]!) / 1000}ms');
      _starts.remove(id);
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
    id = id.toString();
    if (!_starts.containsKey(id)) {
      print('In Benchmark not placed comparing with id=$id');
    }
    final double diff = (DateTime.now().microsecondsSinceEpoch - _starts[id]!) / 1000;
    _starts.remove(id);
    return diff;
  }
}

final _Benchmark bench = _Benchmark();
