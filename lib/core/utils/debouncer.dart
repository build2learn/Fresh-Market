import 'dart:async';

typedef DebounceCallback = void Function();

class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  void run(DebounceCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
