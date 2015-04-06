part of pacman;

abstract class MovingCharacter {
  final Grid grid;
  
  Point position;

  Direction direction;
  
  Direction requestedDirection = null;

  MovingCharacter(this.grid, int x, int y, this.direction) {
    position = new Point(x,y);
  }

  void _move() {
    Point sector = new Point((position.x/innerSize).floor(), (position.y/innerSize).floor());
    List<Direction> crossPointDirections = grid.crossPoints[sector];
    
    // Check if the user requested a positional change
    if(requestedDirection != null) {
      // If it's the opposite, we can make change directly
      if((direction == Direction.LEFT && requestedDirection == Direction.RIGHT) ||
          (direction == Direction.RIGHT && requestedDirection == Direction.LEFT) ||
          (direction == Direction.UP && requestedDirection == Direction.DOWN) ||
          (direction == Direction.DOWN && requestedDirection == Direction.UP)) {
        direction = requestedDirection;
        requestedDirection = null;
        // Return forces a delay when we turn direction!
        return;
      }
      
      // Otherwise check if the sector is a crosspoint!
      if(crossPointDirections != null && crossPointDirections.contains(requestedDirection)) {
        print('[$this] $sector $crossPointDirections');
        
        switch(direction) {
          case Direction.LEFT :
          case Direction.RIGHT :
            if(position.x % innerSize == innerSize / 2) {
              direction = requestedDirection;
              requestedDirection = null;
              return;
            }
            break;
          case Direction.UP :
          case Direction.DOWN :
            if(position.y % innerSize == innerSize / 2) {
              direction = requestedDirection;
              requestedDirection = null;
              return;
            }
            break;
        }
      }
    }
    
    // If we're at a crosspoint and the requested direction is not
    if(crossPointDirections != null && !crossPointDirections.contains(direction) &&
        (((direction == Direction.LEFT || direction == Direction.RIGHT) && position.x % innerSize == innerSize / 2) ||
        ((direction == Direction.UP || direction == Direction.DOWN) && position.y % innerSize == innerSize / 2))) {
      // TODO(rh): Check if we're in the middle of the sector and only cancel there!
      return;
    }
    
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