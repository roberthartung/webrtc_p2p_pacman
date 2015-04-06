part of pacman;

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
    if((x1 == x2 && y1 == y2) || (x1 != x2 && y1 != y2)) {
      throw "Edge has identical points or is not horizontal or vertical.";
    }
    
    // Make sure p1 is always more left/top of p2
    if(y2 < y1 || x2 < x1) {
      p1 = new Point(x2,y2);
      p2 = new Point(x1,y1);
    } else {
      p1 = new Point(x1,y1);
      p2 = new Point(x2,y2);
    }
    
    if(x1 == x2) {
      _vertical = true;
    } else if(y1 == y2) {
      _horizontal = true;
    }
  }
}

/// The field/grid we will be playing on
class Grid {
  final CanvasElement canvas;
  
  CanvasRenderingContext2D _ctx;
  
  CanvasRenderingContext2D get ctx => _ctx;
  
  final List<Edge> edges = new List();
  
  static const int gridSize = 20;

  Map<Point,List<Edge>> sectors = new Map();

  final Map<Point, List<Direction>> crossPoints = new Map();
  
  Grid(this.canvas) {
    _ctx = canvas.getContext('2d');
  }
  
  void _getCrossPoints() {
    // Get all start and end points from all edges
    Set<Point> points = new Set();
    points.addAll(edges.map((Edge edge) => edge.p1));
    points.addAll(edges.map((Edge edge) => edge.p2));
    crossPoints.clear();
    // Loop through points and check in which direction the edges go
    points.forEach((Point crossPoint) {
      if(edges.any((Edge e) => e.p1.y == crossPoint.y && e.p1.x < crossPoint.x)) {
        crossPoints.putIfAbsent(crossPoint, () => new List()).add(Direction.LEFT);
      }
      
      if(edges.any((Edge e) => e.p2.y == crossPoint.y && e.p2.x > crossPoint.x)) {
        crossPoints.putIfAbsent(crossPoint, () => new List()).add(Direction.RIGHT);
      }
      
      if(edges.any((Edge e) => e.p1.x == crossPoint.x && e.p1.y < crossPoint.y)) {
        crossPoints.putIfAbsent(crossPoint, () => new List()).add(Direction.UP);
      }
      
      if(edges.any((Edge e) => e.p1.x == crossPoint.x && e.p2.y > crossPoint.y)) {
        crossPoints.putIfAbsent(crossPoint, () => new List()).add(Direction.DOWN);
      }
    });
  }
  
  void add(Edge e) {
    // Check if this edge intersects with any other edge, if so, create new subedge!
    List<Edge> edgesToRemove = [];
    List<Edge> edgesToAdd = [];
    edges.forEach((Edge otherEdge) {
      Point intersectionPoint = null;
      if(e.isHorizontal) {
        // Use e.y
        if(e.p1.y >= otherEdge.p1.y && e.p1.y <= otherEdge.p2.y &&
            otherEdge.p1.x >= e.p1.x && otherEdge.p1.x <= e.p2.x) {
          intersectionPoint = new Point(otherEdge.p1.x, e.p1.y);
          // print('ok1 $intersectionPoint');
        }
      } else {
        // Use e.x
        if(e.p1.x >= otherEdge.p1.x && e.p1.x <= otherEdge.p2.x &&
              otherEdge.p1.y >= e.p1.y && otherEdge.p1.y <= e.p2.y) {
          intersectionPoint = new Point(e.p1.x, otherEdge.p1.y);
          // print('ok2 $intersectionPoint');
        }
      }
      
      // TODO(rh): Check if otherEdge.p1 == e.p1 etc to see if they connect.
      // Merge lines if the connect.
      if(intersectionPoint != null) {
        try {
          edgesToAdd.add(new Edge(otherEdge.p1.x, otherEdge.p1.y, intersectionPoint.x, intersectionPoint.y));
        } catch(e) { }
        try {
          edgesToAdd.add(new Edge(intersectionPoint.x, intersectionPoint.y, otherEdge.p2.x, otherEdge.p2.y));
        } catch(e) { }
        try {
          edgesToAdd.add(new Edge(e.p1.x, e.p1.y, intersectionPoint.x, intersectionPoint.y));
        } catch(e) { }
        try {
          edgesToAdd.add(new Edge(intersectionPoint.x, intersectionPoint.y, e.p2.x, e.p2.y));
        } catch(e) { }
        edgesToRemove.add(otherEdge);
      }
    });
    // Only add original edge if there was no intersection. This means: we dont remove any existing
    // edges
    if(edgesToRemove.isEmpty) {
      edgesToAdd.add(e);
      edges.add(e);
    }
    edges.removeWhere((Edge e) => edgesToRemove.contains(e));
    edges.addAll(edgesToAdd);
    edgesToAdd.forEach((Edge e) {
      sectors.putIfAbsent(e.p1, () => new List()).add(e);
      sectors.putIfAbsent(e.p2, () => new List()).add(e);
    });
    
    _getCrossPoints();
  }
  
  void _mesh() {
    _ctx.strokeStyle = 'gray';
    // Grid
    for(num x=0.5;x<=canvas.width+.5;x+=gridSize) {
      _ctx.beginPath();
      _ctx.moveTo(x, 0);
      _ctx.lineTo(x, canvas.height);
      _ctx.stroke();
    }

    for(num y=0.5;y<=canvas.height+.5;y+=gridSize) {
      _ctx.beginPath();
      _ctx.moveTo(0, y);
      _ctx.lineTo(canvas.width, y);
      _ctx.stroke();
    }
  }

  void generate() {
    _ctx.clearRect(0, 0, canvas.width, canvas.height);
    _mesh();
    _ctx.strokeStyle = 'blue';
    _ctx.fillStyle = 'red';
    // Draw two lines
    edges.forEach((Edge e) {
      // Draw lines only in case there is more than one sector between start and end
      if((e.isHorizontal && (e.p2.x - e.p1.x > 0)) ||
          (e.isVertical && (e.p2.y - e.p1.y > 0))) {
        _ctx.fillRect(gridSize*e.p1.x+gridSize/2, gridSize*e.p1.y+gridSize/2, 2,2);
        _ctx.fillRect(gridSize*e.p2.x+gridSize/2, gridSize*e.p2.y+gridSize/2, 2,2);
        if(e.isHorizontal) {
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
  }
}

Edge createEdgeFromMouse(Point start, MouseEvent ev) {
  try {
    return new Edge(
        (start.x/Grid.gridSize).floor(),
        (start.y/Grid.gridSize).floor(),
        (ev.offset.x/Grid.gridSize).floor(),
        (ev.offset.y/Grid.gridSize).floor()
    );
  } catch(e) {
    print('$e');
  }
  return null;
}
