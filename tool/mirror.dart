/**
 * Note: there is a LOT of hard-coded paths here. Ideally, mirrors and markdown
 * would be available without linking into Dart SDK internals
 * DARTBUG: https://code.google.com/p/dart/issues/detail?id=13679
 */

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import '/usr/local/Cellar/dart-editor/30821/dart-sdk/lib/_internal/compiler/implementation/mirrors/mirrors.dart' as mirrors;
import '/usr/local/Cellar/dart-editor/30821/dart-sdk/lib/_internal/compiler/implementation/mirrors/dart2js_mirror.dart' as dart2js;
import '/usr/local/Cellar/dart-editor/30821/dart-sdk/lib/_internal/compiler/implementation/source_file_provider.dart' as sfp;
import '/usr/local/Cellar/dart-editor/30821/dart-sdk/lib/_internal/dartdoc/lib/markdown.dart' as md;
import 'package:hop/src/hop_experimental.dart' as hop_exp;
import 'package:html5lib/dom.dart' as dom;
import 'util.dart' as util;

const _LIB_PATH = r'/usr/local/Cellar/dart-editor/30821/dart-sdk/';
const _SOURCE_HTML_FILE = r'web/index_source.html';

void main() {
  hop_exp.transformHtml(_SOURCE_HTML_FILE, _transform)
    .then((bool changed) {
      if(changed) {
        print("+ Updating $_SOURCE_HTML_FILE");
      } else {
        print('- No changes to $_SOURCE_HTML_FILE');
      }
    });
}

Future<dom.Document> _transform(dom.Document document) {

  List<mirrors.ClassMirror> classes;

  return _getTargetClasses()
  .then((List<mirrors.ClassMirror> value) {
    classes = value;

    for(final componentClass in classes) {

      final classSimpleName = componentClass.simpleName;

      final mirrors.CommentInstanceMirror classComment = componentClass.metadata
          .firstWhere((m) => m is mirrors.CommentInstanceMirror && m.isDocComment,
          orElse: () => null);

      if(classComment == null) {
        print('- $classSimpleName - no comment');
      } else {
        print('+ ${componentClass.simpleName} - has doc comments');
        _writeClassComment(document, componentClass.simpleName, classComment.trimmedText);
      }
    }

    return document;
  });
}

Future<List<mirrors.ClassMirror>> _getTargetClasses() {
  final currentLibraryPath = Directory.current.path;
  final libPath = new Uri.file(_LIB_PATH);
  final packageRoot = Uri.base.resolve(r'packages/');

  final componentPaths = util.getDartLibraryPaths()
      .map((String path) => new Uri.file(path))
      .toList();

  var provider = new sfp.CompilerSourceFileProvider();
  var diagnosticHandler =
        new sfp.FormattingDiagnosticHandler(provider).diagnosticHandler;

  return dart2js.analyze(componentPaths, libPath, packageRoot,
      provider.readStringFromUri, diagnosticHandler, ['--preserve-comments'])
      .then((mirrors.MirrorSystem mirrors) {

        final componentLibraries = mirrors.libraries.values.where((lm) {
          final uri = lm.location.sourceUri;
          return uri.scheme == 'file' && uri.path.startsWith(currentLibraryPath);
        }).toList();

        return componentLibraries.expand((lm) {
          return lm.classes.values;
        }).toList();
      });
}

void _writeClassComment(dom.Document doc, String className,
                        String markdownCommentContent) {

  final htmlContent = _getHtmlFromMarkdown(className, markdownCommentContent);
  assert(htmlContent != null);

  final bq = _getBlockQuoteElement(doc, className);

  if(bq != null) {
    bq.innerHtml = htmlContent;
    print(' * updated blockquote');
  }
}

dom.Element _getBlockQuoteElement(dom.Document doc, String className) {
  return doc.queryAll('blockquote')
      .firstWhere((e) => _isRightBlockQuote(e, className), orElse: () => null);
}

bool _isRightBlockQuote(dom.Element element, String className) {
  if(element.attributes['class'] != 'comments') {
    return false;
  }

  final parent = element.parent;
  if(parent == null) {
    return false;
  }

  if(parent.children.indexOf(element) != 1) {
    return false;
  }

  // this should be an h2
  final firstChild = parent.children.first;

  return firstChild.tagName == 'h2' && firstChild.innerHtml == className;
}

String _getHtmlFromMarkdown(String className, String markdown) {
  final md.Resolver resolver = (name) {
    if(name == className) {
      return new md.Element.text('strong', name);
    } else {
      final anchor = new md.Element.text('a', name);
      anchor.attributes['href'] = '#${name.toLowerCase()}';
      return anchor;
    }
  };

  final document = new md.Document(linkResolver: resolver);

  final lines = Util.splitLines(markdown).toList();

  document.parseRefLinks(lines);
  final blocks = document.parseLines(lines);

  return md.renderToHtml(blocks);
}
