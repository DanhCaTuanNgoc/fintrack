import 'package:flutter/material.dart';

final Map<String, IconData> _iconMapping = {
  '🍔': Icons.restaurant,
  '🚗': Icons.directions_car,
  '🛍': Icons.shopping_bag,
  '🎮': Icons.sports_esports,
  '📚': Icons.book,
  '💅': Icons.face,
  '💰': Icons.attach_money,
  '🎁': Icons.card_giftcard,
  '📈': Icons.trending_up,
  '🏠': Icons.home,
};

IconData getIconFromEmoji(String emoji) {
  return _iconMapping[emoji] ?? Icons.category;
}
