part of pacman;

class RandomGhostMovement implements MovementController {
  Direction get direction => _direction;
  Direction _direction;

  void checkDirection(Point position, List<Direction> directions, bool canChange) {
    if(canChange) {
      directions.shuffle();
      _direction = directions.first;
    }
  }

  void attach() {

  }

  void detach() {

  }
}

class FollowingGhostMovement implements MovementController {
  Direction get direction => _direction;
  Direction _direction;

  Pacman pacman;

  FollowingGhostMovement(this.pacman);

  void checkDirection(Point position, List<Direction> directions, bool canChange) {
    if(!canChange) {
      return;
    }
    num dX = pacman.position.x - position.x;
    num dY = pacman.position.y - position.y;
    if(dX < 0 && directions.contains(Direction.LEFT)) {
      _direction = Direction.LEFT;
      // Pacman is left of us
    } else if(dX > 0 && directions.contains(Direction.RIGHT)) {
      _direction = Direction.RIGHT;
      // Pacman is right of us
    } else if(dY < 0 && directions.contains(Direction.UP)) {
      _direction = Direction.UP;
      // Pacman is above us
    } else if(dY > 0 && directions.contains(Direction.DOWN)) {
      _direction = Direction.DOWN;
      // Pacman is below us
    } else {
      if(dX == 0) {
        _direction = directions.contains(Direction.LEFT) ? Direction.LEFT : Direction.RIGHT;
        // Move Left or Right
      } else if(dY == 0) {
        _direction = directions.contains(Direction.UP) ? Direction.UP : Direction.DOWN;
      } else {
        directions.shuffle();
        _direction = directions.first;
        // print('ERROR: Ghost unable to determine next direction ($dX, $dY)');
      }
    }
  }

  void attach() {

  }

  void detach() {

  }
}

class Ghost extends MovingCharacter {
  Pacman pacman;

  bool harmless = false;

  Ghost(movementController, Pacman pacman, Grid grid, Point sector) : super(grid, movementController, sector) {
    this.pacman = pacman;
  }

  void render(CanvasRenderingContext2D ctx) {
    // angle to pacman
    num dX,dY;

    if(pacman != null) {
      dX = pacman.position.x - position.x;
      dY = pacman.position.y - position.y;
      num length = sqrt(dX*dX + dY*dY);
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
    ctx.arc(-3, -3, 4, 0, 2*PI);
    ctx.fillStyle = 'white';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(3, -3, 4, 0, 2*PI);
    ctx.fillStyle = 'white';
    ctx.fill();

    ctx.beginPath();
    ctx.arc(-3 + 2*dX, -5 + 2*dY, 2, 0, 2*PI);
    ctx.fillStyle = 'black';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(3 + 2*dX, -5 + 2*dY, 2, 0, 2*PI);
    ctx.fillStyle = 'black';
    ctx.fill();
  }
}