import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/alien.dart';

class MyGame extends Forge2DGame with HasCollisionDetection, PanDetector {
  MyGame({
    required this.onGameOver,
    required this.aliens,
  }) : super(gravity: Vector2(0, 0), zoom: 10);
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
    addAll(_createBoundaries(this));
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

List<_Wall> _createBoundaries(Forge2DGame game) {
  final topLeft = Vector2.zero();
  final bottomRight = game.screenToWorld(game.camera.viewport.effectiveSize);
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    _Wall(topLeft, topRight),
    _Wall(topRight, bottomRight),
    _Wall(bottomRight, bottomLeft),
    _Wall(bottomLeft, topLeft),
  ];
}

class _Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  _Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 1,
      density: 1000,
    );
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
