import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class Arrow extends PositionComponent with HasGameRef {
  late final Sprite sprite;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final image = await Flame.images.load('arrow.png');

    width = 70;
    height = 70;

    sprite = Sprite(image);

    anchor = Anchor.topLeft;

    add(CircleHitbox(anchor: Anchor.center));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(canvas,
        size: size, position: Vector2.zero(), anchor: Anchor.center);
  }
}
