import 'package:flutter/foundation.dart';

import 'result.dart';

class Command0<T> extends ChangeNotifier {
  Command0(this._action);

  final Future<Result<T>> Function() _action;

  bool _running = false;
  bool _completed = false;
  Object? _error;
  Result<T>? _result;

  bool get running => _running;
  bool get completed => _completed;
  Object? get error => _error;
  Result<T>? get result => _result;

  Future<void> execute() async {
    if (_running) {
      return;
    }

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    final actionResult = await _action();
    _result = actionResult;
    switch (actionResult) {
      case Ok<T>():
        _error = null;
      case Error<T>():
        _error = actionResult.error;
    }

    _running = false;
    _completed = true;
    notifyListeners();
  }

  void clearResult() {
    _completed = false;
    _error = null;
    _result = null;
    notifyListeners();
  }
}

class Command1<A, T> extends ChangeNotifier {
  Command1(this._action);

  final Future<Result<T>> Function(A value) _action;

  bool _running = false;
  bool _completed = false;
  Object? _error;
  Result<T>? _result;

  bool get running => _running;
  bool get completed => _completed;
  Object? get error => _error;
  Result<T>? get result => _result;

  Future<void> execute(A value) async {
    if (_running) {
      return;
    }

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    final actionResult = await _action(value);
    _result = actionResult;
    switch (actionResult) {
      case Ok<T>():
        _error = null;
      case Error<T>():
        _error = actionResult.error;
    }

    _running = false;
    _completed = true;
    notifyListeners();
  }

  void clearResult() {
    _completed = false;
    _error = null;
    _result = null;
    notifyListeners();
  }
}
