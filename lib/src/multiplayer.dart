part of pacman;

class MultiplayerPacmanGame extends PacmanGame {
  PacMan pacMan = null;

  MultiplayerPacmanGame(s, d) : super(s, d);

  void start() {

  }
}

/// Implementation of a [ProcotolProvider] that instantiates the game protocol
/// by using the [SynchronizedMessageProtocol] with the [PacmanMessageFactory]
class PacmanProtocolProvider extends DefaultProtocolProvider {
  DataChannelProtocol provide(Peer peer, RtcDataChannel channel) {
    if (channel.protocol == 'game') {
      return new SynchronizedMessageProtocol(channel, new PacmanMessageFactory());
    }

    return super.provide(peer, channel);
  }
}

/// Local player, listens for events and sends it to others
class LocalPacmanPlayer extends DefaultSynchronizedLocalPlayer {
  LocalPacmanPlayer(SynchronizedGameRoom room, int id) : super(room, id) {
    // TODO(rh): Setup keyboard listener
  }

  void handleMessage(GameMessage message) {
    print('[$this] GameMessage: $message');
  }

  void tick(int tick) {
    super.tick(tick);
  }
}

/// Remote Player
class RemotePacmanPlayer extends DefaultSynchronizedRemotePlayer {
  RemotePacmanPlayer(SynchronizedGameRoom room, ProtocolPeer peer): super(room, peer);

  void handleMessage(GameMessage message) {
    print('[$this] GameMessage: $message');
  }

  void tick(int tick) {
    super.tick(tick);
  }
}

/// Implementation of a gameroom renderer, that renders the actual room.
class PacmanGameRoomRenderer implements GameRoomRenderer<SynchronizedGameRoom> {
  final int targetTickRate = 60;

  SynchronizedGameRoom<SynchronizedP2PGame, LocalPacmanPlayer, RemotePacmanPlayer,Player> gameRoom;

  PacmanGameRoomRenderer(this.gameRoom) {
    gameRoom.startAnimation();
  }

  void render() {
    // TODO(rh): Rendering will be done instantly, thus we have to wait for
    //    the game to actualy start!!
    // TODO(rh): Implement rendering
  }
}

/// Factory that serialized and deserializes message within the game
class PacmanMessageFactory implements MessageFactory<SynchronizedGameMessage> {
  SynchronizedGameMessage unserialize(String message) {
    Object data = JSON.decode(message);
    if(data is Map) {
      if(data.containsKey('start')) {
        return new SynchronizedGameMessage(data['start'], new StartGameMessage());
      }

      throw "Unable to unserialize message: unknown message.";
    } else {
      throw "Unable to unserialize message: data is not a map.";
    }
  }

  String serialize(SynchronizedGameMessage message) {
    if(message.message is StartGameMessage) {
      return JSON.encode({'start': message.tick});
    }

    throw "Unable to serialize message $message: Unknown message.";
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
    return new LocalPacmanPlayer(room, id);
  }

  RemotePacmanPlayer createRemotePlayer(GameRoom room, ProtocolPeer peer) {
    return new RemotePacmanPlayer(room, peer);
  }
}

/// Message that indicates that the game starts now
/// This message is sent by the owner of the room
class StartGameMessage implements GameMessage {

}