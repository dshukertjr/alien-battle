import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer/game/alien.dart';
import 'package:multiplayer/game/game.dart';
import 'package:multiplayer/utils/constants.dart';

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
  late final List<Alien> _aliens;

  @override
  void initState() {
    super.initState();
    _aliens = [
      Alien(
        isMine: true,
        playerIndex: 0,
        onHpChange: () => setState(() {}),
      ),
      Alien(
        isMine: false,
        playerIndex: 1,
        onHpChange: () => setState(() {}),
      ),
      Alien(
        isMine: false,
        playerIndex: 2,
        onHpChange: () => setState(() {}),
      ),
      Alien(
        isMine: false,
        playerIndex: 3,
        onHpChange: () => setState(() {}),
      ),
      Alien(
        isMine: false,
        playerIndex: 4,
        onHpChange: () => setState(() {}),
      ),
      Alien(
        isMine: false,
        playerIndex: 5,
        onHpChange: () => setState(() {}),
      ),
    ];
    game = MyGame(
      aliens: _aliens,
      onGameOver: _onGameOver,
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: GameWidget(game: game),
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: _aliens.map<Widget>((alien) {
                    final hasAlienLost = alien.healthPoints <= 0;
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Stack(
                              children: [
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    hasAlienLost ? Colors.grey : Colors.white,
                                    BlendMode.modulate,
                                  ),
                                  child: Image.asset(
                                    'assets/images/${alien.getImagePath}',
                                  ),
                                ),
                                if (hasAlienLost)
                                  const Positioned.fill(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 80,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            color: Colors.white,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor:
                                    (alien.healthPoints / initialHealthPoints)
                                        .clamp(0, 100),
                                child: Container(
                                  color: Colors.red,
                                  height: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
