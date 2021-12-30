import 'dart:async';
import 'dart:html';
import 'package:widget/effects.dart';

void main() {

  _initialize();
  querySelector('#do-swap').onClick.listen(_doSwap);

}

int _time = 0;

void _doSwap(event) {
  int time = _time++;

  final flag = 'swap $time';

  window.console.time(flag);

  _moveDelta()
    .then((bool value) {
      window.console.timeEnd(flag);
    });

}

final ShowHideEffect _fromTheLeft = new SlideEffect(xStart: HorizontalAlignment.LEFT);
final ShowHideEffect _fromTheRight = new SlideEffect(xStart: HorizontalAlignment.RIGHT);
const _duration = 2000;
final _itemCount = 3;
const _activeClass = 'active';
const _dirClassPrev = 'prev';

Element _contentElementField;

bool _initialized = false;

int get _activeItemIndex {
  return _contentElementField.children.indexOf(_activeItem);
}

Element get _activeItem {
  return _contentElementField.children.singleWhere((e) => e.classes.contains(_activeClass));
}

Future<bool> _moveDelta() {
  final delta = 1;

  final  showEffect = _fromTheRight;
  final  hideEffect = _fromTheLeft;

  final newIndex = (_activeItemIndex + delta) % _itemCount;

  return showItemAtIndex(newIndex, effect: showEffect, hideEffect: hideEffect, duration: _duration);
}

Future<bool> showItemAtIndex(int index, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
  // TODO: support hide all if index == null

  final newActive = _contentElementField.children[index];
  return showItem(newActive, effect: effect, duration: duration, effectTiming: effectTiming, hideEffect: hideEffect);
}

Future<bool> showItem(Element item, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
  assert(_contentElementField.children.contains(item));

  final oldActiveChild = _activeItem;
  if(oldActiveChild == item) {
    return new Future<bool>.value(true);
  }

  [oldActiveChild, item].forEach((e) => e.classes.remove(_dirClassPrev));

  oldActiveChild.classes.remove(_activeClass);
  oldActiveChild.classes.add(_dirClassPrev);

  item.classes.add(_activeClass);

  return Swapper.swap(_contentElementField.children, item,
      effect: effect, duration: duration, effectTiming: effectTiming,
      hideEffect: hideEffect)
      .whenComplete(() {
        oldActiveChild.classes.remove(_dirClassPrev);
      });
}


void _initialize() {
  if(_contentElementField == null) {
    _contentElementField = querySelector('.content');
    if(_contentElementField == null) {
      throw 'Could not find the content element. Either the template has changed or state was accessed too early in the component lifecycle.';
    }

    final theItems = _contentElementField.children;

    // if there are any elements, make sure one and only one is 'active'
    final activeFigures = new List<Element>.from(theItems.where((e) => e.classes.contains(_activeClass)).toList());
    if(activeFigures.length == 0) {
      if(theItems.length > 0) {
        // marke the first of the figures as active
        theItems[0].classes.add(_activeClass);
      }
    } else {
      activeFigures.sublist(1)
      .forEach((e) => e.classes.remove(_activeClass));
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
