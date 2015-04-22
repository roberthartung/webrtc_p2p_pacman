part of pacman;

class SingleplayerPacmanGame extends PacmanGame {
  Pacman pacman;

  static const int numGhosts = 5;

  SingleplayerPacmanGame(s, d) : super(s, d);

  void createGhost() {
    Point start = _startPoints.elementAt(_ghostStartPointOffset);
    Ghost ghost = new Ghost(
        (_ghostStartPointOffset == 1 || _ghostStartPointOffset == 2)
            ? new FollowingGhostMovement(pacman)
            : new RandomGhostMovement(), pacman, grid, start);
    addGhost(ghost);
    _ghostStartPointOffset++;
  }

  void start() {
    pacman = new Pacman(new KeyboardMovementController(), grid, _startPoints.first);
    addPacman(pacman);
    for(int i=1;i<=numGhosts;i++) {
      createGhost();
    }
    super.start();
  }

  void render() {
    super.render();
    querySelector('#score').text = '${pacman.score}';
  }
}