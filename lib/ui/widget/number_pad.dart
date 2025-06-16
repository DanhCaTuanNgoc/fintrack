import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onNumberTap;
  final Function() onBackspaceTap;
  final Color? primaryColor;
  final Color? backgroundColor;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    required this.onBackspaceTap,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.primaryColor;
    final background = backgroundColor ?? theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicator bar

          // Number pad rows
          _buildNumberRow(['7', '8', '9'], primary),
          const SizedBox(height: 16),
          _buildNumberRow(['4', '5', '6'], primary),
          const SizedBox(height: 16),
          _buildNumberRow(['1', '2', '3'], primary),
          const SizedBox(height: 16),

          // Bottom row with special buttons
          Row(
            children: [
              Expanded(
                child: _buildNumberButton('0', () => onNumberTap('0'), primary,
                    isWide: true),
              ),
              const SizedBox(width: 16),
              _buildNumberButton('000', () => onNumberTap('000'), primary),
              const SizedBox(width: 16),
              _buildBackspaceButton(onBackspaceTap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers, Color primaryColor) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildNumberButton(
                number, () => onNumberTap(number), primaryColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String text, VoidCallback onTap, Color primaryColor,
      {bool isWide = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: text == '000' ? 20 : 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D29),
                letterSpacing: text == '000' ? 1 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.1),
        highlightColor: Colors.red.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red[50]!,
                Colors.red[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
              color: Color(0xFFD32F2F),
            ),
          ),
        ),
      ),
    );
  }
}
