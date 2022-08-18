import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/utils/constants.dart';

class Alien extends PositionComponent with HasGameRef, CollisionCallbacks {
  final int playerIndex;
  Alien({
    required this.isMine,
    required this.playerIndex,
    required this.onHpChange,
  });

  final void Function() onHpChange;
  final bool isMine;

  static const _receiveDamageDuration = Duration(milliseconds: 300);

  String get getImagePath {
    return 'alien$playerIndex.png';
  }

  Vector2 velocity = Vector2.zero();

  /// How fast the velocity decreases per second
  static const _deceleration = -150.0;

  late final Sprite sprite;

  bool isAttacking = false;
  double healthPoints = initialHealthPoints;

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

    final sixthOfField = gameRef.size.x / 6;
    switch (playerIndex) {
      case 0:
        position = Vector2(sixthOfField * 1, sixthOfField);
        break;
      case 1:
        position = Vector2(sixthOfField * 5, sixthOfField);
        break;
      case 2:
        position = Vector2(sixthOfField * 1, sixthOfField * 5);
        break;
      case 3:
        position = Vector2(sixthOfField * 5, sixthOfField * 5);
        break;
      case 4:
        position = Vector2(sixthOfField * 2, sixthOfField * 3);
        break;
      case 5:
        position = Vector2(sixthOfField * 4, sixthOfField * 3);
        break;
    }

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
    final unit = velocity.normalized();
    velocity += unit * _deceleration * dt;
    if (velocity.length < 1) {
      velocity.setZero();
      isAttacking = false;
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
      if (velocity.isZero() && other.velocity.isZero()) {
        return;
      }
      final reflectionVector =
          (intersectionPoints.first - intersectionPoints.last).normalized();

      if (other.velocity.isZero()) {
        final velocityMagnitude = (other.velocity.x - other.velocity.y) /
            (reflectionVector.x - reflectionVector.y);
        final velocityOutMagnitude =
            other.velocity.x - velocityMagnitude * reflectionVector.x;
        velocity = velocity.normalized().reflected(reflectionVector) *
            velocityOutMagnitude;
      } else if (velocity.isZero()) {
        final velocityMagnitude = (other.velocity.x - other.velocity.y) /
            (reflectionVector.x - reflectionVector.y);
        // final velocityOutMagnitude =
        //     other.velocity.x - velocityMagnitude * reflectionVector.x;
        velocity = reflectionVector.normalized() * velocityMagnitude;
      } else {
        // final n1 = velocity.reflected(reflectionVector).normalized();
        // final n2 = other.velocity.reflected(reflectionVector).normalized();

        // final velocityMagnitude = (n2.x * (velocity.y + other.velocity.y) -
        //         n2.y * (velocity.x + other.velocity.x)) /
        //     (n2.x + n1.y - n1.x * n2.y);
        // final otherVelocityMagnitude =
        //     (velocity.x + other.velocity.x - n1.x * velocityMagnitude) / n2.x;
        // velocity = velocity.reflected(reflectionVector).normalized() *
        //     velocityMagnitude;
      }

      // final isAttacker = velocity.length > other.velocity.length;
      // if (isAttacker) {
      // } else {
      //   if (!receivingDamage &&
      //       other.isAttacking &&
      //       other.velocity.length > 10) {
      //     receivingDamage = true;
      //     healthPoints -= 40;
      //     if (healthPoints <= 0) {
      //       removeFromParent();
      //     }
      //     onHpChange();
      //     Future.delayed(_receiveDamageDuration)
      //         .then((value) => receivingDamage = false);
      //   }

      // final velocityMagnitude = (other.velocity.x - other.velocity.y) /
      //     (reflectionVector.x - reflectionVector.y);
      // velocity = reflectionVector * velocityMagnitude;
      // }
    }
  }

  /// Released the alien to move in certain direction
  void release(Vector2 releaseVelocity) {
    velocity = releaseVelocity;
    isAttacking = true;
  }
}
