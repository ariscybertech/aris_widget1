library widget.swap;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';

// TODO: cleaner about having requests pile up...handle the pending change cleanly

/**
 * [SwapWidget] is a low-level component designed to be composed by other
 * components. It exposes the functionality of the [Swapper] effect as a simple
 * container element with corresponding methods to
 * `swap` between child elements via code.
 *
 * [TabsWidget] and [CarouselWidget] both use this component.
 */
@CustomTag('swap-widget')
class SwapWidget extends PolymerElement {
  static const _ACTIVE_CLASS = 'active';
  static const _DIR_CLASS_PREV = 'prev';

  // should only be accessed via the [_contentElement] property
  ContentElement _contentElementField;

  SwapWidget.created() : super.created();

  int get activeItemIndex => items.indexOf(activeItem);

  Element get activeItem =>
    items.singleWhere((e) => e.classes.contains(_ACTIVE_CLASS));

  List<Element> get items => _contentElement.getDistributedNodes()
      .where((e) => e is Element)
      .toList(growable: false);

  Future<bool> showItemAtIndex(int index, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
    // TODO: support hide all if index == null

    final newActive = items[index];
    return showItem(newActive, effect: effect, duration: duration, effectTiming: effectTiming, hideEffect: hideEffect);
  }

  Future<bool> showItem(Element item, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
    assert(items.contains(item));

    final oldActiveChild = activeItem;
    if(oldActiveChild == item) {
      return new Future<bool>.value(true);
    }

    [oldActiveChild, item].forEach((e) => e.classes.remove(_DIR_CLASS_PREV));

    oldActiveChild.classes.remove(_ACTIVE_CLASS);
    oldActiveChild.classes.add(_DIR_CLASS_PREV);

    item.classes.add(_ACTIVE_CLASS);

    return Swapper.swap(items, item, effect: effect, duration: duration, effectTiming: effectTiming, hideEffect: hideEffect)
        .whenComplete(() {
          oldActiveChild.classes.remove(_DIR_CLASS_PREV);
        });
  }

  @override
  void enteredView() {
    _initialize();
  }

  @override
  void leftView() {
    _contentElementField = null;
  }

  ContentElement get _contentElement {
    _initialize();
    return _contentElementField;
  }

  void _initialize() {
    if(_contentElementField == null) {
      _contentElementField = shadowRoot.querySelector('content');
      if(_contentElementField == null) {
        throw 'Could not find the content element. Either the template has changed or state was accessed too early in the component lifecycle.';
      }

      var theItems = items;

      // if there are any elements, make sure one and only one is 'active'
      var activeFigures = new List<Element>.from(theItems.where((e) => e.classes.contains(_ACTIVE_CLASS)).toList());
      if(activeFigures.length == 0) {
        if(theItems.length > 0) {
          // marke the first of the figures as active
          theItems[0].classes.add(_ACTIVE_CLASS);
        }
      } else {
        activeFigures.sublist(1)
          .forEach((e) => e.classes.remove(_ACTIVE_CLASS));
      }

      // A bit of a hack. Because we call Swap w/ two displayed items:
      // one marked 'prev' and one marked 'next', Swap tries to hide one of them
      // this only causes a problem when clicking right the first time, since all
      // times after, the cached ShowHideState of the item is set
      // So...we're going to walk the showHide states of all children now
      // ...and ignore the result...but just to populate the values
      theItems.forEach((f) => ShowHide.getState(f));
    }
  }
}
