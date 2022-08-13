import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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

class MyGame extends FlameGame with TapDetector {
  late final MyPlayer player;
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    player = MyPlayer()
      ..width = 100
      ..height = 100;
    add(player);
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }
}

class MyPlayer extends PositionComponent with HasGameRef {
  static Vector2 gravity = Vector2(0, 1000);

  Vector2 velocity = Vector2.zero();

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;
    position = gameRef.size / 2;
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
      position = Vector2(gameRef.size.x / 2, gameRef.size.y);
      velocity = Vector2(0, 0);
    }
  }

  void jump() {
    velocity = Vector2(0, -600);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final game = MyGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
