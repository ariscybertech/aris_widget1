library widget.alert;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';
import 'show_hide.dart';

/**
 * [AlertWidget] follows the same convention as
 * [its inspiration](http://getbootstrap.com/javascript/#alerts) in Bootstrap.
 *
 * Clicking on a nested element with the attribute `data-dismiss='alert'` will
 * cause [AlertWidget] to close.
 *
 * Adding an `alert-*` class to [AlertWidget] will apply the associated
 * Boostrap style. These include `alert-success`, `alert-info`, `alert-warning`,
 * and `alert-danger`.
 */
@CustomTag('alert-widget')
class AlertWidget extends ShowHideWidget {

  AlertWidget.created(): super.created()  {
    this.onClick.listen(_onClick);
  }

  bool get applyAuthorStyles => true;


  void set isShown(bool value) {
    super.isShown = value;
    assert(value != null);

    final action = value ? ShowHideAction.SHOW : ShowHideAction.HIDE;
    ShowHide.begin(action, this, effect: new ScaleEffect());
  }

  @override
  void enteredView() {
    super.enteredView();
    _updateAlertClasses();
  }

  void _updateAlertClasses() {
    var alertClasses = this.classes
        .where((c) => c.startsWith('alert-'));

    var alertDiv = shadowRoot.querySelector('.alert');

    alertDiv.classes.retainWhere((s) => s == 'alert');
    alertDiv.classes.addAll(alertClasses);
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataset['dismiss'] == 'alert') {
        hide();
      }
    }
  }
}
