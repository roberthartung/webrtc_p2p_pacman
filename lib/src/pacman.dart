part of pacman;

class PacMan extends MovingCharacter {
  int angle = 5;

  int mouthDirection = 1;

  static const int radius = 10;
  
  // TODO(rh): Make initial direction random
  PacMan(Grid grid) : super(grid, 410, 310, Direction.RIGHT);

  void _setAngle() {
    if(angle >= 40) {
      mouthDirection = -1;
    } else if(angle <= 5) {
      mouthDirection = 1;
    }
    if(mouthDirection == 1) {
      angle += 2;
    } else {
      angle -= 2;
    }
  }

  void render(CanvasRenderingContext2D ctx, int frame) {
    _move();
    _setAngle();
    _draw(ctx);
  }

  void _draw(CanvasRenderingContext2D ctx) {
    int angleOffset;
    switch(direction) {
      case Direction.UP :
        angleOffset = 270;
        break;
      case Direction.RIGHT :
        angleOffset = 0;
        break;
      case Direction.DOWN :
        angleOffset = 90;
        break;
      case Direction.LEFT :
        angleOffset = 180;
        break;
    }
    ctx.beginPath();
    ctx.moveTo(position.x, position.y);
    ctx.arc(position.x, position.y, radius, (angleOffset + angle) / 180 * PI, (angleOffset + (360-angle)) / 180 * PI);
    ctx.closePath();
    ctx.fillStyle = 'yellow';
    ctx.fill();
  }
}