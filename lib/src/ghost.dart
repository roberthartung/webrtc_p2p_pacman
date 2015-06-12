part of pacman;

class RandomGhostMovement implements MovementController {
  Direction get direction => _direction;
  Direction _direction;
  
  void _forceDirection(Direction newDirection) {
    _direction = newDirection;
  }

  void checkDirection(
      Point position, List<Direction> directions, bool canChange) {
    if (canChange) {
      directions.shuffle();
      _direction = directions.first;
    }
  }

  void attach() {}

  void detach() {}
}

class FollowingGhostMovement implements MovementController {
  Direction get direction => _direction;
  Direction _direction;

  Pacman pacman;
  
  FollowingGhostMovement(this.pacman);
  
  void _forceDirection(Direction newDirection) {
    _direction = newDirection;
  }

  void checkDirection(
      Point position, List<Direction> directions, bool canChange) {
    if (!canChange) {
      return;
    }
    num dX = pacman.position.x - position.x;
    num dY = pacman.position.y - position.y;
    if (dX < 0 && directions.contains(Direction.LEFT)) {
      _direction = Direction.LEFT;
      // Pacman is left of us
    } else if (dX > 0 && directions.contains(Direction.RIGHT)) {
      _direction = Direction.RIGHT;
      // Pacman is right of us
    } else if (dY < 0 && directions.contains(Direction.UP)) {
      _direction = Direction.UP;
      // Pacman is above us
    } else if (dY > 0 && directions.contains(Direction.DOWN)) {
      _direction = Direction.DOWN;
      // Pacman is below us
    } else {
      if (dX == 0) {
        _direction = directions.contains(Direction.LEFT)
            ? Direction.LEFT
            : Direction.RIGHT;
        // Move Left or Right
      } else if (dY == 0) {
        _direction =
            directions.contains(Direction.UP) ? Direction.UP : Direction.DOWN;
      } else {
        directions.shuffle();
        _direction = directions.first;
        // print('ERROR: Ghost unable to determine next direction ($dX, $dY)');
      }
    }
  }

  void attach() {}

  void detach() {}
}

class Ghost extends MovingCharacter {
  Pacman pacman;

  bool harmless = false;

  bool eaten = false;

  bool respawning = false;

  bool leaveExit = false;

  Ghost(movementController, Pacman pacman, Grid grid, Point sector)
      : super(grid, movementController, sector) {
    this.pacman = pacman;
  }

  void render(CanvasRenderingContext2D ctx) {
    // angle to pacman
    num dX, dY;

    if (pacman != null) {
      dX = pacman.position.x - position.x;
      dY = pacman.position.y - position.y;
      num length = sqrt(dX * dX + dY * dY);
      dX /= length;
      dY /= length;
    } else {
      dX = 0;
      dY = 0;
    }

    // Body
    ctx.beginPath();
    ctx.translate(position.x, position.y);
    ctx.moveTo(-10, 10);
    ctx.quadraticCurveTo(-10, -10, 0, -10);
    ctx.quadraticCurveTo(10, -10, 10, 10);
    ctx.closePath();

    ctx.fillStyle = harmless ? 'blue' : 'cyan';
    ctx.fill();
    // Eyes
    ctx.beginPath();
    ctx.arc(-3, -3, 4, 0, 2 * PI);
    ctx.fillStyle = 'white';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(3, -3, 4, 0, 2 * PI);
    ctx.fillStyle = 'white';
    ctx.fill();

    ctx.beginPath();
    ctx.arc(-3 + 2 * dX, -5 + 2 * dY, 2, 0, 2 * PI);
    ctx.fillStyle = 'black';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(3 + 2 * dX, -5 + 2 * dY, 2, 0, 2 * PI);
    ctx.fillStyle = 'black';
    ctx.fill();
  }

  void tick(int tick) {
    if (eaten) {
      // TODO(rh): Only move X in Spawner
      return;
    }

    if (respawning) {
      GhostSpawner s = grid.ghostSpawner;
      // 1. Move to exit
      num targetX =
          s.isHorizontal ? s.exitBegin.x + (s.exitWidth) / 2 : s.exitBegin.x;
      num targetY =
          s.isHorizontal ? s.exitBegin.y : s.exitBegin.y + (s.exitHeight) / 2;
      num xDiff = (targetX * Grid.gridSize) - position.x;
      num yDiff = (targetY * Grid.gridSize) - position.y;

      // Move towards targetX/targetY
      if (xDiff != 0 || yDiff != 0) {
        if (xDiff > 0) {
          position += new Point(1, 0);
        } else if (xDiff < 0) {
          position += new Point(-1, 0);
        }

        if (yDiff > 0) {
          position += new Point(0, 1);
        } else if (yDiff < 0) {
          position += new Point(0, -1);
        }
      } else {
        leaveExit = true;
        respawning = false;
      }
      return;
    }

    if (leaveExit) {
      GhostSpawner s = grid.ghostSpawner;
      // Check position of exit!
      if (s.isHorizontal) {
        if (position.y <= s.p1.y * Grid.gridSize) {
          position += new Point(0, -1);
          if (position.y % 10 == 0) {
            // Change direction
            // TODO(rh): Make direction random
            movementController._forceDirection(Direction.LEFT);
            leaveExit = false;
          }
        } else {
          throw "Not implemented";
        }
      } else {
        if (position.x <= s.p1.x * Grid.gridSize) {
          throw "Not implemented";
        } else {
          throw "Not implemented";
        }
      }
      
      return;
    }

    super.tick(tick);
  }
}
