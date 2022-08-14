import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/circle.dart';
import 'package:multiplayer/game/constants.dart';
import 'package:multiplayer/game/player.dart';

class MyGame extends FlameGame with TapDetector, HasCollisionDetection {
  MyGame({
    required this.onGameOver,
    required this.onScoreUpdate,
    required this.onPoisonHit,
  });
  final void Function() onGameOver;
  final void Function(int) onScoreUpdate;
  final void Function(int) onPoisonHit;

  late final MyPlayer player;
  final random = Random();

  bool _isGameOver = false;

  int score = 0;

  int poisonHitCount = 0;

  @override
  Color backgroundColor() {
    return Colors.white24;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    player = MyPlayer()
      ..width = 100
      ..height = 100;
    add(player);

    for (var i = 0; i < 30; i++) {
      _createNewCircle();
    }
    _keepAddingCircles();
    _keepAddingPoisonCircles();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) {
      return;
    }
    for (final child in children) {
      if (child is PoinsonCircle) {
        if (child.hasBeenEaten) {
          poisonHitCount++;
          onPoisonHit(poisonHitCount);
          if (poisonHitCount >= poisonHitCountToLose) {
            _isGameOver = true;
            onGameOver();
          }
        }
      } else if (child is CircleComponent) {
        if (child.hasBeenEaten) {
          score++;
          onScoreUpdate(score);
        }
      }
    }
  }

  void reset() {
    _isGameOver = false;
    score = 0;
    poisonHitCount = 0;
    for (final child in children) {
      if (child is MyPlayer) {
        child.position = child.initialPosition;
      } else if (child is CircleComponent) {
        child.removeFromParent();
      }
    }
  }

  void _createNewCircle([bool isPoison = false]) async {
    final randomX = random.nextDouble() * size.x * 5 + size.x;
    final randomY = random.nextDouble() * size.y;
    add(
      (isPoison ? PoinsonCircle() : CircleComponent())
        ..width = 30
        ..height = 30
        ..x = randomX
        ..y = randomY,
    );
  }

  Future<void> _keepAddingCircles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _createNewCircle();
    _keepAddingCircles();
  }

  Future<void> _keepAddingPoisonCircles() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _createNewCircle(true);
    _keepAddingPoisonCircles();
  }
}
