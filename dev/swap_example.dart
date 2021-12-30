library dev.swap_example;

import 'dart:html';
import 'package:polymer/polymer.dart';

void main() {
  initPolymer();
  querySelector('#modalOpenButton').onClick.listen(_show);
}

void _show(event) {
  var modal = querySelector('#modal_example');
  modal.show();
}
