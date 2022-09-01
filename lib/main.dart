import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:alienbattle/game/alien.dart';
import 'package:alienbattle/game/game.dart';
import 'package:alienbattle/utils/constants.dart';
import 'package:realtime_client/realtime_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien Battle',
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final MyGame game;
  late final List<Alien> _aliens;

  late final RealtimeClient _client;

  late RealtimeChannel _lobbyChannel;

  late RealtimeChannel _roomChannel;

  late final String _myUserId;

  bool _isInLoggy = true;

  Map<String, Player> _lobbyPlayers = {};

  @override
  void initState() {
    super.initState();

    _myUserId = _generateRandomString();

    _client = RealtimeClient(
        'ws://nlbsnpoablmsxwkdbmer.supabase.co/realtime/v1',
        params: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyOTE5ODEwMiwiZXhwIjoxOTQ0Nzc0MTAyfQ.XZWLzz95pyU9msumQNsZKNBXfyss-g214iTVAwyQLPA'
        });

    _lobbyChannel = _client.channel(
        'lobby',
        const RealtimeChannelConfig(
          ack: true,
          self: true,
        ));

    _lobbyChannel
        .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'location'),
            (payload, [ref]) {
      print(payload);
    });

    _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync'),
        (payload, [ref]) {
      final presenceState = _lobbyChannel.presenceState();
      setState(() {
        _lobbyPlayers = Map.fromEntries(presenceState.entries.map((entry) =>
            MapEntry(
                entry.value.first.payload['user_id'] as String,
                Player(
                    userId: entry.value.first.payload['user_id'] as String))));
      });
    });

    _lobbyChannel.subscribe((status, [_]) async {
      if (status == 'SUBSCRIBED') {
        final status = await _lobbyChannel.track({'user_id': _myUserId});
        print(status);
      }
    });

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

  String _generateRandomString() {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(24, (index) => chars[r.nextInt(chars.length)]).join();
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
          _isInLoggy
              ? Lobby(
                  lobbyPlayerCount: _lobbyPlayers.length,
                  onStartGame: () {
                    setState(() {
                      _isInLoggy = false;
                    });
                  },
                )
              : InGame(game: game, aliens: _aliens),
        ],
      ),
    );
  }
}

class Lobby extends StatelessWidget {
  const Lobby({
    Key? key,
    required this.lobbyPlayerCount,
    required this.onStartGame,
  }) : super(key: key);

  /// Number of players waiting at the lobby
  final int lobbyPlayerCount;

  final void Function() onStartGame;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Material(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Lobby',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lobbyPlayerCount.toString(),
                      style: const TextStyle(fontSize: 40),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 2),
                      child: Text('players waiting '),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: lobbyPlayerCount >= 1 ? onStartGame : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Start Game',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InGame extends StatelessWidget {
  const InGame({
    Key? key,
    required this.game,
    required List<Alien> aliens,
  })  : _aliens = aliens,
        super(key: key);

  final MyGame game;
  final List<Alien> _aliens;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }
}

class Player {
  final String userId;

  Player({
    required this.userId,
  });
}
