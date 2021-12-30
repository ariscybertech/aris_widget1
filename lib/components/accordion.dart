library widget.accordion;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'collapse.dart';
import 'show_hide.dart';

/**
 * [AccordionWidget] wraps a set of [CollapseWidget] elements and ensures only one is
 * visible at a time.
 *
 * See [CollapseWidget] for details on how content is interpreted.
 */
@CustomTag('accordion-widget')
class AccordionWidget extends PolymerElement {

  AccordionWidget.created() : super.created() {
    ShowHideWidget.toggleEvent.forTarget(this).listen(_onOpen);
  }

  void _onOpen(Event openEvent) {
    Element target = openEvent.target;
    if (target is CollapseWidget && target.parent == this && target.isShown) {
      children.where((c) => c is CollapseWidget)
        .where((e) => e != target)
        .forEach((e) => e.hide());
    }
  }
}
