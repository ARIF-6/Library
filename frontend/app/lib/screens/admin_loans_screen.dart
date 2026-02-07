import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/api_service.dart';

class AdminLoansScreen extends StatefulWidget {
  const AdminLoansScreen({super.key});

  @override
  State<AdminLoansScreen> createState() => _AdminLoansScreenState();
}

class _AdminLoansScreenState extends State<AdminLoansScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Loan> _loans = [];

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getAllLoans();
      setState(() => _loans = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load loans: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _returnLoan(Loan loan) async {
    try {
      await _apiService.returnLoan(loan.id);
      _loadLoans();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to return: $e')),
        );
      }
    }
  }

  Future<void> _updateDueDate(Loan loan) async {
    final controller = TextEditingController(
      text: loan.dueDate.toLocal().toString().split(' ').first,
    );
    final newDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Due Date'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'YYYY-MM-DD'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = DateTime.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (newDate == null) return;
    try {
      await _apiService.updateDueDate(loan.id, newDate);
      _loadLoans();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _deleteLoan(Loan loan) async {
    try {
      await _apiService.deleteLoan(loan.id);
      _loadLoans();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue/Return Management'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? const Center(child: Text('No issued books'))
              : ListView.builder(
                  itemCount: _loans.length,
                  itemBuilder: (context, index) {
                    final loan = _loans[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0F4C81),
                          child: Icon(Icons.assignment, color: Colors.white),
                        ),
                        title: Text('Book ID: ${loan.bookId}'),
                        subtitle: Text(
                          'User ID: ${loan.userId} - Due: ${loan.dueDate.toLocal().toString().split(' ').first}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (loan.status == 'issued')
                              IconButton(
                                icon: const Icon(Icons.assignment_return),
                                onPressed: () => _returnLoan(loan),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () => _updateDueDate(loan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteLoan(loan),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showIssueDialog,
        icon: const Icon(Icons.add),
        label: const Text('Issue Book'),
      ),
    );
  }

  Future<void> _showIssueDialog() async {
    final bookIdController = TextEditingController();
    final userIdController = TextEditingController();
    final daysController = TextEditingController(text: '14');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bookIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Book ID'),
            ),
            TextField(
              controller: userIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Due in days'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Issue'),
          ),
        ],
      ),
    );

    if (result != true) return;
    final bookId = int.tryParse(bookIdController.text);
    final userId = int.tryParse(userIdController.text);
    final days = int.tryParse(daysController.text) ?? 14;
    if (bookId == null || userId == null) return;

    try {
      final dueDate = DateTime.now().add(Duration(days: days));
      await _apiService.issueLoan(bookId, userId, dueDate);
      _loadLoans();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to issue: $e')),
        );
      }
    }
  }
}
