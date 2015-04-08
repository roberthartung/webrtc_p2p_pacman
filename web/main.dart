import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'package:webrtc_p2p_pacman/pacman.dart';
import 'package:webrtc_utils/client.dart';
import 'package:webrtc_utils/game.dart';

abstract class Scene {
  final DivElement element;
  Scene(this.element);
  void hide() {
    element.style.display = 'none';
  }
  void show() {
    element.style.display = 'block';
  }
}

class SelectTypeScene extends Scene {
  SelectTypeScene(DivElement element) : super(element) {
    element.querySelector('#btn-singleplayer').onClick.listen((MouseEvent ev) {
      ev.preventDefault();
      hide();
      singlePlayerGameScene.show();
    });

    element.querySelector('#btn-multiplayer').onClick.listen((MouseEvent ev) {
      ev.preventDefault();
      hide();
      multiPlayerJoinRoomScene.show();
    });
  }

  void show() {
    super.show();
  }

  void hide() {
    super.hide();
  }
}

class SinglePlayerGameScene extends Scene {
  SingleplayerPacmanGame _game;

  SinglePlayerGameScene(DivElement element) : super(element) {

  }

  void show() {
    super.show();
    _game = new SingleplayerPacmanGame(querySelector('#canvas-static'), querySelector('#canvas-dynamic'));
    _game.onFinished.listen(_onFinished);
    _game.onEaten.listen(_onFinished);
    _game.start();
  }

  void _onFinished(int score) {
    querySelector('#info-restart').style.visibility = 'visible';
    StreamSubscription restart;
    Timer returnTimer = new Timer(new Duration(seconds: 5), () {
      restart.cancel();
      hide();
      selectTypeScene.show();
    });

    restart = document.onKeyDown.listen((KeyboardEvent ev) {
      if(ev.keyCode == KeyCode.R) {
        returnTimer.cancel();
        // Force new game
        hide();
        show();
      }
    });
  }

  void hide() {
    super.hide();
    _game.stop();
    querySelector('#info-restart').style.visibility = 'hidden';
    _game = null;
  }
}

/// Scene that allows the player to join a room
class MultiPlayerJoinRoomScene extends Scene {
  // MultiplayerPacmanGame _game;

  MultiPlayerJoinRoomScene(DivElement element) : super(element) {
    querySelector('#btn-join-room').onClick.listen((MouseEvent ev) {
      p2pGame.onGameRoomCreated.first.then((SynchronizedGameRoom room) {
        hide();
        multiPlayerLobbyScene.gameRoom = room;
        multiPlayerLobbyScene.show();
      });
      p2pGame.join((querySelector('#room') as InputElement).value);
    });
  }

  void show() {
    super.show();
    /*
    _game = new MultiplayerPacmanGame(querySelector('#canvas-static'), querySelector('#canvas-dynamic'));
    _game.onFinished.listen(_onFinished);
    _game.onEaten.listen(_onFinished);
    _game.start();
    */
  }

  /*
  void _onFinished(int score) {
    querySelector('#info-restart').style.visibility = 'visible';
    StreamSubscription restart;
    Timer returnTimer = new Timer(new Duration(seconds: 5), () {
      restart.cancel();
      hide();
      selectTypeScene.show();
    });

    restart = document.onKeyDown.listen((KeyboardEvent ev) {
      if(ev.keyCode == KeyCode.R) {
        returnTimer.cancel();
        // Force new game
        hide();
        show();
      }
    });
  }
  */

  void hide() {
    super.hide();
  }
}

class MultiPlayerLobbyScene extends Scene {
  SynchronizedGameRoom<SynchronizedP2PGame, LocalPacmanPlayer, RemotePacmanPlayer, Player> gameRoom;

  UListElement ul;

  MultiPlayerLobbyScene(DivElement element) : super(element) {
    ul = querySelector('#lobby-players');
  }

  void _playerJoined(Player p) {
    if(gameRoom.isOwner) {
      ul.appendHtml('<li>Player #${p.id} CHANGE</li>');
    } else {
      ul.appendHtml('<li>Player #${p.id}</li>');
    }
  }

  void show() {
    super.show();

    gameRoom.players.forEach((Player p) {
      _playerJoined(p);
    });
    gameRoom.onPlayerJoin.listen((Player p) {
      // TODO(rh): Exchange information
      _playerJoined(p);
    });

    if(gameRoom.isOwner) {
      print('I am the game owner');
      _enableStartButton();
    }
    gameRoom.onGameOwnerChanged.listen((Player p) {
      if(p.isLocal) {
        print('I became the game owner');
        _enableStartButton();
      }
    });
  }

  void _enableStartButton() {
    querySelector('#btn-start').onClick.listen((MouseEvent ev) {
      gameRoom.synchronizeMessage(new StartGameMessage(), tickDelay: 5);
      hide();
      multiPlayerGameScene.show();
    });
  }

  void hide() {
    super.hide();
  }
}

class MultiPlayerGameScene extends Scene {
  MultiPlayerGameScene(DivElement element) : super(element) {

  }
}

final SelectTypeScene selectTypeScene = new SelectTypeScene(querySelector('#scene-select-type'));
final SinglePlayerGameScene singlePlayerGameScene = new SinglePlayerGameScene(querySelector('#scene-singleplayer-game'));
final MultiPlayerJoinRoomScene multiPlayerJoinRoomScene = new MultiPlayerJoinRoomScene(querySelector('#scene-multiplayer-joinroom'));
final MultiPlayerLobbyScene multiPlayerLobbyScene = new MultiPlayerLobbyScene(querySelector('#scene-multiplayer-lobby'));
final MultiPlayerGameScene multiPlayerGameScene = new MultiPlayerGameScene(querySelector('#scene-multiplayer-game'));
final SynchronizedWebSocketP2PGame p2pGame = new SynchronizedWebSocketP2PGame<LocalPacmanPlayer, RemotePacmanPlayer>('ws://roberthartung.dyndns.org:28080', rtcConfiguration);

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

  querySelector('#btn-sounds').onClick.listen((MouseEvent ev) {
    playSounds = !playSounds;

    if(singlePlayerGameScene._game != null) {
      singlePlayerGameScene._game.playSounds = playSounds;
    }

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