import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/player.dart';

class CircleComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  static final velocity = Vector2(-100, 0);

  bool hasBeenEaten = false;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;

    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, size.x / 2, Paint()..color = Colors.red);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.x < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is MyPlayer) {
      hasBeenEaten = true;
      removeFromParent();
    }
  }
}

class PoinsonCircle extends CircleComponent {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, size.x / 2, Paint()..color = Colors.blue);
  }
}
