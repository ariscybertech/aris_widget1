part of effects_tests;

final _containerSize = const Size(100, 80);

void registerToolsTests() {
  group('Tools', () {
    setUp(() {
      _createPlayground();
    });

    tearDown(() {
      _cleanUpPlayground();
    });

    samples.forEach((css, result) {
      test(css, () {

        final pg = _getPlayground();

        pg.appendHtml('''
<div class='container'>
<style scoped>
div.container {
  background: gray;
  width: ${_containerSize.width}px; height: ${_containerSize.height}px;
}
div.foo { background: red; $css }
</style>
<div class='foo'>content</div>
        ''');

        final element = pg.querySelector('div.foo');

        final style = element.getComputedStyle('');
        final size = Tools.getOuterSize(style);

        expect(size, result);
      });
    });
  });
}

final samples =
{
 'width: 20px; height: 20px;': new Size(20, 20),
 'width: 10px; height: 5.5px;': new Size(10, 5.5),
 'width: 10px; height: 8px; border: 1px;': new Size(10, 8),
 'width: 10px; height: 8px; border: 1px solid;': new Size(12, 10),
 'width: 10px; height: 8px; padding: 2px;': new Size(14, 12),
 'width: 10px; height: 8px; padding: 2px; border: 1px;': new Size(14, 12),
 'width: 10px; height: 8px; padding: 2px; border: 1px solid;': new Size(16, 14),
 'width: 100%; height: 8px;': new Size(_containerSize.width, 8),
 'width: 100%; height: 100%;': new Size(_containerSize.width, _containerSize.height),
 'width: 50%; height: 10%;': new Size(0.5 * _containerSize.width, 0.1 * _containerSize.height),
};
