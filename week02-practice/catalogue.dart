import 'models.dart';

class Library {
  final List<LibraryItem> items = [];
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) => items.add(item);

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) => items.whereType<Book>().where(
        (book) => book.title.toLowerCase() == title.toLowerCase(),
      ).firstOrNull;

  String countryOf(String title) => findByTitle(title)?.author.country ?? 'unknown';

  String report() => _cachedReport ??= displayLines.join('\n');

  List<Book> get books => items.whereType<Book>().toList();

  List<String> get allBookTitles => books.map((book) => book.title).toList();

  List<Book> get booksAfter2010 => books.where((book) => book.year > 2010).toList();

  double get averagePages => books.isEmpty
      ? 0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length;
  // fold works with an empty list; reduce would throw when there are no books.

  Map<String, int> get bookCountByAuthor => books.fold(<String, int>{}, (
        counts,
        book,
      ) {
        counts[book.author.name] = (counts[book.author.name] ?? 0) + 1;
        return counts;
      });

  Set<String> get authorNames => {...books.map((book) => book.author.name)};

  Set<Genre> get genres => {...books.map((book) => book.genre)};

  List<String> get displayLines => [
        'CATALOGUE',
        for (final book in books) '${book.title} (${book.year})',
        ...authorNames,
        if (books.any((book) => book.pages == 0)) '(incomplete data)',
      ];
}

