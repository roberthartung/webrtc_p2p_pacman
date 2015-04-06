import 'dart:html';
import 'dart:math';
import 'dart:async';
//import 'package:webrtc_utils/game.dart';
import 'package:webrtc_p2p_pacman/pacman.dart';

CanvasRenderingContext2D ctx;
CanvasElement canvas;
CheckboxInputElement gameBuilderMode;
// CanvasPattern grid;
Grid grid;
List<Ghost> ghosts = [];
PacMan pacMan;

/*
void createGridPattern() {
  CanvasElement canvas_grid = new CanvasElement(width: 20, height: 20);
  CanvasRenderingContext2D _ctx = canvas_grid.getContext('2d');
  _ctx.strokeStyle = 'blue';
  _ctx.rect(0.5, 0.5, innerSize, innerSize);
  _ctx.stroke();
  grid = ctx.createPattern(canvas_grid, "repeat");
}
*/
void main() {
  gameBuilderMode = querySelector('#enable-game-builder-mode');
  /*
  gameBuilderMode.onChange.listen((Event ev) {
    
  });
  */
  canvas = querySelector('#canvas');
  grid = new Grid(querySelector('#canvas-grid'));
  grid.add(new Edge(20,5,20,25));
  grid.add(new Edge(10,15,30,15));
  //grid.add(new Edge(5,10,5,15));
  //grid.add(new Edge(5,10,20,10));
  //grid.add(new Edge(20,10,20,20));
  //grid.generate();
  
  pacMan = new PacMan(grid);
  ghosts.addAll([new Ghost(grid, 210, 210, Direction.DOWN), new Ghost(grid, 410, 410, Direction.UP)]);
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
        grid.generate();
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
        grid.generate();
      }
    });
  });
  
  ctx = canvas.getContext('2d');
  //createGridPattern();
  window.animationFrame.then(render);

  document.onKeyDown.listen((KeyboardEvent ev) {
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
}

void render(num time) {
  int frame = time ~/ (1000 / 60);
  
  grid.ctx.clearRect(0, 0, grid.canvas.width, grid.canvas.height);
  if(gameBuilderMode.checked) {
    grid.generate();
  }
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
  pacMan.render(ctx, frame);
  ctx.restore();
  // Ghosts
  ghosts.forEach((Ghost ghost) {
    ctx.save();
    ghost.render(ctx, frame);
    ctx.restore();
  });
  ctx.restore();
  window.animationFrame.then(render);
}