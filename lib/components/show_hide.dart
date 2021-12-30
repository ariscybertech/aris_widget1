library widget.tabs;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('show-hide-widget')
class ShowHideWidget extends PolymerElement {
  static const String _TOGGLE_EVENT_NAME = 'toggle';

  static const EventStreamProvider<Event> toggleEvent =
      const EventStreamProvider<Event>(_TOGGLE_EVENT_NAME);

  ShowHideWidget.created() : super.created();

  ShowHideWidget.createdWithValue(bool isShown) :
    this._isShown = isShown,
    super.created();

  bool _isShown = false;

  bool get isShown => _isShown;

  void set isShown(bool value) {
    assert(value != null);
    if(value != _isShown) {
      _isShown = value;
      notifyPropertyChange(#isShown, !isShown, isShown);
      dispatchEvent(new Event(_TOGGLE_EVENT_NAME));
    }
  }

  void hide() {
    isShown = false;
  }

  void show() {
    isShown = true;
  }

  void toggle() {
    isShown = !isShown;
  }
}
