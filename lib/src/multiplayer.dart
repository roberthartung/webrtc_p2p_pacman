part of pacman;

class MultiplayerPacmanGame extends PacmanGame {
  Pacman pacMan = null;

  MultiplayerPacmanGame(canvas_static, canvas_dynamic, int seed, SynchronizedGameRoom room, Map positions)
      : super(canvas_static, canvas_dynamic, seed) {
    room.players.forEach((Player p) {
      Point start = _startPoints.elementAt(positions[p.id.toString()]);
      CommonPacmanPlayer player = p as CommonPacmanPlayer;
      switch (player.characterType) {
        case CharacterType.GHOST:
          Ghost g = player.character = new Ghost(player.movementController, null, grid, start);
          addGhost(g);
          break;
        case CharacterType.PACMAN:
          Pacman p = player.character = new Pacman(player.movementController, grid, start);
          addPacman(p);
          break;
      }
    });
  }

  /*
  void start() {
    super.start();
  }
  */
}

enum CharacterType { GHOST, PACMAN }

/// Implementation of a [ProcotolProvider] that instantiates the game protocol
/// by using the [SynchronizedMessageProtocol] with the [PacmanMessageFactory]
class PacmanProtocolProvider extends DefaultProtocolProvider {
  DataChannelProtocol provide(Peer peer, RtcDataChannel channel) {
    if (channel.protocol == 'game') {
      return new SynchronizedMessageProtocol(
          channel, new PacmanMessageFactory());
    }

    return super.provide(peer, channel);
  }
}

abstract class CommonPacmanPlayer {
  CharacterType characterType = CharacterType.GHOST;

  MovingCharacter character;

  SynchronizedMovementController movementController =
      new SynchronizedMovementController();

  String name;

  SynchronizedGameRoom get room;

  int get id;

  void handleMessage(GameMessage message) {
    if (message is PlayerNameMessage) {
      this.name = message.name;
      querySelector('[data-id="${id}"] .name').text = '$name';
    } else if (message is RequestDirectionMessage) {
      movementController.requestDirection(message.requestedDirection);
    } else if (message is StartGameMessage) {
      (room.renderer as PacmanGameRoomRenderer).start(message);
    } else {
      print('[$this] GameMessage: $message');
    }
  }

  /*
    switch(characterType) {
      case CharacterType.PACMAN :
          character = new Pacman(grid, start);
        break;
      case CharacterType.GHOST :
        character = new Ghost(new KeyboardMovementController(), pacman, grid, sector);
        break;
    }
  */

  void setCharacterType(CharacterType newType) {
    characterType = newType;
  }
}

/// Local player, listens for events and sends it to others
class LocalPacmanPlayer extends DefaultSynchronizedLocalPlayer
    with CommonPacmanPlayer {
  LocalPacmanPlayer(SynchronizedGameRoom room, int id) : super(room, id) {
    if(room.owner == this) {
      characterType = CharacterType.PACMAN;
    }
    room.onGameOwnerChanged.listen((Player p) {
      if(p == this) {
        characterType = CharacterType.PACMAN;
      } else {
        characterType = CharacterType.GHOST;
      }
    });

    document.onKeyDown.listen((KeyboardEvent ev) {
      switch (ev.keyCode) {
        case KeyCode.LEFT:
          ev.preventDefault();
          room.synchronizeMessage(new RequestDirectionMessage(Direction.LEFT));
          break;
        case KeyCode.RIGHT:
          ev.preventDefault();
          room.synchronizeMessage(new RequestDirectionMessage(Direction.RIGHT));
          break;
        case KeyCode.DOWN:
          ev.preventDefault();
          room.synchronizeMessage(new RequestDirectionMessage(Direction.DOWN));
          break;
        case KeyCode.UP:
          ev.preventDefault();
          room.synchronizeMessage(new RequestDirectionMessage(Direction.UP));
          break;
      }
    });

    // TODO(rh): Init pacman or ghost and movement controller depending if
    // we're on touch or desktop!
  }

  void tick(int tick) {
    super.tick(tick);
  }
}

/// Remote Player
class RemotePacmanPlayer extends DefaultSynchronizedRemotePlayer
    with CommonPacmanPlayer {
  RemotePacmanPlayer(SynchronizedGameRoom room, ProtocolPeer peer)
      : super(room, peer) {
    if(room.owner == this) {
      characterType = CharacterType.PACMAN;
    }
    room.onGameOwnerChanged.listen((Player p) {
      if(p == this) {
        characterType = CharacterType.PACMAN;
      } else {
        characterType = CharacterType.GHOST;
      }
    });
  }

  void tick(int tick) {
    super.tick(tick);
  }
}

/// Implementation of a gameroom renderer, that renders the actual room.
class PacmanGameRoomRenderer implements GameRoomRenderer<SynchronizedGameRoom> {
  final int targetTickRate = 60;

  SynchronizedGameRoom<SynchronizedP2PGame, LocalPacmanPlayer, RemotePacmanPlayer, Player> gameRoom;

  MultiplayerPacmanGame game;

  bool started = false;

  PacmanGameRoomRenderer(this.gameRoom) {
    gameRoom.startAnimation();
  }

  void start(StartGameMessage message) {
    game = new MultiplayerPacmanGame(
                querySelector('#scene-multiplayer-game .canvas-static'),
                querySelector('#scene-multiplayer-game .canvas-dynamic'), message.seed, gameRoom, message.positions);
    started = true;
    game.init();
    game.renderStatic();
    multiPlayerLobbyScene.hide();
    multiPlayerGameScene.show();
  }

  void tick(int t) {
    if(started) {
      game.tick(t);
    }
  }

  void render() {
    if(started) {
      game.render();
    }
  }
}

/// Factory that serialized and deserializes message within the game
class PacmanMessageFactory implements MessageFactory<SynchronizedGameMessage> {
  SynchronizedGameMessage unserialize(String message) {
    Object data = JSON.decode(message);
    if (data is Map) {
      GameMessage gm;
      if (data.containsKey('start')) {
        gm = new StartGameMessage(data['start'], data['seed']);
      } else if (data.containsKey('name')) {
        gm = new PlayerNameMessage(data['name']);
      } else if (data.containsKey('direction')) {
        gm = new RequestDirectionMessage(
            Direction.values.elementAt(data['direction']));
      } else {
        throw "Unable to unserialize message: unknown message.";
      }
      return new SynchronizedGameMessage(data['tick'], gm);
    } else {
      throw "Unable to unserialize message: data is not a map.";
    }
  }

  String serialize(SynchronizedGameMessage message) {
    Map data = {'tick': message.tick};
    if (message.message is StartGameMessage) {
      StartGameMessage m = (message.message as StartGameMessage);
      data['start'] = m.positions;
      data['seed'] = m.seed;
    } else if (message.message is PlayerNameMessage) {
      data['name'] = (message.message as PlayerNameMessage).name;
    } else if (message.message is RequestDirectionMessage) {
      data['direction'] = Direction.values.indexOf(
          (message.message as RequestDirectionMessage).requestedDirection);
    } else {
      throw "Unable to serialize message $message: Unknown message.";
    }
    return JSON.encode(data);
  }
}

/// Factory that creates a [GameRoomRenderer] for each [GameRoom]
class PacmanGameRoomRendererFactory implements GameRoomRendererFactory {
  GameRoomRenderer createRenderer(gameRoom) {
    return new PacmanGameRoomRenderer(gameRoom);
  }
}

/// Factory that creates local and remote players
class PacmanPlayerFactory implements PlayerFactory {
  LocalPacmanPlayer createLocalPlayer(GameRoom room, int id) {
    LocalPacmanPlayer p = new LocalPacmanPlayer(room, id);
    // TODO(rh): Is this the correct position?
    p.name = (querySelector('#playername') as InputElement).value;
    return p;
  }

  RemotePacmanPlayer createRemotePlayer(GameRoom room, ProtocolPeer peer) {
    return new RemotePacmanPlayer(room, peer);
  }
}

/// Message that indicates that the game starts now
/// This message is sent by the owner of the room
class StartGameMessage implements GameMessage {
  Map positions;

  int seed;

  StartGameMessage(this.positions, this.seed);
}

class PlayerNameMessage implements GameMessage {
  String name;

  PlayerNameMessage(this.name);
}

class RequestDirectionMessage implements GameMessage {
  Direction requestedDirection;

  RequestDirectionMessage(this.requestedDirection);
}
