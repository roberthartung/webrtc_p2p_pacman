import 'dart:html';
import 'dart:async';
import 'dart:math';

import 'package:webrtc_utils/game.dart';
import 'package:webrtc_utils/client.dart';
import 'package:webrtc_p2p_pacman/pacman.dart';
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

  Timer _harmlessGhostsTimer = null;

  Iterable<Ghost> get ghosts => characters.where((c) => c is Ghost);

  bool _harmless = false;

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

  void init() {
    characters.forEach((MovingCharacter c) => c.movementController.attach());
    sectors.clear();
    // Generate collectables
    grid.edges.forEach((Edge edge) {
      sectors.add(edge.p1);
      sectors.add(edge.p2);
      if (edge.isHorizontal) {
        final int y = edge.p1.y;
        int x = edge.p1.x + 1;
        while (x < edge.p2.x) {
          sectors.add(new Point(x, y));
          x++;
        }
      } else {
        final int x = edge.p1.x;
        int y = edge.p1.y + 1;
        while (y < edge.p2.y) {
          sectors.add(new Point(x, y));
          y++;
        }
      }
    });

    // Create PowerUp to be able to eat ghosts
    List<Point> s = sectors.toList(growable: false);
    // TODO(rh): Dynamic random
    s.shuffle(nextRandom());
    s.take(10).forEach((Point p) {
      collectables.add(new Powerup(new Point(
          p.x * Grid.gridSize + Grid.gridSize / 2,
          p.y * Grid.gridSize + Grid.gridSize / 2)));
    });
    sectors.skip(10).forEach((Point p) {
      collectables.add(new Dot(new Point(
          p.x * Grid.gridSize + Grid.gridSize / 2,
          p.y * Grid.gridSize + Grid.gridSize / 2)));
    });
  }

  Random nextRandom() {
    return new Random(seed);
  }

  void _loadLevel() {
    grid.add(new Edge(1, 1, 1, 5));
    grid.add(new Edge(1, 1, 6, 1));
    grid.add(new Edge(1, 5, 1, 8));
    grid.add(new Edge(1, 5, 6, 5));
    grid.add(new Edge(6, 5, 6, 8));
    grid.add(new Edge(6, 1, 6, 5));
    grid.add(new Edge(6, 5, 9, 5));
    grid.add(new Edge(6, 1, 12, 1));
    grid.add(new Edge(9, 5, 12, 5));
    grid.add(new Edge(12, 1, 12, 5));
    grid.add(new Edge(12, 5, 15, 5));
    grid.add(new Edge(9, 5, 9, 8));
    grid.add(new Edge(15, 1, 21, 1));
    grid.add(new Edge(15, 1, 15, 5));
    grid.add(new Edge(18, 5, 18, 8));
    grid.add(new Edge(15, 5, 18, 5));
    grid.add(new Edge(21, 1, 26, 1));
    grid.add(new Edge(21, 1, 21, 5));
    grid.add(new Edge(26, 1, 26, 5));
    grid.add(new Edge(18, 5, 21, 5));
    grid.add(new Edge(21, 5, 21, 8));
    grid.add(new Edge(21, 5, 26, 5));
    grid.add(new Edge(26, 5, 26, 8));
    grid.add(new Edge(1, 8, 6, 8));
    grid.add(new Edge(6, 8, 6, 14));
    grid.add(new Edge(9, 8, 12, 8));
    grid.add(new Edge(9, 11, 9, 14));
    grid.add(new Edge(6, 14, 9, 14));
    grid.add(new Edge(9, 11, 12, 11));
    grid.add(new Edge(12, 8, 12, 11));
    grid.add(new Edge(15, 8, 18, 8));
    grid.add(new Edge(12, 11, 15, 11));
    grid.add(new Edge(15, 8, 15, 11));
    grid.add(new Edge(15, 11, 18, 11));
    grid.add(new Edge(18, 11, 18, 14));
    grid.add(new Edge(21, 8, 26, 8));
    grid.add(new Edge(21, 8, 21, 14));
    grid.add(new Edge(18, 14, 21, 14));
    grid.add(new Edge(9, 14, 9, 16));
    grid.add(new Edge(9, 16, 18, 16));
    grid.add(new Edge(18, 14, 18, 16));
    grid.add(new Edge(9, 16, 9, 19));
    grid.add(new Edge(18, 16, 18, 19));
    grid.add(new Edge(9, 19, 12, 19));
    grid.add(new Edge(15, 19, 18, 19));
    grid.add(new Edge(6, 14, 6, 19));
    grid.add(new Edge(21, 14, 21, 19));
    grid.add(new Edge(1, 19, 1, 22));
    grid.add(new Edge(26, 19, 26, 22));
    grid.add(new Edge(1, 22, 3, 22));
    grid.add(new Edge(1, 25, 3, 25));
    grid.add(new Edge(24, 22, 26, 22));
    grid.add(new Edge(1, 25, 1, 28));
    grid.add(new Edge(26, 25, 26, 28));
    grid.add(new Edge(3, 22, 3, 25));
    grid.add(new Edge(6, 19, 9, 19));
    grid.add(new Edge(1, 19, 6, 19));
    grid.add(new Edge(3, 25, 6, 25));
    grid.add(new Edge(24, 22, 24, 25));
    grid.add(new Edge(24, 25, 26, 25));
    grid.add(new Edge(18, 19, 21, 19));
    grid.add(new Edge(21, 19, 26, 19));
    grid.add(new Edge(21, 25, 24, 25));
    grid.add(new Edge(12, 19, 12, 22));
    grid.add(new Edge(12, 22, 15, 22));
    grid.add(new Edge(6, 19, 6, 22));
    grid.add(new Edge(6, 22, 6, 25));
    grid.add(new Edge(15, 19, 15, 22));
    grid.add(new Edge(21, 19, 21, 22));
    grid.add(new Edge(21, 22, 21, 25));
    grid.add(new Edge(6, 22, 9, 22));
    grid.add(new Edge(9, 22, 12, 22));
    grid.add(new Edge(9, 22, 9, 25));
    grid.add(new Edge(1, 28, 12, 28));
    grid.add(new Edge(12, 25, 12, 28));
    grid.add(new Edge(9, 25, 12, 25));
    grid.add(new Edge(15, 22, 18, 22));
    grid.add(new Edge(18, 22, 21, 22));
    grid.add(new Edge(18, 22, 18, 25));
    grid.add(new Edge(12, 28, 15, 28));
    grid.add(new Edge(15, 28, 26, 28));
    grid.add(new Edge(15, 25, 15, 28));
    grid.add(new Edge(15, 25, 18, 25));
  }

  void startMultiplayer() {
    print('start mutliplayer');
  }

  void createGhost(Pacman pacman) {
    Point start = _startPoints.elementAt(_ghostStartPointOffset);
    Ghost ghost = new Ghost(
        (_ghostStartPointOffset == 1 || _ghostStartPointOffset == 2)
            ? new FollowingGhostMovement(pacman)
            : new RandomGhostMovement(), pacman, grid, start);
    characters.add(ghost);
    _ghostStartPointOffset++;
  }

  void startSingleplayer() {
    Pacman pacman =
        new Pacman(new KeyboardMovementController(), grid, _startPoints.first);
    characters.add(pacman);

    for(int i=1;i<=5;i++) {
      createGhost(pacman);
    }

    init();
    _startTime = window.performance.now();
    window.animationFrame.then(_renderStatic);
    window.animationFrame.then(_render);

    //_loop = true;
    //window.animationFrame.then(_tick);
    print('start singleplayer');
  }

  void _renderStatic(num time) {
    renderStatic();
  }

  void renderStatic() {
    ctx_static.clearRect(0, 0, canvas_dynamic.width, canvas_static.height);
    grid.render();
  }

  void _render(num time) {
    int lastTick = (time - _startTime) ~/ (1000 / 60);
    for (int t = _lastTick + 1; t <= lastTick; t++) {
      tick(t);
    }
    _lastTick = lastTick;
    render();
    // Check if we were eaten by a ghost
    if (pacmans.isNotEmpty) {
      // If there is at least one Dot to collect -> render loop
      if (collectables.any((Collectable c) => c is Dot)) {
        window.animationFrame.then(_render);
      } else {
        _onFinishedStreamController.add(null);
        stop();
      }
    } else {
      _onEatenStreamController.add(null);
    }
  }

  void stop() {
    characters.forEach((MovingCharacter c) => c.movementController.detach());
    // TODO(rh): Anything else we have to consider to cleanup here?
  }

  /*
  void _tick(num time) {
    // TODO(rh): All Ticks
    tick(time ~/ (1000 / 60));
    render();
    if (_loop) {
      window.animationFrame.then(_tick);
    }
  }
  */

  void spawnCherry() {
    List points = sectors.toList();
    points.shuffle(new Random(seed));
    collectables.add(new Cherry(new Point(
        Grid.gridSize / 2 + Grid.gridSize * points.first.x,
        Grid.gridSize / 2 + Grid.gridSize * points.first.y)));
  }

  void tick(int tick) {
// bool eaten = false;

    if (tick % 1000 == 0) {
      spawnCherry();
    }

    // Make one tick for each character
    characters.forEach((MovingCharacter character) {
      if (character is Pacman) {
        if (tick % 10 == 0) {
          character.score -= 1;
        }
      }
      character.tick(tick);
    });

    // Check for collisions
    ghosts.forEach((Ghost ghost) {
      pacmans.forEach((Pacman pacman) {
        if (ghost.position.distanceTo(pacman.position) <= 15) {
          if (!_harmless) {
            pacman.alive = false;
            // TODO(rh): Play sounds only locally!
            if (playSounds) {
              document.body.appendHtml(
                  '<audio src="sounds/pacman_death.wav" autoplay preload="auto"></audio>');
            }
          } else {
            // TODO(rh): Remove ghost temporarily
            // Start timer to spawn ghost
            // ghost.position = ...;
            new Timer(new Duration(seconds: 5), () {
              print('Ghost was eaten. [$ghost]. Respawn!');
            });
          }
        }
      });
    });

    if (pacmans.isEmpty) {
      return;
    }

    // Render collectables
    List<Collectable> collected = [];
    collectables.forEach((Collectable collectable) {
      pacmans.forEach((Pacman pacman) {
        if (collectable.sector.distanceTo(pacman.position) <= 6) {
          collected.add(collectable);
          if (collectable is Dot) {
            pacman.score += 50;
          } else if (collectable is Cherry) {
            pacman.score += 500;
          } else if (collectable is Powerup) {
            if (_harmlessGhostsTimer != null) {
              _harmlessGhostsTimer.cancel();
            }
            print('[$this] Ghost are now harmless.');
            _harmless = true;
            ghosts.forEach((Ghost g) => g.harmless = true);
            _harmlessGhostsTimer = new Timer(new Duration(seconds: 10), () {
              _harmless = false;
              ghosts.forEach((Ghost g) => g.harmless = false);
              print('[$this] Ghost are not harmless anymore.');
            });
          }
        }
      });
    });
    collectables.removeWhere((c) => collected.contains(c));
  }

  /// Render the dynamic scene
  void render() {
    // Clear canvas
    ctx_dynamic.clearRect(0, 0, canvas_dynamic.width, canvas_dynamic.height);
    // Render character
    characters.forEach((MovingCharacter character) {
      ctx_dynamic.save();
      character.render(ctx_dynamic);
      ctx_dynamic.restore();
    });
    collectables.forEach((Collectable c) => c.render(ctx_dynamic));
  }
}

main() async {
  initPolymer();
  await Polymer.onReady;

  GameElement game = querySelector('rh-game');
  game.setP2PGame(new SynchronizedWebSocketP2PGame(
      'ws://signaling.roberthartung.de:28080', rtcConfiguration));
  game.setGameController(new PacmanGameController(
      querySelector('#canvas-static'), querySelector('#canvas-dynamic')));

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
