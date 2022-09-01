import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:alienbattle/utils/constants.dart';
import 'package:vibration/vibration.dart';

class Alien extends BodyComponent with ContactCallbacks {
  final bool isMine;
  final int positionIndex;
  final void Function() onHpChanged;

  final String userId;

  late final SpriteComponent? arrowSprite;
  SpriteComponent? _fireSprite;

  late final Sprite sprite;
  double healthPoints = initialHealthPoints;
  bool isAttacking = false;

  Alien({
    required this.isMine,
    required this.positionIndex,
    required this.onHpChanged,
    required this.userId,
  }) {
    paint = Paint()..color = Colors.transparent;
  }

  String get getImagePath {
    return 'alien$positionIndex.png';
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await Flame.images.load(getImagePath);
    _fireSprite =
        SpriteComponent(sprite: Sprite(await Flame.images.load('fire.png')))
          ..width = 9
          ..height = 9
          ..anchor = Anchor.bottomCenter
          ..position = Vector2(0, 3)
          ..setAlpha(0);
    add(_fireSprite!);
    final arrowImage = await Flame.images.load('arrow.png');
    if (isMine) {
      arrowSprite = SpriteComponent(sprite: Sprite(arrowImage))
        ..width = 7
        ..anchor = Anchor.center
        ..setAlpha(0);
      add(arrowSprite!);
    }
    if (isMine) {
      add(MyAlienCircle());
    }
    sprite = Sprite(image);
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(6, 6),
      anchor: Anchor.center,
    ));
  }

  Vector2 get _getInitialPosition {
    final sixthOfField = gameRef.size.x / 6;
    switch (positionIndex) {
      case 0:
        return Vector2(sixthOfField * 1, sixthOfField);

      case 1:
        return Vector2(sixthOfField * 5, sixthOfField * 5);

      case 2:
        return Vector2(sixthOfField * 1, sixthOfField * 5);

      case 3:
        return Vector2(sixthOfField * 5, sixthOfField);

      case 4:
        return Vector2(sixthOfField * 2, sixthOfField * 3);

      case 5:
        return Vector2(sixthOfField * 4, sixthOfField * 3);
      default:
        return Vector2(sixthOfField * 4, sixthOfField * 3);
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = 3;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0,
      density: 1,
      friction: 0,
    );

    final bodyDef = BodyDef(
      userData: this,
      linearDamping: 0.2,
      position: _getInitialPosition,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    if (other is Alien && other.isAttacking) {
      healthPoints -= 10;
      if (healthPoints <= 0) {
        removeFromParent();
      }
      if (isMine) {
        Vibration.vibrate(duration: 100);
      }
      onHpChanged();
    }
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
  }

  /// Released the alien to move in certain direction
  void release(Vector2 releaseVelocity) {
    arrowSprite?.setAlpha(0);
    body.linearVelocity = releaseVelocity;
    isAttacking = true;

    _fireSprite?.setAlpha(255);
    Future.delayed(const Duration(seconds: 2)).then((_) {
      isAttacking = false;
      _fireSprite?.setAlpha(0);
    });
  }
}

class MyAlienCircle extends PositionComponent {
  static const strokeWidth = 0.5;
  static const _radius = 3.25;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke; //important set stroke style

    final path = Path()
      ..moveTo(strokeWidth, strokeWidth)
      ..addOval(Rect.fromCircle(
        center: const Offset(0, 0),
        radius: _radius,
      ));

    canvas.drawPath(path, paint);
  }
}
