import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final _apiService = ApiService();
  String? _role;
  Book? _book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Book) {
      _book = args;
    }
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _apiService.getUserRole();
    if (mounted) setState(() => _role = role);
  }

  Future<void> _reserve() async {
    try {
      if (_book == null) return;
      await _apiService.reserveBook(_book!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation created')),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Book Details')),
      body: _book == null
          ? const Center(child: Text('Book not found'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _book!.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Author: ${_book!.author}'),
                      Text('ISBN: ${_book!.isbn}'),
                      Text('Genre: ${_book!.genre ?? '-'}'),
                      Text('Published: ${_book!.publishedYear ?? '-'}'),
                      Text('Status: ${_book!.status}'),
                      const SizedBox(height: 16),
                      if (_role == 'user' && _book!.status == 'available')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _reserve,
                            child: const Text('Reserve Book'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
