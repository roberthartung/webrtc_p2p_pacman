part of pacman;

/// Base class for a moving character
/// It both used by [Ghost] and [Pacman]
abstract class MovingCharacter {
  /// Instance of the grid the character moves on
  final Grid grid;

  final MovementController movementController;

  /// Current position
  Point position;

  /// Current direction
  /*Direction direction;*/

  MovingCharacter(
      this.grid, this.movementController, Point start /*,this.direction*/) {
    // Make sure we have our own object!
    position =
        new Point(10 + start.x * Grid.gridSize, 10 + start.y * Grid.gridSize);
  }

  void tick(int tick) {
    // Get current sector from position
    Point sector = new Point(
        (position.x / innerSize).floor(), (position.y / innerSize).floor());
    // Check if the sector is a crosspoint
    List<Direction> crossPointDirections = grid.crossPoints[sector];
    // Indicator if the position can be changed
    bool _canChangeDirection = crossPointDirections != null &&
        position.x % innerSize == innerSize / 2 &&
        position.y % innerSize == innerSize / 2;

    movementController.checkDirection(
        position, crossPointDirections, _canChangeDirection);

    // If we're at a crosspoint and the requested direction is not ok
    /*if (crossPointDirections != null &&
        !crossPointDirections.contains(direction) &&
        (((direction == Direction.LEFT || direction == Direction.RIGHT) &&
                position.x % innerSize == innerSize / 2) ||
            ((direction == Direction.UP || direction == Direction.DOWN) &&
                position.y % innerSize == innerSize / 2))) {
      return;
    }
    */

    // Stop moving at a crosspoint if the requested direction can not be satisfied
    if (_canChangeDirection &&
        !crossPointDirections.contains(movementController.direction)) {
      return;
    }
    switch (movementController.direction) {
      case Direction.UP:
        position += new Point(0, -1);
        break;
      case Direction.RIGHT:
        position += new Point(1, 0);
        break;
      case Direction.DOWN:
        position += new Point(0, 1);
        break;
      case Direction.LEFT:
        position += new Point(-1, 0);
        break;
    }
  }

  void render(CanvasRenderingContext2D ctx);
}
