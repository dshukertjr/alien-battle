import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/alien.dart';

class MyGame extends FlameGame with HasCollisionDetection, PanDetector {
  MyGame({
    required this.onGameOver,
    required this.onScoreUpdate,
    required this.onPoisonHit,
  });
  final void Function() onGameOver;
  final void Function(int) onScoreUpdate;
  final void Function(int) onPoisonHit;

  final random = Random();

  final bool _isGameOver = false;

  int score = 0;

  int poisonHitCount = 0;

  late final Alien _alien;

  @override
  Color backgroundColor() {
    return Colors.white24;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(ScreenHitbox());

    _alien = Alien()
      ..width = 70
      ..height = 70
      ..position = size / 2;
    add(_alien);
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
    _alien.release(-_draggedDelta * 2);
    super.onPanEnd(info);
  }
}
