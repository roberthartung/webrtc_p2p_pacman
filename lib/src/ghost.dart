part of pacman;

enum GhostStrategy {RANDOM, FOLLOW}

class Ghost extends MovingCharacter {
  PacMan pacMan;

  final GhostStrategy strategy;

  Ghost(this.strategy, this.pacMan, Grid grid, Point sector, direction) : super(grid, sector, direction);

  void _checkDirection(List<Direction> directions) {
    switch(strategy) {
      case GhostStrategy.RANDOM :
        directions.shuffle();
        requestedDirection = directions.first;
        break;
      case GhostStrategy.FOLLOW :
        num dX = pacMan.position.x - position.x;
        num dY = pacMan.position.y - position.y;
        if(dX < 0 && directions.contains(Direction.LEFT)) {
          requestedDirection = Direction.LEFT;
          // Pacman is left of us
        } else if(dX > 0 && directions.contains(Direction.RIGHT)) {
          requestedDirection = Direction.RIGHT;
          // Pacman is right of us
        } else if(dY < 0 && directions.contains(Direction.UP)) {
          requestedDirection = Direction.UP;
          // Pacman is above us
        } else if(dY > 0 && directions.contains(Direction.DOWN)) {
          requestedDirection = Direction.DOWN;
          // Pacman is below us
        } else {
          if(dX == 0) {
            requestedDirection = directions.contains(Direction.LEFT) ? Direction.LEFT : Direction.RIGHT;
            // Move Left or Right
          } else if(dY == 0) {
            requestedDirection = directions.contains(Direction.UP) ? Direction.UP : Direction.DOWN;
          } else {
            directions.shuffle();
            requestedDirection = directions.first;
            // print('ERROR: Ghost unable to determine next direction ($dX, $dY)');
          }
        }
        break;
    }
  }

  void render(CanvasRenderingContext2D ctx, int frame) {
    // angle to pacman
    num dX = pacMan.position.x - position.x;
    num dY = pacMan.position.y - position.y;
    num length = sqrt(dX*dX + dY*dY);
    dX /= length;
    dY /= length;

    // Move character
    _move();

    // Body
    ctx.beginPath();
    ctx.translate(position.x, position.y);
    ctx.moveTo(-10, 10);
    ctx.quadraticCurveTo(-10, -10, 0, -10);
    ctx.quadraticCurveTo(10, -10, 10, 10);
    ctx.closePath();
    ctx.fillStyle = 'cyan';
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