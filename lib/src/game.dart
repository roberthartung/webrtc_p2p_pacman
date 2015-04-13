part of pacman;

/// Common interface for both of the multiplayer and singleplay version
abstract class PacmanGame {
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

  PacmanGame(canvas_static, this.canvas_dynamic, [this.seed = null])
      : grid = new Grid(canvas_static),
        this.canvas_static = canvas_static {
    ctx_static = canvas_static.getContext('2d');
    ctx_dynamic = canvas_dynamic.getContext('2d');
    _loadLevel();
    _startPoints = grid.crossPoints.keys.toList();
    _startPoints.shuffle(new Random(seed));
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

  void spawnCherry() {
    List points = sectors.toList();
    points.shuffle(new Random(seed));
    collectables.add(new Cherry(new Point(
        Grid.gridSize / 2 + Grid.gridSize * points.first.x,
        Grid.gridSize / 2 + Grid.gridSize * points.first.y)));
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

  void start() {
    init();
    _startTime = window.performance.now();
    window.animationFrame.then(_renderStatic);
    window.animationFrame.then(_render);
  }

  void stop() {
    characters.forEach((MovingCharacter c) => c.movementController.detach());
    // TODO(rh): Anything else we have to consider to cleanup here?
  }

  void _renderStatic(num time) {
    renderStatic();
  }

  void renderStatic() {
    ctx_static.clearRect(0, 0, canvas_dynamic.width, canvas_static.height);
    grid.render();
  }

  void addGhost(Ghost g) {
    characters.add(g);
  }

  void addPacman(Pacman p) {
    characters.add(p);
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

  Timer _harmlessGhostsTimer = null;

  bool _harmless = false;
  // bool get harmless => _harmless;

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
          if(!_harmless) {
            pacman.alive = false;
            // TODO(rh): Play sounds only locally!
            if (playSounds) {
              document.body.appendHtml(
                  '<audio src="sounds/pacman_death.wav" autoplay preload="auto"></audio>');
            }
          } else {
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
          } else if(collectable is Powerup) {
            if(_harmlessGhostsTimer != null) {
              _harmlessGhostsTimer.cancel();
            }
            print('[$this] Ghost are now harmless.');
            _harmless = true;
            ghosts.forEach((Ghost g) => g._harmless = true);
            _harmlessGhostsTimer = new Timer(new Duration(seconds: 10), () {
              _harmless = false;
              ghosts.forEach((Ghost g) => g._harmless = false);
              print('[$this] Ghost are not harmless anymore.');
            });
          }
        }
      });
    });
    collectables.removeWhere((c) => collected.contains(c));
  }
}
