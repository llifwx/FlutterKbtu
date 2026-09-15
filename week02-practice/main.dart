import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();
  final library = Library()..open();

  books.forEach(library.add);
  library.add(const Magazine(title: 'Dart Monthly', year: 2024, issue: 2));
  library.add(const Ghost(title: 'Invisible Manual', year: 1980));

  print(library.report());
  print('');
  print('Opened at: ${library.openedAt}');
  print('All titles: ${library.allBookTitles}');
  print('Books after 2010: ${library.booksAfter2010}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Book count by author: ${library.bookCountByAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((genre) => genre.label).toSet()}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Find missing title: ${library.findByTitle('Missing Title')}');
  print('');

  final stats = statsOf(books);
  print('Stats: count=${stats.count}, avgPages=${stats.avgPages.toStringAsFixed(1)}');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Shelf support is cracked')));
}
