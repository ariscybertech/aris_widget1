library widget.dropdown;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';
import 'show_hide.dart';

// TODO: esc and click outside to collapse
// https://github.com/kevmoo/widget.dart/issues/14

/**
 * [DropdownWidget] aligns closely with the model provided by the
 * [dropdown functionality](http://getbootstrap.com/javascript/#dropdowns)
 * in Bootstrap.
 *
 * [DropdownWidget] content is inferred from all child elements that have
 * class `dropdown-menu`. Bootstrap defines a CSS selector for `.dropdown-menu`
 * with an initial display of `none`.
 *
 * [DropdownWidget] listens for `click` events and toggles visibility of content
 * if the click target has attribute `data-toggle="dropdown"`.
 *
 * Bootstrap also defines a CSS selector which sets `display: block;` for
 * elements matching `.open > .dropdown-menu`. When [DropdownWidget] opens, the
 * class `open` is added to the inner element wrapping all content. Causing
 * child elements with class `dropdown-menu` to become visible.
 */
@CustomTag('dropdown-widget')
class DropdownWidget extends ShowHideWidget {
  static final ShowHideEffect _effect = new FadeEffect();
  static const int _duration = 100;

  DropdownWidget.created() : super.createdWithValue(false) {
    this.querySelectorAll('[data-toggle=dropdown]').onClick.listen(_onClick);
    this.onKeyDown.listen(_onKeyDown);
  }

  void set isShown(bool value) {
    if(value) {
      // before we set the local shown value, ensure
      // all of the other dropdowns are closed
      closeDropdowns();
    }

    super.isShown = value;

    if(value) {
      this.classes.add('open');
    } else {
      this.classes.remove('open');
    }

    final action = value ? ShowHideAction.SHOW : ShowHideAction.HIDE;
    final contentDiv = this.querySelector('.dropdown-menu');
    if(contentDiv != null) {
      ShowHide.begin(action, contentDiv, effect: _effect);
    }
  }

  static void closeDropdowns() {
    document.querySelectorAll('dropdown-widget')
      .forEach((dd) => dd.hide());
  }

  void _onKeyDown(KeyboardEvent e) {
    if(!e.defaultPrevented && e.keyCode == KeyCode.ESC) {
      this.hide();
      e.preventDefault();
    }
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented && event.target is Element) {
      final Element target = event.target;
      if(target != null && target.dataset['toggle'] == 'dropdown') {
        toggle();
        event.preventDefault();
        target.focus();
      }
    }
  }
}
