import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien hits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
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
      onGameOver: _onGameOver,
      onScoreUpdate: (newScore) {
        setState(() {});
      },
      onPoisonHit: (newPoisonHitCount) {
        setState(() {});
      },
    );
  }

  Future<void> _onGameOver() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text('Game Over'),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    game.reset();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Retry'))
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: GameWidget(game: game),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
