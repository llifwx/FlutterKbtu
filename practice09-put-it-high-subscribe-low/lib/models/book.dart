class Book {
  const Book({required this.title, required this.author, required this.price});

  final String title;
  final String author;
  final int price; // tenge
}

const books = [
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    price: 4200,
  ),
  Book(title: 'Null Safety for Humans', author: 'B. Seitkali', price: 3100),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    price: 5600,
  ),
  Book(title: 'The Navigator Is a Stack', author: 'D. Alibekov', price: 2900),
  Book(
    title: 'Forms That Validate Themselves',
    author: 'E. Omarova',
    price: 3800,
  ),
  Book(
    title: 'Put It High, Subscribe Low',
    author: 'F. Kairatuly',
    price: 4700,
  ),
];
