class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    this.year,
    this.read = false,
  });

  Book.fromMap(Map<String, dynamic> m)
    : title = m['title'] as String,
      author = m['author'] as String,
      pages = m['pages'] as int,
      year = m['year'] as int?,
      read = m['read'] as bool? ?? false;

  final String title;
  final String author;
  final int pages;
  final int? year;
  bool read;

  @override
  String toString() =>
      '$title — $author, $pages pp.${year == null ? '' : ' ($year)'}';
}

int totalPages(List<Book> books) =>
    books.fold(0, (total, book) => total + book.pages);
List<Book> unread(List<Book> books) =>
    books.where((book) => book.read == false).toList();
List<String> authors(List<Book> books) =>
    books.map((book) => book.author).toSet().toList();

final seed = <Book>[
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    pages: 288,
    year: 2021,
    read: true,
  ),
  Book(
    title: 'Null Safety for Humans',
    author: 'B. Seitkali',
    pages: 196,
    year: 2022,
  ),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    pages: 320,
  ),
  Book(
    title: 'The Navigator Is a Stack',
    author: 'D. Alibekov',
    pages: 240,
    year: 2020,
  ),
  Book(
    title:
        'A Very Long Title About Forms, Focus, the Keyboard '
        'and Everything That Overflows',
    author: 'E. Omarova',
    pages: 176,
    year: 2023,
  ),
];
