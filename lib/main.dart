import 'package:flutter/material.dart';
import 'package:fluttergames/memorygame/game_screen.dart';
import 'package:fluttergames/tictactoe/tic_tac_toe_game.dart';
import 'package:fluttergames/word_scramble/word_scramble_screen.dart';
import 'package:fluttergames/wordle/views/wordle_screen.dart';
import 'package:flutter/services.dart';
import 'tetris/board.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
  AudioManager().playBackgroundMusic();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121213),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: GameSelectionScreen(),
    );
  }
}

class GameSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> games = [
    {'name': 'Tic Tac Toe', 'icon': Icons.grid_3x3, 'screen': TicTacToeScreen()},
    {'name': 'Wordle', 'icon': Icons.spellcheck, 'screen': WordleScreen()},
    {'name': 'Tetris', 'icon': Icons.grid_view_outlined, 'screen': TetrisGameBoard()},
    {'name': 'Memory Game', 'icon': Icons.psychology_outlined, 'screen': MemoryGameScreen()},
    {'name': 'Scramble', 'icon': Icons.abc_rounded, 'screen': WordScrambleScreen()},
    {'name': 'Minesweeper', 'icon': Icons.flag, 'screen': PlaceholderScreen('Minesweeper')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Games', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildGameButton(context, games[index]);
          },
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, Map<String, dynamic> game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => game['screen']),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(game['icon'], size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              game['name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for future games
class PlaceholderScreen extends StatelessWidget {
  final String gameName;
  const PlaceholderScreen(this.gameName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(gameName)),
    body: Center(child: Text('$gameName Coming Soon!', style: TextStyle(fontSize: 24),),));
  }
}


class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _backgroundPlayer = AudioPlayer();

  AudioManager._internal();

  Future<void> playBackgroundMusic() async {
    await _backgroundPlayer.play(AssetSource('audio/BG music.mp3'));
  }

  void stopBackgroundMusic() {
    _backgroundPlayer.stop();
  }
}
