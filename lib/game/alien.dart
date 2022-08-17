import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/utils/constants.dart';

class Alien extends PositionComponent with HasGameRef, CollisionCallbacks {
  final int playerIndex;
  Alien({
    required this.playerIndex,
    required this.onHpChange,
  });

  final void Function() onHpChange;

  static const _receiveDamageDuration = Duration(seconds: 1);

  String get getImagePath {
    return 'alien$playerIndex.png';
  }

  Vector2 velocity = Vector2.zero();

  /// How fast the velocity decreases per second
  static const _deceleration = -150.0;

  late final Sprite sprite;

  bool hasLost = false;
  bool moving = false;
  double healthPoints = initialHealthPoints;

  /// Random string generated when user releases the alien
  String? currentInteractionId;

  /// Contains all the interaction id that this alien has interacted with
  final List<String> _interactedIds = [];

  /// `true` when receiving damage.
  /// Won't receive any damage while true.
  /// Will turn false after _receiveDamageDuration
  bool receivingDamage = false;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final image = await Flame.images.load(getImagePath);

    width = 70;
    height = 70;

    sprite = Sprite(image);

    anchor = Anchor.topLeft;
    final random = Random();
    position = Vector2(random.nextDouble() * gameRef.size.x,
        random.nextDouble() * gameRef.size.y);

    add(CircleHitbox(anchor: Anchor.center));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(canvas,
        size: size, position: Vector2.zero(), anchor: Anchor.center);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity += velocity.normalized() * _deceleration * dt;
    if (velocity.isZero()) {
      moving = false;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ScreenHitbox) {
      final reflectionVector =
          intersectionPoints.first.x == intersectionPoints.last.x
              ? Vector2(1, 0)
              : Vector2(0, 1);
      velocity.reflect(reflectionVector);
    } else if (other is Alien) {
      final interactionId = other.currentInteractionId;
      if (interactionId == null || _interactedIds.contains(interactionId)) {
        return;
      }
      _interactedIds.add(interactionId);
      if (moving) {
        velocity = velocity * 0.9;
      } else {
        if (!other.moving) {
          return;
        }
        if (!receivingDamage) {
          receivingDamage = true;
          healthPoints -= 40;
          if (healthPoints <= 0) {
            hasLost = true;
            removeFromParent();
          }
          onHpChange();
          Future.delayed(_receiveDamageDuration)
              .then((value) => receivingDamage = false);
        }

        final targetX = (other.position.y -
                position.y -
                other.position.x * other.velocity.y / other.velocity.x +
                other.velocity.x * position.x / other.velocity.y) *
            (other.velocity.x *
                other.velocity.y /
                (other.velocity.x * other.velocity.x -
                    other.velocity.y * other.velocity.y));
        final targetY = other.position.y +
            (targetX - other.position.x) * other.velocity.y / other.velocity.x;
        final moveAwayVector =
            -(Vector2(targetX, targetY) - position).normalized();
        velocity += moveAwayVector * 100;
      }
    }
  }

  /// Released the alien to move in certain direction
  void release(Vector2 releaseVelocity) {
    velocity = releaseVelocity;
    moving = true;
    currentInteractionId = generateRandomString();
  }
}
