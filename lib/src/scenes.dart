part of pacman;

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

  TableElement playersTable;

  MultiPlayerLobbyScene(DivElement element) : super(element) {
    playersTable = querySelector('#lobby-players');
  }

  void _playerJoined(Player p) {
    playersTable.appendHtml('<tr data-id="${p.id}" class="${p.isLocal ? 'local' : 'remote'}"><td class="pacman">${gameRoom.owner == p ? '1' : '9'}</td><td class="name">Player #${p.id}</td></tr>');

    if(p is RemotePacmanPlayer) {
      p.getGameChannel().then((SynchronizedMessageProtocol protocol) {
        protocol.send(new SynchronizedGameMessage(0, new PlayerNameMessage(gameRoom.localPlayer.name)));
      });
    } else if(p is LocalPacmanPlayer) {
      querySelector('[data-id="${p.id}"] .name').text = '${p.name}';
    }
  }

  void show() {
    super.show();

    gameRoom.players.forEach((Player p) {
      _playerJoined(p);
    });

    gameRoom.onPlayerJoin.listen((RemotePacmanPlayer p) {
      // TODO(rh): Exchange information
      _playerJoined(p);
    });

    gameRoom.onGameOwnerChanged.listen((Player p) {
      playersTable.querySelector('tr[data-id="${p.id}"] td.pacman').text = '1';
    });

    gameRoom.onPlayerLeave.listen((Player p) {
      playersTable.querySelector('tr[data-id="${p.id}"]').remove();
    });

    if(gameRoom.isOwner) {
      print('I am the game owner');
      _enableStartButton();
    }

    gameRoom.onSynchronizationStateChanged.listen((bool state) {
      print('State: $state');
      if(state) {

      } else {

      }
    });

    gameRoom.onGameOwnerChanged.listen((Player p) {
      if(p.isLocal) {
        print('I became the game owner');
        _enableStartButton();
      }
    });
  }

  void _enableStartButton() {
    querySelector('#btn-start').onClick.listen((MouseEvent ev) {
      // Send start message to everyone
      Map positions = {};
      int seed = new Random().nextInt(0xFFFFFFFF);
      Random r = new Random(seed);
      List<int> _positions = [];
      gameRoom.players.forEach((Player player) {
        int position;
        do {
          position = r.nextInt(gameRoom.players.length);
        } while(_positions.contains(position));
        _positions.add(position);
        // TODO(rh): Make sure the offset is unique
        positions[player.id.toString()] = position;
      });
      gameRoom.synchronizeMessage(new StartGameMessage(positions, seed), tickDelay: 5);
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