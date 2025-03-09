import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fluttergames/wordle/data/word_list.dart';
import 'package:fluttergames/wordle/wordle_keyboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class WordleScreen extends StatefulWidget {
  @override
  _WordleScreenState createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  List<List<String>> guesses = List.generate(6, (_) => List.filled(5, ''));
  int currentRow = 0;
  int currentCol = 0;
  bool gameOver = false;
  bool hintUsed = false;
  int winStreak = 0; // Win streak counter
  List<List<GlobalKey<FlipCardState>>> cardKeys =
  List.generate(6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>()));
  Map<String, Color> keyboardColors = {};
  List<String> fiveLetterWords = words.where((word) => word.length == 5).toList();
  late String targetWord = fiveLetterWords[Random().nextInt(fiveLetterWords.length)];



  @override
  void initState() {
    super.initState();
    _loadWinStreak();
    String targetWord = fiveLetterWords[Random().nextInt(fiveLetterWords.length)];
    print(targetWord); // Debugging
  }



  Future<void> _loadWinStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      winStreak = prefs.getInt('winStreak') ?? 0;
    });
  }

  Future<void> _saveWinStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('winStreak', streak);
  }

  void onKeyPressed(String letter) {
    if (currentCol < 5 && !gameOver) {
      setState(() {
        guesses[currentRow][currentCol] = letter;
        currentCol++;
      });
    }
  }

  void onDelete() {
    if (currentCol > 0 && !gameOver) {
      setState(() {
        currentCol--;
        guesses[currentRow][currentCol] = '';
      });
    }
  }

  /*void onEnter() {
    if (currentCol == 5 && !gameOver) {
      String guessWord = guesses[currentRow].join('');

      if (words.contains(guessWord)) {
        flipTiles(0);
      } else {
        _showMessage("Not a valid word!");
      }
    }
  }*/

  void onEnter() {
    if (currentCol == 5 && !gameOver) {
      flipTiles(0);
    }
  }

  void flipTiles(int index) {
    if (index < 5) {
      Future.delayed(Duration(milliseconds: 300), () {
        cardKeys[currentRow][index].currentState?.toggleCard();
        setState(() {
          keyboardColors[guesses[currentRow][index]] = getTileColor(guesses[currentRow][index], index);
        });
        flipTiles(index + 1);
      });
    } else {
      Future.delayed(Duration(milliseconds: 1500), () async {
        if (guesses[currentRow].join('') == targetWord) {
          gameOver = true;
          winStreak++; // Increase win streak
          await _saveWinStreak(winStreak);
          _showMessage("You Win!");
        } else if (currentRow == 5) {
          gameOver = true;
          winStreak = 0; // Reset win streak on loss
          await _saveWinStreak(winStreak);
          _showMessage("Game Over! The word was $targetWord");
        } else {
          setState(() {
            currentRow++;
            currentCol = 0;
          });
        }
      });
    }
  }

  void useHint() {
    if (!hintUsed && !gameOver) {
      for (int i = 0; i < 5; i++) {
        if (!guesses[currentRow].contains(targetWord[i])) {
          setState(() {
            guesses[currentRow][i] = targetWord[i];
            keyboardColors[targetWord[i]] = Colors.blue; // Hint letters are blue
            hintUsed = true;
          });
          break;
        }
      }
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (gameOver) resetGame();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      targetWord = words[Random().nextInt(words.length)];
      guesses = List.generate(6, (_) => List.filled(5, ''));
      currentRow = 0;
      currentCol = 0;
      gameOver = false;
      hintUsed = false;
      keyboardColors.clear();
      cardKeys = List.generate(6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>()));
    });
  }

  Color getTileColor(String letter, int index) {
    if (targetWord[index] == letter) {
      return Colors.green; // Correct letter in the correct place
    } else if (targetWord.contains(letter)) {
      return Colors.orange; // Correct letter in the wrong place
    } else {
      return Colors.red; // Incorrect letter
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Wordle Game"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
          IconButton(
            icon: Icon(
              Icons.lightbulb,
              color: hintUsed ? Colors.grey : Colors.yellow, // Yellow if hint not used, Grey if used
            ),
            onPressed: useHint,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Win Streak: $winStreak",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8,),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.1,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              int row = index ~/ 5;
              int col = index % 5;
              String letter = guesses[row][col];
              return FlipCard(
                key: cardKeys[row][col],
                flipOnTouch: false,
                front: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                back: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: getTileColor(letter, col),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8,),

          CustomWordleKeyboard(
            onKeyPressed: onKeyPressed,
            onDelete: onDelete,
            onEnter: onEnter,
          ),
        ],
      ),
    );
  }
}
