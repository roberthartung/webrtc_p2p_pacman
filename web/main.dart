import 'dart:html';
import 'dart:async';

import 'package:webrtc_utils/game.dart';
import 'package:webrtc_utils/client.dart';
// import 'package:webrtc_p2p_pacman/pacman.dart';
import 'package:webrtc_p2p_pacman/rh_game.dart';
import 'package:polymer/polymer.dart';

bool playMusic = false;
bool playSounds = true;
num volume = 10;
AudioElement music;

class PacmanGameController implements GameController {
  final CanvasElement canvas_static;
  final CanvasElement canvas_dynamic;

  CanvasRenderingContext2D ctx_static;
  CanvasRenderingContext2D ctx_dynamic;

  Stream<int> get onFinished => _onFinishedStreamController.stream;
  StreamController<int> _onFinishedStreamController =
      new StreamController.broadcast();

  Stream<int> get onEaten => _onEatenStreamController.stream;
  StreamController<int> _onEatenStreamController =
      new StreamController.broadcast();

  bool _loop;

  final Grid grid;

  List<Point> _startPoints;
  int _ghostStartPointOffset = 1;

  final Set<Point> sectors = new Set();

  final List<Collectable> collectables = new List();

  final int seed;

  bool playSounds = true;

  double _startTime;

  int _lastTick = 0;

  List<MovingCharacter> characters = [];

  Iterable<Ghost> get ghosts => characters.where((c) => c is Ghost);

  /// List of [Pacman] objects that are alive
  Iterable<Pacman> get pacmans =>
      characters.where((c) => c is Pacman && c.alive);

  PacmanGameController(canvas_static, this.canvas_dynamic, [this.seed = null])
      : grid = new Grid(canvas_static),
        this.canvas_static = canvas_static {
    ctx_static = canvas_static.getContext('2d');
    ctx_dynamic = canvas_dynamic.getContext('2d');
    _loadLevel();
    _startPoints = grid.crossPoints.keys.toList();
    _startPoints.shuffle(new Random(seed));
  }

  void startMultiplayer() {
    print('start mutliplayer');
  }

  void startSingleplayer() {
    Pacman pacman =
        new Pacman(new KeyboardMovementController(), grid, _startPoints.first);
    addPacman(pacman);

    _loop = true;
    window.animationFrame.then(_tick);
    print('start singleplayer');
  }

  void _tick(num time) {
    tick(time);
    if (_loop) {
      window.animationFrame.then(_tick);
    }
  }

  void tick(num time) {
    render(0);
  }

  void render(int tick) {}
}

main() async {
  initPolymer();
  await Polymer.onReady;
  GameElement game = querySelector('rh-game');
  game.setP2PGame(new SynchronizedWebSocketP2PGame(
      'ws://signaling.roberthartung.de:28080', rtcConfiguration));
  game.setGameController(new PacmanGameController());

  MediaStream ms;

  /*
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
  */

}
