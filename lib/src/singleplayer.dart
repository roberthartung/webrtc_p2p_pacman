part of pacman;

class SingleplayerPacmanGame extends PacmanGame {
  PacMan pacMan;

  static const int numGhosts = 5; // 5

  SingleplayerPacmanGame(s, d) : super(s, d);

  void start() {
    pacMan = new PacMan(grid, _startPoints.first);
    for(int i=1;i<=numGhosts;i++) {
      createGhost();
    }
    super.start();
  }

  void render(num time) {
    super.render(time);
  }
}