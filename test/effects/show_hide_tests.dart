part of effects_tests;

void registerShowHideTests() {
  group('ShowHide', () {
    final displayValues = ['block', 'inline-block', 'inline', 'none', 'inherit', ''];

    for(final tag in ['div', 'span']) {
      for(final inheritedStyle in displayValues) {
        for(final inlineStyle in displayValues) {
          _registerTest(tag, inheritedStyle, inlineStyle);
        }
      }
    }
  });
}

// intentionally picking a 'weird' value that neither the style nor the element
// ever has defined
final String _playgroundWrapperDisplay = 'list-item';

void _registerTest(String tag, String sheetStyle, String inlineStyle) {
  final title = '[$tag~${_getEmptyText(sheetStyle)}~${_getEmptyText(inlineStyle)}]';
  group(title, () {
    setUp(() {
      _createShowHidePlayground(tag, sheetStyle, inlineStyle);
    });

    tearDown(_cleanUpPlayground);

    test('initial state', () {

      final sampleElement = querySelector('.sample');

      final tuple = _getValues(tag, sheetStyle, inlineStyle, sampleElement);

      final defaultTagValue = tuple.item1;
      final calculatedDisplayValue = tuple.item2;
      final calculatedState = tuple.item3;

      final expectedDisplayValue = _getExpectedInitialCalculatedValue(defaultTagValue, sheetStyle, inlineStyle);

      expect(expectedDisplayValue, isNot(isEmpty), reason: 'Expected value should not be empty string');
      expect(calculatedDisplayValue, expectedDisplayValue);

      final expectedState = _getState(calculatedDisplayValue);

      expect(calculatedState, isNotNull);
      expect(calculatedState, expectedState);
    });

    final actions = [ShowHideAction.SHOW, ShowHideAction.HIDE, ShowHideAction.TOGGLE];

    for(final a1 in actions) {

      test(a1.name, () {
        final element = querySelector('.sample');

        String initialCalculatedValue;

        final future = new Future(() {
              initialCalculatedValue = element.getComputedStyle('').display;
              return ShowHide.begin(a1, element);
            })
            .then((_) => _getValues(tag, sheetStyle, inlineStyle, element))
            .then((Tuple3<String, String, ShowHideState> tuple) {
              final defaultTagValue = tuple.item1;
              final calculatedDisplayValue = tuple.item2;

              final calculatedState = tuple.item3;

              _verifyState([a1], tag, sheetStyle, inlineStyle, defaultTagValue, element,
                  initialCalculatedValue, calculatedState, calculatedDisplayValue);
            });

        expect(future, finishes);

      });

      for(final a2 in actions) {
        test('$a1 then $a2', () {
          final element = querySelector('.sample');

          String initialCalculatedValue;

          final future = new Future(() {
                initialCalculatedValue = element.getComputedStyle('').display;
                return ShowHide.begin(a1, element);
              })
              .then((_) => ShowHide.begin(a2, element))
              .then((_) => _getValues(tag, sheetStyle, inlineStyle, element))
              .then((Tuple3<String, String, ShowHideState> tuple) {

                final defaultTagValue = tuple.item1;
                final calculatedDisplayValue = tuple.item2;

                final calculatedState = tuple.item3;

                _verifyState([a1, a2], tag, sheetStyle, inlineStyle, defaultTagValue, element,
                    initialCalculatedValue, calculatedState, calculatedDisplayValue);
              });

          expect(future, finishes);
        });
      }
    }
  });
}

void _verifyState(List<ShowHideAction> actions, String tag, String sheetStyle, String inlineStyle,
                  String defaultTagValue,
                  Element element, String initialCalculatedValue,
                  ShowHideState calculatedState, String calculatedDisplayValue) {
  final initialDisplayValue = _getExpectedInitialCalculatedValue(defaultTagValue, sheetStyle, inlineStyle);
  final initialState = _getState(initialDisplayValue);

  ShowHideState expectedState = initialState;
  for(final theAction in actions) {
    expectedState = _getActionResult(theAction, expectedState);
  }

  expect(calculatedState, expectedState, reason: 'The calculated state did not match the expected state');

  final expectedCalculatedDisplay = _getExpectedCalculatedDisplay(tag, sheetStyle, inlineStyle, calculatedState, defaultTagValue);
  expect(expectedCalculatedDisplay, isNot(''), reason: 'calculated display should never be empty string');
  expect(calculatedDisplayValue, expectedCalculatedDisplay, reason: 'The calculated display value is off');

  final localDisplay = element.style.display;
  final expectedLocalDisplay = _getExpectedLocalDisplay(tag, sheetStyle, inlineStyle, calculatedState, defaultTagValue,
      initialCalculatedValue);
  expect(localDisplay, expectedLocalDisplay, reason: 'The local display value is off');
}

String _getExpectedLocalDisplay(String tag, String sheetStyle, String inlineStyle, ShowHideState state, String tagDefault, String initialCalculatedValue) {
  switch(state) {
    case ShowHideState.HIDDEN:
      return 'none';
    case ShowHideState.SHOWN:
      if(inlineStyle == 'none') {
        return tagDefault;
      } else if(inlineStyle == '' && sheetStyle == 'none') {
        return tagDefault;
      } else if(inlineStyle == 'inherit') {
        if(initialCalculatedValue != 'none') {
          return inlineStyle;
        } else {
          return initialCalculatedValue;
        }
      } else if(inlineStyle != '') {
        return inlineStyle;
      }
      return '';
    default:
      throw 'no clue about $state';
  }
}

String _getExpectedCalculatedDisplay(String tag, String sheetStyle, String inlineStyle, ShowHideState state, String tagDefault) {
  switch(state) {
    case ShowHideState.HIDDEN:
      return 'none';
    case ShowHideState.SHOWN:
      if (inlineStyle == '') {
        if(sheetStyle == 'inherit') {
          return _playgroundWrapperDisplay;
        }
        else if(sheetStyle != 'none' && sheetStyle != '') {
          return sheetStyle;
        }
      } else if(inlineStyle == 'inherit') {
        return _playgroundWrapperDisplay;
      } else if(inlineStyle != 'none' && inlineStyle != 'inherit') {
        return inlineStyle;
      }
      return tagDefault;
    default:
      throw 'no clue about $state';
  }
}

ShowHideState _getActionResult(ShowHideAction action, ShowHideState initial) {
  switch(action) {
    case ShowHideAction.SHOW:
      return ShowHideState.SHOWN;
    case ShowHideAction.HIDE:
      return ShowHideState.HIDDEN;
    case ShowHideAction.TOGGLE:
      switch(initial) {
        case ShowHideState.HIDDEN:
          return ShowHideState.SHOWN;
        case ShowHideState.SHOWN:
          return ShowHideState.HIDDEN;
        default:
          throw 'boo!';
      }
      // DARTBUG: http://code.google.com/p/dart/issues/detail?id=6563
      break;
    default:
      throw 'no clue how to party on $action';
  }
}

Tuple3<String, String, ShowHideState> _getValues(String tag, String sheetStyle, String inlineStyle, Element element) {
  final defaultDisplay = Tools.getDefaultDisplay(tag);

  final calculatedDisplayValue = element.getComputedStyle('').display;

  final showHide = ShowHide.getState(element);

  return new Tuple3(defaultDisplay, calculatedDisplayValue, showHide);
}

ShowHideState _getState(String calculatedDisplay) {
  return calculatedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;
}

String _getEmptyText(String text) {
  assert(text != null);
  return text.isEmpty ? 'empty' : text;
}

String _getExpectedInitialCalculatedValue(String defaultTagValue, String sheetStyle, String inlineStyle) {
  switch(inlineStyle) {
    case 'inherit':
      return _playgroundWrapperDisplay;
    case '':
      switch(sheetStyle) {
        case 'inherit':
          return _playgroundWrapperDisplay;
        case '':
          return defaultTagValue;
        default:
          return sheetStyle;
      }
      // DARTBUG: http://code.google.com/p/dart/issues/detail?id=6563
      break;
    default:
      return inlineStyle;
  }
}

void _createShowHidePlayground(String tag, String sheetStyle, String inlineStyle) {
  _createPlayground();
  final pg = _getPlayground();
  assert(pg != null);
  assert(pg.children.length == 0);

  pg.style.height = '500px';
  pg.style.width = '500px';
  pg.style.padding = '10px';
  pg.style.background = 'pink';
  pg.style.display = _playgroundWrapperDisplay;

  // While I'd love to use `StyleElement` here, seems FireFox doesn't like it
  // so doing it by hand -- https://github.com/kevmoo/widget.dart/issues/8
  pg.appendHtml('<style type="text/css"> .sample { display: $sheetStyle; }</style>');

  // text describing our story
  pg.appendHtml('<p>tag: $tag</p>');
  pg.appendHtml('<p>Inherited style: $sheetStyle</p>');
  pg.appendHtml('<p>In-line style: $inlineStyle</p>');

  pg.appendHtml('<hr/>');

  pg.appendText('test before');

  // child element
  final testElement = new Element.tag(tag)
    ..classes.add('sample')
    ..appendText('sample text')
    ..style.margin = '5px'
    ..style.padding = '5px'
    ..style.width = '300px'
    ..style.height = '200px'
    ..style.background = 'gray'
    ..style.display = inlineStyle;

  pg.append(testElement);

  pg.appendText('test after');
}
