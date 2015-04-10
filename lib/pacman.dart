library pacman;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:webrtc_utils/client.dart';
import 'package:webrtc_utils/game.dart';

part 'src/character.dart';
part 'src/ghost.dart';
part 'src/pacman.dart';
part 'src/grid.dart';
part 'src/multiplayer.dart';
part 'src/singleplayer.dart';
part 'src/game.dart';
part 'src/collectables.dart';
part 'src/scenes.dart';
part 'src/movement.dart';

enum Direction {UP, RIGHT, DOWN, LEFT}
const int innerSize = 20;

final SelectTypeScene selectTypeScene = new SelectTypeScene(querySelector('#scene-select-type'));
final SinglePlayerGameScene singlePlayerGameScene = new SinglePlayerGameScene(querySelector('#scene-singleplayer-game'));
final MultiPlayerJoinRoomScene multiPlayerJoinRoomScene = new MultiPlayerJoinRoomScene(querySelector('#scene-multiplayer-joinroom'));
final MultiPlayerLobbyScene multiPlayerLobbyScene = new MultiPlayerLobbyScene(querySelector('#scene-multiplayer-lobby'));
final MultiPlayerGameScene multiPlayerGameScene = new MultiPlayerGameScene(querySelector('#scene-multiplayer-game'));
final SynchronizedWebSocketP2PGame p2pGame = new SynchronizedWebSocketP2PGame<LocalPacmanPlayer, RemotePacmanPlayer>('ws://signaling.roberthartung.de:28080', rtcConfiguration);