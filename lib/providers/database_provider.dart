import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
