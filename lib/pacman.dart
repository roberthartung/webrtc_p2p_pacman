library pacman;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:webrtc_utils/client.dart';
import 'package:webrtc_utils/game.dart';

part 'src/character.dart';
part 'src/ghost.dart';
part 'src/pacman.dart';
part 'src/grid.dart';
part 'src/multiplayer.dart';
part 'src/singleplayer.dart';
part 'src/game.dart';
part 'src/collectables.dart';

enum Direction {UP, RIGHT, DOWN, LEFT}
const int innerSize = 20;