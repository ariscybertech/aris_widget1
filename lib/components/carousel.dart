library widget.carousel;

import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';
import 'swap.dart';

// TODO: option to enable/disable wrapping. Disable buttons if the end is hit...

/**
 * [CarouselWidget] allows moving back and forth through a set of child
 * elements.
 *
 * It is based on a [similar component](http://getbootstrap.com/javascript/#carousel)
 * in Bootstrap.
 *
 * [CarouselWidget] leverages the [SwapWidget] to render the transition
 * between items.
 */
@CustomTag('carousel-widget')
class CarouselWidget extends PolymerElement {

  static const _DURATION = 1000;

  final ShowHideEffect _fromTheLeft =
      new SlideEffect(xStart: HorizontalAlignment.LEFT);

  final ShowHideEffect _fromTheRight =
      new SlideEffect(xStart: HorizontalAlignment.RIGHT);

  CarouselWidget.created() : super.created();

  bool get applyAuthorStyles => true;

  Future<bool> _pendingAction = null;

  Future<bool> next() => _moveDelta(true);

  Future<bool> previous() => _moveDelta(false);

  void onNext(event, detail, target) {
    next();
  }

  void onPrevious(event, detail, target) {
    previous();
  }

  SwapWidget get _swap =>
      shadowRoot.querySelector('.carousel > swap-widget').xtag;

  Future<bool> _moveDelta(bool doNext) {
    if (_pendingAction != null) {
      // Ignore all calls to moveDelta until the current pending action is
      // complete to avoid ugly janky UI.
      return _pendingAction.then((_) => false);
    }

    var swap = _swap;
    assert(swap != null);

    if (swap.items.length == 0) {
      return new Future.value(false);
    }

    assert(doNext != null);
    var delta = doNext ? 1 : -1;

    ShowHideEffect showEffect, hideEffect;
    if (doNext) {
      showEffect = _fromTheRight;
      hideEffect = _fromTheLeft;
    } else {
      showEffect = _fromTheLeft;
      hideEffect = _fromTheRight;
    }

    var activeIndex = _swap.activeItemIndex;

    var newIndex = (activeIndex + delta) % _swap.items.length;

    return _pendingAction = _swap.showItemAtIndex(newIndex, effect: showEffect,
        hideEffect: hideEffect, duration: _DURATION)
          .whenComplete(() { _pendingAction = null; });
  }
}
