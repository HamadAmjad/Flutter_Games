import 'dart:ui';
import 'dart:math';

enum TetrisShapes { L, J, I, O, S, Z, T, Dot }

enum Direction { left, right, down }

// Grid dimension
int rowLength = 10, colLength = 15;

// Function to get a random color
Color getRandomColor() {
  List<Color> colors = [
    const Color(0xFFFFA500), // Orange
    const Color.fromARGB(255, 0, 102, 255), // Blue
    const Color.fromARGB(255, 242, 0, 255), // Pink
    const Color(0xFFFFFF00), // Yellow
    const Color(0xFF008000), // Green
    const Color(0xFFFF0000), // Red
    const Color.fromARGB(255, 144, 0, 255), // Purple
    const Color(0xFF808080), // Grey
  ];
  return colors[Random().nextInt(colors.length)];
}

// Map that assigns a random color each time it's accessed
Map<TetrisShapes, Color> TetrisShapesColors = {
  for (var shape in TetrisShapes.values) shape: getRandomColor(),
};
