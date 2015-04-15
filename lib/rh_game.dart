library rh.game;

import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';

import 'menu_item.dart';
import 'scene.dart';

@CustomTag('rh-game')
class GameElement extends PolymerElement {
  @published bool keyboard = false;

  @published bool singleplayer = false;

  @published bool multiplayer = false;

  Scene currentScene = null;

  GameElement.created() : super.created() {
    if(keyboard) {
      // TODO(rh): Allow menu navigation by keyboard
    }

    new Timer(new Duration(seconds: 3), () {
      querySelector('#btn-multiplayer').attributes['disabled'] = 'false';
    });

    currentScene = querySelector('rh-scene[visible="true"]');
    querySelectorAll('rh-menu-item').forEach((MenuItem item) {
      String scene = null;
      if(item.action.startsWith('show-scene:')) {
        scene = item.action.substring('show-scene:'.length);
      } else if(item.action == 'start') {
        scene = 'game';
      }

      item.onClick.listen((MouseEvent ev) {
        if(!item.disabled) {
          ev.stopPropagation();
          ev.preventDefault();
          currentScene.attributes['visible'] = 'false';
          currentScene = querySelector('rh-scene#${scene}');
          currentScene.attributes['visible'] = 'true';
        }
      });
    });
  }
}