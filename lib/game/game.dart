import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/alien.dart';

class MyGame extends FlameGame with HasCollisionDetection, PanDetector {
  MyGame({
    required this.onGameOver,
    required this.aliens,
  });
  final void Function() onGameOver;

  final List<Alien> aliens;

  final random = Random();

  int score = 0;

  int poisonHitCount = 0;

  late final Alien _myAlien;

  @override
  Color backgroundColor() {
    return Colors.white24;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(ScreenHitbox());

    _myAlien = aliens[0];
    addAll(aliens);
  }

  late Vector2 _initialPanPosition;
  late Vector2 _draggedDelta;

  @override
  void onPanStart(DragStartInfo info) {
    _initialPanPosition = info.eventPosition.game;
    super.onPanStart(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _draggedDelta = info.eventPosition.game - _initialPanPosition;
    super.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _myAlien.release(-_draggedDelta * 3);
    super.onPanEnd(info);
  }
}
