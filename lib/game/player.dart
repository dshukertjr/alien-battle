import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MyPlayer extends PositionComponent with HasGameRef, CollisionCallbacks {
  static Vector2 gravity = Vector2(0, 1000);

  Vector2 velocity = Vector2.zero();

  late final Vector2 initialPosition;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomLeft;
    initialPosition = Vector2(0, gameRef.size.y);
    position = initialPosition;

    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.green);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt + gravity * dt * dt / 2;
    velocity += gravity * dt;
    if (position.y > gameRef.size.y) {
      position = initialPosition;

      velocity = Vector2(0, 0);
    }
  }

  void jump() {
    velocity = Vector2(0, -600);
  }
}
