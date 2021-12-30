library widget.modal;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';
import 'show_hide.dart';

// TODO: ESC to close: https://github.com/kevmoo/widget.dart/issues/17
// TODO: clicking on background to close is broken - fix it!

/**
 * When added to a page, [ModalWidget] is hidden. It can be displayed by calling
 * the `show` method.
 *
 * Similar to [AlertWidget], elements with the attribute `data-dismiss="modal"`
 * will close [ModalWidget] when clicked.
 *
 * Content within [ModalWidget] is placed in a div with class `modal` so related
 * styles from Bootstrap are applied.
 *
 * The [ModalWidget] component leverages the [ModalManager] effect.
 */
@CustomTag('modal-widget')
class ModalWidget extends ShowHideWidget {

  bool get applyAuthorStyles => true;

  /** If false, clicking the backdrop closes the dialog. */
  bool staticBackdrop = false;

  ShowHideEffect effect = new ScaleEffect();

  ModalWidget.created() : super.created() {
    this.onClick.listen(_onClick);
  }

  @override
  void enteredView() {
    super.enteredView();
    var modal = _modalElement;

    if(modal != null && !isShown) {
      ModalManager.hide(modal);
    }
  }

  void set isShown(bool value) {
    super.isShown = value;
    _shown_changed();
  }

  void _shown_changed() {

    var modal = _modalElement;
    if(modal != null) {

      if(isShown) {
        ModalManager.show(modal, effect: effect,
            backdropClickHandler: _onBackdropClicked);
      } else {
        ModalManager.hide(modal, effect: effect);
      }
    }
  }

  Element get _modalElement => shadowRoot.querySelector('.modal');

  void _onClick(MouseEvent event) {

    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataset['dismiss'] == 'modal') {
        hide();
      }
    }
  }

  void _onBackdropClicked() {
    // TODO: ignoring some edge cases here
    // like what if this element has been removed from the tree before the backdrop is clicked
    // ...etc
    if (!staticBackdrop) {
      hide();
    }
  }
}
