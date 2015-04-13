part of pacman;

abstract class Collectable {
  final Point sector;

  Collectable(this.sector);

  void render(CanvasRenderingContext2D ctx);
}

class Dot extends Collectable {
  Dot(s) : super(s);

  void render(CanvasRenderingContext2D ctx) {
    ctx.save();
    ctx.beginPath();
    ctx.translate(sector.x, sector.y);
    ctx.rect(-1, -1, 2, 2);
    ctx.fillStyle = 'white';
    ctx.fill();
    ctx.restore();
  }
}

class Powerup extends Collectable {
  Powerup(s) : super(s);

  void render(CanvasRenderingContext2D ctx) {
    ctx.save();
    ctx.beginPath();
    ctx.translate(sector.x, sector.y);
    ctx.rect(-3, -3, 6, 6);
    ctx.fillStyle = 'white';
    ctx.fill();
    ctx.restore();
  }
}

class Cherry extends Collectable {
  Cherry(s) : super(s);

  void render(CanvasRenderingContext2D ctx) {
    ctx.save();
    ctx.translate(sector.x, sector.y);
    ctx.drawImageScaled(
        querySelector('#cherry') as ImageElement, -20 / 2, -17 / 2, 20, 17);
    ctx.restore();
  }
}
