part of pacman;

class Ghost extends MovingCharacter {
  Ghost(Grid grid, x, y, direction) : super(grid, x,y,direction) {
    
  }

  void render(CanvasRenderingContext2D ctx, int frame) {
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