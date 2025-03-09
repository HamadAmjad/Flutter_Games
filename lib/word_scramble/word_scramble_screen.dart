import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttergames/wordle/data/word_list.dart';
import '../keyboard.dart';

class WordScrambleScreen extends StatefulWidget {
  @override
  _WordScrambleScreenState createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {


  late String originalWord;
  late String scrambledWord;
  String userAnswer = "";
  int score = 0;
  int winStreak = 0;
  int attemptsLeft = 3;

  @override
  void initState() {
    super.initState();
    getNewWord();
  }

  void getNewWord() {
    final random = Random();
    originalWord = words[random.nextInt(words.length)];
    scrambledWord = shuffleWord(originalWord);
    userAnswer = "";
    attemptsLeft = 3; // Reset attempts for the new word
    setState(() {});
  }

  void reshuffleWord() {
    setState(() {
      scrambledWord = shuffleWord(originalWord);
    });
  }

  String shuffleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle();
    return chars.join('');
  }

  void checkAnswer() {
    if (userAnswer.toLowerCase() == originalWord.toLowerCase()) {
      setState(() {
        score += 10;
        winStreak += 1;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text("Correct! 🎉", style: TextStyle(color: Colors.green)),
          content: Text("You guessed the word correctly!", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                getNewWord();
              },
              child: Text("Next Word", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        attemptsLeft -= 1;
      });

      if (attemptsLeft > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wrong! You have $attemptsLeft attempts left."),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        setState(() {
          winStreak = 0;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: Text("Out of Attempts ❌", style: TextStyle(color: Colors.red)),
            content: Text("The correct word was: $originalWord", style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getNewWord();
                },
                child: Text("Next Word", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      }
    }
  }

  void onKeyPressed(String key) {
    setState(() {
      userAnswer += key;
    });
  }

  void onDelete() {
    setState(() {
      if (userAnswer.isNotEmpty) {
        userAnswer = userAnswer.substring(0, userAnswer.length - 1);
      }
    });
  }

  void onEnter() {
    checkAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Word Scramble Game"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: getNewWord,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Scrambled Word:",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scrambledWord,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.shuffle, color: Colors.orange, size: 30),
                          onPressed: reshuffleWord, // Only reshuffles the current word
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        userAnswer.isEmpty ? "Enter your answer..." : userAnswer,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: userAnswer.isEmpty ? Colors.grey : Colors.white, // Grey for filler text
                        ),
                      )

                    ),
                    SizedBox(height: 20),
                    Text(
                      "Score: $score",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Win Streak: $winStreak 🔥",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Attempts Left: $attemptsLeft",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomKeyboard(
            onKeyPressed: onKeyPressed,
            onDelete: onDelete,
            onEnter: onEnter,
          ),
        ],
      ),
    );
  }
}

