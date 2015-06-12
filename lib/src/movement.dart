part of pacman;

/// Interface that handles movement of a character
/// It is responsible
abstract class MovementController {
  Direction get direction;

  void checkDirection(
      Point position, List<Direction> directions, bool canChange);

  void attach();

  void detach();
  
  void _forceDirection(Direction direction);
}

abstract class BaseMovementController {
  /// Next direction to take
  Direction get direction => _direction;
  Direction _direction = Direction.UP;
  /// Requested direction
  Direction _requestedDirection = null;

  void attach() {

  }

  void detach() {

  }
  
  void _forceDirection(Direction newDirection) {
    _direction = newDirection;
  }

  void checkDirection(
      Point position, List<Direction> directions, bool canChange) {
    // Check if the user requested a positional change
    if (_requestedDirection != null) {
      // If it's the opposite, we can make change directly
      if ((direction == Direction.LEFT &&
              _requestedDirection == Direction.RIGHT) ||
          (direction == Direction.RIGHT &&
              _requestedDirection == Direction.LEFT) ||
          (direction == Direction.UP && _requestedDirection == Direction.DOWN) ||
          (direction == Direction.DOWN && _requestedDirection == Direction.UP)) {
        _direction = _requestedDirection;
        _requestedDirection = null;
        // Return forces a delay when we turn direction!
        return;
      }

      // Otherwise check if the sector is a crosspoint!
      // Note: canChange implies that we're at a crosspoint,
      //       thus directions is not null
      if (canChange && directions.contains(_requestedDirection)) {
        switch (direction) {
          case Direction.LEFT:
          case Direction.RIGHT:
            _direction = _requestedDirection;
            _requestedDirection = null;
            break;
          case Direction.UP:
          case Direction.DOWN:
            _direction = _requestedDirection;
            _requestedDirection = null;
            break;
        }
      }
    }
  }
}

class SynchronizedMovementController extends BaseMovementController implements MovementController {
  void requestDirection(Direction d) {
    _requestedDirection = d;
  }
}

/// Implementation of a [MovementController] that handles keyboard keys
class KeyboardMovementController extends BaseMovementController implements MovementController {
  StreamSubscription _keyboardSub = null;

  void attach() {
    _keyboardSub = document.onKeyDown.listen((KeyboardEvent ev) {
      switch (ev.keyCode) {
        case KeyCode.LEFT:
          ev.preventDefault();
          _requestedDirection = Direction.LEFT;
          break;
        case KeyCode.RIGHT:
          ev.preventDefault();
          _requestedDirection = Direction.RIGHT;
          break;
        case KeyCode.DOWN:
          ev.preventDefault();
          _requestedDirection = Direction.DOWN;
          break;
        case KeyCode.UP:
          ev.preventDefault();
          _requestedDirection = Direction.UP;
          break;
      }
    });
  }

  void detach() {
    if (_keyboardSub != null) {
      _keyboardSub.cancel();
      _keyboardSub = null;
    }
  }
}
