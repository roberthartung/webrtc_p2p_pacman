library pacman.scene;

import 'package:polymer/polymer.dart';

@CustomTag('rh-scene')
class Scene extends PolymerElement {
  @published bool visible;

  Scene.created() : super.created() {

  }
}