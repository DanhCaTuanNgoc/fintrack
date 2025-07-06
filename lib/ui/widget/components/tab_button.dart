import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(25.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 4.w),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        themeColor,
                        themeColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: isSelected
                    ? themeColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 2.w,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.15),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                        spreadRadius: 2.r,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 1.r,
                        offset: Offset(0, -1.h),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: themeColor.withOpacity(0.2),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        color: isSelected ? themeColor : Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  if (icon != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 8.w : 6.w,
                      child: const SizedBox(),
                    ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? themeColor : Colors.white,
                      fontSize: isSelected ? 13.sp : 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
