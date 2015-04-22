library pacman.menu.item;
import 'package:polymer/polymer.dart';

@CustomTag('rh-menu-item')
class MenuItem extends PolymerElement {
  @published String action;

  @published String value;

  @published bool disabled = false;

  MenuItem.created() : super.created() {

  }
}