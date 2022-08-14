import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class Alien extends PositionComponent with HasGameRef, CollisionCallbacks {
  Vector2 _velocity = Vector2.zero();

  static const _deceleration = -150.0;

  late final Sprite sprite;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final image = await Flame.images.load('alien1.png');

    sprite = Sprite(image);

    anchor = Anchor.center;

    position = gameRef.size / 2;

    add(CircleHitbox(anchor: Anchor.center));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
        Offset.zero, size.x / 2, Paint()..color = Colors.lightBlue);
    sprite.render(canvas,
        size: size, position: Vector2.zero(), anchor: Anchor.center);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    _velocity += _velocity.normalized() * _deceleration * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ScreenHitbox) {
      final reflectionVector =
          intersectionPoints.first.x == intersectionPoints.last.x
              ? Vector2(1, 0)
              : Vector2(0, 1);
      _velocity.reflect(reflectionVector);
    }
  }

  /// Released the alien to move in certain direction
  void release(Vector2 velocity) {
    _velocity = velocity;
  }
}
