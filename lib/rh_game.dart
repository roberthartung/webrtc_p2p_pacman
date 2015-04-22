library rh.game;

import 'dart:html';
import 'dart:async';

import 'package:webrtc_utils/game.dart';
import 'package:polymer/polymer.dart';

import 'menu_item.dart';
import 'scene.dart';

abstract class GameController {
  void startSingleplayer();
  void startMultiplayer();
}

@CustomTag('rh-game')
class GameElement extends PolymerElement {
  @published bool keyboard = false;

  @published bool singleplayer = false;

  @published bool multiplayer = false;

  Scene currentScene = null;

  _onMenuItemClicked(MenuItem item, MouseEvent ev) {
    final String scene = item.action == 'start' ? 'game' : item.value;
    if(!item.disabled) {
      ev.stopPropagation();
      ev.preventDefault();
      currentScene.attributes['visible'] = 'false';
      currentScene = querySelector('rh-scene#${scene}');
      currentScene.attributes['visible'] = 'true';
      if(item.action == 'start') {
        if(item.value == 'multiplayer') {
          _gameController.startMultiplayer();
        } else if(item.value == 'singleplayer') {
          _gameController.startSingleplayer();
        }
      }
    }
  }

  GameElement.created() : super.created() {
    if(keyboard) {
      // TODO(rh): Allow menu navigation by keyboard
    }

    new Timer(new Duration(seconds: 3), () {
      querySelector('#btn-multiplayer').attributes['disabled'] = 'false';
    });

    currentScene = querySelector('rh-scene[visible="true"]');
    querySelectorAll('rh-menu-item').forEach((MenuItem item) {
      /*
      String scene = null;
      if(item.action.startsWith('show-scene:')) {
        scene = item.action.substring('show-scene:'.length);
      } else if(item.action.startsWith('start')) {
        scene = 'game';
      }
      */
      item.onClick.listen((MouseEvent ev) => _onMenuItemClicked(item, ev));
    });
  }

  GameController _gameController;

  P2PGame _game;

  P2PGame get game => _game;

  void setP2PGame(P2PGame g) {
    _game = g;
  }

  void setGameController(GameController c) {
    _gameController = c;
  }
}