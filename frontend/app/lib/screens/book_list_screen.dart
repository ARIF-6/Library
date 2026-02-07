import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _apiService = ApiService();
  List<Book> _books = [];
  bool _isLoading = true;
  String? _role;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchBooks();
  }

  Future<void> _loadRole() async {
    final role = await _apiService.getUserRole();
    if (mounted) {
      setState(() => _role = role);
    }
  }

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _apiService.getBooks(search: _search);
      setState(() => _books = books);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load books: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBook(Book book) async {
    try {
      await _apiService.deleteBook(book.id);
      _fetchBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete book: $e')),
        );
      }
    }
  }

  Future<void> _reserveBook(Book book) async {
    try {
      await _apiService.reserveBook(book.id);
      _fetchBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reserve: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        automaticallyImplyLeading: false,
        actions: [
          if (_role == 'admin')
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.pushNamed(context, '/add_book')
                    .then((_) => _fetchBooks());
              },
              tooltip: 'Add Book',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title, author, ISBN, genre',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _search = value);
                _fetchBooks();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? const Center(child: Text('No books available'))
                    : ListView.builder(
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF0F4C81),
                                child: Text(
                                  book.title.isNotEmpty
                                      ? book.title[0].toUpperCase()
                                      : 'B',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/book_details',
                                  arguments: book,
                                );
                              },
                              title: Text(
                                book.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${book.author} - ${book.isbn} - ${book.status}',
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_role == 'admin') ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/edit_book',
                                          arguments: book,
                                        ).then((_) => _fetchBooks());
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteBook(book),
                                    ),
                                  ],
                                  if (_role == 'user' &&
                                      book.status == 'available')
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_add),
                                      onPressed: () => _reserveBook(book),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add_book')
                    .then((_) => _fetchBooks());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Book'),
            )
          : null,
    );
  }
}
