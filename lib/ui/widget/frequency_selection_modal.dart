import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/localization.dart';

class FrequencySelectionModal extends StatelessWidget {
  final String currentFrequency;
  final ValueChanged<String> onFrequencySelected;
  final Color themeColor;

  const FrequencySelectionModal({
    super.key,
    required this.currentFrequency,
    required this.onFrequencySelected,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frequencies = {
      'daily': {'label': l10n.daily, 'icon': Icons.today},
      'weekly': {'label': l10n.weekly, 'icon': Icons.view_week},
      'monthly': {'label': l10n.monthly, 'icon': Icons.calendar_month},
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Text(
            l10n.chooseFrequency,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          SizedBox(height: 20.h),
          ...frequencies.entries.map((entry) {
            final key = entry.key;
            final label = entry.value['label'] as String;
            final icon = entry.value['icon'] as IconData;
            final isSelected = currentFrequency == key;

            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeColor.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? themeColor : Colors.grey[600],
                  size: 20.sp,
                ),
              ),
              title: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? themeColor : const Color(0xFF2D3142),
                  fontSize: 14.sp,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: themeColor,
                      size: 20.sp,
                    )
                  : null,
              onTap: () {
                onFrequencySelected(key);
                Navigator.pop(context);
              },
            );
          }).toList(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

Future<void> showFrequencySelectionModal(
    {required BuildContext context,
    required String currentFrequency,
    required ValueChanged<String> onFrequencySelected,
    required Color themeColor}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => FrequencySelectionModal(
      currentFrequency: currentFrequency,
      onFrequencySelected: onFrequencySelected,
      themeColor: themeColor,
    ),
  );
}
