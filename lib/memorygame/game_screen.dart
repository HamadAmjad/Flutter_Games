import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<Map<String, dynamic>> availableItems = [
    {'icon': Icons.star, 'color': Colors.yellow},
    {'icon': Icons.favorite, 'color': Colors.red},
    {'icon': Icons.circle, 'color': Colors.blue},
    {'icon': Icons.square, 'color': Colors.green},
    {'icon': Icons.table_restaurant_rounded, 'color': Colors.orange},
    {'icon': Icons.lightbulb, 'color': Colors.amber},
    {'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'icon': Icons.access_alarm, 'color': Colors.pink},
    {'icon': Icons.cake, 'color': Colors.purple},
    {'icon': Icons.car_rental, 'color': Colors.teal},
    {'icon': Icons.computer, 'color': Colors.indigo},
    {'icon': Icons.directions_bike, 'color': Colors.brown},
    {'icon': Icons.email, 'color': Colors.deepOrange},
    {'icon': Icons.flight, 'color': Colors.lime},
    {'icon': Icons.home, 'color': Colors.deepPurple},
  ];

  late List<Map<String, dynamic>> gameItems;
  late List<bool> flippedCards;
  late List<GlobalKey<FlipCardState>> cardKeys;

  int firstIndex = -1;
  int secondIndex = -1;
  int tries = 0;
  int score = 0;
  bool wait = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<Map<String, dynamic>> selectedItems = List.from(availableItems)..shuffle();
    selectedItems = selectedItems.take(6).toList();
    gameItems = [...selectedItems, ...selectedItems];
    gameItems.shuffle(Random());

    flippedCards = List.generate(gameItems.length, (index) => false);
    cardKeys = List.generate(gameItems.length, (index) => GlobalKey<FlipCardState>());

    setState(() {
      firstIndex = -1;
      secondIndex = -1;
      tries = 0;
      score = 0;
    });
  }

  void _onCardFlipped(int index) {
    if (wait || flippedCards[index]) return;

    setState(() {
      if (firstIndex == -1) {
        firstIndex = index;
      } else {
        secondIndex = index;
        wait = true;
        tries++;

        Future.delayed(Duration(milliseconds: 800), () {
          if (gameItems[firstIndex]['icon'] == gameItems[secondIndex]['icon']) {
            flippedCards[firstIndex] = true;
            flippedCards[secondIndex] = true;
            score++;
          } else {
            cardKeys[firstIndex].currentState?.toggleCard();
            cardKeys[secondIndex].currentState?.toggleCard();
          }

          firstIndex = -1;
          secondIndex = -1;
          wait = false;

          if (score == gameItems.length ~/ 2) {
            _showSuccessDialog();
          }

          setState(() {});
        });
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🎉 Congratulations!"),
        content: Text("You matched all pairs in $tries tries."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memory Game"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Tries: $tries", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: gameItems.length,
              itemBuilder: (context, index) {
                return FlipCard(
                  key: cardKeys[index],
                  onFlip: () => _onCardFlipped(index),
                  flipOnTouch: !flippedCards[index],
                  direction: FlipDirection.HORIZONTAL,
                  front: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Icon(Icons.help, size: 50, color: Colors.white)),
                  ),
                  back: Container(
                    decoration: BoxDecoration(
                      color: gameItems[index]['color'],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Center(
                      child: Icon(
                        gameItems[index]['icon'],
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _initializeGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Restart Game", style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
