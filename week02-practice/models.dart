class Author {
  final String name;
  final String? country;

  const Author({
    required this.name,
    this.country,
  });

  @override
  String toString() => country == null ? name : '$name ($country)';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;

  const Genre(this.label);

  factory Genre.fromString(String? raw) => switch (raw) {
        'craft' => Genre.craft,
        'theory' => Genre.theory,
        _ => Genre.unknown,
      };
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({
    required this.title,
    required this.year,
  });

  bool get isOld => year < 2000;

  String describe();
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  const Book.missing()
      : pages = 0,
        author = const Author(name: 'Unknown'),
        genre = Genre.unknown,
        description = null,
        super(title: 'Untitled', year: 0);

  factory Book.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final year = json['year'];
    final pages = json['pages'];
    final author = json['author'];
    final country = json['country'];
    final genre = json['genre'];
    final description = json['description'];

    return Book(
      title: title is String ? title : 'Untitled',
      year: year is int ? year : 0,
      pages: pages is int ? pages : 0,
      author: Author(
        name: author is String ? author : 'Unknown',
        country: country is String ? country : null,
      ),
      genre: Genre.fromString(genre is String ? genre : null),
      description: description is String ? description : null,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) =>
      Book(
        title: title ?? this.title,
        year: year ?? this.year,
        pages: pages ?? this.pages,
        author: author ?? this.author,
        genre: genre ?? this.genre,
        description: description ?? this.description,
      );

  @override
  String describe() => '$title by ${author.name}, ${genre.label}, $pages pages';

  @override
  String toString() => '$title ($year), ${author.name}, ${genre.label}';
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => '$title, issue $issue, $year';
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({
    required this.title,
    required this.year,
  });

  @override
  bool get isOld => year < 2000;

  @override
  String describe() => 'Ghost item: $title';
}

