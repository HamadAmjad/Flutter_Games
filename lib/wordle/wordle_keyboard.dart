import 'package:flutter/material.dart';

class CustomWordleKeyboard extends StatelessWidget {
  final void Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onEnter;
  const CustomWordleKeyboard({
    Key? key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onEnter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> keyboardRows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM'
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keyboardRows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.split('').map((letter) {
            return _buildKey(letter, context);
          }).toList(),
        );
      }).toList()
        ..add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey('ENTER', onEnter, Colors.green), // Green for Enter
            _buildSpecialKey('DEL', onDelete, Colors.red),    // Red for Delete
          ],
        )),
    );
  }

  Widget _buildKey(String letter, BuildContext context) {
    double keyWidth = MediaQuery.of(context).size.width * 0.074; // Responsive width
    double keyHeight = MediaQuery.of(context).size.height * 0.06; // Responsive height

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () => onKeyPressed(letter),
        child: Container(
          width: keyWidth,
          height: keyHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onPressed, Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 90, // Fixed size for special buttons
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color, // Use the color parameter
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

}
