part of effects_tests;

void registerAnimationCoreTests() {
  group('AnimationCore', () {
    setUp(setupTestTimeManager);

    tearDown(tearDownTestTimeManager);

    test('basic', () {
      final animation = new AnimationCore(10);
      expect(animation.percentComplete, 0);
      expect(animation.ended, isFalse);

      _timeManagerInstance.tick(1);
      expect(animation.percentComplete, 0.1);
      expect(animation.ended, isFalse);

      _timeManagerInstance.tick(8);
      expect(animation.percentComplete, 0.9);
      expect(animation.ended, isFalse);

      _timeManagerInstance.tick(1);
      expect(animation.percentComplete, 1.0);
      expect(animation.ended, isTrue);

      _timeManagerInstance.tick(1);
      expect(animation.percentComplete, 1.0);
      expect(animation.ended, isTrue);
    });
  });
}
