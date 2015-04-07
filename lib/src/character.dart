part of pacman;

abstract class MovingCharacter {
  final Grid grid;

  Point position;

  Direction direction;

  Direction requestedDirection = null;

  MovingCharacter(this.grid, Point start, this.direction) {
    // Make sure we have our own object!
    position = new Point(10 + start.x * Grid.gridSize, 10 + start.y * Grid.gridSize);
  }

  bool _canChangeDirection = true;

  void _checkDirection(List<Direction> directions);

  /// Moves the character in one tick
  void _move() {
    // Get current sector from position
    Point sector = new Point((position.x/innerSize).floor(), (position.y/innerSize).floor());
    // Check if the sector is a crosspoint
    List<Direction> crossPointDirections = grid.crossPoints[sector];
    // Indicator if the position can be changed
    _canChangeDirection = crossPointDirections != null &&
        position.x % innerSize == innerSize / 2 &&
        position.y % innerSize == innerSize / 2;

    if(_canChangeDirection) {
      _checkDirection(crossPointDirections);
    }

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
      if(_canChangeDirection && crossPointDirections.contains(requestedDirection)) {
        switch(direction) {
          case Direction.LEFT :
          case Direction.RIGHT :
            direction = requestedDirection;
            requestedDirection = null;
            break;
          case Direction.UP :
          case Direction.DOWN :
            direction = requestedDirection;
            requestedDirection = null;
            break;
        }
      }
    }

    // If we're at a crosspoint and the requested direction is not ok
    if(crossPointDirections != null && !crossPointDirections.contains(direction) &&
        (((direction == Direction.LEFT || direction == Direction.RIGHT) && position.x % innerSize == innerSize / 2) ||
        ((direction == Direction.UP || direction == Direction.DOWN) && position.y % innerSize == innerSize / 2))) {
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