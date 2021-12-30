library widget.tabs;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'swap.dart';

// TODO:TEST: no active tabs -> first is active
// TODO:TEST: 2+ active tabs -> all but first is active
// TODO:TEST: no tabs -> no crash

// TODO: be more careful that the source tab is actually 'ours'
// TODO: support click on child elements with data-toggle="tab"

/**
 * [TabsWidget] is based on the
 * [analogous feature](http://getbootstrap.com/javascript/#tabs) in Bootstrap.
 *
 * The tab headers are processed as all child `<li>` elements in content. The
 * rest of the child elements are considered tab content.
 *
 * [TabsWidget] responds to click events from any child with `data-toggle="tab"`
 * or `data-toggle="pill"`.
 *
 * The target content id is either the value of `data-target` on the clicked
 * element or the anchor in `href`.
 */
@CustomTag('tabs-widget')
class TabsWidget extends PolymerElement {

  bool get applyAuthorStyles => true;

  TabsWidget.created() : super.created() {
    this.onClick.listen(_clickListener);
  }

  @override
  void enteredView() {
    super.enteredView();
    _ensureAtMostOneTabActive();
  }

  void _clickListener(MouseEvent e) {
    if(!e.defaultPrevented && e.target is Element) {
      final Element target = e.target;
      final completed = _targetClick(target);
      if(completed) {
        e.preventDefault();
      }
    }
  }

  bool _targetClick(Element clickElement) {
    final toggleData = clickElement.dataset['toggle'];
    if(toggleData != 'tab' && toggleData != 'pill') {
      return false;
    }

    //
    // The parent tab to the click should become active
    //
    final allTabs = _getAllTabs();
    final clickAncestors = Tools.getAncestors(clickElement);
    final activatedTab = allTabs.firstWhere((t) => clickAncestors.contains(t), orElse: () => null);
    if(activatedTab != null) {
      allTabs.forEach((t) {
        if(t == activatedTab) {
          t.classes.add('active');
        } else {
          t.classes.remove('active');
        }
      });
    }

    //
    // Find the target for the click
    //
    final target = _getClickTarget(clickElement);

    //
    // Try to find and activate the content for the target
    //
    if(target != null) {
      _updateContent(target);
    }

    return true;
  }

  static String _getClickTarget(Element clickedElement) {
    assert(clickedElement != null);
    String target = clickedElement.dataset['target'];
    if(target == null) {
      final href = clickedElement.attributes['href'];
      if(href != null) {
        target = Uri.parse(href).fragment;
      }
    }
    return target;
  }

  List<Element> _getAllTabs() =>
      (shadowRoot.querySelector('.nav-tabs > content') as ContentElement)
      .getDistributedNodes();

  void _ensureAtMostOneTabActive() {
    final tabs = _getAllTabs();
    Element activeTab = null;
    tabs.forEach((Element tab) {
      if(tab.classes.contains('active')) {
        if(activeTab == null) {
          activeTab = tab;
        } else {
          tab.classes.remove('active');
        }
      }
    });

    if(activeTab == null && !tabs.isEmpty) {
      activeTab = tabs[0];
      activeTab.classes.add('active');
    }
  }

  SwapWidget _getSwap() =>
      shadowRoot.querySelector('swap-widget');

  void _updateContent(String target) {
    final swap = _getSwap();

    if(swap != null) {
      final items = swap.items;

      final targetItem = $(items).firstWhere((e) => e.id == target, orElse: () => null);
      if(targetItem != null) {
        swap.showItem(targetItem);
      }
    }
  }
}
