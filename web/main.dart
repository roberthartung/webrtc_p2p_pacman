import 'dart:html';
import 'package:webrtc_p2p_pacman/pacman.dart';

bool playMusic = false;
bool playSounds = true;
num volume = 10;
AudioElement music;

void main() {
  p2pGame.setGameRoomRendererFactory(new PacmanGameRoomRendererFactory());
  p2pGame.setPlayerFactory(new PacmanPlayerFactory());
  p2pGame.setProtocolProvider(new PacmanProtocolProvider());
  p2pGame.onConnect.listen((int localId) {
    print('connected to signaling server');
    querySelector('#btn-multiplayer').classes.remove('disabled');
  });

  selectTypeScene.show();
  music = querySelector('#music');
  music.volume = volume/100.0;
  music.play();
  music.muted = !playMusic;
  querySelector('#btn-music').onClick.listen((MouseEvent ev) {
    playMusic = !playMusic;
    music.muted = !playMusic;
    if(playMusic) {
      querySelector('#btn-music').text = 'Disable music';
    } else {
      querySelector('#btn-music').text = 'Enable music';
    }
  });

  querySelector('#btn-singleplayer').focus();

  querySelector('#btn-sounds').onClick.listen((MouseEvent ev) {
    playSounds = !playSounds;
    // TODO(rh)
    /*if(singlePlayerGameScene._game != null) {
      singlePlayerGameScene._game.playSounds = playSounds;
    }*/
    if(playSounds) {
      querySelector('#btn-sounds').text = 'Disable sounds';
    } else {
      querySelector('#btn-sounds').text = 'Enable sounds';
    }
  });

  RangeInputElement volumneElement = querySelector('#volume');
  volumneElement.onChange.listen((Event ev) {
    volume = volumneElement.valueAsNumber;
    music.volume = volume/100.0;
  });

  // CheckboxInputElement gameBuilderMode;
  //gameBuilderMode = querySelector('#enable-game-builder-mode');

  /*
  (querySelector('#btn-print-edges') as ButtonElement).onClick.listen((MouseEvent ev) {
    grid.edges.forEach((Edge e) {
      print('grid.add(new Edge(${e.p1.x}, ${e.p1.y}, ${e.p2.x}, ${e.p2.y}));');
    });
  });
  */
  /*
  canvas.onMouseMove.listen((MouseEvent ev) {
    Point sector = new Point((ev.offset.x/Grid.gridSize).floor(), (ev.offset.y/Grid.gridSize).floor());
    if(grid.crossPoints.containsKey(sector)) {
      print('$sector ${grid.crossPoints[sector]}');
    }
  });
  */
  /*
  Point start;
  Edge tmpEdge = null;
  StreamSubscription sub;
  canvas.onMouseDown.listen((MouseEvent ev) {
    if(ev.which != 1) {
      return;
    }
    start = ev.offset;

    sub = canvas.onMouseMove.listen((MouseEvent ev) {
      if(tmpEdge != null) {
        grid.edges.remove(tmpEdge);
      }
      tmpEdge = createEdgeFromMouse(start, ev);
      if(tmpEdge != null) {
        grid.edges.add(tmpEdge);
      }
    });

    document.onMouseUp.first.then((MouseEvent ev) {
      if(sub != null) {
        sub.cancel();
        sub = null;
      }
      if(tmpEdge != null) {
        grid.edges.remove(tmpEdge);
        tmpEdge = null;
      }
      Edge e = createEdgeFromMouse(start, ev);
      if(e != null) {
        grid.add(e);
      }
    });
  });

  ctx = canvas.getContext('2d');
  */
}