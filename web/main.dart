import 'dart:html';
import 'dart:math';
//import 'package:webrtc_utils/game.dart';

enum Direction {UP, RIGHT, DOWN, LEFT}

const int innerSize = 20;

abstract class MovingCharacter {
  Point position;

  Direction direction;

  MovingCharacter(int x, int y, this.direction) {
    position = new Point(x,y);
  }

  void _move() {
    switch(direction) {
      case Direction.UP :
        position += new Point(0, -1);
        break;
      case Direction.RIGHT :
        position += new Point(1, 0);
        break;
      case Direction.DOWN :
        position += new Point(0, 1);
        break;
      case Direction.LEFT :
        position += new Point(-1, 0);
        break;
    }
  }
}

class Ghost extends MovingCharacter {
  Ghost(x, y, direction) : super(x,y,direction) {

  }

  void render(int frame) {
    _move();
    // Body

    ctx.beginPath();
    ctx.translate(position.x, position.y);
    ctx.moveTo(-15, 0);
    ctx.quadraticCurveTo(-15, -30, 0, -30);
    ctx.quadraticCurveTo(15, -30, 15, 0);
    ctx.closePath();
    ctx.fillStyle = 'cyan';
    ctx.fill();
    /*
    ctx.beginPath();
    ctx.arc(0,0, 2, 0, 2*PI);
    ctx.fillStyle = 'red';
    ctx.fill();
    */
  }
}

class PacMan extends MovingCharacter {
  int angle = 5;

  int mouthDirection = 1;

  static const int radius = 10;

  PacMan() : super(110, 110, Direction.RIGHT);

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

  void render(int frame) {
    _move();
    _setAngle();
    _draw();
  }

  void _draw() {
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

CanvasRenderingContext2D ctx;
CanvasElement canvas;
CanvasPattern grid;
PacMan pacMan = new PacMan();
List<Ghost> ghosts = [new Ghost(210, 210, Direction.DOWN), new Ghost(410, 410, Direction.UP)];

void createGridPattern() {
  CanvasElement canvas_grid = new CanvasElement(width: 20, height: 20);
  CanvasRenderingContext2D _ctx = canvas_grid.getContext('2d');
  _ctx.strokeStyle = 'blue';
  _ctx.rect(0.5, 0.5, innerSize, innerSize);
  _ctx.stroke();
  grid = ctx.createPattern(canvas_grid, "repeat");
}

class Edge {
  Point p1;

  Point p2;

  Edge(x1, y1, x2, y2) {
    p1 = new Point(x1,y1);
    p2 = new Point(x2,y2);
  }
}

/// The field/grid we will be playing on
class Grid {
  final CanvasElement canvas;

  Map<Point,List<Edge>> sectors = new Map();

  Grid(this.canvas);

  void generate(List<Edge> edges) {
    edges.forEach((Edge edge) {
      sectors.putIfAbsent(edge.p1, () => new List()).add(edge);
      sectors.putIfAbsent(edge.p2, () => new List()).add(edge);
    });


  }
}

void main() {
  Grid grid = new Grid(querySelector('#canvas-grid'));
  grid.generate([new Edge(5,10,5,15)]);

  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  //createGridPattern();
  window.animationFrame.then(render);

  document.onKeyDown.listen((KeyboardEvent ev) {
    switch(ev.keyCode) {
      case KeyCode.LEFT :
        ev.preventDefault();
        pacMan.direction = Direction.LEFT;
        break;
      case KeyCode.RIGHT :
        ev.preventDefault();
        pacMan.direction = Direction.RIGHT;
        break;
      case KeyCode.DOWN :
        ev.preventDefault();
        pacMan.direction = Direction.DOWN;
        break;
      case KeyCode.UP :
        ev.preventDefault();
        pacMan.direction = Direction.UP;
        break;
    }
  });
}

void render(num time) {
  int frame = time ~/ (1000 / 60);
  ctx.clearRect(0, 0, canvas.width,  canvas.height);
  ctx.save();
  /*
  ctx.translate(10, 10);

  ctx.strokeStyle = 'blue';
  // Grid
  for(num x=0.5;x<=canvas.width-innerSize+.5;x+=innerSize) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height-innerSize);
    ctx.stroke();
  }

  for(num y=0.5;y<=canvas.height-innerSize+.5;y+=innerSize) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(canvas.width-innerSize, y);
    ctx.stroke();
  }
  */
  /*
  ctx.save();
  ctx.translate(0,0);
  ctx.rect(0,0, canvas.width, canvas.height);
  ctx.fillStyle = grid;
  ctx.fill();
  ctx.restore();
  */
  // PacMan
  ctx.save();
  pacMan.render(frame);
  ctx.restore();

  // Ghosts
  ghosts.forEach((Ghost ghost) {
    ctx.save();
    ghost.render(frame);
    ctx.restore();
  });
  ctx.restore();
  window.animationFrame.then(render);
}