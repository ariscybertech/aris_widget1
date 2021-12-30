part of effects_tests;

class TestTimeManager extends TimeManager {
  RequestAnimationFrameCallback _callback = null;

  // yes, this is a dupe of the value stored in TimeManager
  // that's okay. They should align nicely
  int _callbackId = 0;
  int _currentTick = 0;

  void tick(int count) {
    assert(isValidNumber(count));
    assert(count > 0);
    _currentTick += count;
    if(_callback != null) {
      _callback(_currentTick);
    }
  }

  // override, protected
  int requestFrame(RequestAnimationFrameCallback callback) {
    assert(_callback == null);
    assert(callback != null);
    _callback = callback;
    return _callbackId;
  }

  // override, protected
  void cancelAnimationFrame(int id) {
    assert(_callback != null);
    assert(id == _callbackId);
    _callback = null;
    _callbackId++;
  }

  // override, protected
  num getNowMilliseconds() => _currentTick;
}
