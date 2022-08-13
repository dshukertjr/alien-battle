import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

const _poisonHitCountToLose = 3;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyGame extends FlameGame with TapDetector, HasCollisionDetection {
  MyGame({
    required this.onGameOver,
    required this.onScoreUpdate,
    required this.onPoisonHit,
  });
  final void Function() onGameOver;
  final void Function(int) onScoreUpdate;
  final void Function(int) onPoisonHit;

  late final MyPlayer player;
  final random = Random();

  bool _isGameOver = false;

  int score = 0;

  int poisonHitCount = 0;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final background = BackgroundComponent()
      ..width = size.x
      ..height = size.y;
    add(background);

    player = MyPlayer()
      ..width = 100
      ..height = 100;
    add(player);

    for (var i = 0; i < 30; i++) {
      _createNewCircle();
    }
    _keepAddingCircles();
    _keepAddingPoisonCircles();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) {
      return;
    }
    for (final child in children) {
      if (child is PoinsonCircle) {
        if (child.hasBeenEaten) {
          poisonHitCount++;
          onPoisonHit(poisonHitCount);
          if (poisonHitCount >= _poisonHitCountToLose) {
            _isGameOver = true;
            onGameOver();
          }
        }
      } else if (child is CircleComponent) {
        if (child.hasBeenEaten) {
          score++;
          onScoreUpdate(score);
        }
      }
    }
  }

  void reset() {
    _isGameOver = false;
    score = 0;
    poisonHitCount = 0;
    for (final child in children) {
      if (child is MyPlayer) {
        child.position = child.initialPosition;
      } else if (child is CircleComponent) {
        child.removeFromParent();
      }
    }
  }

  void _createNewCircle([bool isPoison = false]) async {
    final randomX = random.nextDouble() * size.x * 5 + size.x;
    final randomY = random.nextDouble() * size.y;
    add(
      (isPoison ? PoinsonCircle() : CircleComponent())
        ..width = 30
        ..height = 30
        ..x = randomX
        ..y = randomY,
    );
  }

  Future<void> _keepAddingCircles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _createNewCircle();
    _keepAddingCircles();
  }

  Future<void> _keepAddingPoisonCircles() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _createNewCircle(true);
    _keepAddingPoisonCircles();
  }
}

class BackgroundComponent extends PositionComponent with HasGameRef {
  late final Sprite sprite;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('background.jpg');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(canvas, size: Vector2(width, height));
  }
}

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

    add(RectangleHitbox());
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MyGame game;

  @override
  void initState() {
    super.initState();
    game = MyGame(
      onGameOver: () {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: const Text('Game Over'),
                actions: [
                  TextButton(
                      onPressed: () {
                        game.reset();
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Retry'))
                ],
              );
            }));
      },
      onScoreUpdate: (newScore) {
        setState(() {});
      },
      onPoisonHit: (newPoisonHitCount) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${game.score} points',
                  style: const TextStyle(color: Colors.white),
                ),
                Row(
                  children: List.generate(_poisonHitCountToLose, (index) {
                    final lifeLeft =
                        _poisonHitCountToLose - game.poisonHitCount;
                    if (index < lifeLeft) {
                      return const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                      );
                    } else {
                      return const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                      );
                    }
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
