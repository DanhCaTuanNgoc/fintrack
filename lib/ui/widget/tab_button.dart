import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final Color themeColor;
  final IconData? icon;
  final void Function(int) onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.themeColor,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : themeColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.grey.shade300 : themeColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: isSelected ? const Color(0xFF2D3142) : Colors.white,
                    size: 16,
                  ),
                if (icon != null) const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF2D3142) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
