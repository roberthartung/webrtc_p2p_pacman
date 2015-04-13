library pacman.game;
import 'package:polymer/polymer.dart';

@CustomTag('pacman-game')
class PacmanGame extends PolymerElement {
  PacmanGame.created() : super.created() {
    print('[$this] created');
  }
}