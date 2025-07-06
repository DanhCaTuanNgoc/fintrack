import 'package:flutter/material.dart';

class DevelopmentNotice extends StatelessWidget {
  const DevelopmentNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Các tính năng này đang được phát triển và sẽ sớm có mặt trong phiên bản tiếp theo.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
