import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/repositories/book_repository.dart';
import './database_provider.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BookRepository(dbHelper);
});

final booksProvider =
    StateNotifierProvider<BooksNotifier, AsyncValue<List<Book>>>((ref) {
  return BooksNotifier(ref);
});

class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  BooksNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadBooks();
  }

  final Ref ref;

  Future<void> loadBooks() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      final books = await repository.getBooks();
      state = AsyncValue.data(books);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createBook(String name) async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      // Lấy danh sách book hiện tại để kiểm tra trùng tên
      final books = await repository.getBooks();
      final book = Book(name: name, balance: 0.0, userId: 1);
      await repository.createBook(book);
      await loadBooks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAllBooks() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      await repository.deleteAllBooks();
      await loadBooks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final currentBookProvider =
    StateNotifierProvider<CurrentBookNotifier, AsyncValue<Book?>>((ref) {
  return CurrentBookNotifier(ref);
});

class CurrentBookNotifier extends StateNotifier<AsyncValue<Book?>> {
  CurrentBookNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCurrentBook();
  }

  final Ref ref;

  Future<void> loadCurrentBook() async {
    try {
      final booksState = ref.read(booksProvider);
      booksState.whenData((books) {
        state = AsyncValue.data(books.isNotEmpty ? books.first : null);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void setCurrentBook(Book book) {
    state = AsyncValue.data(book);
  }
}
