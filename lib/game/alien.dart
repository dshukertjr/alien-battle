import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/utils/constants.dart';

// class Alien extends PositionComponent with HasGameRef, CollisionCallbacks {
//   final int playerIndex;
//   Alien({
//     required this.isMine,
//     required this.playerIndex,
//     required this.onHpChange,
//   });

//   final void Function() onHpChange;
//   final bool isMine;

//   static const _receiveDamageDuration = Duration(milliseconds: 300);

//   String get getImagePath {
//     return 'alien$playerIndex.png';
//   }

//   Vector2 velocity = Vector2.zero();

//   /// How fast the velocity decreases per second
//   static const _deceleration = -150.0;

//   late final Sprite sprite;

//   bool isAttacking = false;
//   double healthPoints = initialHealthPoints;

//   /// `true` when receiving damage.
//   /// Won't receive any damage while true.
//   /// Will turn false after _receiveDamageDuration
//   bool receivingDamage = false;

//   @override
//   Future<void>? onLoad() async {
//     await super.onLoad();
//     final image = await Flame.images.load(getImagePath);

//     width = 70;
//     height = 70;

//     sprite = Sprite(image);

//     anchor = Anchor.topLeft;

//     add(CircleHitbox(anchor: Anchor.center));
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     sprite.render(canvas,
//         size: size, position: Vector2.zero(), anchor: Anchor.center);
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     position += velocity * dt;
//     final unit = velocity.normalized();
//     velocity += unit * _deceleration * dt;
//     if (velocity.length < 1) {
//       velocity.setZero();
//       isAttacking = false;
//     }
//   }

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollision(intersectionPoints, other);
//     if (other is ScreenHitbox) {
//       final reflectionVector =
//           intersectionPoints.first.x == intersectionPoints.last.x
//               ? Vector2(1, 0)
//               : Vector2(0, 1);
//       velocity.reflect(reflectionVector);
//     } else if (other is Alien) {
//       if (velocity.isZero() && other.velocity.isZero()) {
//         return;
//       }
//       // final isAttacker = velocity.length > other.velocity.length;
//       // if (isAttacker) {
//       // } else {
//       //   if (!receivingDamage &&
//       //       other.isAttacking &&
//       //       other.velocity.length > 10) {
//       //     receivingDamage = true;
//       //     healthPoints -= 40;
//       //     if (healthPoints <= 0) {
//       //       removeFromParent();
//       //     }
//       //     onHpChange();
//       //     Future.delayed(_receiveDamageDuration)
//       //         .then((value) => receivingDamage = false);
//       //   }

//       // final velocityMagnitude = (other.velocity.x - other.velocity.y) /
//       //     (reflectionVector.x - reflectionVector.y);
//       // velocity = reflectionVector * velocityMagnitude;
//       // }
//     }
//   }

//   /// Released the alien to move in certain direction
//   void release(Vector2 releaseVelocity) {
//     velocity = releaseVelocity;
//     isAttacking = true;
//   }
// }

class Alien extends BodyComponent with ContactCallbacks {
  double healthPoints = initialHealthPoints;

  final bool isMine;
  final int playerIndex;
  final void Function() onHpChange;

  Alien({
    required this.isMine,
    required this.playerIndex,
    required this.onHpChange,
  }) {
    paint = Paint()..color = Colors.transparent;
  }

  String get getImagePath {
    return 'alien$playerIndex.png';
  }

  late final Sprite sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await Flame.images.load(getImagePath);

    sprite = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(
      canvas,
      size: Vector2(6, 6),
      anchor: Anchor.center,
    );
  }

  Vector2 get _getInitialPosition {
    final sixthOfField = gameRef.size.x / 6;
    switch (playerIndex) {
      case 0:
        return Vector2(sixthOfField * 1, sixthOfField);

      case 1:
        return Vector2(sixthOfField * 5, sixthOfField);

      case 2:
        return Vector2(sixthOfField * 1, sixthOfField * 5);

      case 3:
        return Vector2(sixthOfField * 5, sixthOfField * 5);

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
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is Alien) {
      print('here');
    }
  }

  @override
  void renderCircle(Canvas c, Offset center, double radius) {
    super.renderCircle(c, center, radius);
    // final lineRotation = Offset(0, radius);
    // c.drawLine(center, center + lineRotation, _blue);
  }

  /// Released the alien to move in certain direction
  void release(Vector2 releaseVelocity) {
    body.linearVelocity = releaseVelocity.normalized() * 100;
  }
}
