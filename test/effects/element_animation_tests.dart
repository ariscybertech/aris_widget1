part of effects_tests;

void registerElementAnimationTests() {
  group('ElementAnimation', () {
    setUp(() {
      setupTestTimeManager();
      _createPlayground();
    });

    tearDown(() {
      tearDownTestTimeManager();
      _cleanUpPlayground();
    });

    test('height to 0', () {
      final pg = _getPlayground();
      pg.appendHtml("<style scoped>div.foo { height: 50px; background: pink; }</style><div class='foo'>content</div>");

      pg.appendHtml('<strong>this is strong!</strong>');

      final fooDiv = querySelector('div.playground div.foo');
      expect(fooDiv, isNotNull);

      final style = fooDiv.getComputedStyle('');

      expect(style.height, equals('50px'));
      expect(fooDiv.style.height, equals(''));

      final animation = new ElementAnimation(fooDiv, 'height', '0px');

      expect(animation.duration, equals(400));
      expect(fooDiv.style.height, equals(''));

      _timeManagerInstance.tick(40);
      expect(animation.percentComplete, 0.1);
      expect(fooDiv.style.height, equals('45px'));

      _timeManagerInstance.tick(320);
      expect(animation.percentComplete, 0.9);
      expect(fooDiv.style.height, equals('5px'));
    });

  });
}
