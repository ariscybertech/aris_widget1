library widegt_util;

import 'dart:io';

const _dartFileExtension = '.dart';

Iterable<String> getDartLibraryPaths() =>
    _getDartFilePaths([r'lib/', r'lib/components/']);

Iterable<String> _getDartFilePaths(List<String> dirPaths) =>
  dirPaths.expand((String dirPath) {
    final dir = new Directory(dirPath);
    assert(dir.existsSync());
    return dir.listSync()
        .where((i) => i is File)
        .where((File file) => file.path.endsWith(_dartFileExtension))
        .map((File file) => file.resolveSymbolicLinksSync());
  });
