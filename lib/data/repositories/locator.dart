import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import 'user_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Database
  locator.registerLazySingleton(() => DatabaseHelper.instance);

  // Repositories
  locator.registerLazySingleton(() => UserRepository(locator()));
  // locator.registerLazySingleton(() => BookRepository(locator()));
  // locator.registerLazySingleton(() => CategoryRepository(locator()));
  // locator.registerLazySingleton(() => TransactionRepository(locator()));
}