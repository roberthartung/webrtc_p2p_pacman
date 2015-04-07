part of pacman;

/// Common interface for both of the multiplayer and singleplay version
abstract class PacmanGame {
  final CanvasElement canvas_static;
  final CanvasElement canvas_dynamic;

  CanvasRenderingContext2D ctx_static;
  CanvasRenderingContext2D ctx_dynamic;

  Stream<int> get onFinished => _onFinishedStreamController.stream;
  StreamController<int> _onFinishedStreamController = new StreamController.broadcast();

  Stream<int> get onEaten => _onEatenStreamController.stream;
  StreamController<int> _onEatenStreamController = new StreamController.broadcast();

  final Grid grid;
  final List<Ghost> ghosts = [];
  List<Point> _startPoints;
  // TODO(rh): Hack, only 1 pacman allowed at this time
  PacMan get pacMan;
  int _ghostStartPointOffset = 1;

  final Set<Point> sectors = new Set();

  final List<Collectable> collectables = new List();

  StreamSubscription _keyboardSub;

  int _score = 0;

  bool playSounds = true;

  PacmanGame(canvas_static, this.canvas_dynamic)
    : grid = new Grid(canvas_static),
      this.canvas_static = canvas_static {
    ctx_static = canvas_static.getContext('2d');
    ctx_dynamic = canvas_dynamic.getContext('2d');
    _loadLevel();
    _startPoints = grid.crossPoints.keys.toList();
    _startPoints.shuffle();
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

  void createGhost() {
    Point start = _startPoints.elementAt(_ghostStartPointOffset);
    ghosts.add(new Ghost((_ghostStartPointOffset == 1 || _ghostStartPointOffset == 2) ? GhostStrategy.FOLLOW : GhostStrategy.RANDOM, pacMan, grid, start, grid.crossPoints[start].first));
    _ghostStartPointOffset++;
  }

  void spawnCherry() {
    List points = sectors.toList();
    points.shuffle();
    collectables.add(new Cherry(new Point(Grid.gridSize / 2 + Grid.gridSize * points.first.x, Grid.gridSize / 2 + Grid.gridSize * points.first.y)));
  }

  void start() {
    sectors.clear();
    // Generate collectables
    grid.edges.forEach((Edge edge) {
      sectors.add(edge.p1);
      sectors.add(edge.p2);
      if(edge.isHorizontal) {
        final int y = edge.p1.y;
        int x = edge.p1.x + 1;
        while(x < edge.p2.x) {
          sectors.add(new Point(x,y));
          x++;
        }
      } else {
        final int x = edge.p1.x;
        int y = edge.p1.y + 1;
        while(y < edge.p2.y) {
          sectors.add(new Point(x,y));
          y++;
        }
      }
    });

    sectors.forEach((Point p) {
      collectables.add(new Dot(new Point(p.x*Grid.gridSize + Grid.gridSize / 2, p.y*Grid.gridSize + Grid.gridSize / 2)));
    });

    // ...
    _keyboardSub = document.onKeyDown.listen((KeyboardEvent ev) {
      switch(ev.keyCode) {
        case KeyCode.LEFT :
          ev.preventDefault();
          pacMan.requestedDirection = Direction.LEFT;
          break;
        case KeyCode.RIGHT :
          ev.preventDefault();
          pacMan.requestedDirection = Direction.RIGHT;
          break;
        case KeyCode.DOWN :
          ev.preventDefault();
          pacMan.requestedDirection = Direction.DOWN;
          break;
        case KeyCode.UP :
          ev.preventDefault();
          pacMan.requestedDirection = Direction.UP;
          break;
      }
    });
    window.animationFrame.then(renderStatic);
    window.animationFrame.then(render);
  }

  void stop() {
    if(_keyboardSub != null) {
      _keyboardSub.cancel();
      _keyboardSub = null;
    }
    // TODO(rh): Anything else we have to consider to cleanup here?
  }

  void renderStatic(num time) {
    ctx_static.clearRect(0, 0, canvas_dynamic.width,  canvas_static.height);
    grid.render(time);
  }

  void render(num time) {
    int frame = time ~/ (1000 / 60);
    if(frame % 10 == 0) {
      _score += 1;
    }
    if(frame % 1000 == 0) {
      spawnCherry();
    }
    ctx_dynamic.clearRect(0, 0, canvas_dynamic.width,  canvas_static.height);
    bool eaten = false;
    // grid.ctx.clearRect(0, 0, grid.canvas.width, grid.canvas.height);
    // grid.generate(gameBuilderMode.checked);
    ctx_dynamic.clearRect(0, 0, canvas_dynamic.width,  canvas_dynamic.height);
    // PacMan
    ctx_dynamic.save();
    pacMan.render(ctx_dynamic, frame);
    ctx_dynamic.restore();
    // Ghosts
    ghosts.forEach((Ghost ghost) {
      ctx_dynamic.save();
      ghost.render(ctx_dynamic, frame);
      ctx_dynamic.restore();

      // Check if this ghost is close to pacman
      if(ghost.position.distanceTo(pacMan.position) <= 15) {
        if(playSounds) {
          document.body.appendHtml('<audio src="sounds/pacman_death.wav" autoplay preload="auto"></audio>');
        }
        eaten = true;
        return;
      }
    });
    // Render collectables

    List<Collectable> collected = [];
    collectables.forEach((Collectable collectable) {
      if(collectable.sector.distanceTo(pacMan.position) <= 6) {
        collected.add(collectable);
        if(collectable is Dot) {
          _score += 50;
        } else if(collectable is Cherry) {
          _score += 500;
        }
      } else {
        collectable.render(ctx_dynamic);
      }
    });
    collectables.removeWhere((c) => collected.contains(c));

    querySelector('#score').text = '$_score';

    if(!eaten) {
      if(collectables.isEmpty) {
        _onFinishedStreamController.add(_score);
        print('FINISHED!');
      } else {
        window.animationFrame.then(render);
      }
    } else {
      _onEatenStreamController.add(_score);
    }
  }
}