import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  final Color primaryColor = Colors.teal;
  final Color secondaryColor = Colors.orange;
  final Color accentColor = Colors.yellowAccent;
  final Color highlightColor = Colors.redAccent;
  final Color backgroundColor = Colors.black87;
  final Color keyColor = Colors.grey.shade900;

  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _winner = '';
  List<int> _winningCells = [];

  void _makeMove(int index) {
    if (_board[index] == '' && _winner == '') {
      setState(() {
        _board[index] = _currentPlayer;
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        _checkWinner();
      });
      HapticFeedback.mediumImpact(); // Vibration feedback
    }
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6] // Diagonals
    ];

    for (var combination in winningCombinations) {
      if (_board[combination[0]] != '' &&
          _board[combination[0]] == _board[combination[1]] &&
          _board[combination[1]] == _board[combination[2]]) {
        setState(() {
          _winner = _board[combination[0]];
          _winningCells = combination;
        });
        _showWinnerDialog(_winner);
        return;
      }
    }

    if (!_board.contains('')) {
      setState(() {
        _winner = 'Draw';
      });
      _showWinnerDialog('Draw');
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = '';
      _winningCells = [];
    });
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          winner == 'Draw' ? 'Game Over' : 'Congratulations!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        content: Text(
          winner == 'Draw' ? 'It\'s a tie!' : '$winner Wins!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('Play Again', style: TextStyle(color: highlightColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: keyColor,
      appBar: AppBar(
        title: Text('Tic Tac Toe', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            _winner == '' ? 'Turn: $_currentPlayer' : 'Winner: $_winner',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: accentColor),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                bool isWinningCell = _winningCells.contains(index);
                return GestureDetector(
                  onTap: () => _makeMove(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _board[index] == ''
                          ? backgroundColor
                          : _board[index] == 'X'
                          ? primaryColor
                          : secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isWinningCell ? highlightColor : Colors.black45,
                          blurRadius: isWinningCell ? 8 : 4,
                          spreadRadius: isWinningCell ? 2 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          _board[index],
                          key: ValueKey(_board[index]),
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: highlightColor,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Restart Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
