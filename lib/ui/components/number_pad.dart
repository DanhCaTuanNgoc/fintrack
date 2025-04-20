import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onNumberTap;
  final Function() onBackspaceTap;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    required this.onBackspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7', () => onNumberTap('7')),
            _buildNumberButton('8', () => onNumberTap('8')),
            _buildNumberButton('9', () => onNumberTap('9')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4', () => onNumberTap('4')),
            _buildNumberButton('5', () => onNumberTap('5')),
            _buildNumberButton('6', () => onNumberTap('6')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1', () => onNumberTap('1')),
            _buildNumberButton('2', () => onNumberTap('2')),
            _buildNumberButton('3', () => onNumberTap('3')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('0', () => onNumberTap('0')),
            _buildNumberButton('000', () => onNumberTap('000')),
            _buildBackspaceButton(onBackspaceTap),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '⌫',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
