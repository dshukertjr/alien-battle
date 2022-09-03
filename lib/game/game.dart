import 'dart:async';

import 'package:alienbattle/main.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:alienbattle/game/alien.dart';

class AlienBattleGame extends Forge2DGame
    with HasCollisionDetection, PanDetector {
  AlienBattleGame({
    required this.onGameOver,
    required this.onGameStateUpdated,
    required this.onSelfRelease,
    required List<Player> players,
    required String myUserId,
  })  : _players = players,
        _myUserId = myUserId,
        super(gravity: Vector2(0, 0), zoom: 10);

  final List<Alien> aliens = [];
  final void Function(bool didWin) onGameOver;
  final void Function() onGameStateUpdated;
  final List<Player> _players;
  final String _myUserId;

  /// Callback for when you release your alien
  final void Function(Vector2) onSelfRelease;

  void Function()? onDamage;

  int score = 0;

  int poisonHitCount = 0;

  late final Alien _myAlien;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(ScreenHitbox());

    setupAliens();

    addAll(_createBoundaries(this));

    onGameStateUpdated();
  }

  late Vector2 _initialPanPosition;
  late Vector2 _draggedDelta;

  @override
  void onPanStart(DragStartInfo info) {
    super.onPanStart(info);
    _initialPanPosition = info.eventPosition.game;
    _myAlien.arrowSprite
      ?..height = 0
      ..setAlpha(255);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    _draggedDelta = info.eventPosition.game - _initialPanPosition;
    _myAlien.arrowSprite
      ?..height = _draggedDelta.length * 24 / 30
      ..angle = _draggedDelta.screenAngle();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    final releaseVelocity = -_draggedDelta * 3;
    _myAlien.release(releaseVelocity);

    // broadcast the release velocity to other clients
    onSelfRelease(releaseVelocity);
  }

  void setupAliens() {
    final aliens = _players
        .asMap()
        .entries
        .map(
          (entry) => Alien(
              isMine: _myUserId == entry.value.userId,
              positionIndex: entry.key,
              onHpChanged: onGameStateUpdated,
              userId: entry.value.userId,
              characterType: entry.value.chracterType),
        )
        .toList();
    _myAlien = aliens.singleWhere((alien) => alien.isMine)..onDamage = onDamage;
    this.aliens.addAll(aliens);
    addAll(aliens);
  }

  void releaseAlien({
    required String userId,
    required Vector2 releaseVelocity,
  }) {
    aliens
        .singleWhere((alien) => alien.userId == userId)
        .release(releaseVelocity);
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
