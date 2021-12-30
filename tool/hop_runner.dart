import 'package:args/args.dart';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test;

void main(List<String> args) {
  addTask('build', _getBuildTask());

  addTask('test_dart2js',
      createDartCompilerTask(['test/browser_test_harness.dart']));

  addTask('test', createUnitTestTask(test.testCore));

  addTask('pages', (ctx) => branchForDir(ctx, 'master', 'build', 'gh-pages'));

  runHop(args);
}

const _MODE = 'mode';
const _VERBOSE = 'verbose';

Task _getBuildTask() =>
    new Task((TaskContext ctx) {
      var args = ['build', '--mode', ctx.arguments[_MODE]];

      if(ctx.arguments[_VERBOSE]) {
        args.add('--verbose');
      }

      return startProcess(ctx, 'pub', args);
    }, argParser: new ArgParser()
        ..addOption(_MODE, abbr: 'm', allowed: ['release', 'debug'], defaultsTo: 'debug')
        ..addFlag(_VERBOSE, abbr: 'v', defaultsTo: false)
    );
