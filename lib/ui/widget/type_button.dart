import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color themeColor;

  const TypeButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
