import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/api_service.dart';

class UserLoansScreen extends StatefulWidget {
  const UserLoansScreen({super.key});

  @override
  State<UserLoansScreen> createState() => _UserLoansScreenState();
}

class _UserLoansScreenState extends State<UserLoansScreen> {
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
      final data = await _apiService.getMyLoans();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issued Books'),
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
                          child: Icon(Icons.menu_book, color: Colors.white),
                        ),
                        title: Text('Book ID: ${loan.bookId}'),
                        subtitle: Text(
                          'Due: ${loan.dueDate.toLocal().toString().split(' ').first} - Fine: ${loan.fineAmount}',
                        ),
                        trailing: loan.status == 'issued'
                            ? IconButton(
                                icon: const Icon(Icons.assignment_return),
                                onPressed: () => _returnLoan(loan),
                              )
                            : const Text('Returned'),
                      ),
                    );
                  },
                ),
    );
  }
}
