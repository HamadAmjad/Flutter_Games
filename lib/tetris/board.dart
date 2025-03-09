import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'piece.dart';
import 'pixel.dart';
import 'values.dart';

// Create game board
List<List<TetrisShapes?>> gameBoard = List.generate(
    colLength,
        (i) => List.generate(
      rowLength,
          (j) => null,
    ));

class TetrisGameBoard extends StatefulWidget {
  const TetrisGameBoard({super.key});

  @override
  State<TetrisGameBoard> createState() => _TetrisGameBoardState();
}

class _TetrisGameBoardState extends State<TetrisGameBoard> {
  Piece currentPiece = Piece(type: TetrisShapes.L);
  int currentScore = 0;
  bool gameOver = false;
  bool isPlaying = false;
  bool isPaused = false;
  Timer? gameTimer;
  int responsiveValue() {
    return (currentScore > 5) ? 300 : 400;
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    resetGame();
  }



  void playSound(String sound) async {
    await _sfxPlayer.play(AssetSource('audio/row removed.ogg'));
  }


  void startGame() {
    currentPiece.initializePiece();
    Duration getGameSpeed(int score) {
      return Duration(milliseconds: (score > 5) ? 300 : 500);
    }

// Call the game loop with the dynamic duration
    gameLoop(getGameSpeed(currentScore));
  }
  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // Ensure row is within a valid range before checking collision
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      // Check for collision only if the row is within a valid range
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }
  bool checkLanded() {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // Stop movement immediately if the piece reaches row 0
      if (row + 1 >= colLength || (row >= 0 && gameBoard[row + 1][col] != null)) {
        return true; // Collision detected
      }
    }
    return false; // No collision, keep moving
  }
  void gameLoop(Duration frameRate) {
    gameTimer = Timer.periodic(frameRate, (timer) {
      if (isPaused) return; // Prevent game updates while paused

      setState(() {
        isPlaying = true;
        clearLines();
        checkLanding();
        if (gameOver) {
          timer.cancel();
          showGameOverDialog();
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }
  void checkLanding() {
    if (checkCollision(Direction.down) || checkLanded()) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }
  void clearLines() {
    // step 1: Loop through each row of the game board from bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      // step 2: Initialize a variable to track if the row is full
      bool rowIsFull = true;
      // step 3: Check if the row if full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there's an empty column, set rowlsFult to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: if the row is full, clear the row and shift rows down
      if (rowIsFull) {
        // step 5: move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          // copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);

          // step 6: set top row to empty
          gameBoard[0] = List.generate(row, (index) => null);
        }
        // step 7: Increase the score
        currentScore++;
        playSound('clear');
      }
    }
  }
  bool isGameOver() {
    // Check if all columns in the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true; // If any block is empty, game is not over
      }
    }
    return false; // All blocks in the top row are filled
  }
  void createNewPiece() {
    Random rand = Random();
    TetrisShapes randomType =
    TetrisShapes.values[rand.nextInt(TetrisShapes.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();
    if (isGameOver()) {
      gameOver = true;
    }
  }
  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }
  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Game Over!'),
        content: Text('You Scored: $currentScore'),
        actions: [
          TextButton(
              onPressed: () {
                // reset the game
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again',style: TextStyle(color: Colors.blue),))
        ],
      ),
    );
  }
  void resetGame() {
    gameBoard =
        List.generate(colLength, (i) => List.generate(rowLength, (j) => null));
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TETRIS'),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: pauseGame,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score Display
          Text(
            'Score: $currentScore ',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          Divider(),

          // Game Board
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(right: 12,left: 12),
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowLength,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ rowLength;
                int col = index % rowLength;

                Color pixelColor = Colors.black;

                // Ensure the index is within valid bounds before accessing gameBoard and currentPiece.position
                if (currentPiece.position.contains(index)) {
                  pixelColor = currentPiece.color;
                } else if (row >= 0 && row < gameBoard.length && col >= 0 && col < gameBoard[row].length) {
                  if (gameBoard[row][col] != null) {
                    pixelColor = TetrisShapesColors[gameBoard[row][col]]!;
                  }
                }

                return Pixel(color: pixelColor);
              },

            ),
          ),
          Divider(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ControlButton(icon: Icons.arrow_left, onPressed: moveLeft),
              ControlButton(icon: Icons.rotate_right, onPressed: rotatePiece),
              ControlButton(icon: Icons.arrow_right, onPressed: moveRight),
            ],
          ),
        ],
      )

    );
  }


  void pauseGame() {
    if (gameTimer != null && gameTimer!.isActive) {
      gameTimer!.cancel(); // Stop the timer
    }
    setState(() {
      isPaused = true;
    });
    showPauseDialog();
  }


  void resumeGame() {
    setState(() {
      isPaused = false;
    });
    // Restart the game loop with the same speed
    Duration getGameSpeed(int score) {
      return Duration(milliseconds: (score > 5) ? 300 : 500);
    }

// Call the game loop with the dynamic duration
    gameLoop(getGameSpeed(currentScore));
  }

  void showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Paused'),
        actions: [
          TextButton(
            onPressed: () {
              resumeGame();
              Navigator.pop(context);
            },
            child: const Text('Resume',style: TextStyle(color: Colors.blueAccent),),
          ),
        ],
      ),
    );
  }

  /*void moveDown() {
    setState(() {
      currentPiece.movePiece(Direction.down);
    });
  }*/
}
class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 46),
      onPressed: onPressed,
    );
  }
}