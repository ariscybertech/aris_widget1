import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'effects/_effects_tests.dart' as effects;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  effects.main();
}
