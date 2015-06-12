part of pacman;

class GhostSpawner {
  final Point p1;
  final Point p2;
  num get height => p2.y - p1.y;
  num get width => p2.x - p1.x;

  final bool _horizontal;
  bool get isHorizontal => _horizontal;
  
  final Point exitBegin;
  final Point exitEnd;
  num get exitHeight => exitEnd.y - exitBegin.y;
  num get exitWidth => exitEnd.x - exitBegin.x;

  GhostSpawner(p1, p2, exitBegin, exitEnd)
      : this.p1 = p1,
        this.p2 = p2,
        this.exitBegin = exitBegin,
        this.exitEnd = exitEnd,
        _horizontal = (exitBegin.y == exitEnd.y) {
  }
}

class Edge {
  Point p1;
  Point p2;
  bool _vertical = false;
  bool _horizontal = false;
  bool get isVertical => _vertical;
  bool get isHorizontal => _horizontal;
  num get height => p2.y - p1.y;
  num get width => p2.x - p1.x;

  Edge(x1, y1, x2, y2) {
    if ((x1 == x2 && y1 == y2) || (x1 != x2 && y1 != y2)) {
      throw "Edge has identical points or is not horizontal or vertical.";
    }

    // Make sure p1 is always more left/top of p2
    if (y2 < y1 || x2 < x1) {
      p1 = new Point(x2, y2);
      p2 = new Point(x1, y1);
    } else {
      p1 = new Point(x1, y1);
      p2 = new Point(x2, y2);
    }

    if (x1 == x2) {
      _vertical = true;
    } else if (y1 == y2) {
      _horizontal = true;
    }
  }

  String toString() => 'Edge:$p1->$p2';
}

/// The field/grid we will be playing on
class Grid {
  final CanvasElement canvas;

  CanvasRenderingContext2D _ctx;

  CanvasRenderingContext2D get ctx => _ctx;

  final List<Edge> edges = new List();

  static const int gridSize = 20;

  //Map<Point,List<Edge>> sectors = new Map();

  final Map<Point, List<Direction>> crossPoints = new Map();

  GhostSpawner ghostSpawner;

  Grid(this.canvas) {
    _ctx = canvas.getContext('2d');
  }

  void setGhostSpawner(spawner) {
    ghostSpawner = spawner;
  }

  /// Called to get

  void _getCrossPoints() {
    // Idea: Loop through edges and add position to the points.
    crossPoints.clear();
    edges.forEach((Edge edge) {
      if (edge.isHorizontal) {
        crossPoints.putIfAbsent(edge.p1, () => new List()).add(Direction.RIGHT);
        crossPoints.putIfAbsent(edge.p2, () => new List()).add(Direction.LEFT);
      } else {
        crossPoints.putIfAbsent(edge.p1, () => new List()).add(Direction.DOWN);
        crossPoints.putIfAbsent(edge.p2, () => new List()).add(Direction.UP);
      }
    });
  }

  void add(Edge e) {
    // Check if this edge intersects with any other edge, if so, create new subedge!
    List<Edge> edgesToRemove = [];
    List<Edge> edgesToAdd = [];
    edges.forEach((Edge otherEdge) {
      Point intersectionPoint = null;
      if (e.isHorizontal) {
        // Use e.y
        if (e.p1.y > otherEdge.p1.y &&
            e.p1.y < otherEdge.p2.y &&
            otherEdge.p1.x > e.p1.x &&
            otherEdge.p1.x < e.p2.x) {
          intersectionPoint = new Point(otherEdge.p1.x, e.p1.y);
        }
      } else {
        // Use e.x
        if (e.p1.x > otherEdge.p1.x &&
            e.p1.x < otherEdge.p2.x &&
            otherEdge.p1.y > e.p1.y &&
            otherEdge.p1.y < e.p2.y) {
          intersectionPoint = new Point(e.p1.x, otherEdge.p1.y);
        }
      }

      // Merge lines if the connect.
      if (intersectionPoint != null) {
        Edge edge;
        try {
          edge = new Edge(otherEdge.p1.x, otherEdge.p1.y, intersectionPoint.x,
              intersectionPoint.y);
          edgesToAdd.add(edge);
        } catch (e) {}
        try {
          edge = new Edge(intersectionPoint.x, intersectionPoint.y,
              otherEdge.p2.x, otherEdge.p2.y);
          edgesToAdd.add(edge);
        } catch (e) {}
        try {
          edge = new Edge(
              e.p1.x, e.p1.y, intersectionPoint.x, intersectionPoint.y);
          edgesToAdd.add(edge);
        } catch (e) {}
        try {
          edge = new Edge(
              intersectionPoint.x, intersectionPoint.y, e.p2.x, e.p2.y);
          edgesToAdd.add(edge);
        } catch (e) {}
        edgesToRemove.add(otherEdge);
      }
    });
    // Only add original edge if there was no intersection. This means: we dont remove any existing
    // edges
    if (edgesToRemove.isEmpty) {
      edgesToAdd.add(e);
    } else {
      edges.removeWhere((Edge e) => edgesToRemove.contains(e));
    }
    edges.addAll(edgesToAdd);
    _getCrossPoints();
  }

  void _mesh() {
    _ctx.strokeStyle = '#666';
    _ctx.lineWidth = 1;
    // Grid
    for (num x = 0.5; x <= canvas.width + .5; x += gridSize) {
      _ctx.beginPath();
      _ctx.moveTo(x, 0);
      _ctx.lineTo(x, canvas.height);
      _ctx.stroke();
    }

    for (num y = 0.5; y <= canvas.height + .5; y += gridSize) {
      _ctx.beginPath();
      _ctx.moveTo(0, y);
      _ctx.lineTo(canvas.width, y);
      _ctx.stroke();
    }
  }

  void generate(bool mesh) {
    _ctx.clearRect(0, 0, canvas.width, canvas.height);
    if (mesh) {
      _mesh();
    }
    _ctx.strokeStyle = '#00F';
    _ctx.lineWidth = 3;
    // Draw two lines
    edges.forEach((Edge e) {
      // Draw lines only in case there is more than one sector between start and end
      if ((e.isHorizontal && (e.p2.x - e.p1.x > 0)) ||
          (e.isVertical && (e.p2.y - e.p1.y > 0))) {
        //_ctx.fillRect(gridSize*e.p1.x+gridSize/2, gridSize*e.p1.y+gridSize/2, 2,2);
        //_ctx.fillRect(gridSize*e.p2.x+gridSize/2, gridSize*e.p2.y+gridSize/2, 2,2);
        if (e.isHorizontal) {
          // Top
          _ctx.beginPath();
          _ctx.moveTo((e.p1.x + 1) * gridSize, e.p1.y * gridSize);
          _ctx.lineTo((e.p1.x + e.width) * gridSize, e.p1.y * gridSize);
          _ctx.stroke();
          // Bottom
          _ctx.beginPath();
          _ctx.moveTo((e.p1.x + 1) * gridSize, (e.p1.y + 1) * gridSize);
          _ctx.lineTo((e.p1.x + e.width) * gridSize, (e.p1.y + 1) * gridSize);
          _ctx.stroke();
        } else {
          // Left
          _ctx.beginPath();
          _ctx.moveTo(e.p1.x * gridSize, (e.p1.y + 1) * gridSize);
          _ctx.lineTo(e.p1.x * gridSize, (e.p1.y + e.height) * gridSize);
          _ctx.stroke();
          // Right
          _ctx.beginPath();
          _ctx.moveTo((e.p1.x + 1) * gridSize, (e.p1.y + 1) * gridSize);
          _ctx.lineTo((e.p1.x + 1) * gridSize, (e.p1.y + e.height) * gridSize);
          _ctx.stroke();
        }
      }
    });

    crossPoints.forEach((Point point, List<Direction> directions) {
      // Draw Lines
      if (!directions.contains(Direction.DOWN)) {
        _ctx.beginPath();
        _ctx.moveTo((point.x) * gridSize, (point.y + 1) * gridSize);
        _ctx.lineTo((point.x + 1) * gridSize, (point.y + 1) * gridSize);
        _ctx.stroke();
      }
      if (!directions.contains(Direction.UP)) {
        _ctx.beginPath();
        _ctx.moveTo((point.x) * gridSize, (point.y) * gridSize);
        _ctx.lineTo((point.x + 1) * gridSize, (point.y) * gridSize);
        _ctx.stroke();
      }
      if (!directions.contains(Direction.LEFT)) {
        _ctx.beginPath();
        _ctx.moveTo((point.x) * gridSize, (point.y) * gridSize);
        _ctx.lineTo((point.x) * gridSize, (point.y + 1) * gridSize);
        _ctx.stroke();
      }
      if (!directions.contains(Direction.RIGHT)) {
        _ctx.beginPath();
        _ctx.moveTo((point.x + 1) * gridSize, (point.y) * gridSize);
        _ctx.lineTo((point.x + 1) * gridSize, (point.y + 1) * gridSize);
        _ctx.stroke();
      }
    });

    _ctx.fillStyle = '#111';
    _ctx.beginPath();
    _ctx.rect(ghostSpawner.p1.x * gridSize, ghostSpawner.p1.y * gridSize,
        ghostSpawner.width * gridSize, ghostSpawner.height * gridSize);
    _ctx.fill();

    _ctx.strokeStyle = 'yellow';
    _ctx.beginPath();
    _ctx.moveTo((ghostSpawner.exitBegin.x) * gridSize,
        (ghostSpawner.exitBegin.y) * gridSize);
    _ctx.lineTo((ghostSpawner.exitEnd.x) * gridSize,
        (ghostSpawner.exitEnd.y) * gridSize);
    _ctx.lineWidth = 5;
    _ctx.stroke();
  }

  void render() {
    generate(false);
  }
}

Edge createEdgeFromMouse(Point start, MouseEvent ev) {
  try {
    return new Edge((start.x / Grid.gridSize).floor(),
        (start.y / Grid.gridSize).floor(),
        (ev.offset.x / Grid.gridSize).floor(),
        (ev.offset.y / Grid.gridSize).floor());
  } catch (e) {
    print('$e');
  }
  return null;
}
