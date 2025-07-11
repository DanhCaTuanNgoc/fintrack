import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/repositories/book_repository.dart';
import './database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

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
      final book = Book(name: name, balance: 0.0, userId: 1);
      await repository.createBook(book);
      await loadBooks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateBook(Book book, String newName) async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      await repository.updateBook(book, newName);
      await loadBooks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteBook(Book book) async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      await repository.deleteBook(book);
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
    _initialize();
  }

  final Ref ref;
  static const String _currentBookIdKey = 'current_book_id';

  Future<void> _initialize() async {
    // Wait for books to be loaded
    final booksState = ref.read(booksProvider);
    if (booksState is AsyncData) {
      await loadCurrentBook();
    } else {
      // Listen for books to be loaded
      ref.listen(booksProvider, (previous, next) {
        if (next is AsyncData) {
          loadCurrentBook();
        }
      });
    }
  }

  Future<void> loadCurrentBook() async {
    try {
      final booksState = ref.read(booksProvider);
      if (booksState is! AsyncData) {
        state = const AsyncValue.loading();
        return;
      }

      final books = booksState.value;
      if (books == null || books.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final int? savedBookId = prefs.getInt(_currentBookIdKey);
      print("Saved Book : $savedBookId");

      Book? currentBook;
      if (savedBookId != null && books.isNotEmpty) {
        currentBook = books.firstWhereOrNull(
          (book) => book.id == savedBookId,
        );
      }

      // If no book found with saved ID or no saved ID, use first book
      if (currentBook == null && books.isNotEmpty) {
        currentBook = books.first;
      }

      state = AsyncValue.data(currentBook);
      print("CurrentBook :$currentBook");
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setCurrentBook(Book? book) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (book == null) {
        // Remove saved book ID from preferences
        await prefs.remove(_currentBookIdKey);
        print("Removed current book from local storage");
        // Update state to null
        state = const AsyncValue.data(null);
      } else {
        // Save to preferences first
        await prefs.setInt(_currentBookIdKey, book.id!);
        print("Saved current book into local variable !");
        // Then update state
        state = AsyncValue.data(book);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
