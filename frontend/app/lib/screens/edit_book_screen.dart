import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishedYearController = TextEditingController();
  final _genreController = TextEditingController();
  bool _available = true;
  final _apiService = ApiService();
  bool _isLoading = false;
  late Book _book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) return;
    _book = arguments as Book;
    _titleController.text = _book.title;
    _authorController.text = _book.author;
    _isbnController.text = _book.isbn;
    _publishedYearController.text = _book.publishedYear?.toString() ?? '';
    _genreController.text = _book.genre ?? '';
    _available = _book.available;
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      final updatedBook = Book(
        id: _book.id,
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text,
        publishedYear: int.tryParse(_publishedYearController.text),
        genre: _genreController.text.isEmpty ? null : _genreController.text,
        available: _available,
      );
      await _apiService.updateBook(updatedBook);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update book: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Update Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the author';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _isbnController,
                    decoration: const InputDecoration(labelText: 'ISBN'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the ISBN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _publishedYearController,
                    decoration:
                        const InputDecoration(labelText: 'Published Year'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(labelText: 'Genre'),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    title: const Text('Available'),
                    value: _available,
                    onChanged: (value) {
                      setState(() => _available = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateBook,
                            child: const Text('Update Book'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
