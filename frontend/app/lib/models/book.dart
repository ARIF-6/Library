class Book {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final int? publishedYear;
  final String? genre;
  final bool available;
  final String status;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.publishedYear,
    this.genre,
    required this.available,
    this.status = 'available',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final dynamic publishedYearValue = json['publishedYear'];
    int? parsedPublishedYear;
    if (publishedYearValue is int) {
      parsedPublishedYear = publishedYearValue;
    } else if (publishedYearValue is String) {
      parsedPublishedYear = int.tryParse(publishedYearValue);
    }

    final dynamic availableValue = json['available'];
    final bool parsedAvailable =
        availableValue is bool ? availableValue : true;

    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      publishedYear: parsedPublishedYear,
      genre: json['genre'],
      available: parsedAvailable,
      status: (json['status'] as String?) ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publishedYear': publishedYear,
      'genre': genre,
      'available': available,
      'status': status,
    };
  }
}
